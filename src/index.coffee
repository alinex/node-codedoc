# Main controlling class
# =================================================


# Node Modules
# -------------------------------------------------

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
# internal methods
language = require './language'


# Initialize
# -------------------------------------------------
exports.run = (setup, cb) ->
  # set up system
  setup.input ?= '.'
  setup.input = path.resolve setup.input ? '.'
  setup.output = path.resolve setup.output ? '.'
  setup.find ?= {}
  setup.find.type = 'file'
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
        processFile file, (err, report) ->
          if err
            return cb err if err instanceof Error
            return cb() # no real problem but abort
          p = file[setup.input.length..]
          map[p] =
            report: report
            dest: "#{setup.output}#{p}.html"
            parts: p[1..].toLowerCase().split /\//
            title: (report.getTitle() ? p[1..]).replace /^Alinex\s+/i, ''
          cb()
      , (err) ->
        return cb err if err
        map = sortMap map
        async.eachLimit Object.keys(map), 1, (name, cb) ->
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
              files: files
          , (err, html) ->
            fs.mkdirs path.dirname(file.dest), (err) ->
              return cb err if err
              fs.writeFile file.dest, html, 'utf8', cb
        , cb

processFile = (file, cb) ->
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
        report.p 'Not parseable, yet'
        # parseSections
        # highlight
        # renderCodeFile
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
