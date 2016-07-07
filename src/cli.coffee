# Startup script
# =================================================


# Node Modules
# -------------------------------------------------

# include base modules
yargs = require 'yargs'
chalk = require 'chalk'
path = require 'path'
# include alinex modules
fs = require 'alinex-fs'
alinex = require 'alinex-core'
util = require 'alinex-util'
# include classes and helpers
builder = require './index'

process.title = 'Builder'
logo = alinex.logo 'Development Builder'


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


# Command Setup
# -------------------------------------------------
command = (name, file) ->
  try
    lib = require file
  catch error
    alinex.exit 1, error if error
  # return builder and handler
  builder: (yargs) ->
    yargs
    .usage "\nUsage: $0 #{name} [options] [dir]...\n\n#{lib.description ? ''}"
    # add options
    if lib.options
      yargs.option key, def for key, def of lib.options
      yargs.group Object.keys(lib.options), "#{util.string.ucFirst name} Command Options:"
    # help
    yargs.strict()
    .help 'h'
    .alias 'h', 'help'
    .epilogue """
      This is the description of the '#{name}' command. You may also look into the
      general help or the man page.
      """
  handler: (args) ->
    # implement some global switches
    chalk.enabled = false if args.nocolors
    # run command
    builder.command name, lib, args, (err) ->
      alinex.exit err if err
      alinex.exit 0
    return true


# Main routine
# -------------------------------------------------
unless quiet
  console.log logo
  console.log chalk.grey "Initializing..."

builder.setup (err) ->
  alinex.exit 16, err if err
  # Start argument parsing
  yargs
  .usage "\nUsage: $0 <command> [options] [dir]..."
  .env 'BUILDER' # use environment arguments prefixed with SCRIPTER_
  # examples
  .example '$0 test -vb', 'to run the tests till first failure'
  .example '$0 test -v --coverage --browser', 'to run all the tests and also show coverage info'
  .example '$0 changes', 'show overview of changes'
  .example '$0 publish --minor', 'to publish on npm new minor version'
  # general options
  .options
    help:
      alias: 'h',
      description: 'display help message'
    nocolors:
      alias: 'C'
      describe: 'turn of color output'
      type: 'boolean'
      global: true
    verbose:
      alias: 'v'
      describe: 'run in verbose mode (multiple makes more verbose)'
      count: true
      global: true
    quiet:
      alias: 'q'
      describe: "don't output header and footer"
      type: 'boolean'
      global: true
  # add the commands
  list = fs.findSync __dirname + '/command',
    type: 'f'
  for file in list
    continue unless file.match /\.(coffee|js)$/
    name = path.basename file, path.extname file
    lib = require file
    yargs.command name, lib.title, command name, file
  # help
  yargs.help 'help'
  .updateStrings
    'Options:': 'General Options:'
  .epilogue """
    You may use environment variables prefixed with 'BUILDER_' to set any of
    the options like 'BUILDER_VERBOSE' to set the verbose level.

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
  # check for corrct call
  unless argv._.length
    alinex.exit 2, new Error "Nothing to do specify --help for available options"
