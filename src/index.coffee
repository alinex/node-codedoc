###
API: Main Controller
=================================================

> /src/index.coffee

This class is loaded by the CLI call or from other packages. This collects all
accessible methods to use the package.

How it Works
-------------------------------------------------

The following graph will show you the basic steps in creating the documentation:

$$$ plantuml
  :CLI Call;
  :codedoc|
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
    endif
    :report;
  }
  :sort documents]
  partition "parallel run" {
    :convert to html]
    :write report>
  }
$$$

### Sorting

The file links are sorted in a natural way. This is from upper to lower directories
and alphabetically but with some defined orders. This means that 'index.*' always
comes before 'README.md' and the other files.

Node Modules
-------------------------------------------------
###

# include base modules
debug = require('debug') 'codedoc'
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


###
Initialize
-------------------------------------------------
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


exports.run = (setup, cb) ->
  # set up system
  setup.input ?= '.'
  setup.input = path.resolve setup.input ? '.'
  setup.output = path.resolve setup.output ? '.'
  setup.find ?= {}
  setup.find.type = 'file'
  setup.brand ?= 'alinex'
  # start converting
  console.log "Output to #{setup.output}..."
  fs.mkdirs setup.output, (err) ->
    return cb err if err
    # start
    debug "search files in #{setup.input}"
    fs.find setup.input, setup.find, (err, list) ->
      return cb err if err
      debug "convert files..."
      map = {}
      async.eachLimit list, 1, (file, cb) ->
        p = file[setup.input.length..]
        processFile file, p, (err, report) ->
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
        map = sortMap map
        mapKeys = Object.keys map
        moduleName = map[mapKeys[0]].title.replace /\s*[-:].*/, ''
        .replace new RegExp("^#{setup.brand}\\s+", 'i'), ''
        async.eachLimit mapKeys, 1, (name, cb) ->
          # create link list
          files = []
          for p, e of map
            files.push
              depth: e.parts.length - 1
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
              files: files
          , (err, html) ->
            html = html.replace ///href=\"(?!https?://|/)(.*?)\"///, 'href="$1.html"'
            fs.mkdirs path.dirname(file.dest), (err) ->
              return cb err if err
              fs.writeFile file.dest, html, 'utf8', cb
        , cb

processFile = (file, local, cb) ->
  async.waterfall [
    # get file
    (cb) ->
      debug "analyze #{file}"
      fs.readFile file, (err, buffer) ->
        return cb err if err
        isBinaryFile buffer, buffer.length, (err, binary) ->
          return cb err ? 'BINARY' if err or binary
          cb null, buffer.toString 'utf8'
    # analyze language
    (contents, cb) ->
      lang = language file, contents
      unless lang
        debug chalk.magenta "could not detect language of #{file}"
        return cb 'UNKNOWN'
      debug chalk.grey "#{lang.name}: #{file}"
      cb null, contents, lang
    # create report
    (contents, lang, cb) ->
      report = new Report()
      if lang.name is 'markdown'
        report.raw contents
      else
        # document comments
        docs = []
        if lang.doc
          for re in lang.doc
            while match = re.exec contents
              docs.push [match.index, match.index + match[0].length, match[1]]
        # sort found sections
        docs.sort (a, b) ->
          return -1 if a[0] < b[0]
          return 1 if a[0] > b[0]
          0
        # create report
        unless docs.length
          report.h1 "File: #{path.basename local}"
          report.quote local
          report.code trim(contents), lang.name
          report.p Report.style 'code: style="max-height:none"'
          return cb null, report
        pos = 0
        for doc in docs
          if pos < doc[0]
            part = contents[pos..doc[0]]
            report.code trim(part), lang.name
            if pos # set correct line number
              line = contents[0..pos].split('\n').length - 1
              report.p Report.style "code: style=\"counter-reset:line #{line}\""
          report.raw doc[2]
          pos = doc[1]
        if pos < contents.length
          report.code trim(contents[pos..]), lang.name
          if pos # set correct line number
            line = contents[0..pos].split('\n').length - 1
            report.p Report.style "code: style=\"counter-reset:line #{line}\""
      cb null, report
  ], cb

orderFirst = [
  'readme.*'
  '/man'
  'index.*'
  '/src'
]
orderLast = [
  '/bin'
  '/lib'
  '/var'
  '.travis.yml'
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
      for v, i in orderFirst
        continue unless v in check
        return util.string.lpad(i, 2, '0') + util.string.rpad(p, 10, '_')
      for v, i in orderLast
        continue unless v in check
        return util.string.lpad(51 + i, 2, '0') + util.string.rpad(p, 10, '_')
      50 + util.string.rpad(p, 10, '_')
    .join ''
    "#{sortnum} => #{e}"
  list.sort()
  list = list.map (e) -> e.split(/ => /)[1]
  sorted = {}
  sorted[k] = map[k] for k in list
  sorted

trim = (code) ->
  code
