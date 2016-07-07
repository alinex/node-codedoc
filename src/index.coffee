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


# Initialize
# -------------------------------------------------
exports.run = (setup, cb) ->
  setup.dir = path.resolve setup.dir ? '.'
  setup.find.source = path.resolve setup.find.source ? '.'
  setup.find.options ?= {}
  setup.find.options.type = 'file'
  console.log "Output to #{setup.dir}..."
  fs.mkdirs setup.dir, (err) ->
    return cb err if err
    # start
    console.log "Analyze #{setup.find.source}..."
    debug "search files in #{setup.find.source}"
    console.log setup
    fs.find setup.find.source, setup.find.options, (err, list) ->
      return cb err if err
      list.shift() # fix because root dir is first
      async.mapLimit list, 10, processFile, (err, res) ->
        return cb err if err
        map = {}
        for i in [0..list.length-1]
          map[list[i]] =
            dir: path.dirname(list[i])[setup.find.source.length+1..]
            content: res[i]
        console.log "Write into #{setup.dir}..."
#        console.log map
        async.parallel [
          (cb) ->
            debug "write pages..."
            cb()
          (cb) ->
            debug "copy resources..."
            cb()
        ], cb

processFile = (file, cb) ->
  debug "analyze #{file}"
  fs.readFile file, (err, buffer) ->
    return cb err if err
    isBinaryFile buffer, buffer.length, (err, binary) ->
      return cb() if err or binary
      cb null, buffer.toString 'utf8'
