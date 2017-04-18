###
Controller - API Usage
=================================================
This module is used as the base API. If you load the package you will get a reference
to the exported methods, here. Also the CLI works through this API.

Based on the defined file filters the input folder is **searched for files** to check
for documentation. All those files are **read** if not binary. The type or language
of each file is auto detected to know how to parse it. **Documents** like markdown
are directly added to as full report.

**Code** will be analyzed and documentation blocks will be identified and **extracted**.
This contains the document comments, API comments and part of the code.

JsDoc like **tags** are interpreted and extended by auto detected information from
code. For the internal view the code will also be added with **syntax highlighting**.
Altogether will go in an report.

The reports will be **sorted**, some internal tags will be replaced and each report
will be rendered as HTML and stored in output folder. An additional **index page** will
be created if missing.

#3 Sorting

The file links are sorted in a natural way. This is from upper to lower directories
and alphabetically but with some defined orders. This means that 'index.*' always
comes before 'README.md' and the other files.
###


# Node Modules
# -------------------------------------------------

# include base modules
debug = require('debug') 'codedoc'
debugProcess = require('debug') 'codedoc:process'
chalk = require 'chalk'
path = require 'path'
async = require 'async'
isBinaryFile = require 'isbinaryfile'
handlebars = require 'handlebars'
# include alinex modules
util = require 'alinex-util'
fs = require 'alinex-fs'
Report = require 'alinex-report'
config = require 'alinex-config'
require('alinex-handlebars').register handlebars
# internal methods
language = require './helper/language'
parser = require './helper/parser'
doctags = require './helper/doctags'
transcode = require './helper/transcode'


# Setup
# -------------------------------------------------
STATIC_FILES = /\.(html|gif|png|jpg|js|css)$/i # files to copy
TYPES = ['api', 'devel']

###
Initialize Module
-------------------------------------------------
To use the template search through the {@link alinex-config}
path module you have to init the template type by calling this method once.

This will setup the {@link alinex-report} component
and register the template type to search for templates in the global, user and
local path like known from the config module.
###

###
@param {function(<Error>)} cb method, to call with 'Error' or `null` after done.
###
exports.setup = util.function.once this, (cb) ->
  debug chalk.grey "setup codedoc component" if debug.enabled
  async.each [Report], (mod, cb) ->
    mod.setup cb
  , (err) ->
    return cb err if err
    # set module search path
    config.register 'codedoc', path.dirname __dirname
    config.register 'codedoc', path.dirname(__dirname),
      folder: 'template'
      type: 'template'
    cb()

###
Create Documentation
-------------------------------------------------
###

###
Like described in the workflow above this is the main routine and will do all the
steps to make the documentation ready to browse in the local path.

@param {object} setup defining the document creation
- `input` - `String` path to read from
- `find` - `Object` source search pattern
  - `include` - `String|RegExp|Array` files to include see {@link alinex-fs}
  - `exclude` - `String|RegExp|Array` files to exclude see {@link alinex-fs}
- `òutput`- `String` output directory to store to
- `format` - `Array<String>` format to generate like `html` or `md` (defaults to html only)
- `verbose` - `Integer` level of verbose mode
- `parallel` - `Integer` estimated max parallel runs (default is 100 or 1 if in
  debug mode)
@param {function(<Error>)} cb function to be called after done

@internal
The `work` context contains:
- `files`
  - `source` - full source path
  - `local` - local path (from given directory)
  - `content` - source content
  - `lang` - language settings
  - `devel` - report
  - `api` - report
  - `title`
    - `devel`
    - `api`
  - `links`
    - `devel`
    - `api`
- `devel`
  - `pages`
  - `links`
- `api`
  - `pages`
  - `links`
###
exports.run = (setup, cb) ->
  # set up system
  setup.input = path.resolve setup.input ? '.'
  setup.output = path.resolve setup.output ? '.'
  setup.find ?= {}
  setup.find.type = 'file'
  setup.parallel ?= if debug.enabled then 1 else 100
  setup.format ?= ['html']
  # work context
  work = {}
  # run steps
  async.series [
    (cb) -> clean work, setup, cb
    (cb) -> find work, setup, cb
    (cb) -> copyResources work, setup, cb
    (cb) ->
      # each file in parallel
      (if setup.verbose > 1 then console.log else debug) "load file docs..."
      async.each work.files, (file, cb) ->
        async.series [
          (cb) -> loadFile file, setup, cb
          (cb) -> fileInfo file, setup, cb
          (cb) -> createReport file, setup, cb
          (cb) -> analyzePage file, setup, cb
        ], (err) ->
          return cb() if err and typeof err is 'string'
          cb err
      , cb
    (cb) -> summarize work, setup, cb
    (cb) ->
      # each file in parallel
      (if setup.verbose > 1 then console.log else debug) "format and write docs..."
      async.each work.files, (file, cb) ->
        async.series [
          (cb) -> optimize work, file, setup, cb
          (cb) -> writeFile work, file, setup, cb
        ], cb
      , cb
    (cb) -> createIndex work, setup, cb
    # create index
  ], cb


# Helper methods
# --------------------------------------------------------

clean = (work, setup, cb) ->
  return cb() unless setup.clean
  (if setup.verbose then console.log else debug) "cleanup output directory #{setup.output}..."
  fs.remove setup.output, cb
  
find = (work, setup, cb) ->
  (if setup.verbose then console.log else debug) "search files in #{setup.input}..."
  fs.find setup.input,
    filter: setup.find
    dereference: true
  , (err, list) ->
#    list = ['/home/alex/github/node-codedoc/README.md']
#    list = ['/home/alex/github/node-codedoc/src/index.coffee']
#    list = ['/home/alex/github/node-codedoc/src/helper/parser.coffee']
    work.files = list.map (e) ->
      source: e
      local: e[setup.input.length..]
    cb()

copyResources = (work, setup, cb) ->
  # find resources
  (if setup.verbose then console.log else debug) "copy static files from #{setup.input}"
  filter = util.extend util.clone(setup.find),
    include: STATIC_FILES
  async.eachSeries TYPES, (type, cb) ->
    async.eachSeries setup.format, (format, cb) ->
      debug "-> #{setup.output}/#{format}/#{type}/"
      fs.copy setup.input, "#{setup.output}/#{format}/#{type}/",
        filter: filter
        dereference: true
        overwrite: true
        noempty: true
        ignoreErrors: true
      , (err) ->
        return cb err if err
        return cb() unless setup.resources?.include
        fs.copy setup.input, "#{setup.output}/#{format}/#{type}/",
          filter: setup.resources
          dereference: true
          overwrite: true
          noempty: true
          ignoreErrors: true
        , cb
    , cb
  , cb

loadFile = (file, setup, cb) ->
  debugProcess chalk.grey "load #{file.source}" if debugProcess.enabled
  fs.readFile file.source, (err, buffer) ->
    return cb err if err
    isBinaryFile buffer, buffer.length, (err, binary) ->
      return cb err if err
      file.content = if binary then 'BINARY' else buffer.toString 'utf8'
      cb null, file

fileInfo = (file, setup, cb) ->
  lang = language file.local, file.content
  unless lang
    (if setup.verbose then console.log else debug) \
      chalk.magenta "could not detect language of #{file.local}"
    return cb 'UNKNOWN'
  if debugProcess.enabled
    debugProcess chalk.grey "#{file.source}: detected as #{lang.name}"
  file.lang = lang
  cb()

createReport = (file, setup, cb) ->
  if file.lang.name is 'markdown'
    devel = file.content # don't change anything
  else
    try
      if debugProcess.enabled
        debugProcess chalk.grey "convert #{file.local} to markdown"
      devel = parser file, setup
    catch error
      return cb error
  # store devel and use copy for api
  api = devel
  devel = devel.replace /<!--\s*(end )?internal\s*-->/g, ''
  file.devel = new Report()
  file.devel.toc()
  file.devel.markdown devel
#  console.log devel if file.local.match /index.coffee$/
#  console.log file.devel.tokens.data if file.local.match /codedoc$/
  # create api doc
  api = api.replace ///
    <!--\s*internal\s*-->
#    (?:           # alternative content
#      (`{3,})     # 1: markdown code block
#      [\s\S]*?    # content
#      \1          # end code block
#    |
      [\s\S]*?    # anything
#    )
    <!--\s*end\ internal\s*-->
    ///ig, ''
  .replace /<!--\s*internal\s*-->[\s\S]*$/i, ''
  .trim()
  return cb() unless api
  file.api = new Report()
  file.api.toc()
  file.api.markdown api
  cb()

analyzePage = (file, setup, cb) ->
  file.links = {}
  file.title = {}
  async.each TYPES, (type, cb) ->
    return cb() unless file[type]
    # convert to html and get title + links
    file[type].format 'html', (err) ->
      return cb err if err
      document = file[type].formatter.html.tokens.data[0]
      file.title[type] = document.title
      file.links[type] = {}
      for link, e of document.heading
        file.links[type][e.title] = link
      cb()
  , cb

summarize = (work, setup, cb) ->
  (if setup.verbose then console.log else debug) "summarize files..."
  linksearch = {}
  for type in TYPES
    pages = []
    symbols = {}
    for file in work.files
      continue unless file[type]
      # get pages
      pages.push
        local: file.local
        parts: file.local[1..].toLowerCase().split /\//
        title: file.title[type]
      # add links
      for n, l of file.links[type]
        symbols[n] = [file.local, l, n]
        if n.match /\(\)$/
          s = n.replace /\(\)$/, ''
          symbols[s] = [file.local, l, n] unless symbols[s]
      # add files
      for page in pages
        name = path.basename page.local
        symbols[name] = [page.local, null, page.title] unless symbols[name]
#        console.log name
      if type is 'devel' and search = file.lang?.tags?.searchtype
        linksearch[search] ?= 0
        linksearch[search]++
    # store results
    work[type] =
      symbols: symbols
      pages: sortPages pages
    linksearchDefault = null
    max = 0
    for type, num in linksearch
      continue if num <= max
      max = num
      linksearchDefault = type
    work.search = linksearchDefault
  # output resulting doc sources
  for file in work.devel.pages
    api = work.api.pages.filter (e) -> e.local is file.local
    debug "add #{chalk.yellow file.local} to devel #{if api.length then 'and api' else ''}"
  cb()

optimize = (work, file, setup, cb) ->
  debugProcess chalk.grey "optimize #{file.local}"
  async.eachSeries TYPES, (type, cb) ->
    return cb() unless file[type]
    # optimize
    file[type].format 'md', (err, md) ->
      return cb err if err
      ##### set search type per file
      search = file.lang.tags?.searchtype
      search = work.search if search is 'default' or not search
      doctags file, type, md, work[type].symbols, search, (err, md) ->
        return cb err if err
        # recreate report
        file[type] = new Report()
        file[type].markdown md
        transcode file, type, md, (err, md) ->
          return cb err if err
          # recreate report
          file[type] = new Report()
          file[type].markdown md
          cb()
  , cb

writeFile = (work, file, setup, cb) ->
  async.each TYPES, (type, cb) ->
    return cb() unless file[type]
    async.each setup.format, (format, cb) ->
      if debugProcess.enabled
        debugProcess chalk.grey "write #{setup.output}/#{format}/#{type}#{file.local}.#{format}"
      file[type].format format, (err, data) ->
        return cb err if err
        if format is 'html'
          pages = work[type].pages.map (e) ->
            depth = e.parts.length - 1
            depth-- if path.basename(e.local, path.extname e.local) is 'index'
            depth = 0 if depth < 0
            # result
            depth: depth
            title: e.title
            path: e.local
            link: e.title.replace /^.*?[-:]\s+/, ''
            url: "#{path.relative path.dirname(file.local), e.local}.html"
            active: e.local is file.local
          # replace template variables
          match = data.match ///
            ^([\s\S]*?)
            (<!--\ START\ CONTENT\ -->[\s\S]*<!--\ END\ CONTENT\ -->)
            ([\s\S]*)$
            ///
          switchUrl = "../#{pages[0].url}".replace /(.*\.\.)/, \
            "$1/#{if type is 'api' then 'devel' else 'api'}"
          context =
            switch:
              url: switchUrl
              icon: if type is 'api' then 'code' else 'book'
              name: if type is 'api' then 'Internal Documentation' else 'External API only'
              title: if type is 'api'
                "switch to internal documentation with code"
              else
                "switch to external api documentation"
            moduleName: pages[0].title.replace /\s*[-:].*/, ''
            pages: pages
          match[1] = handlebars.compile(match[1]) context
          match[3] = handlebars.compile(match[3]) context
          data = match[1..3].join ''
        # write file
        dest = "#{setup.output}/#{format}/#{type}#{file.local}.#{format}"
        fs.mkdirs path.dirname(dest), (err) ->
          return cb err if err
          fs.writeFile dest,
            data, 'utf8', cb
    , cb
  , cb

createIndex = (work, setup, cb) ->
  file = "#{setup.output}/html/index.html"
  dest = "api#{work.api.pages[0].local}.html"
  fs.exists file, (exists) ->
    return cb() if exists
    (if setup.verbose then console.log else debug) "create index..."
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


# #3 Setup Page Order
#
# This is done by patterns in the first and last listing. All undefined will be
# between them in ordered list.
orderFirst = [
  # documentation
  'readme'
  'readme.*'
  '/man'
  'index.md'
  '*.md'
  '/doc'
  # main scripts
  'index.*'
  '/src'
]
orderLast = [
  '/bin'
  '/lib'
  '/var'
  # helper data
  '.travis.yml'
  # changelog
  'changelog'
  'changelog.*'
]

# Sorting the page map is done by generating sort strings for each page from the
# order in the lists above, the file depth and file name. The keys will be sorted
# and a new object is generated in this sort order.
#
# @param {Array} list of pages
# - `parts` - `Array<String>` is used to calculate the order
# @return {Object} the sorted map of pages
sortPages = (list) ->
  num = 0
  names = list.map (e) ->
    parts = e.parts[..-2].map (p) -> "/#{p}"
    parts.push e.parts[e.parts.length-1]
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
    "#{sortnum} => #{num++}"
  names.sort()
  names.map (e) -> list[e.split(/ => /)[1]]
