###
Controller
=================================================

This module is used as the base API. If you load the package you will get a reference
to the exported methods, here. Also the CLI works through this API.

Workflow
-------------------------------------------------

The following graph will show you the basic steps in creating the documentation:

$$$ plantuml
  :API Call;
  :run|
  :Find files]
  note right
    Includes and excludes
    definable
  end note
  partition "parallel run" {
    note right
      for each
      file
    end note
    :read file<
    :analyze language]
    if (is markdown) then (yes)
      :add as report]
    else (no)
      :extract
      block comments]
      :interpret JsDoc]
      if (add code) then (no)
      else (yes)
        :add code]
        note right
          with highlights
        end note
      endif
    endif
    :report;
  }
  :sort documents]
  partition "parallel run" {
    :convert to html]
    :write report>
  }
$$$

#3 Sorting

The file links are sorted in a natural way. This is from upper to lower directories
and alphabetically but with some defined orders. This means that 'index.*' always
comes before 'README.md' and the other files.
###


# Node Modules
# -------------------------------------------------
#

# include base modules
debug = require('debug') 'codedoc'
debugPage = require('debug') 'codedoc:page'
debugCopy = require('debug') 'codedoc:copy'
chalk = require 'chalk'
path = require 'path'
async = require 'async'
isBinaryFile = require 'isbinaryfile'
# include alinex modules
util = require 'alinex-util'
fs = require 'alinex-fs'
Report = require 'alinex-report'
config = require 'alinex-config'
# internal methods
language = require './language'

PARALLEL = 10
STATIC_FILES = /\.(html|gif|png|jpg|js|css)$/i

###
Initialize Module - setup()
-------------------------------------------------
To use the template search through the [alinex-config](http://alinex.github.io/node-config)
path module you have to init the template type by calling this method once.

This will setup the [alinex-report](http://alinex.github.io/node-report) component
and register the template type to search for templates in the global, user and
local path like known from the config module.
###
exports.setup = util.function.once this, (cb) ->
  debug chalk.grey "setup codedoc component"
  async.each [Report], (mod, cb) ->
    mod.setup cb
  , (err) ->
    return cb err if err
    # set module search path
    config.register 'codedoc', path.dirname(__dirname),
      folder: 'template'
      type: 'template'
    cb()

###
Create Documentation - run()
-------------------------------------------------
Like described in the workflow above this is the main routine and will do all the
steps to make the documentation ready to browse in the local path.

::: alert
The method documentation in form of @tags will come soon.
:::
###
exports.run = (setup, cb) ->
  # set up system
  setup.input ?= '.'
  setup.input = path.resolve setup.input ? '.'
  setup.output = path.resolve setup.output ? '.'
  setup.find ?= {}
  setup.find.type = 'file'
  setup.brand ?= 'alinex'
  # start converting
  fs.mkdirs setup.output, (err) ->
    return cb err if err
    async.parallel [
      (cb) -> # search source files
        (if setup.verbose then console.log else debug) "search files in #{setup.input}"
        fs.find setup.input, setup.find, (err, list) ->
          return cb err if err
          # create reports
          (if setup.verbose then console.log else debug) "convert files..."
          map = {}
          async.eachLimit list, PARALLEL, (file, cb) ->
            p = file[setup.input.length..]
            processFile file, p, setup, (err, report) ->
              if err
                return cb err if err instanceof Error
                return cb() # no real problem but abort
              map[p] =
                report: report
                dest: "#{setup.output}#{p}.html"
                parts: p[1..].toLowerCase().split /\//
                title: report.getTitle() ? p[1..]
              cb()
          , (err) ->
            return cb err if err
            # write files
            map = sortMap map
            mapKeys = Object.keys map
            moduleName = map[mapKeys[0]].title.replace /\s*[-:].*/, ''
            .replace new RegExp("^#{setup.brand}\\s+", 'i'), ''
            async.eachLimit mapKeys, PARALLEL, (name, cb) ->
              # create link list
              pages = []
              for p, e of map
                pages.push
                  depth: if setup.code then e.parts.length - 1 else 0
                  title: e.title
                  path: p
                  link: e.title.replace /^.*?[-:]\s+/, ''
                  url: "#{path.relative path.dirname(name), p}.html"
                  active: p is name
              # convert to html
              file = map[name]
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
            , (err) ->
              return cb err if err
              (if setup.verbose then console.log else debug) "check index page"
              createIndex setup.output, map[mapKeys[0]].dest, (err) ->
                return cb err if err
                (if setup.verbose then console.log else debug) "page creation done"
                cb()
      (cb) -> # copy resources
        (if setup.verbose then console.log else debug) "copy static files from #{setup.input}"
        filter = util.extend util.clone(setup.find),
          include: STATIC_FILES
        fs.find setup.input, filter, (err, list) ->
          return cb err if err
          async.eachLimit list, PARALLEL, (file, cb) ->
            (if setup.verbose > 1 then console.log else debugCopy) "copy #{file}"
            dest = "#{setup.output}#{file[setup.input.length..]}"
            fs.remove dest, ->
              fs.copy file, dest, cb
          , (err) ->
            return cb err if err
            (if setup.verbose then console.log else debug) "copying files done"
            cb()
    ], (err) ->
      return cb err if err
      (if setup.verbose then console.log else debug) "finished document creation"
      cb()

# If not existing create an `index.html` file which forwards to the first page
# immediately.
#
# @test this is only for testing the tags
createIndex = (dir, link, cb) ->
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

processFile = (file, local, setup, cb) ->
  async.waterfall [
    # get file
    (cb) ->
      (if setup.verbose > 1 then console.log else debugPage) "analyze #{file}"
      fs.readFile file, (err, buffer) ->
        return cb err if err
        isBinaryFile buffer, buffer.length, (err, binary) ->
          return cb err ? 'BINARY' if err or binary
          cb null, buffer.toString 'utf8'
    # analyze language
    (contents, cb) ->
      lang = language file, contents
      unless lang
        (if setup.verbose then console.log else debug) \
          chalk.magenta "could not detect language of #{file}"
        return cb 'UNKNOWN'
      (if setup.verbose > 2 then console.log else debugPage) \
        chalk.grey "#{file}: detected as #{lang.name}"
      cb null, contents, lang
    # create report
    (contents, lang, cb) ->
      report = new Report()
      report.toc()
      report.raw '<!-- end-of-toc -->\n\n' # needed in case raw adding will follow
      if lang.name is 'markdown'
        report.raw contents
      else
        # document comments
        docs = []
        if lang.doc
          [re, fn] = lang.doc
          while match = re.exec contents
            match[1] = fn match[1] if fn
            end = match.index + match[0].length
            cend = contents.indexOf '\n', end
            code = if cend > 0 then contents[end..cend] else contents[end..]
            docs.push [match.index, end, match[1], code.trim()]
          (if setup.verbose > 2 then console.log else debugPage) \
            chalk.grey "#{file}: #{docs.length} doc comments"
        if lang.api and setup.code
          [re, fn] = lang.api
          while match = re.exec contents
            match[1] = fn match[1] if fn
            end = match.index + match[0].length
            found = false
            for c in docs
              if c[0] is match.index and c[1] is end
                found = true
                break
            unless found
              end = match.index + match[0].length
              cend = contents.indexOf '\n', end
              code = if cend > 0 then contents[end..cend] else contents[end..]
              docs.push [match.index, end, match[1], code.trim()]
          (if setup.verbose > 2 then console.log else debugPage) \
            chalk.grey "#{file}: #{docs.length} doc comments (with internal)"
        # sort found sections
        docs.sort (a, b) ->
          return -1 if a[0] < b[0]
          return 1 if a[0] > b[0]
          0
        # create report
        unless docs.length
          return cb 'CODE_DISABLED' unless setup.code
          report.h1 "File: #{path.basename local}"
          report.quote "Path: #{local}"
          report.code stripIndent(contents, lang.tab), lang.name
          report.p Report.style 'code: style="max-height:none"'
          return cb null, report
        pos = 0
        for doc in docs
          # doc optimizations
          optimize doc, lang.tags, file
          if pos < doc[0] and setup.code
            # code block before doc
            part = contents[pos..doc[0]]
            report.code stripIndent(part, lang.tab), lang.name
            if pos # set correct line number
              line = contents[0..pos].split('\n').length - 1
              report.p Report.style "code: style=\"counter-reset:line #{line}\""
          # add doc block
          md = doc[2].replace /(\n\s*)#3(\s+)/, '$1###$2'
          .replace /\n\s*?$/, ''
          report.raw "\n#{md}\n\n"
          pos = doc[1]
        if pos < contents.length and setup.code
          # last code block
          report.code stripIndent(contents[pos..], lang.tab), lang.name
          if pos # set correct line number
            line = contents[0..pos].split('\n').length - 1
            report.p Report.style "code: style=\"counter-reset:line #{line}\""
        # optimize report by adding path with compiled path
        source = "`#{local}`"
        if match = local.match /^\/src(\/.*)\.coffee$/
          source += " compiled to `/lib#{match[1]}.js`"
        report.body = report.body.replace /(\n\s*={10,}\s*\n)/, "$1\n> Path: #{source}\n\n"
      cb null, report
  ], cb

orderFirst = [
  'readme.*'
  'readme'
  '/man'
  '*.md'
  'index.*'
  '/src'
]
orderLast = [
  '/bin'
  '/lib'
  '/var'
  '.travis.yml'
  'changelog'
  'changelog.*'
]
sortMap = (map) ->
  list = Object.keys(map).map (e) ->
    parts = map[e].parts[..-2].map (p) -> "/#{p}"
    parts.push map[e].parts[map[e].parts.length-1]
    sortnum = parts.map (p) ->
      check = [p]
      if ~p.indexOf '.'
        check.push "*#{path.extname p}"
        check.push "#{path.basename p, path.extname p}.*"
      for v, i in orderLast
        continue unless v in check
        return util.string.lpad(51 + i, 2, '0') + util.string.rpad(p, 10, '_')
      for v, i in orderFirst
        continue unless v in check
        return util.string.lpad(i, 2, '0') + util.string.rpad(p, 10, '_')
      50 + util.string.rpad(p, 10, '_')
    .join ''
    "#{sortnum} => #{e}"
  list.sort()
  list = list.map (e) -> e.split(/ => /)[1]
  sorted = {}
  sorted[k] = map[k] for k in list
  sorted

stripIndent = (code, tab) ->
  str = code.replace /^[ \t]*(?=\S)/gm, (e) ->
    e.replace '\t', util.string.repeat ' ', tab ? 2
  match = str.match /^ *(?=\S)/gm
  return code unless match
  indent = Math.min.apply Math, match.map (e) -> e.length
  code.replace new RegExp("^ {#{indent}}", 'gm'), ''

optimize = (doc, lang, file) ->
  return unless lang
  md = doc[2]
  code = doc[3]
  # extract tags
  spec = {}
  if match = md.match /(?:\n|[ \t\r]){2,}(?=@)/
    add = md[match.index+match[0].length..]
    md = md[0..match.index-1]
    for part in add.split /(?:\n|[ \t\r])(?=@)/g
      if match = part.match /^@(\S+)\s+/
        spec[match[1]] = part[match[0].length..]
  # add markdown for spec


  # replace inline tags


  # add heading 3 if not there
  unless md.match /(^|\n)(#{1,3}[^#]|[^\n]+\n[-=]{3,})/
    title = if lang.title then lang.title code else code
    md = "### #{title}\n\n#{md}"

#  if file.match /index.coffee/
#    console.log '000000000000000000000000000000000000000000000000000'
#    console.log util.inspect(doc[2]), spec, code
#    console.log '__________________'
#    console.log md
  # store changes
  doc[2] = md
