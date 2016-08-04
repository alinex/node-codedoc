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

#3 Sorting

The file links are sorted in a natural way. This is from upper to lower directories
and alphabetically but with some defined orders. This means that 'index.*' always
comes before 'README.md' and the other files.
###


# Node Modules
# -------------------------------------------------

# include base modules
debug = require('debug') 'codedoc'
debugCopy = require('debug') 'codedoc:copy'
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
PARALLEL = 10
STATIC_FILES = /\.(html|gif|png|jpg|js|css)$/i


###
Initialize Module
-------------------------------------------------
To use the template search through the [alinex-config](https://alinex.github.io/node-config)
path module you have to init the template type by calling this method once.

This will setup the [alinex-report](https://alinex.github.io/node-report) component
and register the template type to search for templates in the global, user and
local path like known from the config module.
###

###
@param {function(err)} cb method, to call with 'Error' or `null` after done.
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
Like described in the workflow above this is the main routine and will do all the
steps to make the documentation ready to browse in the local path.
###

###
@param {object} setup defining the document creation
- `input` - path to read from
- `òutput`- output directory to store to
- `find` - source search pattern
  - `include` - files to include see [alinex-fs](https://alinex.github.io/node-fs)
  - `exclude` - files to exclude see [alinex-fs](https://alinex.github.io/node-fs)
- `brand` - branding name to remove from automatic titles
- `verbose` - level of verbose mode
@param {function(err)} cb function to be called after done
###
exports.run = (setup, cb) ->
  # set up system
  setup.input = path.resolve setup.input ? '.'
  setup.output = path.resolve setup.output ? '.'
  setup.find ?= {}
  setup.find.type = 'file'
  setup.brand ?= 'alinex'
  symbols = {} # document wide collection
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
            parse.file file, p, setup, symbols, (err, report) ->
              if err
                return cb err if err instanceof Error
                return cb() # no real problem but abort
              map[p] =
                report: report
                source: file
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
                  depth: if e.parts.length > 1 then e.parts.length - 1 else 0
                  title: e.title
                  path: p
                  link: e.title.replace /^.*?[-:]\s+/, ''
                  url: "#{path.relative path.dirname(name), p}.html"
                  active: p is name
              # convert to html
              file = map[name]
              file.report.body = render.optimize file.report.body, file.source, symbols, pages
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
        fs.find setup.input, filter, (err, list) ->
          return cb err if err
          async.eachLimit list, PARALLEL, (file, cb) ->
            (if setup.verbose > 1 then console.log else debugCopy) "copy #{file}"
            dest = "#{setup.output}#{file[setup.input.length..]}"
            fs.remove dest, ->
#              fs.copy file, dest, cb
              async.retry 3,
                (cb) -> fs.copy file, dest, cb
              , cb
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
# @param {object} map map of pages
# - `parts` is used to calculate the order
# @return {object} the sorted map of pages
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
