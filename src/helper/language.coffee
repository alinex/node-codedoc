# Language Definition
# =================================================
# Code and definition for language recognition. This includes the file detection as
# well as the language agnostic auto detection.


# Node Modules
# -------------------------------------------------
path = require 'path'


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
  match = SHEBANG.exec contents
  if match
    for _, l of languages
      return l if l.executables? and match[1] in l.executables
  # If we still can't figure it out, give up and return null.
  null


# General Definitions
# -------------------------------------------------

# Use with match to get the executable name out of shebang syntax.
#
# __Example:__ `#!/usr/bin env node`
# - $1 - will be the executable: 'node'
SHEBANG =
  ///
    ^                     # start of contents
    \#!                   # this have to be the first two bytes
    \s*(?:/usr/bin/env)?  # the call to search executable in path
    \s*(?:[^\n]*/)*       # any path before the executable
    ([^/\n]+)             # the executable
    (?:\n|$)              # end of line
  ///

# Use the RegExp from list element #0 to get all code documents and the optimization
# method (list element #1) afterwards
#
# __Example:__ `/** ... */`
# - `$1` - the unoptimized content
# - optimized - leading asterisk removed
C_DOC = [
  ///
    \s*         # with optional spaces
    /\*{2,}     # start with slash and at least two asterisk
    (           # content of the comment
    [\s\S]*?    # comment charactes
    )           # end of comment
    \*+/        # at least one asterisk and slash
    \s*         # with optional spaces
  ///g
  (txt) ->      # remove optional starting asterisk
    txt.replace /\n[\t\r ]*\*[\t\r ]?/g, '\n'
]

# Use the RegExp from list element #0 to get all code documents and the optimization
# method (list element #1) afterwards
#
# __Example:__ `/* ... */`
# - `$1` - the unoptimized content
# - optimized - leading asterisk removed
C_API = [
  ///
    \s*         # with optional spaces
    /\*         # start with slash and a single asterisk
    (           # content of the comment
      ([^*]       # no asterisk
      |[\r\n]     # or newline
      |(          # or
        \*+(        # asterisk
          [^/]      # but not comment end
          |[\r\n]   # or return
      )))*        # and that all multiple times
      \n          # at least two lines
      ([^*]|[\r\n]|(\*+([^/]|[\r\n])))* # same as above
    )           # end of comment
    \*+/        # at least one asterisk and slash
    \s*         # with optional spaces
  ///g
  (txt) ->      # remove optional starting asterisk
    txt.replace /\n[\t\r ]*\*[\t\r ]?/g, '\n'
]

# Use the RegExp from list element #0 to get all code documents and the optimization
# method (list element #1) afterwards
#
# __Example:__ `###\n ... ###`
# - `$1` - the unoptimized content
# - optimized - leading asterisk removed
COFFEE_DOC = [
  ///           # ###\n ... \n###
    (?:^|\n)    # start of document or line
    \s*         # with optional spaces
    \#{3}       # then three hashes: ###
    (           # content of the comment
      [^\#!]    # no more than the three hashes
      .*        # everything in that line
      \n        # at least two lines
      [\s\S]*?  # other comment charactes
    )           # end of comment
    \#{3,}      # then three or more hashes
    [\t\r\ ]*?\n # only spaces till end of line
  ///g
]

# Use the RegExp from list element #0 to get all code documents and the optimization
# method (list element #1) afterwards
#
# __Example:__ `### ...` + `# ... lines`
# - `$1` - the unoptimized content
# - optimized - leading asterisk removed
HASH_DOC = [
  ///           # ###\n ... \n###
    (?:^|\n)    # start of document or line
    \s*         # with optional spaces
    \#{3}       # then three hashes: ###
    (           # content of the comment
      [^\#!]    # no more than the three hashes
      .*        # everything in that line
      (?:       # multiple lines
        \n[\t\r\ ]*\# # each following line start with an hash
        [\t\r\ ]?.*   # and all in that line
      )+        # at least two lines
    )           # end of comment
    \n          # end the match
  ///g
  (txt) ->      # remove optional starting asterisk
    txt.replace /\n[\t\r ]*\#[\t\r ]?/g, '\n'
]

# Use the RegExp from list element #0 to get all code documents and the optimization
# method (list element #1) afterwards
#
# __Example:__ `# ... lines`
# - `$1` - the unoptimized content
# - optimized - leading asterisk removed
HASH_API = [
  ///           # #\n ... \n#
    (?:^|\n)    # start of document or line
    \s*         # with optional spaces
    \#\s?       # then three hashes: ###
    (           # content of the comment
      [^\#!]    # no more than the three hashes
      .*        # everything in that line
      (?:       # multiple lines
        \n[\t\r\ ]*\# # each following line start with an hash
        [\t\r\ ]?.*   # and all in that line
      )+        # at least two lines
    )           # end of comment
    \n          # end the match
  ///g
  (txt) ->      # remove optional starting asterisk
    txt.replace /\n[\t\r ]*\#[\t\r ]?/g, '\n'
]

# Use the RegExp from list element #0 to get all code documents and the optimization
# method (list element #1) afterwards
#
# __Example:__ `\n=begin\n ... \n=end\n`
# - `$1` - the unoptimized content
# - optimized - leading asterisk removed
RB_DOC = [
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

# Use the RegExp from list element #0 to get all code documents and the optimization
# method (list element #1) afterwards
#
# __Example:__ `\n=pod\n ... \n=cut\n`
# - `$1` - the unoptimized content
# - optimized - leading asterisk removed
PL_DOC = [
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


# Language Definitions
# -------------------------------------------------
# All the languages which are parseable are in here.
# A language can have the following properties:
#
# - `extensions` - all possible file extensions for the language
# - `executables` - executables for the language that might be in a shebang
# - `doc` - document comment parsers as list of RegExp and optimization function
# - `api` - internal api documentation parser as list of RegExp and optimization function
# - `tab` - number of spaces to use for tab indenting (default 2)
# - `tags`: whether to try and extract jsDoc/javaDoc-style tag elements
#   - `title` - function to extract the function/class name from first code line
#   - `access` - function to detect access level from first code line
languages =
  coffeescript:
    extensions: [ 'coffee' ]
    names: [ 'cakefile' ]
    executables: [ 'coffee' ]
    doc: COFFEE_DOC
    api: HASH_API
    tags:
      title: (c) ->
        # function call
        return "#{m[1]}()" if m = c.match /^\s*(?:module\.)?(?:exports\.)?(\S+)\s*[=:].*?[-=]>.*/
        # function call
        return "#{m[1]}()" if m = c.match /^\s*(?:module\.)?(?:exports\.)?(\S+)\s*[=:]\s*\(/
        # variable setting
        return m[1] if m = c.match /^\s*(?:module.)?(?:exports.)?(\S+)\s*[=:]/
        return "Class #{m[1]}" if m = c.match /^\s*Class\s*(\S+)/ # class definition
        null
      access: (c) ->
        return 'public' if c.match /^\s*(module\.)?exports([. \t=])/
        null
      linksearch: 'nodejs javascript'
  javascript:
    extensions: [ 'js', 'es6' ]
    executables: [ 'node' ]#
    doc: C_DOC
    api: C_API
  livescript:
    extensions: [ 'ls' ]
    executables: [ 'lsc' ]
    doc: C_DOC
    api: C_API
  ruby:
    extensions: [ 'rb', 'rbw', 'rake', 'gemspec' ]
    executables: [ 'ruby' ]
    names: [ 'rakefile' ]
    doc: RB_DOC
    api: HASH_API
  python:
    extensions: [ 'py' ]
    executables: [ 'python' ]
    doc: HASH_DOC
    api: HASH_API
  perl:
    extensions: [ 'pl', 'pm' ]
    executables: [ 'perl' ]
    doc: PL_DOC
    api: HASH_API
  c:
    extensions: [ 'c', 'h' ]
    executables: [ 'gcc' ]
    doc: C_DOC
    api: C_API
  cpp:
    extensions: [ 'cc', 'cpp' ]
    executables: [ 'g++' ]
    doc: C_DOC
    api: C_API
  cs:
    extensions: [ 'cs' ]
    comment: '//'
    doc: C_DOC
    api: C_API
  java:
    extensions: [ 'java' ]
    doc: C_DOC
    api: C_API
  jsp:
    extensions: [ 'jsp' ]
    doc: C_DOC
    api: C_API
  php:
    extensions: [ 'php', 'phtml', 'php3', 'php4', 'php5', 'php7' ]
    executables: [ 'php' ]
    doc: C_DOC
    api: C_API
  bash:
    extensions: [ 'sh', 'kst', 'bash' ]
    names: [ '.bashrc', 'bashrc']
    executables: [ 'bash', 'sh', 'zsh' ]
    doc: HASH_DOC
    api: HASH_API
  yaml:
    extensions: [ 'yaml', 'yml' ]
    doc: HASH_DOC
    api: HASH_API
  markdown:
    extensions: [ 'md', 'mkd', 'markdown' ]
    type: 'markdown'
  scss:
    extensions: [ 'scss' ]
    comment: '//'
    doc: C_DOC
    api: C_API
  makefile:
    names: [ 'makefile' ]
    doc: HASH_DOC
    api: HASH_API
  apache:
    names: [ '.htaccess', 'apache.conf', 'apache2.conf' ]
    doc: HASH_DOC
    api: HASH_API
    tab: 8
  handlebars:
    extensions: [ 'hbs', 'handlebars' ]
  groovy:
    extensions: [ 'groovy' ]
    doc: C_DOC
    api: C_API
  stylus:
    extensions: [ 'styl' ]
    doc: C_DOC
    api: C_API
  css:
    extensions: [ 'css' ]
    doc: C_DOC
    api: C_API
  less:
    extensions: [ 'less' ]
    doc: C_DOC
    api: C_API
  html:
    extensions: [ 'html', 'htm' ]
  json:
    extensions: [ 'json' ]
    names: [ '.eslintrc', '.jshintrc' ]


# also add the language name within the definition
l.name = name for name, l of languages
