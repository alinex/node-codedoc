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
      async.mapLimit list, 1, (file, cb) ->
        dest = "#{setup.output}#{file[setup.input.length..]}.html"
        processFile file, dest, cb
      , cb

processFile = (file, dest, cb) ->
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
    # write file
    (report, cb) ->
      report.toHtml
        style: 'codedoc'
      , (err, html) ->
        fs.writeFile dest, html, 'utf8', cb
    # addFileToTree
    (cb) ->
      cb()
  ], -> cb()
