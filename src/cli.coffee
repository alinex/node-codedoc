# Startup script
# =================================================


# Node Modules
# -------------------------------------------------

# include base modules
yargs = require 'yargs'
chalk = require 'chalk'
async = require 'async'
# include alinex modules
fs = require 'alinex-fs'
alinex = require 'alinex-core'
# include classes and helpers
codedoc = require './index'

process.title = 'CodeDoc'
logo = alinex.logo 'Code Documentation Extractor'


# Support quiet mode through switch
# -------------------------------------------------
quiet = false
for a in ['--get-yargs-completions', 'bashrc', '-q', '--quiet']
  quiet = true if a in process.argv


# Error management
# -------------------------------------------------
alinex.initExit()
process.on 'exit', ->
  console.log "Goodbye\n" unless quiet


# Support quiet mode through switch
# -------------------------------------------------
quiet = false
for a in ['--get-yargs-completions', 'bashrc', '-q', '--quiet']
  quiet = true if a in process.argv


# Main routine
# -------------------------------------------------
unless quiet
  console.log logo
  console.log chalk.grey "Initializing..."

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
.group ['i', 'o', 's'], 'Document Options:'
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


# Helper Methods
# -----------------------------------------------------------

readExcludes = (dir, cb) ->
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
        e.replace /^\//, ''
        .replace /\./, '\\.'
        .replace /\*+/, '.*'
      cb null, new RegExp "^(#{list.join '|'})"


# Main routine
# -----------------------------------------------------------

argv.input ?= '.'
readExcludes argv.input, (err, list) ->
  alinex.exit err if err
  codedoc.run
    input: argv.input
    find:
      exclude: list
    output: argv.output
    style: argv.style
  , (err) ->
    console.log '========'
    alinex.exit err
