# CLI Parser
# =================================================
# This is used only for command line calls to get the parameters and invoke the
# codedoc generation process.


# Node Modules
# -------------------------------------------------
yargs = require 'yargs'
chalk = require 'chalk'
async = require 'async'
path = require 'path'
# include alinex modules
fs = require 'alinex-fs'
alinex = require 'alinex-core'
config = require 'alinex-config'
Report = require 'alinex-report'
# include classes and helpers
codedoc = require './index'

SegfaultHandler = require 'segfault-handler'
SegfaultHandler.registerHandler "crash.log"

# Setup
# -------------------------------------------------
# Set the logo for command line output.
logo = alinex.logo 'Code Documentation Extractor'


# Support Quiet Mode
# -------------------------------------------------
# Detect quiet mode before the real initialization starts, to support it just from
# the beginning. It should run in quiet mode for command completion or if specified so.
quiet = false
for a in ['--get-yargs-completions', 'bashrc', '-q', '--quiet']
  quiet = true if a in process.argv


# Error Management
# -------------------------------------------------
# Initialize default error and signal handling and also add a method for an exit
# message.
alinex.initExit()
process.on 'exit', ->
  console.log "Goodbye\n" unless quiet


# Helper Methods
# -----------------------------------------------------------

# Read and interpret the exclude list from `.docignore` or `.gitignore` file.
#
# @param {string} dir directory to search for ignore files
# @param {function(err)} cb callback if done or failed
readExcludes = (dir, cb) ->
  dir = path.resolve dir
  async.detectSeries ["#{dir}/.docignore", "#{dir}/.gitignore"], (file, cb) ->
    fs.exists file, (exists) -> cb null, exists
  , (err, file) ->
    return cb() unless file
    fs.readFile file, 'utf8', (err, res) ->
      if err
        console.error chalk.magenta "Could not read #{file} for excludes"
        return cb()
      list = ".git/\n#{res}".split /\s*\n\s*/
      .filter (e) -> e.trim().length
      .map (e) ->
        e.replace /^\//, "^"
        .replace /\./, '\\.'
        .replace /\*+/, '.*'
      cb null, new RegExp list.join '|'

readResources = (dir, cb) ->
  dir = path.resolve dir
  file = "#{dir}/.docresource"
  fs.exists file, (exists) ->
    return cb() unless exists
    fs.readFile file, 'utf8', (err, res) ->
      if err
        console.error chalk.magenta "Could not read #{file} for resources"
        return cb()
      list = res.split /\s*\n\s*/
      .filter (e) -> e.trim().length
      .map (e) ->
        e.replace /^\//, "^"
        .replace /\./, '\\.'
        .replace /\*+/, '.*'
      cb null, new RegExp list.join '|'

# Main routine
# -------------------------------------------------
unless quiet
  console.log logo
  console.log chalk.grey "Initializing..."

# Try to setup codedoc system and parse the command line options through the following
# yargs configuration:
codedoc.setup (err) ->
  alinex.exit 16, err if err
  # Start argument parsing
  yargs
  .usage "\nUsage: $0 [options]"
  .env 'CODEDOC' # use environment arguments prefixed with SCRIPTER_
  # examples
  .example '$0', 'to create the default documentation'
  # general options
  .options
    help:
      alias: 'h',
      description: 'display help message'
    nocolors:
      alias: 'C'
      description: 'turn of color output'
      type: 'boolean'
      global: true
    verbose:
      alias: 'v'
      description: 'run in verbose mode (multiple makes more verbose)'
      count: true
      global: true
    quiet:
      alias: 'q'
      description: "don't output header and footer"
      type: 'boolean'
      global: true
    parallel:
      alias: 'p'
      description: "max parallel runs"
      type: 'number'
      global: true
    # add specific args
    input:
      alias: 'i'
      description: "directory to analyse code"
      type: 'string'
    output:
      alias: 'o'
      description: "directory to write html site to"
      type: 'string'
      default: './doc'
    style:
      alias: 's'
      description: "set layout style to use"
      type: 'string'
    code:
      alias: 'c'
      description: "add highlighted code"
      type: 'boolean'
  .group ['i', 'o', 's', 'c'], 'Document Options:'
  # help
  yargs.help 'help'
  .updateStrings
    'Options:': 'General Options:'
  .epilogue """
    You may use environment variables prefixed with 'CODEDOC_' to set any of
    the options like 'CODEDOC_VERBOSE' to set the verbose level.

    For more information, look into the man page.
    """
  .completion 'bashrc-script', false
  # validation
  .strict()
  .fail (err) ->
    err = new Error "CLI #{err}"
    err.description = 'Specify --help for available options'
    alinex.exit 2, err
  # now parse the arguments
  argv = yargs.argv

  # ### Start processing
  #
  # Call codedoc {@link run} to do it's work.
  argv.input ?= '.'
  readExcludes argv.input, (err, list) ->
    alinex.exit err if err
    readResources argv.input, (err, res) ->
      config.init (err) ->
        alinex.exit err if err
        Report.init (err) ->
          alinex.exit err if err
          console.log "Output to #{argv.output}..."
          codedoc.run
            input: argv.input
            find:
              exclude: list
            resources:
              include: res
            output: argv.output
            style: argv.style
            code: argv.code
            parallel: argv.parallel
            verbose: argv.verbose
          , (err) ->
            console.log 'Everything done.'
            alinex.exit err
