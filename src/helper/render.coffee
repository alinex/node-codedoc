# Renderer
# ================================================


# Node Modules
# -------------------------------------------------

# include base modules
debug = require('debug') 'codedoc'
path = require 'path'
# include alinex modules
fs = require 'alinex-fs'


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

# @param {Report} report to replace inline tags within markdown
# @param {file} file file name used for relative link creation
# @param {Object} symbols map as `[file, anchor]` to resolve links
# @param {Array} pages list of pages from table of contents
exports.inlineTags = (report, file, symbols, pages) ->
  # find inline tags
  report.body = report.body.replace /\{@(\w+) ([^ \t}]*)\s?(.*)?\}/g, (source, tag, uri, text) ->
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

# Helper methods
# --------------------------------------------------------
