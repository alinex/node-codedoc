# Renderer
# ================================================
# Collection of methods used to generate the HTML files out of the reports and
# structures from parsing. It will create the results on disk.


# Node Modules
# -------------------------------------------------
debug = require('debug') 'codedoc:doctags'
path = require 'path'
chalk = require 'chalk'
asyncReplace = require 'async-replace'
async = require 'async'
request = require 'request'
# alinex modules
util = require 'alinex-util'
validator = require 'alinex-validator'


# Setup
# -------------------------------------------------
PAGE_SEARCH = # define the possible settings and methods to use
  nodejs: ['nodejs', 'npm', 'mdn']
  javascript: ['mdn']


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
module.exports = (file, type, md, symbols, search, cb) ->
  first = true
  asyncReplace md, ///
    ([ \t]*)
    \{@(\w+)
    \s([^ \t}]*)
    \s?([^}]*)?
    \}
    ///g
  , (source, indent, tag, uri, text, offset, all, cb) ->
    if first
      debug "replace tags in #{file.local} (#{type})" if debug.enabled
      first = false
    switch tag
      when 'link'
        # check in symbols
        findSymbol uri, symbols, search, type, (err, symbol) ->
          if err
            console.error chalk.magenta "Link not found in #{file.local}:
              #{source.trim()} (#{err.message})"
            return cb null, source
          url = if symbol[0].match /https?:\/\// then symbol[0]
          else path.relative path.dirname(file.local), symbol[0]
          url += "##{symbol[1]}" if symbol[1]
          title = if symbol[2] then " \"\
          #{if symbol[2]?.match /\(\)$/ then 'Method: ' else ''}#{symbol[2]}\"" else ''
          symbol[2] = "`#{symbol[2]}`" if symbol[2]?.match /\(\)$/
          if debug.enabled
            debug chalk.green "  #{source.trim()} -> [#{text ? symbol[2] ? uri}](#{url + title})"
          cb null, "#{indent}[#{text ? symbol[2] ? uri}](#{url + title})"
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
        console.error chalk.magenta "Unknown tag for transform in #{file.local}: #{source.trim()}"
        cb null, source
  , cb

cache = {}

findSymbol = (uri, symbols, search, type, cb) ->
  [uri, anchor] = uri.split /\#/
  # check in given symbols
  if symbol = symbols[uri]
    return cb null, ["#{symbol[0]}.html", symbol[1] ? anchor, symbol[2]]
  # urls
  if uri.match /^(https?):\/\//
    return cb null, [uri, anchor]
  # alinex link
  searchAlinex uri, anchor, type, (err, res) ->
    return cb err if err
    return cb null, res if res
    # internet search
    unless search
      return cb new Error "Unknown uri type to search for (no search defined)."
    if symbol = cache["#{uri}##{anchor}"]
      return cb null, symbol
    searchLink uri, search, (err, res) ->
      if err or not res?.url
        return cb new Error "Could not resolve link to #{uri} in #{search} search. #{err}"
      cache["#{uri}##{anchor}"] = symbol = [res.url, anchor, res.title]
      cb null, symbol

searchAlinex = (uri, anchor, type, cb) ->
  return cb() unless m = uri.match /^alinex-(\w+)(.*)/
  # try to get symbols
  loadAlinex m[1], type, (_, symbols) ->
    if symbols
      base = "https://alinex.github.io/node-#{name}/#{type}"
      # 1. /.... path symbol
      if m[2].length and symbol = symbols[m[2]]
        return cb null, ["#{base}#{symbol[0]}.html", symbol[1] ? anchor, symbol[2]]
      # 2. #...  title search
      if anchor and symbol = symbols[anchor]
        return cb null, ["#{base}#{symbol[0]}.html", symbol[1], symbol[2]]
    # else
    m[2] += '.html' if m[2].match /\/./ and not m[2].match /\.(gif|html|png|jpg)$/
    return cb null, ["https://alinex.github.io/node-#{m[1]}#{m[2]}", anchor]

alinex = {}
loadAlinex = (name, type, cb) ->
  return cb null, alinex["#{name}-#{type}"] if alinex["#{name}-#{type}"]
  requestURL "https://alinex.github.io/node-#{name}/#{type}-symbols.json", (err, body) ->
    if body
      try
        alinex["#{name}-#{type}"] = JSON.parse body
    alinex["#{name}-#{type}"] ?= false
    return cb null, alinex["#{name}-#{type}"]


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
      debug chalk.grey "search for link to #{link} in MDN" if debug.enabled
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
      debug chalk.grey "search for link to #{link} in NodeJS API" if debug.enabled
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
      debug chalk.grey "search for link to #{link} in NPM" if debug.enabled
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
