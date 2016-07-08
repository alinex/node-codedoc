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
      async.mapLimit list, 1, processFile, cb

processFile = (file, cb) ->
  async.waterfall [
    (cb) -> # get file
      debug "analyze #{file}"
      fs.readFile file, (err, buffer) ->
        return cb err if err
        isBinaryFile buffer, buffer.length, (err, binary) ->
          return cb err ? 'BINARY' if err or binary
          cb null, buffer.toString 'utf8'
    (contents, cb) -> # analyze language
      lang = language file, contents
      unless lang
        debug chalk.magenta "could not detect language of #{file}"
        return cb 'UNKNOWN'
      debug chalk.grey "#{lang.name}: #{file}"
      cb null, contents, lang
    (contents, lang, cb) -> # analyze language
#      console.log file, lang, contents.length, 'bytes'
      cb()
  ], -> cb()

# addFileToTree
# markdown:
  # renderMarkdownFile
# code:
  # parseSections
  # highlight
  # renderCodeFile
