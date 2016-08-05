# Renderer
# ================================================
# Collection of methods used to generate the HTML files out of the reports and
# structures from parsing. It will create the results on disk.


# Node Modules
# -------------------------------------------------
debug = require('debug') 'codedoc'
path = require 'path'
# include alinex modules
fs = require 'alinex-fs'
util = require 'alinex-util'


# Setup
# -------------------------------------------------
STATIC_FILES = /\.(html|gif|png|jpg|js|css)$/i


# Exported Methods
# --------------------------------------------------------

# If not existing create an `index.html` file which forwards to the first page
# immediately.
#
# @param {string} dir base path of index file
# @param {string} link destination for the link to the first page
# @param {function(err)} cb callback method after done
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

# @param {String} report text to replace inline tags within
# @param {file} file file name used for relative link creation
# @param {Object} symbols map as `[file, anchor]` to resolve links
# @param {Array} pages list of pages from table of contents
# @return {String} new content
exports.optimize = (report, file, symbols, pages) ->
  # find inline tags
  report
  .replace /(\n\s*)#([1-6])(\s+)/, (_, pre, num, post) ->
    "#{pre}#{util.string.repeat '#', num}#{post}"
  .replace /\{@(\w+) ([^ \t}]*)\s?(.*)?\}/g, (source, tag, uri, text) ->
    switch tag
      when 'link'
        # check for symbol
        if symbols[uri]
          url = path.relative path.dirname(file), "#{symbols[uri][0]}.html"
          url += "##{symbols[uri][1]}"
          title = " \"File: #{symbols[uri][0]} Element: #{uri}\""
          return "[`#{text ? uri}`](#{url + title})"
        # check for file
        [uri, anchor] = uri.split /#/
        found = []
        .concat pages.filter (e) -> ~e.path.indexOf uri
        .concat pages.filter (e) -> uri is path.basename e.path
        if found.length
          text ?= found[0].title ? uri
          url = found[0].url ? uri
          title = " \"File: #{uri}\""
          return "[#{text}](#{url}#{if anchor then '#' + anchor else ''}#{title})"
        # default
        text ? uri
      when 'include'
        # include file
        [uri, anchor] = uri.split /#/
        file = path.resolve path.dirname(file), uri
        content = fs.readFileSync file, 'UTF8'
        if anchor
          [from, to] = anchor.split /\s*-\s*/
          content = anchor.split(/\n/)[from-1..to-1]
        # run inlineTags over this, too
        return exports.inlineTag content, file, symbols, pages

# @param {Object} file file information with report
# @param {String} moduleName name of the complete documentation project
# @param {Array} pages list of pages from table of contents
# @param {function(err)} cb callback if done or error occured
exports.writeHtml = (file, moduleName, pages, cb) ->
  file.report.toHtml
    style: 'codedoc'
    context:
      moduleName: moduleName
      pages: pages
  , (err, html) ->
    html = html
    .replace /(<\/ul>\n<\/p>)\n<!-- end-of-toc -->\n/
    , '<li class="sidebar"><a href="#further-pages">Further Pages</a></li>$1'
    .replace ///href=\"(?!https?://|/)(.*?)(["#])///gi, (_, link, end) ->
      if link.length is 0 or link.match STATIC_FILES
        "href=\"#{link}#{end}" # keep link
      else
        "href=\"#{link}.html#{end}" # add .html
    fs.mkdirs path.dirname(file.dest), (err) ->
      return cb err if err
      fs.writeFile file.dest, html, 'utf8', cb
