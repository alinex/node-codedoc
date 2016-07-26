###
Controller
=================================================

This module is used as the base API. If you load the package you will get a reference
to the exported methods, here. Also the CLI works through this API.

Workflow
-------------------------------------------------

The following graph will show you the basic steps in creating the documentation:

$$$ plantuml
  :API Call;
  :run|
  :Find files]
  note right
    Includes and excludes
    definable
  end note
  partition "parallel run" {
    note right
      for each
      file
    end note
    :read file<
    :analyze language]
    if (is markdown) then (yes)
      :add as report]
    else (no)
      :extract
      block comments]
      :interpret JsDoc]
      if (add code) then (no)
      else (yes)
        :add code]
        note right
          with highlights
        end note
      endif
    endif
    :report;
  }
  :sort documents]
  partition "parallel run" {
    :convert to html]
    :write report>
  }
$$$

#3 Sorting

The file links are sorted in a natural way. This is from upper to lower directories
and alphabetically but with some defined orders. This means that 'index.*' always
comes before 'README.md' and the other files.
###


# Node Modules
# -------------------------------------------------
#

# include base modules
debug = require('debug') 'codedoc'
debugPage = require('debug') 'codedoc:page'
debugCopy = require('debug') 'codedoc:copy'
chalk = require 'chalk'
path = require 'path'
async = require 'async'
isBinaryFile = require 'isbinaryfile'
# include alinex modules
util = require 'alinex-util'
fs = require 'alinex-fs'
Report = require 'alinex-report'
config = require 'alinex-config'
# internal methods
language = require './language'

PARALLEL = 10
STATIC_FILES = /\.(html|gif|png|jpg|js|css)$/i

###
Initialize Module
-------------------------------------------------
To use the template search through the [alinex-config](https://alinex.github.io/node-config)
path module you have to init the template type by calling this method once.

This will setup the [alinex-report](https://alinex.github.io/node-report) component
and register the template type to search for templates in the global, user and
local path like known from the config module.
###

###
@param {function(err)} cb method, to call with 'Error' or `null` after done.
###
exports.setup = util.function.once this, (cb) ->
  debug chalk.grey "setup codedoc component"
  async.each [Report], (mod, cb) ->
    mod.setup cb
  , (err) ->
    return cb err if err
    # set module search path
    config.register 'codedoc', path.dirname(__dirname),
      folder: 'template'
      type: 'template'
    cb()

###
Create Documentation
-------------------------------------------------
Like described in the workflow above this is the main routine and will do all the
steps to make the documentation ready to browse in the local path.
###

###
@param {object} setup defining the document creation
- `input` - path to read from
- `òutput`- output directory to store to
- `find` - source search pattern
  - `include` - files to include see [alinex-fs](https://alinex.github.io/node-fs)
  - `exclude` - files to exclude see [alinex-fs](https://alinex.github.io/node-fs)
- `brand` - branding name to remove from automatic titles
- `verbose` - level of verbose mode
@param {function(err)} cb function to be called after done
###
exports.run = (setup, cb) ->
  # set up system
  setup.input ?= '.'
  setup.input = path.resolve setup.input ? '.'
  setup.output = path.resolve setup.output ? '.'
  setup.find ?= {}
  setup.find.type = 'file'
  setup.brand ?= 'alinex'
  # start converting
  fs.mkdirs setup.output, (err) ->
    return cb err if err
    async.parallel [
      (cb) -> # search source files
        (if setup.verbose then console.log else debug) "search files in #{setup.input}"
        fs.find setup.input, setup.find, (err, list) ->
          return cb err if err
          # create reports
          (if setup.verbose then console.log else debug) "convert files..."
          map = {}
          async.eachLimit list, PARALLEL, (file, cb) ->
            p = file[setup.input.length..]
            processFile file, p, setup, (err, report) ->
              if err
                return cb err if err instanceof Error
                return cb() # no real problem but abort
              map[p] =
                report: report
                dest: "#{setup.output}#{p}.html"
                parts: p[1..].toLowerCase().split /\//
                title: report.getTitle() ? p[1..]
              cb()
          , (err) ->
            return cb err if err
            # write files
            map = sortMap map
            mapKeys = Object.keys map
            moduleName = map[mapKeys[0]].title.replace /\s*[-:].*/, ''
            .replace new RegExp("^#{setup.brand}\\s+", 'i'), ''
            async.eachLimit mapKeys, PARALLEL, (name, cb) ->
              # create link list
              pages = []
              for p, e of map
                pages.push
                  depth: if setup.code then e.parts.length - 1 else 0
                  title: e.title
                  path: p
                  link: e.title.replace /^.*?[-:]\s+/, ''
                  url: "#{path.relative path.dirname(name), p}.html"
                  active: p is name
              # convert to html
              file = map[name]
              file.report.toHtml
                style: 'codedoc'
                context:
                  moduleName: moduleName
                  pages: pages
              , (err, html) ->
                html = html
                .replace /(<\/ul>\n<\/p>)\n<!-- end-of-toc -->\n/
                , '<li class="sidebar"><a href="#further-pages">Further Pages</a></li>$1'
                .replace ///href=\"(?!https?://|/)(.*?)(["#])///gi, (_, link, end) ->
                  if link.length is 0 or link.match STATIC_FILES
                    "href=\"#{link}#{end}" # keep link
                  else
                    "href=\"#{link}.html#{end}" # add .html
                fs.mkdirs path.dirname(file.dest), (err) ->
                  return cb err if err
                  fs.writeFile file.dest, html, 'utf8', cb
            , (err) ->
              return cb err if err
              (if setup.verbose then console.log else debug) "check index page"
              createIndex setup.output, map[mapKeys[0]].dest, (err) ->
                return cb err if err
                (if setup.verbose then console.log else debug) "page creation done"
                cb()
      (cb) -> # copy resources
        (if setup.verbose then console.log else debug) "copy static files from #{setup.input}"
        filter = util.extend util.clone(setup.find),
          include: STATIC_FILES
        fs.find setup.input, filter, (err, list) ->
          return cb err if err
          async.eachLimit list, PARALLEL, (file, cb) ->
            (if setup.verbose > 1 then console.log else debugCopy) "copy #{file}"
            dest = "#{setup.output}#{file[setup.input.length..]}"
            fs.remove dest, ->
              #async.times 3, (cb) ->
              fs.copy file, dest, cb
              #, cb
          , (err) ->
            return cb err if err
            (if setup.verbose then console.log else debug) "copying files done"
            cb()
    ], (err) ->
      return cb err if err
      (if setup.verbose then console.log else debug) "finished document creation"
      cb()

# If not existing create an `index.html` file which forwards to the first page
# immediately.
#
# @test this is only for testing the tags
#
# @param {string} dir base path of index file
# @param {string} link destination for the link to the first page
# @param {function(err)} cb callback method after done
createIndex = (dir, link, cb) ->
  file = path.join dir, 'index.html'
  dest = path.relative dir, link
  fs.exists file, (exists) ->
    return cb() if exists
    debug "create index page"
    fs.writeFile file, """
      <html>
      <head>
        <meta http-equiv="refresh" content="0; url=#{dest}" />
        <script type="text/javascript">
            window.location.href = "#{dest}"
        </script>
        <title>Page Redirection</title>
      </head>
      <body>
        If you are not redirected automatically, follow the link to the
        <a href='#{dest}'>README</a>.
      </body>
      </html>
      """, cb

processFile = (file, local, setup, cb) ->
  async.waterfall [
    # get file
    (cb) ->
      (if setup.verbose > 1 then console.log else debugPage) "analyze #{file}"
      fs.readFile file, (err, buffer) ->
        return cb err if err
        isBinaryFile buffer, buffer.length, (err, binary) ->
          return cb err ? 'BINARY' if err or binary
          cb null, buffer.toString 'utf8'
    # analyze language
    (contents, cb) ->
      lang = language file, contents
      unless lang
        (if setup.verbose then console.log else debug) \
          chalk.magenta "could not detect language of #{file}"
        return cb 'UNKNOWN'
      (if setup.verbose > 2 then console.log else debugPage) \
        chalk.grey "#{file}: detected as #{lang.name}"
      cb null, contents, lang
    # create report
    (contents, lang, cb) ->
      report = new Report()
      report.toc()
      report.raw '<!-- end-of-toc -->\n\n' # needed in case raw adding will follow
      if lang.name is 'markdown'
        report.raw contents
      else
        # document comments
        docs = []
        if lang.doc
          [re, fn] = lang.doc
          while match = re.exec contents
            match[1] = fn match[1] if fn
            end = match.index + match[0].length
            cend = contents.indexOf '\n', end
            code = if cend > 0 then contents[end..cend] else contents[end..]
            docs.push [match.index, end, match[1], code.trim()]
          (if setup.verbose > 2 then console.log else debugPage) \
            chalk.grey "#{file}: #{docs.length} doc comments"
        if lang.api and setup.code
          [re, fn] = lang.api
          while match = re.exec contents
            match[1] = fn match[1] if fn
            end = match.index + match[0].length
            found = false
            for c in docs
              if c[0] is match.index and c[1] is end
                found = true
                break
            unless found
              end = match.index + match[0].length
              cend = contents.indexOf '\n', end
              code = if cend > 0 then contents[end..cend] else contents[end..]
              docs.push [match.index, end, match[1], code.trim()]
          (if setup.verbose > 2 then console.log else debugPage) \
            chalk.grey "#{file}: #{docs.length} doc comments (with internal)"
        # sort found sections
        docs.sort (a, b) ->
          return -1 if a[0] < b[0]
          return 1 if a[0] > b[0]
          0
        # create report
        unless docs.length
          return cb 'CODE_DISABLED' unless setup.code
          report.h1 "File: #{path.basename local}"
          report.quote "Path: #{local}"
          report.code stripIndent(contents, lang.tab), lang.name
          report.p Report.style 'code: style="max-height:none"'
          return cb null, report
        pos = 0
        for doc in docs
          # doc optimizations
          try
            optimize doc, lang.tags, file
          catch error
            debugPage chalk.magenta "Could not parse documentation at #{file}: \
            #{chalk.grey util.inspect doc[2]}"
            debugPage chalk.magenta "caused by #{error.message}"
            return cb new Error "Could not parse documentation at #{file}: \
            #{chalk.grey util.inspect doc[2]}"
          if pos < doc[0] and setup.code
            # code block before doc
            part = contents[pos..doc[0]]
            report.code stripIndent(part, lang.tab), lang.name
            if pos # set correct line number
              line = contents[0..pos].split('\n').length - 1
              report.p Report.style "code: style=\"counter-reset:line #{line}\""
          # add doc block
          md = doc[2]
          .replace /(\n\s*)#([1-6])(\s+)/, (_, pre, num, post) ->
            "#{pre}#{util.string.repeat '#', num}#{post}"
          .replace /\n\s*?$/, ''
          report.raw "\n#{md}\n\n"
          pos = doc[1]
        if pos < contents.length and setup.code
          # last code block
          report.code stripIndent(contents[pos..], lang.tab), lang.name
          if pos # set correct line number
            line = contents[0..pos].split('\n').length - 1
            report.p Report.style "code: style=\"counter-reset:line #{line}\""
        # optimize report by adding path with compiled path
        source = "`#{local}`"
        if match = local.match /^\/src(\/.*)\.coffee$/
          source += " compiled to `/lib#{match[1]}.js`"
        report.body = report.body.replace /(\n\s*={10,}\s*\n)/, "$1\n> Path: #{source}\n\n"
      cb null, report
  ], cb

orderFirst = [
  'readme.*'
  'readme'
  '/man'
  '*.md'
  'index.*'
  '/src'
]
orderLast = [
  '/bin'
  '/lib'
  '/var'
  '.travis.yml'
  'changelog'
  'changelog.*'
]
sortMap = (map) ->
  list = Object.keys(map).map (e) ->
    parts = map[e].parts[..-2].map (p) -> "/#{p}"
    parts.push map[e].parts[map[e].parts.length-1]
    sortnum = parts.map (p) ->
      check = [p]
      if ~p.indexOf '.'
        check.push "*#{path.extname p}"
        check.push "#{path.basename p, path.extname p}.*"
      for v, i in orderLast
        continue unless v in check
        return util.string.lpad(51 + i, 2, '0') + util.string.rpad(p, 10, '_')
      for v, i in orderFirst
        continue unless v in check
        return util.string.lpad(i, 2, '0') + util.string.rpad(p, 10, '_')
      50 + util.string.rpad(p, 10, '_')
    .join ''
    "#{sortnum} => #{e}"
  list.sort()
  list = list.map (e) -> e.split(/ => /)[1]
  sorted = {}
  sorted[k] = map[k] for k in list
  sorted

stripIndent = (code, tab) ->
  str = code.replace /^[ \t]*(?=\S)/gm, (e) ->
    e.replace '\t', util.string.repeat ' ', tab ? 2
  match = str.match /^ *(?=\S)/gm
  return code unless match
  indent = Math.min.apply Math, match.map (e) -> e.length
  code.replace new RegExp("^ {#{indent}}", 'gm'), ''

tagAlias =
  alias: 'name'
  arg: 'param'
  argument: 'param'
  returns: 'return'
  exception: 'throws'
  fires: 'event'
  constructor: 'construct'
optimize = (doc, lang, file) ->
  return unless lang
  md = doc[2]
  code = doc[3]
  # extract tags
  spec = {}
  if match = md.match /(?:(?:\n|[ \t\r]){2,}|\s*)(?=@)/
    add = md[match.index+match[0].length..]
    md = if match.index then md[0..match.index-1] + '\n' else ''
    for part in add.split /(?:\n|[ \t\r])(?=@)/g
      if match = part.match /^@(\S+)\s+/
        name = tagAlias[match[1]] ? match[1]
        spec[name] ?= []
        spec[name].push part[match[0].length..]
  # split some tags further down
  for type in ['return', 'throws']
    if spec[type]
      spec[type] = spec[type].map (e) ->
        m = e.match /^(?:\s*\{(.+)\})\s*([\s\S]*)?$/
        if m then [m[1], m[2]] else [null, spec[type]]
  for type in ['param', 'event']
    if spec[type]
      spec[type] = spec[type].map (e) ->
        m = e.match /^(?:\s*\{(.+)\})\s*(\S+)(?:\s+(?:-\s*)?([\s\S]*))?$/
        if m then [m[1], m[2], m[3]] else [null, spec[type]]
  # get title
  title = if lang.title then lang.title code else code
  if spec.name
    for e in spec.name
      title = e
  # optimize spec with auto detect
  if lang.access and not spec.access
    spec.access = [access] if access = lang.access code
  # deprecation warning
  if spec.deprecated
    md += "\n::: warning\n**Deprecated!** #{spec.deprecated.join ' '}\n:::\n"
  # create usage line
  if title and (spec.access or spec.private or spec.protected or spec.public or spec.constant or
  spec.static or spec.construct or spec.param)
    md += "\n> **Usage:** "
    if spec.access
      md += "#{util.array.last spec.access} "
    else if spec.private
      md += 'private '
    else if spec.protected
      md += 'protected '
    else if spec.public
      md += 'public '
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
  if spec.param
    md += "\nParameter\n:   "
    for e in spec.param
      md += "- "
      md += "`#{e[1]}` - " if e[1]
      md += "`#{e[0]}` - " if e[0]
      md += "#{e[2].replace /\n/g, '\n      '}\n    "
  if spec.return
    md += "\nReturn\n:   "
    md += "`#{e[0]}` - " if e[0]
    md += "#{e[1].replace '\n', '      \n'}\n"
  if spec.throws
    md += "\nThrows\n:   "
    for e in spec.throws
      md += "- "
      md += "`#{e[0]}` - " if e[0]
      md += "#{e[1].replace '\n', '      \n'}\n    "
  if spec.event
    md += "\nEvent\n:   "
    for e in spec.event
      md += "- "
      md += "`#{e[1]}` - " if e[1]
      md += "`#{e[0]}` - " if e[0]
      md += "#{e[2].replace '\n', '      \n'}\n    "
  if spec.see
    md += "\nSee also\n:   "
    for e in spec.see
      md += "- "
      md += "#{e.replace '\n', '      \n'}\n    "
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
    md += "\n\n<!-- {p:.api-signator} -->\n"
  # replace inline tags
  # {@link}

  # add heading 3 if not there
  if title and not md.match /(^|\n)(#{1,3}[^#]|[^\n]+\n[-=]{3,})/
    md = "### #{title}\n\n#{md}"
  # store changes
  doc[2] = md
