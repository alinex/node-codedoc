# Startup script
# =================================================


# Node Modules
# -------------------------------------------------
path = require 'path'


shebangRegex = ///
  ^                     # start of contents
  \#!                   # this have to be the first two bytes
  \s*(?:/usr/bin/env)?  # the call to search executable in path
  \s*(?:[^\n]*/)*       # any path before the executable
  ([^/\n]+)             # the executable
  (?:\n|$)              # end of line
  ///


# Detection
# -------------------------------------------------
# Provides language-specific params for a given file name.
#
# @param {string} filename The name of the file to test
# @param {string} contents The contents of the file (to check for shebang)
# @return {object} Object containing all of the language-specific params
module.exports = (file, contents) ->
  # First try to detect the language from the file extension
  ext = path.extname(file)[1..]
  return languages.cpp if ext is 'C' # hacky of incorporating .C for C++
  ext = ext.toLowerCase()
  base = path.basename(file).toLowerCase()
  # search for match
  for _, l of languages
    return l if l.extensions? and ext in l.extensions
    return l if l.names? and base in l.names
  # If that doesn't work, see if we can grab a shebang
  match = shebangRegex.exec(contents)
  if match
    for _, l of languages
      return l if l.executables? and match[1] in l.executables
  # If we still can't figure it out, give up and return null.
  null


# Language definition
# -------------------------------------------------

C_DOC =
  ///
    \s*         # with optional spaces
    /\*{2,}     # start with slash and at least two asterisk
    (           # content of the comment
      [\s\S]*?  # comment charactes
    )           # end of comment
    \*+/        # at least one asterisk and slash
    \s*         # with optional spaces
  ///g
HASH_DOC =
  ///           # ###\n ... \n###
    (?:^|\n)    # start of document or line
    \s*         # with optional spaces
    \#{3}       # then three hashes: ###
    (           # content of the comment
      [^\#]     # no more than the three hashes
      .*        # everything in that line
      \n\s*\#   # each following line start with an hash
      \s?.*     # and all in that line
    )           # end of comment
    \n          # end the match
  ///g


# # Languages
#
# All the languages Docker can parse are in here.
# A language can have the following properties:
#
# * `extensions`: All possible file extensions for the language
# * `executables`: Executables for the language that might be in a shebang
# * `comment`: Delimiter for single-line comments
# * `multiLine`: Start and end delimiters for multi-line comments
# * `commentsIgnore`: Regex for comments that shouldn't be interpreted as descriptive
# * `jsDoc`: whether to try and extract jsDoc-style comment data
# * `literals`: Quoted strings are ignored when looking for comment delimiters.
#   Any extra literals go here
# * `highlightLanguage`: override for language to use with highlight.js
languages =
  coffeescript:
    extensions: [ 'coffee' ]
    names: [ 'cakefile' ]
    executables: [ 'coffee' ]
    doc: [
      ///           # ###\n ... \n###
        (?:^|\n)    # start of document or line
        \s*         # with optional spaces
        \#{3}       # then three hashes: ###
        (           # content of the comment
          [^\#]     # no more than the three hashes
          [\s\S]*?  # other comment charactes
        )           # end of comment
        \#{3,}      # then three or more hashes
        [ \t]*?\n   # only spaces till end of line
      ///g
    ]
  javascript:
    extensions: [ 'js' ]
    executables: [ 'node' ]#
    doc: [ C_DOC ]
  livescript:
    extensions: [ 'ls' ]
    executables: [ 'lsc' ]
    doc: [ C_DOC ]
  ruby:
    extensions: [ 'rb', 'rbw', 'rake', 'gemspec' ]
    executables: [ 'ruby' ]
    names: [ 'rakefile' ]
    doc: [
      ///
        \s*\n       # with optional spaces
        =begin      # start the line with '=begin'
        \s*\n       # and no more in this line
        (           # content of the comment
          [\s\S]*?  # comment charactes
        )           # end of comment
        \s*\n       # start a new line
        =end        # with '=end' at the start
        \s*\n       # with no more in this line
      ///g
    ]
  python:
    extensions: [ 'py' ]
    executables: [ 'python' ]
    doc: [ HASH_DOC ]
  perl:
    extensions: [ 'pl', 'pm' ]
    executables: [ 'perl' ]
    doc: [
      ///
        \s*\n       # with optional spaces
        =           # start the line with any allowed pod command
          (pod|head[1-4]|over|item|back|begin|end|for|encoding)
        \s*\n       # and no more in this line
        (           # content of the comment
          [\s\S]*?  # comment charactes
        )           # end of comment
        \s*\n       # start a new line
        =cut        # with '=cut' at the start
        \s*\n       # with no more in this line
      ///g
    ]
  c:
    extensions: [ 'c', 'h' ]
    executables: [ 'gcc' ]
    doc: [ C_DOC ]
  cpp:
    extensions: [ 'cc', 'cpp' ]
    executables: [ 'g++' ]
    doc: [ C_DOC ]
  cs:
    extensions: [ 'cs' ]
    comment: '//'
    doc: [ C_DOC ]
  java:
    extensions: [ 'java' ]
    doc: [ C_DOC ]
  jsp:
    extensions: [ 'jsp' ]
    doc: [ C_DOC ]
  php:
    extensions: [ 'php', 'phtml', 'php3', 'php4', 'php5', 'php7' ]
    executables: [ 'php' ]
    doc: [ C_DOC ]
  bash:
    extensions: [ 'sh', 'kst', 'bash' ]
    names: [ '.bashrc', 'bashrc']
    executables: [ 'bash', 'sh', 'zsh' ]
    doc: [ HASH_DOC ]
  yaml:
    extensions: [ 'yaml', 'yml' ]
    doc: [ HASH_DOC ]
  markdown:
    extensions: [ 'md', 'mkd', 'markdown' ]
    type: 'markdown'
  scss:
    extensions: [ 'scss' ]
    comment: '//'
    doc: [ C_DOC ]
  makefile:
    names: [ 'makefile' ]
    doc: [ HASH_DOC ]
  apache:
    names: [ '.htaccess', 'apache.conf', 'apache2.conf' ]
    doc: [ HASH_DOC ]
  handlebars:
    extensions: [ 'hbs', 'handlebars' ]
  groovy:
    extensions: [ 'groovy' ]
    doc: [ C_DOC ]
  stylus:
    extensions: [ 'styl' ]
    doc: [ C_DOC ]
  css:
    extensions: [ 'css' ]
    doc: [ C_DOC ]
  less:
    extensions: [ 'less' ]
    doc: [ C_DOC ]
  html:
    extensions: [ 'html', 'htm' ]
  json:
    extensions: [ 'json' ]
    names: [ '.eslintrc', '.jshintrc' ]

# also add the language name within the definition
l.name = name for name, l of languages
