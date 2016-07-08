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
    console.log setup
    fs.find setup.input, setup.find, (err, list) ->
      return cb err if err
      debug "convert files..."
      async.mapLimit list, 10, processFile, cb

#      (err, res) ->
#        return cb err if err
#        map = {}
#        for i in [0..list.length-1]
#          map[list[i]] =
#            dir: path.dirname(list[i])[setup.input.length+1..]
#            content: res[i]
#        console.log "Write into #{setup.output}..."
##        console.log map
#        async.parallel [
#          (cb) ->
#            debug "write pages..."
#            cb()
#          (cb) ->
#            debug "copy resources..."
#            cb()
#        ], cb

processFile = (file, cb) ->
  async.waterfall [
    (cb) -> # get file
      debug "analyze #{file}"
      fs.readFile file, (err, buffer) ->
        return cb err if err
        isBinaryFile buffer, buffer.length, (err, binary) ->
          return cb() if err or binary
          cb null, buffer.toString 'utf8'
    (contents, cb) -> # analyze language
      cb null, contents, language file, contents
    (contents, lang, cb) -> # analyze language
      console.log file, lang, contents.length, 'bytes'
      cb()
  ], cb
