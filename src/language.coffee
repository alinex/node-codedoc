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
# * `literals`: Quoted strings are ignored when looking for comment delimiters. Any extra literals go here
# * `highlightLanguage`: override for language to use with highlight.js
languages =
  javascript:
    extensions: [ 'js' ]
    executables: [ 'node' ]
    comment: '//'
    multiLine: [
      /\/\*\*?/
      /\*\//
    ]
    commentsIgnore: /^\s*\/\/=/
    jsDoc: true
    literals: [ [
      /\/(?![\*\/])((?:[^\\\/]|(?:\\\\)*?\\[^\\])*?)\//g
      '/./'
    ] ]
  coffeescript:
    extensions: [ 'coffee' ]
    names: [ 'cakefile' ]
    executables: [ 'coffee' ]
    comment: '#'
    multiLine: [
      /^\s*#{3}\s*$/m
      /^\s*#{3}\s*$/m
    ]
    jsDoc: true
    literals: [ [
      /\/(?![\*\/])((?:[^\\\/]|(?:\\\\)*?\\[^\\])*?)\//g
      '/./'
    ] ]
  livescript:
    extensions: [ 'ls' ]
    executables: [ 'lsc' ]
    comment: '#'
    multiLine: [
      /\/\*\*?/
      /\*\//
    ]
    jsDoc: true
  ruby:
    extensions: [
      'rb'
      'rbw'
      'rake'
      'gemspec'
    ]
    executables: [ 'ruby' ]
    names: [ 'rakefile' ]
    comment: '#'
    multiLine: [
      /\=begin/
      /\=end/
    ]
  python:
    extensions: [ 'py' ]
    executables: [ 'python' ]
    comment: '#'
  perl:
    extensions: [
      'pl'
      'pm'
    ]
    executables: [ 'perl' ]
    comment: '#'
  c:
    extensions: [
      'c'
      'h'
    ]
    executables: [ 'gcc' ]
    comment: '//'
    multiLine: [
      /\/\*\*?/
      /\*\//
    ]
    jsDoc: true
  cpp:
    extensions: [
      'cc'
      'cpp'
    ]
    executables: [ 'g++' ]
    comment: '//'
    multiLine: [
      /\/\*\*?/
      /\*\//
    ]
    jsDoc: true
  vbnet:
    extensions: [
      'vb'
      'vbs'
      'bas'
    ]
    comment: '\''
  'aspx-vb':
    extensions: [
      'asp'
      'aspx'
      'asax'
      'ascx'
      'ashx'
      'asmx'
      'axd'
    ]
    comment: '\''
  csharp:
    extensions: [ 'cs' ]
    comment: '//'
    multiLine: [
      /\/\*\*?/
      /\*\//
    ]
    jsDoc: true
  'aspx-cs':
    extensions: [
      'aspx'
      'asax'
      'ascx'
      'ashx'
      'asmx'
      'axd'
    ]
    comment: '//'
    multiLine: [
      /\/\*\*?/
      /\*\//
    ]
    jsDoc: true
  java:
    extensions: [ 'java' ]
    comment: '//'
    multiLine: [
      /\/\*\*?/
      /\*\//
    ]
    jsDoc: true
  php:
    extensions: [
      'php'
      'php3'
      'php4'
      'php5'
    ]
    executables: [ 'php' ]
    comment: '//'
    multiLine: [
      /\/\*\*?/
      /\*\//
    ]
    jsDoc: true
  actionscript:
    extensions: [ 'as' ]
    comment: '//'
    multiLine: [
      /\/\*/
      /\*\//
    ]
  sh:
    extensions: [
      'sh'
      'kst'
      'bash'
    ]
    names: [
      '.bashrc'
      'bashrc'
    ]
    executables: [
      'bash'
      'sh'
      'zsh'
    ]
    comment: '#'
  yaml:
     extensions: [ 'yaml', 'yml' ]
     comment: '#'
  markdown:
    extensions: [
      'md'
      'mkd'
      'markdown'
    ]
    type: 'markdown'
  # not supported by highlight.js
  sass:
    extensions: [ 'sass' ]
    comment: '//'
    multiLine: [
      /\/\*/
      /\*\//
    ]
  scss:
    extensions: [ 'scss' ]
    comment: '//'
    multiLine: [
      /\/\*\*?/
      /\*\//
    ]
    jsDoc: true
  makefile:
    names: [ 'makefile' ]
    comment: '#'
  apache:
    names: [
      '.htaccess'
      'apache.conf'
      'apache2.conf'
    ]
    comment: '#'
  jade:
    extensions: [ 'jade' ]
    comment: '//-?'
    multiLine: [
      /\/\*\*?/
      /\*\//
    ]
    jsDoc: true
  groovy:
    extensions: [ 'groovy' ]
    comment: '//'
    multiLine: [
      /\/\*\*?/
      /\*\//
    ]
    jsDoc: true
  gsp:
    extensions: [ 'gsp' ]
    multiLine: [
      /<%--/
      /--%>/
    ]
    highlightLanguage: 'html'
  stylus:
    extensions: [ 'styl' ]
    comment: '//'
    multiLine: [
      /\/\*/
      /\*\//
    ]
  css:
    extensions: [ 'css' ]
    multiLine: [
      /\/\*/
      /\*\//
    ]
    commentStart: '/*'
    commentEnd: '*/'
  less:
    extensions: [ 'less' ]
    comment: '//'
    multiLine: [
      /\/\*/
      /\*\//
    ]
  html:
    extensions: [
      'html'
      'htm'
    ]
    multiLine: [
      /<!--/
      /-->/
    ]
    commentStart: '<!--'
    commentEnd: '-->'
  json:
    extensions: [ 'json' ]
    names: [
      '.eslintrc'
      '.jshintrc'
    ]
    comment: '//'
    multiLine: [
      /\/\*\*?/
      /\*\//
    ]
# also add the language name within the definition
l.name = name for name, l of languages
