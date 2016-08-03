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
  report.body = report.body.replace /\{@(\w+) ([^ \t}]*)\s?(.*)?\}/, (source, tag, link, text) ->
    switch tag
      when 'link'
        # check for symbol
        if symbols[link]
          url = path.relative path.dirname(file), "#{symbols[link][0]}.html"
          url += "##{symbols[link][1]}"
          "[`#{text ? link}`](#{url})"
        # check for file
        else
          [link, anchor] = link.split /#/
          found = []
          .concat pages.filter (e) -> ~e.path.indexOf link
          .concat pages.filter (e) -> link is path.basename e.path
          if found
            text ?= found[0].title
            url = found[0].url
          "[#{text ? link}](#{url ? link}#{if anchor then '#' + anchor else ''})"
      else
        source

# Helper methods
# --------------------------------------------------------
