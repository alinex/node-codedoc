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
path = require 'path'
# include alinex modules
util = require 'alinex-util'


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

module.exports = (file, setup) ->
  content = file.content
  lang = file.lang
  # extract docs
  try
    docs = extractDocs file.source, content, setup, lang
  catch error
    if debug.enabled
      debug chalk.magenta "Could not parse documentation at #{file.source}: \
      #{chalk.grey error.stack}"
    throw new Error "Could not parse documentation at #{file.source}: \
    #{chalk.grey error.message}"
  # create report for undocumented code
  unless docs.length
    return """
      <!-- internal -->
      # File: #{path.basename file.local}

      > Path: #{file.local}

      ``` #{lang.name}
      #{stripIndent(content, lang.tab)}-
      ```
      """
  # create out of api docs
  report = ''
  pos = 0
#  console.log docs if file.local.match /codedoc$/
  for doc in docs
    if pos < doc[0]
      # code block before doc
      if code = content[pos..doc[0]].replace /\s+$/, ''
        report += """
          <!-- internal -->
          ``` #{lang.name}
          #{stripIndent(code, lang.tab)}
          ```
          """
        if pos # set correct line number
          line = content[0..pos].split('\n').length - 1
          report += "<!-- {pre:style=\"counter-reset:line #{line}\"} -->"
        report +=  "\n<!-- end internal -->\n"
    # add doc block
    report += '<!-- internal -->' if doc[4]
    report += "\n#{doc[2].replace /\n\s*?$/, ''}\n"
    report += '<!-- end internal -->' if doc[4]
    pos = doc[1]
  if pos < content.length
    # last code block
    if code = content[pos..].replace /\s+$/, ''
      report += """
        <!-- internal -->
        ``` #{lang.name}
        #{stripIndent(code, lang.tab)}
        ```
        """
      if pos # set correct line number
        line = content[0..pos].split('\n').length - 1
        report += "\n<!-- {code:style=\"counter-reset:line #{line}\"} -->"
      report +=  "\n<!-- end internal -->\n"
  # return resulting doc
#  console.log report if file.local.match /codedoc$/
  report
  .replace /\n#3 /g, '\n### ' # replace special syntax for coffee files


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
# - `4` - `Boolean` developer documentation only
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
        docs.push [match.index, end, "\n#{match[1]}\n", code.trim(), false]
    (if setup.verbose > 2 then console.log else debug) \
      chalk.grey "#{file}: #{docs.length} doc comments"
  # internal comments extraction
  if lang.api
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
        docs.push [match.index, end, "\n#{match[1]}\n", code.trim(), true]
    (if setup.verbose > 2 then console.log else debug) \
      chalk.grey "#{file}: #{docs.length} doc comments (with internal)"
  # interpret tags
  for doc in docs
    from = content[0..doc[0]].split('\n').length
    to = content[0..doc[1]].split('\n').length - 1
    doc.line = "line #{from}..#{to}"
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
tags = (doc, lang, setup, file) ->
  return unless lang
  md = stripIndent doc[2]
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
        spec[name].push part[match[0].length..].trim()
      break if match[1] is 'internal' and not setup.code
  # split some tags further down into name and desc
  for type in ['return', 'throws', 'type']
    if spec[type]
      spec[type] = spec[type].map (e) ->
        m = e.match /^\s*(?:\{([^}]+)\})?\s*([\s\S]+)$/
        if m then [m[1], m[2]]
        else throw new Error "tag is not formatted properly: @#{type} at #{doc.line}" unless m
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
        unless m
          throw new Error "tag is not formatted properly: @#{type} at #{doc.line}"
        if details = m[2].match /^\[([^=]*?)(?:\s*=\s*(.*))?\]$/
          m[2] = details[1]
          # interpret optional and default for params
          m[3] = "optional #{m[3] ? ''}"
          m[3] += " (default: #{details[2]})" if details[2]
        if m then [m[1], m[2], m[3]] else [null, spec[type]]
  # boolean tags
  for type in ['construct']
    spec[type] = true if spec[type]?
  # tags spec with auto detect
  if lang.access and not spec.access
    spec.access = [access] if access = lang.access code
  if lang.construct
    spec.construct ?= lang.construct code
  # get title
  title = if lang.title then lang.title code else code
  if spec.name
    for e in spec.name
      title = e.trim()
  # deprecation warning
  if spec.deprecated
    md += "\n::: warning\n**Deprecated!** #{spec.deprecated.join ' '}\n:::\n"
  try
    # create usage line
    if title and (spec.access?.join('') isnt 'public' or spec.private or
    spec.protected or spec.constant or
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
      md += "#{title}"
      if spec.param
        md = md.replace /(\(\))?$/, ''
        md += "(#{spec.param.map((e) -> e[1]).join ', '})"
      else if spec.construct
        md += '()' unless md.match /\(.*\)/
      md += "`\n{.api-usage}\n"
    # method definitions
    md += tagParamEvent spec.param, 'Parameter' if spec.param
    if spec.type
      md += "\nType\n:   "
      for e in spec.type
        md += "`#{e[0]}` " if e[0]
        md += "#{e[1].replace /\n/g, '\n      '}\n    "
    if spec.return
      e = spec.return[spec.return.length-1]
      md += "\nReturn\n:   "
      md += "`#{e[0]}` " if e[0]
      md += "#{e[1].replace /\n/g, '\n    '}\n    "
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
    doc[2] = if doc[4] then "<!-- internal -->\n#{md}\n<!-- end internal -->" else md
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
