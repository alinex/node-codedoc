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
# make caching method
request = memoize require('request'), {maxAge: 3600000}
async = require 'async'
# include alinex modules
fs = require 'alinex-fs'
util = require 'alinex-util'


# Setup
# -------------------------------------------------
STATIC_FILES = /\.(html|gif|png|jpg|js|css)$/i
PAGE_SEARCH =
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

# @param {String} report markdown text to replace inline tags within
# @param {String} file file name used for relative link creation
# @param {Object} symbols map as `[file, anchor]` to resolve links
# @param {Array} pages list of pages from table of contents used attributes:
# - `path` - file path
# - `title` - title of the document
# - `url` - generated file
# @param {String} search additional search words for link resolve
# @param {function(<Error>, <Dtring>)} cb callback which will get the new markdown
exports.optimize = (report, file, symbols, pages, search, cb) ->
  # find inline tags
  report = report.replace /(\n\s*)#([1-6])(\s+)/g, (_, pre, num, post) ->
    "#{pre}#{util.string.repeat '#', num}#{post}"
  asyncReplace report, /\{@(\w+) ([^ \t}]*)\s?([^}]*)?\}/g
  , (source, tag, uri, text, offset, all, cb) ->
    switch tag
      when 'link'
        # check for symbol
        if symbols[uri]
          url = path.relative path.dirname(file), "#{symbols[uri][0]}.html"
          url += "##{symbols[uri][1]}"
          title = " \"File: #{symbols[uri][0]} Element: #{uri}\""
          return cb null, "[`#{text ? uri}`](#{url + title})"
        # check for file
        [filepath, anchor] = uri.split /#/
        found = pages.filter (e) -> ~e.path.indexOf filepath
        if found.length
          text ?= found[0].title ? filepath
          url = found[0].url ? filepath
          title = " \"File: #{filepath}\""
          return cb null, "[#{text}](#{url}#{if anchor then '#' + anchor else ''}#{title})"
        # alinex link
        if m = uri.match /^alinex-(.*)/
          return cb null, "[#{text ? uri}](https://alinex.github.io/node-#{m[1]})"
        # urls
        if uri.match /^(https?):\/\//
          return cb null, "[#{text ? uri}](#{uri})"
        # search
        if search
          return searchLink uri, search, (err, res) ->
            return cb null, text ? uri if err or not res?.url
            cb null, "[#{text ? res.title ? uri}](#{res.url})"
        # default
        console.error "Could not resolve link to #{uri} in #{file}"
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
  , cb

# @param {Object} file file information with report
# @param {String} moduleName name of the complete documentation project
# @param {Array} pages list of pages from table of contents
# @param {function(<Error>)} cb callback if done or error occured
exports.writeHtml = (file, moduleName, pages, cb) ->
  debug "#{file.source}: transform to html"
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
    debug "#{file.source}: write html to file"
    fs.mkdirs path.dirname(file.dest), (err) ->
      return cb err if err
      fs.writeFile file.dest, html, 'utf8', cb

# @param {String} link element to link to
# @param {String} search type name to use in search
# @param {function(<Error>, <Object>)} cb callback with `null` or result with:
# - `title` page title to use as link text if none given
# - `url` url for the page
searchLink = (link, search, cb) ->
  return cb() unless PAGE_SEARCH[search]
  # support search type before link target
  if match = link.match /^(\w+):(.*)$/
    search = match[1]
    link = match[2]
  link = encodeURIComponent link
  # do the search
  async.map PAGE_SEARCH[search], (type, cb) ->
    if type is 'mdn'
      debug "search for link to #{link} in MDN"
      return requestURL "https://developer.mozilla.org/de/search?q=#{link}", (err, body) ->
        return cb() unless body
        match = body.match /<div class="column-5 result-list-item">([\s\S]+?)<\/div>/
        return cb() unless match
        return cb() unless match = match[1].match /href="([^"]*)"[^>]*>(.*?)</
        check = link.replace /[.]/, '\.(?:.*\.)?'
        .replace /\(\)/, ''
        check = new RegExp "\\b#{check}\\b", 'i'
        return cb() unless match[2].match check
        cb null,
          title: match[2]
          url: match[1]
    if type is 'nodejs'
      debug "search for link to #{link} in NodeJS API"
      [module, method] = link.split /\./
      page = "https://nodejs.org/dist/latest-v6.x/docs/api/#{module.toLowerCase()}.html"
      return requestURL page, (err, body) ->
        return cb() unless body
        check = method.replace /\(\)/, '\\([^)]+\\)'
        check = new RegExp "<h2>(.*?\\b#{check}.*?)<.*id=\"(.*?)\"", 'i'
        return cb() unless match = body.match check
        cb null,
          title: match[1].replace /\(.*?\)/, '()'
          url: "#{page}##{match[2]}"
    if type is 'npm'
      debug "search for link to #{link} in NodeJS API"
      page = "https://www.npmjs.com/package/#{link}"
      return requestURL page, (err, body) ->
        return cb() unless body
        cb null,
          title: link
          url: page
    # not possible
    cb()
  , (_, results) ->
    for res in results
      return cb null, res if res
    cb()

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
    cb null, body
