# Parser
# ================================================
# Methods used to get the documentation out of the files and formatted as Markdown.
# This will
# - read the file's content
# - extract the document parts
# - some autodetection from code
# - add code as highlight text (in internal view)
# - interpret @tags
# - create a complete report per file


# Node modules
# ------------------------------------------------
debug = require('debug') 'codedoc:parse'
chalk = require 'chalk'
async = require 'async'
path = require 'path'
isBinaryFile = require 'isbinaryfile'
uslug = require 'uslug'
# include alinex modules
util = require 'alinex-util'
fs = require 'alinex-fs'
Report = require 'alinex-report'
# internal methods
language = require './language'


# Setup
# ------------------------------------------------

# #3 Alternative Tag Names
#
# These are aliases for other tags, implemented below.
tagAlias =
  alias: 'name'
  arg: 'param'
  argument: 'param'
  returns: 'return'
  throw: 'throws'
  exception: 'throws'
  fires: 'event'
  constructor: 'construct'
  describe: 'description'


# External Methods
# ================================================

# Parse a single file and get it's documentation as report back.
#
# @param {String} file absolute path of file to analyze
# @param {String} local local path, absolute from input directory
# @param {Object} setup setup configuration from {@link run} method
# @param {Object<Array>} symbol map to fill with code symbols as `[file, anchor]` to
# resolve links later
# @param {function(<Error>, <Report>)} cb callback which is called with error or `Report` instance
exports.file = (file, local, setup, symbols, cb) ->
  async.waterfall [
    # get file
    (cb) ->
      (if setup.verbose > 1 then console.log else debug) "analyze #{file}"
      fs.readFile file, (err, buffer) ->
        return cb err if err
        isBinaryFile buffer, buffer.length, (err, binary) ->
          return cb err ? 'BINARY' if err or binary
          cb null, buffer.toString 'utf8'
    # analyze language
    (content, cb) ->
      lang = language file, content
      unless lang
        (if setup.verbose then console.log else debug) \
          chalk.magenta "could not detect language of #{file}"
        return cb 'UNKNOWN'
      (if setup.verbose > 2 then console.log else debug) \
        chalk.grey "#{file}: detected as #{lang.name}"
      cb null, content, lang
    # create report
    (content, lang, cb) ->
      report = new Report()
      if lang.name is 'markdown'
        report.raw content
      else
        # extract docs
        try
          docs = extractDocs file, content, setup, lang, symbols
        catch error
          debug chalk.magenta "Could not parse documentation at #{file}: \
          #{chalk.grey error.message + error.stack}"
          return cb new Error "Could not parse documentation at #{file}: \
          #{chalk.grey error.message}"
        # create report for undocumented code
        unless docs.length
          return cb 'CODE_DISABLED' unless setup.code
          report.h1 "File: #{path.basename local}"
          report.quote "Path: #{local}"
          report.code stripIndent(content, lang.tab), lang.name
          report.p Report.style 'code: style="max-height:none"'
          return cb null, report, lang
        # create report out of docs
        pos = 0
        for doc in docs
          if pos < doc[0] and setup.code
            # code block before doc
            report.code stripIndent(content[pos..doc[0]], lang.tab), lang.name
            if pos # set correct line number
              line = content[0..pos].split('\n').length - 1
              report.p Report.style "code: style=\"counter-reset:line #{line}\""
          # add doc block
          md = doc[2].replace /\n\s*?$/, ''
          report.raw "\n#{md}\n\n"
          pos = doc[1]
        if pos < content.length and setup.code
          # last code block
          report.code stripIndent(content[pos..], lang.tab), lang.name
          if pos # set correct line number
            line = content[0..pos].split('\n').length - 1
            report.p Report.style "code: style=\"counter-reset:line #{line}\""
        # optimize report by adding path with compiled path
        source = "`#{local}`"
        if match = local.match /^\/src(\/.*)\.coffee$/
          source += " compiled to `/lib#{match[1]}.js`"
        report.body = report.body.replace /(\n\s*={10,}\s*\n)/, "$1\n> Path: #{source}\n\n"
      cb null, report, lang
    # remove internal
    (report, lang, cb) ->
      report.body = unless setup.code
        report.body
        .replace /<!--\s*internal\s*-->[\s\S]*?<!--\s*end internal\s*-->/ig, ''
        .replace /<!--\s*internal\s*-->[\s\S]*$/i, ''
      else
        report.body.replace /<!--\s*(end )?internal\s*-->/ig, ''
      unless report.body.trim().length
        return cb 'EMPTY'
      # add table of contents and HTML comment mark for later additions
      report.body = '@[toc]\n\n' + report.body
      cb null, report, lang
  ], cb


# Helper methods
# --------------------------------------------------------

# @param {String} file full filename for reporting
# @param {String} content complete file content
# @param {Object} setup setup configuration from {@link run()} method
# @param {Object} lang language definition structure from {@link language.coffee}
# @param {Object<Array>} symbol map to fill with code symbols as `[file, anchor]` to
# resolve links later
# @return {Array<Array>} list of documentation extracts
# - `0` - `Integer` character position from start of extraction
# - `1` - `Integer` character position from end of extraction
# - `2` - `String` extracted text
# - `3` - `String` following code line
extractDocs = (file, content, setup, lang, symbols) ->
  # document comments extraction
  docs = []
  if lang.doc
    for [re, fn] in lang.doc
      other = content
      for doc in docs
        start = if doc[0] then other[0..doc[0]-1] else ''
        other = start + util.string.repeat('\n', doc[1] - doc[0]) + other[doc[1]..]
      while match = re.exec other
        match[1] = fn match[1] if fn
        end = match.index + match[0].length
        cend = content.indexOf '\n', end
        code = if cend > 0 then content[end..cend] else content[end..]
        docs.push [match.index, end, "\n#{match[1].trim()}\n", code.trim()]
    (if setup.verbose > 2 then console.log else debug) \
      chalk.grey "#{file}: #{docs.length} doc comments"
  # internal comments extraction
  if lang.api and setup.code
    for [re, fn] in lang.api
      other = content
      for doc in docs
        start = if doc[0] then other[0..doc[0]-1] else ''
        other = start + util.string.repeat('\n', doc[1] - doc[0]) + other[doc[1]..]
      while match = re.exec other
        match[1] = fn match[1] if fn
        end = match.index + match[0].length
        cend = content.indexOf '\n', end
        code = if cend > 0 then content[end..cend] else content[end..]
        docs.push [match.index, end, "\n#{match[1].trim()}\n", code.trim()]
    (if setup.verbose > 2 then console.log else debug) \
      chalk.grey "#{file}: #{docs.length} doc comments (with internal)"
  # interpret tags
  for doc in docs
    tags doc, lang.tags, setup, file, symbols
  # sort found sections
  docs.sort (a, b) ->
    return -1 if a[0] < b[0]
    return 1 if a[0] > b[0]
    0
  return docs


# Remove indents which are the same in all lines. The tab size is used to translate
# if tabs are included.
#
# @param {String} code original code lines
# @param {Integer} tab number of spaces to use instead of tab
# @return {String} optimized code view
stripIndent = (code, tab) ->
  str = code.replace /^[ \t]*(?=\S)/gm, (e) ->
    e.replace '\t', util.string.repeat ' ', tab ? 2
  match = str.match /^ *(?=\S)/gm
  return code unless match
  indent = Math.min.apply Math, match.map (e) -> e.length
  code.replace new RegExp("^ {#{indent}}", 'gm'), ''

# Replace tags in markdown with real markdown syntax and add some possible information
# autodetected from code.
#
# @param {Array} doc markdown document as read from {@link extractDocs}
# @param {Object} lang language definition structure from {@link language.coffe#exports}
# @param {Object} setup setup configuration from {@link run()} method
# @param {String} file file name used for relative link creation
# @param {Object<Array>} symbol map to fill with code symbols as `[file, anchor]` to
# resolve links later
tags = (doc, lang, setup, file, symbols) ->
  return unless lang
  md = doc[2]
  code = doc[3]
  # extract tags
  spec = {}
  check = md.replace /([`$]{3,})[\s\S]*?\1/g, (match) -> util.string.repeat '?', match.length
  if match = check.match /(?:^|(?:\n|[ \t\r]){2,})\s*(?=@)/
    add = md[match.index+match[0].length..].trim()
    md = if match.index then md[0..match.index-1] + '\n' else ''
    for part in add.split /(?:\n|[ \t\r])(?=@)/g
      if match = part.match /^@(\S+)\s*/
        name = tagAlias[match[1]] ? match[1]
        spec[name] ?= []
        spec[name].push part[match[0].length..]
      break if match[1] is 'internal' and not setup.code
  # split some tags further down into name and desc
  for type in ['return', 'throws']
    if spec[type]
      spec[type] = spec[type].map (e) ->
        m = e.match /^\s*(?:\{([^}]+)\})?\s*([\s\S]+)$/
        if m then [m[1], m[2]]
        else throw new Error "tag is not formatted properly: @#{type} #{e}" unless m
  # split some tags further down into name, type and desc
  for type in ['param', 'event']
    if spec[type]
      spec[type] = spec[type].map (e) ->
        m = e.match ///
          ^\s*          # start of line (whitespace removed)
          (?:           # find type
            \{([^}]+)\} # #1: type in curly braces
            \s+         # something has to follow
          )?            # make it optional
          (\S+)         # #2: name (mandatory)
          (?:\s+        # find description
            (?:-\s+)?   # allow optional dash as separator
            ([\s\S]*)   # #3: description
          )?            # make it optional
          $             # end of line
        ///
        throw new Error "tag is not formatted properly: @#{type} #{e}" unless m
        if details = m[2].match /^\[([^=]*?)(?:\s*=\s*(.*))?\]$/
          m[2] = details[1]
          # interpret optional and default for params
          m[3] = "optional #{m[3] ? ''}"
          m[3] += " (default: #{details[2]})" if details[2]
        if m then [m[1], m[2], m[3]] else [null, spec[type]]
  # tags spec with auto detect
  if lang.access and not spec.access
    spec.access = [access] if access = lang.access code
  # get title
  title = if lang.title then lang.title code else code
  if spec.name
    for e in spec.name
      title = e
  # register in symbol table
  if title
    symbols[title] = [ file, uslug title ]
  # deprecation warning
  if spec.deprecated
    md += "\n::: warning\n**Deprecated!** #{spec.deprecated.join ' '}\n:::\n"
  try
    # create usage line
    if title and (spec.access or spec.private or spec.protected or spec.public or spec.constant or
    spec.static or spec.construct or spec.param)
      md += "\n> **Usage:** "
      if spec.access and spec.access[spec.access.length-1] isnt 'public'
        md += "#{util.array.last spec.access} "
      else if spec.private then md += 'private '
      else if spec.protected then md += 'protected '
      md += 'static ' if spec.static
      md += '`'
      md += 'const ' if spec.constant
      md += 'new ' if spec.construct
      md += "#{title}`"
      if spec.param
        md = md.replace /(\(\))?`$/, ''
        md += "(#{spec.param.map((e) -> e[1]).join ', '})`\n"
      md += "\n<!-- {p:.api-usage} -->\n"
    # method definitions
    md += tagParamEvent spec.param, 'Parameter' if spec.param
    if spec.return
      e = spec.return[spec.return.length-1]
      md += "\nReturn\n:   "
      md += "`#{e[0]}` " if e[0]
      md += "#{e[1].replace /\n/g, '\n      '}\n    "
    if spec.throws
      md += "\nThrows\n:   "
      for e in spec.throws
        md += "- "
        md += "`#{e[0]}` " if e[0]
        md += "#{e[1].replace /\n/g, '\n      '}\n    "
    md += tagParamEvent spec.event, 'Event' if spec.event
    if spec.see
      md += "\nSee also\n:   "
      for e in spec.see
        md += "- "
        md += "#{e.replace /\n/g, '      \n'}\n    "
    if spec.param or spec.return or spec.throws or spec.event or spec.see
      md += "\n<!-- {dl:.api-spec} -->\n"
    # signature
    if spec.version or spec.copyright or spec.author or spec.license
      md += "\n"
      for type in ['version', 'copyright', 'author']
        if spec[type]
          md += "#{spec[type].join ' '} "
      if spec.license
        md += "- License: #{spec.license.join ' '} "
      md += "\n\n<!-- {p:.api-signature} -->\n"
    # additional text
    md += "\n#{spec.description.join ' '}\n" if spec.description
    if spec.internal and setup.code
      md += "\n#{spec.internal.join ' '}\n"
    # add heading 3 if not there
    if title and not check.match /(^|\n)(#{1,3}[^#]|[^\n]+\n[-=]{3,})/
      md = "### #{title}\n#{md}"
    # store changes
    doc[2] = md
  catch error
    console.error chalk.magenta "Document error: #{error.message} at #{file}:
    \n     #{chalk.grey doc[2].replace /\n/g, '\n     '}"

# Format @param or @event as markdown from extracted tag specification.
#
# @param {Array<Array<String>>} spec list of tag contents
# @param {String} title name to display for this spec type
# @return {String} markdown to add
tagParamEvent = (spec, title) ->
  md = "\n#{title}\n:   "
  for e in spec
    md += "- "
    md += "`#{e[1]}` - " if e[1]
    md += "`#{e[0]}` " if e[0]
    if e[2] then md += "#{e[2].replace /\n/g, '\n      '}\n    "
    else md = util.string.trim(md, ' -') + '\n    '
  return md
