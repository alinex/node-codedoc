###
Controller - API Usage
=================================================
This module is used as the base API. If you load the package you will get a reference
to the exported methods, here. Also the CLI works through this API.

$$$ plantuml {.right}
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

Based on the defined file filters the input folder is **searched for files** to check
for documentation. All those files are **read** if not binary. The type or language
of each file is auto detected to know how to parse it. **Documents** like markdown
are directly added to as full report.

**Code** will be analyzed and documentation blocks will be identified and **extracted**.
This contains the document comments, api comments and part of the code.

JsDoc like **tags** are interpreted and extended by autodetected information from
code. For the internal view the code will also be added with **syntax highlighting**.
Alltogethher will go in an report.

The reports will be **sorted**, some internal tags will be replaced and each report
will be rendered as html and stored in output folder. An additional **index page** will
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
chalk = require 'chalk'
path = require 'path'
async = require 'async'
# include alinex modules
util = require 'alinex-util'
fs = require 'alinex-fs'
Report = require 'alinex-report'
config = require 'alinex-config'
# internal methods
parse = require './helper/parse'
render = require './helper/render'


# Setup
# -------------------------------------------------
STATIC_FILES = /\.(html|gif|png|jpg|js|css)$/i # files to copy


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
Create Documentation
-------------------------------------------------
###

###
Like described in the workflow above this is the main routine and will do all the
steps to make the documentation ready to browse in the local path.

@param {object} setup defining the document creation
- `input` - `String` path to read from
- `òutput`- `String` output directory to store to
- `find` - `Object` source search pattern
  - `include` - `String|RegExp|Array` files to include see {@link alinex-fs}
  - `exclude` - `String|RegExp|Array` files to exclude see {@link alinex-fs}
- `verbose` - `Integer` level of verbose mode
- `parallel` - `Integer` estimated max parallel runs (default is 100 or 1 if in
  debug mode)
@param {function(<Error>)} cb function to be called after done
###
exports.run = (setup, cb) ->
  # set up system
  setup.input = path.resolve setup.input ? '.'
  setup.output = path.resolve setup.output ? '.'
  setup.find ?= {}
  setup.find.type = 'file'
  setup.parallel ?= if debug.enabled then 1 else 100
  symbols = {} # document wide collection
  # start converting
  fs.mkdirs setup.output, (err) ->
    return cb err if err
    async.series [
      (cb) -> # search source files
        (if setup.verbose then console.log else debug) "search files in #{setup.input}"
        fs.find setup.input,
          filter: setup.find
          dereference: true
        , (err, list) ->
          return cb err if err
          # create reports
          (if setup.verbose then console.log else debug) "convert files..."
          map = {}
          linksearch = {}
          async.eachLimit list, setup.parallel, (file, cb) ->
            p = file[setup.input.length..]
            parse.file file, p, setup, symbols, (err, report, lang) ->
              if err
                return cb err if err instanceof Error
                return cb() # no real problem but abort
              map[p] =
                report: report
                language: lang
                source: file
                dest: "#{setup.output}#{p}.html"
                parts: p[1..].toLowerCase().split /\//
                title: report.getTitle() ? p[1..]
              if type = lang.tags?.searchtype
                linksearch[type] ?= 0
                linksearch[type]++
              cb()
          , (err) ->
            return cb err if err
            # add the title of the symbol as element
            s[2] = name for name, s of symbols
            # write files
            linksearchDefault = null
            max = 0
            for type, num in linksearch
              continue if num <= max
              max = num
              linksearchDefault = type
            map = sortMap map
            mapKeys = Object.keys map
            moduleName = map[mapKeys[0]].title.replace /\s*[-:].*/, ''
            (if setup.verbose then console.log else debug) "create html files..."
            async.eachLimit mapKeys, setup.parallel, (name, cb) ->
              # create link list
              pages = []
              for p, e of map
                pages.push
                  depth: if e.parts.length > 1 then e.parts.length - 1 else 0
                  title: e.title
                  path: p
                  link: e.title.replace /^.*?[-:]\s+/, ''
                  url: "#{path.relative path.dirname(name), p}.html"
                  active: p is name
              # convert to html
              file = map[name]
              search = file.language.tags?.searchtype
              search = linksearchDefault if search is 'default'
              render.optimize file.report.body, file.source, symbols, pages, search
              , (err, md) ->
                file.report.body = md
                render.writeHtml file, moduleName, pages, cb
            , (err) ->
              return cb err if err
              (if setup.verbose then console.log else debug) "check index page"
              render.createIndex setup.output, map[mapKeys[0]].dest, (err) ->
                return cb err if err
                (if setup.verbose then console.log else debug) "page creation done"
                cb()
      (cb) -> # copy resources
        (if setup.verbose then console.log else debug) "copy static files from #{setup.input}"
        filter = util.extend util.clone(setup.find),
          include: STATIC_FILES
        fs.copy setup.input, setup.output,
          filter: filter
          dereference: true
          overwrite: true
          noempty: true
          ignoreErrors: true
        , (err) ->
          return cb err if err
          (if setup.verbose then console.log else debug) "copying files done"
          cb()
    ], (err) ->
      return cb err if err
      (if setup.verbose then console.log else debug) "finished document creation"
      cb()

# Helper methods
# --------------------------------------------------------

# #3 Setup Page Order
#
# This is done by patterns in the first and last listing. All undefined will be
# between them in ordered list.
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

# Sorting the page map is done by generating sort strings for each page from the
# order in the lists above, the file depth and file name. The keys will be sorted
# and a new object is generated in this sort order.
#
# @param {Object} map map of pages
# - `parts` - `Array<String>` is used to calculate the order
# @return {Object} the sorted map of pages
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
