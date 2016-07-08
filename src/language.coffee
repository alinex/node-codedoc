# Startup script
# =================================================


# Node Modules
# -------------------------------------------------


# Detection
# -------------------------------------------------
# Provides language-specific params for a given file name.
#
# @param {string} filename The name of the file to test
# @param {string} contents The contents of the file (to check for shebang)
# @return {object} Object containing all of the language-specific params
module.exports = (file, contents) ->
  return '???'
  # First try to detect the language from the file extension
  ext = path.extname(filename)
  ext = ext.replace(/^\./, '')
  # Bit of a hacky way of incorporating .C for C++
  if ext == '.C'
    return languages.cpp
  ext = ext.toLowerCase()
  base = path.basename(filename)
  base = base.toLowerCase()
  for i of languages
    if !languages.hasOwnProperty(i)
      continue
    if languages[i].extensions and languages[i].extensions.indexOf(ext) != -1
      return languages[i]
    if languages[i].names and languages[i].names.indexOf(base) != -1
      return languages[i]
  # If that doesn't work, see if we can grab a shebang
  shebangRegex = /^\n*#!\s*(?:\/usr\/bin\/env)?\s*(?:[^\n]*\/)*([^\/\n]+)(?:\n|$)/
  match = shebangRegex.exec(contents)
  if match
    for j of languages
      if !languages.hasOwnProperty(j)
        continue
      if languages[j].executables and languages[j].executables.indexOf(match[1]) != -1
        return languages[j]
  # If we still can't figure it out, give up and return false.
  false


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
langs =
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
  markdown:
    extensions: [
      'md'
      'mkd'
      'markdown'
    ]
    type: 'markdown'
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
Object.keys(langs).forEach (l) ->
  langs[l].language = l
  return
