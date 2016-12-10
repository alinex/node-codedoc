# Renderer
# ================================================
# Collection of methods used to generate the HTML files out of the reports and
# structures from parsing. It will create the results on disk.


# Node Modules
# -------------------------------------------------
debug = require('debug') 'codedoc:render'
path = require 'path'
chalk = require 'chalk'
asyncReplace = require 'async-replace'
memoize = require 'memoizee'
async = require 'async'
coffee = null # load on demand
# make caching method
request = memoize require('request'), {maxAge: 3600000}
# include alinex modules
fs = require 'alinex-fs'
util = require 'alinex-util'
validator = require 'alinex-validator'


# Setup
# -------------------------------------------------
STATIC_FILES = /\.(html|gif|png|jpg|js|css)$/i # won't get .html extension
PAGE_SEARCH = # define the possible settings and methods to use
  nodejs: ['nodejs', 'npm', 'mdn']
  javascript: ['mdn']


# Exported Methods
# --------------------------------------------------------

# If not existing create an `index.html` file which forwards to the first page
# immediately.
#
# @param {String} dir base path of index file
# @param {String} link destination for the link to the first page
# @param {function(<Error>)} cb callback method after done
exports.createIndex = (dir, link, cb) ->
  file = path.join dir, 'index.html'
  dest = path.relative dir, link
  fs.exists file, (exists) ->
    return cb() if exists
    debug "create index page"
    fs.writeFile file, """
      <html>
      <head>
        <meta http-equiv="refresh" content="0; url=#{dest}" />
        <script type="text/javascript">
            window.location.href = "#{dest}"
        </script>
        <title>Page Redirection</title>
      </head>
      <body>
        If you are not redirected automatically, follow the link to the
        <a href='#{dest}'>README</a>.
      </body>
      </html>
      """, cb

# Optimize markdown of report before converting it further.
#
# @param {String} report markdown text to replace inline tags within
# @param {String} file file name used for relative link creation
# @param {Object<Array>} symbols map as `[file, anchor]` to resolve links
# @param {Array<Object>} pages list of pages from table of contents used attributes:
# - `path` - `String` file path
# - `title` - `String` title of the document
# - `url` - `String` generated file
# @param {String} search additional search words for link resolve
# @param {function(<Error>, <String>)} cb callback which will get the new markdown
exports.optimize = (report, file, symbols, pages, search, cb) ->
  # find inline tags
  debug "#{file}: optimize for html conversion" if debug.enabled
  report = report.replace /(\n\s*)#([1-6])(\s+)/g, (_, pre, num, post) ->
    "#{pre}#{util.string.repeat '#', num}#{post}"
  asyncReplace report, /([ \t]*)\{@(\w+) ([^ \t}]*)\s?([^}]*)?\}/g
  , (source, indent, tag, uri, text, offset, all, cb) ->
    switch tag
      when 'link'
        # check for symbol
        if symbol = symbols[uri] ? symbols["#{uri}()"]
          url = path.relative path.dirname(file), "#{symbol[0]}.html"
          url += "##{symbol[1]}"
          title = " \"File: #{symbol[0]} Element: #{symbol[2]}\""
          return cb null, "#{indent}[`#{text ? symbol[2]}`](#{url + title})"
        # check for file
        [filepath, anchor] = uri.split /#/
        found = pages.filter (e) -> ~e.path.indexOf filepath
        if found.length
          text ?= found[0].title ? filepath
          url = found[0].url ? filepath
          title = " \"File: #{filepath}\""
          return cb null, "#{indent}[#{text}](#{url}#{if anchor then '#' + anchor else ''}#{title})"
        # alinex link
        if m = uri.match /^alinex-(.*)/
          m[1] += '.html' if m[1].match /\/./ and not m[1].match /\.(gif|html|png|jpg)$/
          return cb null, "#{indent}[#{text ? uri}](https://alinex.github.io/node-#{m[1]})"
        # urls
        if uri.match /^(https?):\/\//
          return cb null, "[#{text ? uri}](#{uri})"
        # search
        if search
          return searchLink uri, search, (err, res) ->
            if err or not res?.url
              console.error chalk.magenta "Could not resolve link to #{uri} in #{file}"
              return cb null, text ? uri
            cb null, "[#{text ? res.title ? uri}](#{res.url})"
        # default
        console.error chalk.magenta "Could not resolve link to #{uri} in #{file}"
        cb null, text ? uri
      when 'include'
        # include file
        [uri, anchor] = uri.split /#/
        debug "include #{uri}"
        inc = path.resolve path.dirname(file), uri
        fs.readFile inc, 'UTF8', (err, content) ->
          if err
            console.error chalk.magenta "Could not include in #{file}: #{err.message}"
            return cb null, "@include #{uri}"
          if anchor
            [from, to] = anchor.split /\s*-\s*/
            content = content.split(/\n/)[from-1..to-1].join '\n'
          # run inlineTags over this, too
          exports.optimize content, file, symbols, pages, search, cb
      when 'schema'
        # get schema description
        [uri, anchor] = uri.split /#/
        uri = if uri then path.resolve path.dirname(file), uri else file
        debug "analyze schema at #{uri}##{anchor}" if debug.enabled
        unless coffee
          coffee = require 'coffee-script'
          coffee.register()
        try
          schema = require uri
        catch error
          console.error chalk.magenta "Could not parse #{uri} to get schema specification"
          if debug.enabled
            debug chalk.magenta "#{error.message}\n#{error.stack.split(/\n/)[1..5].join '\n'}"
        schema = util.object.path schema, anchor if schema and anchor
        debug chalk.magenta "Could not find anchor #{uri}##{anchor}" unless schema
        return cb null, source unless schema # broken if not parseable or not found
        validator.describe
          name: "#{path.basename uri}.#{anchor}"
          schema: schema
        , (err, md) ->
          if err
            md = """
            :::alert Invalid Schema
            The Schema could not be evaluated into a description:

            __#{err.message}__
            :::
            """
          cb null, indent + md.replace /\n/g, "\n#{indent}"
      else
        console.error chalk.magenta "Unknwn tag for transform in #{file}: #{source}"
        cb null, source
  , (err, report) ->
    return cb err if err
    # fill empty transform code from previous
    report = report.replace ///
      \n(\ *`{3,})\ *       # start1
      (\w+)                 # lang1
      ([^\n]*\n)            # addon1
      ([\s\S]*?\n)          # code1
      \1\ *\n               # end
      ([\s\S]*?\n)          # other
      (\ *`{3,})\ *       # start2
      \2[2](\w+)            # lang2
      ([^\n]*\n)            # addon2
      \6\ *\n               # end
    ///g, (_, start1, lang1, addon1, code1, other, start2, lang2, addon2) ->
      "\n#{start1} #{lang1}#{addon1}#{code1}#{start1}\n#{other}\
      #{start2} #{lang1}2#{lang2}#{addon2}#{code1}#{start2}\n"
    # transform code
    .replace ///
      \n(\ *`{3,})\ *       # start
      (\w+)2                # lang1
      (\w+)                 # lang2
      ([^\n]*\n)            # addon
      ([\s\S]*?\n?)         # code
      \1\ *\n               # end
    ///g, (_, start, lang1, lang2, addon, code) ->
      return '\nNo code given!\n' unless code.trim().length
      unless transform["#{lang1}2#{lang2}"]
        return cb new Error "No transformer for #{lang1}2#{lang2} found at #{file}"
      transform["#{lang1}2#{lang2}"] start, addon, code
    cb null, report

# Transform code entries before interpreting.
#
# @type {Object<Function>} collection of transformer functions defined under
# `<source-language>2<dest-language>` with the following parameters:
# - `String` - `start` code tag with indention
# - `String` - `addon` additional styles
# - `String` - `code` content of the source code
#
# This will return the resulting markdown with the transformed code.
transform =
  coffee2js: (start, addon, code) ->
    coffee ?= require 'coffee-script'
    compiled = coffee.compile code,
      bare: true
    "\n#{start} js#{addon}#{compiled}#{start}\n"

# Convert report to HTML and write it to disk.
#
# @param {Object} file file information with report
# - `report` - `Report` containing the content for the page
# - `source` - `String` source path from which the report was created
# - `dest` - `String` destination path to which to write the converted HTML
# @param {String} moduleName name of the complete documentation project
# @param {Array<Object>} pages list of pages from table of contents used attributes:
# - `path` - `String` file path
# - `title` - `String` title of the document
# - `url` - `String` generated file
# @param {function(<Error>)} cb callback if done or error occured
exports.writeHtml = (file, moduleName, pages, cb) ->
  debug "#{file.source}: transform to html" if debug.enabled
  file.report.toHtml
    style: 'codedoc'
    context:
      moduleName: moduleName
      pages: pages
  , (err, html) ->
    # optimize further
    html = html
    .replace ///href=\"(?!https?://|/)(.*?)(["#])///gi, (_, link, end) ->
      if link.length is 0 or link.match STATIC_FILES
        "href=\"#{link}#{end}" # keep link
      else
        "href=\"#{link}.html#{end}" # add .html
    debug "#{file.source}: write html to file" if debug.enabled
    fs.mkdirs path.dirname(file.dest), (err) ->
      return cb err if err
      fs.writeFile file.dest, html, 'utf8', cb

# Run internet search to find link destination.
#
# @param {String} link element to link to
# @param {String} search type name to use in search
# @param {function(<Error>, <Object>)} cb callback with `null` or result object with:
# - `title` - `String` page title to use as link text if none given
# - `url` - `String` url for the page
searchLink = (link, search, cb) ->
  return cb() unless PAGE_SEARCH[search]
  # support search type before link target
  if match = link.match /^(\w+):(.*)$/
    search = match[1]
    link = match[2]
  link = encodeURIComponent link
  # do the search
  async.mapSeries PAGE_SEARCH[search], (type, cb) ->
    if type is 'mdn'
      debug "search for link to #{link} in MDN" if debug.enabled
      return requestURL "https://developer.mozilla.org/en/search?q=#{link}", (err, body) ->
        return cb() if err or not body
        matches = body.match /<div class="column-5 result-list-item">([\s\S]+?)<\/div>/g
        return cb() unless matches
        check = link.replace /[.]/, '\\.(?:.*\\.)?'
        .replace /\(\)/, ''
        check = new RegExp "\\b#{check}\\b", 'i'
        for match in matches[0..4] # check only the first 5 entries
          continue unless match = match.match /href="([^"]*)"[^>]*>(.*?)</
          if match[2].match check
            return cb 'DONE',
              title: match[2]
              url: match[1]
        return cb() # nothing found
    if type is 'nodejs'
      debug "search for link to #{link} in NodeJS API" if debug.enabled
      [module, method] = link.split /\./
      page = "https://nodejs.org/dist/latest-v6.x/docs/api/#{module.toLowerCase()}.html"
      return requestURL page, (err, body) ->
        return cb() unless body
        check = method.replace /\(\)/, '\\([^)]+\\)'
        check = new RegExp "<h2>(.*?\\b#{check}.*?)<.*id=\"(.*?)\"", 'i'
        return cb() unless match = body.match check
        cb 'DONE',
          title: match[1].replace /\(.*?\)/, '()'
          url: "#{page}##{match[2]}"
    if type is 'npm' and link.match /^[^()]+$/
      debug "search for link to #{link} in NPM" if debug.enabled
      page = "https://www.npmjs.com/package/#{link}"
      return requestURL page, (err, body) ->
        return cb() unless body
        cb 'DONE',
          title: link
          url: page
    # not possible
    cb()
  , (_, results) ->
    for res in results
      return cb null, res if res
    cb()

# Request a url and check that it was successfully retrieved.
#
# @param {String} url page to grab
# @param {function(<Error>, <String>)} cb callback with body if page could be retrieved successfully
requestURL = (url, cb) ->
  request
    url: url
    headers:
      'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) \
      Chrome/52.0.2743.116 Safari/537.36'
  , (err, res, body) ->
    return cb() if err or res.statusCode isnt 200
    cb null, body.toString()
