# Renderer
# ================================================
# Collection of methods used to generate the HTML files out of the reports and
# structures from parsing. It will create the results on disk.


# Node Modules
# -------------------------------------------------
debug = require('debug') 'codedoc:transcode'
coffee = null # load on demand


# Optimize markdown of report before converting it further.
#
# @param {String} report markdown text to replace inline tags within
# @param {String} file file name used for relative link creation
# @param {Object<Array>} symbols map as `[file, anchor]` to resolve links
# @param {Array<Object>} pages list of pages from table of contents used attributes:
# - `path` - `String` file path
# - `title` - `String` title of the document
# - `url` - `String` generated file
# @param {String} search additional search words for link resolve
# @param {function(<Error>, <String>)} cb callback which will get the new markdown
module.exports = (file, type, md, cb) ->
  first = true
  md = md
  # insert empty code from previous by transform name
  .replace ///
    \n(\ *`{3,})\ *       # 1: start1
    (\w+)                 # 2: lang1
    ([^\n]*\n)            # 3: addon1
    ([\s\S]*?\n)          # 4: code1
    \1\ *\n               # end
    ([\s\S]*?\n)          # 5: other
    (\ *`{3,})\ *         # 6: start2
    \2[2](\w+)            # 7: lang2
    ([^\n]*\n+)           # 8: addon2
    \6\ *\n               # end
  ///g, (_, start1, lang1, addon1, code1, other, start2, lang2, addon2) ->
    "\n#{start1} #{lang1}#{addon1}#{code1}#{start1}\n#{other}\
    #{start2} #{lang1}2#{lang2}#{addon2}#{code1}#{start2}\n"
  # transform code
  .replace ///
    \n(\ *`{3,})\ *       # 1: start
    (\w+)2                # 2: lang1
    (\w+)                 # 3: lang2
    ([^\n]*\n)            # 4: addon
    ([\s\S]*?\n?)         # 5: code
    \1\ *\n               # end
  ///g, (_, start, lang1, lang2, addon, code) ->
    if first
      debug "transform #{file.local} (#{type})" if debug.enabled
      first = false
    return '\nNo code given!\n' unless code.trim().length
    unless transform["#{lang1}2#{lang2}"]
      return cb new Error "No transformer for #{lang1}2#{lang2} found at #{file}"
    transform["#{lang1}2#{lang2}"] start, addon, code
  cb null, md

# Transform code entries before interpreting.
#
# @type {Object<Function>} collection of transformer functions defined under
# `<source-language>2<dest-language>` with the following parameters:
# - `String` - `start` code tag with indention
# - `String` - `addon` additional styles
# - `String` - `code` content of the source code
#
# This will return the resulting markdown with the transformed code.
transform =
  coffee2js: (start, addon, code) ->
    coffee ?= require 'coffee-script'
    # convert single line comments to keep them
    code = code
    .replace /(^|\n\s*)#([^#].*)(?=\n)/g, '$1###$2 ###'
    .replace /\#{3}\n(\s*)\#{3}/g, '\n$1 *'
    compiled = coffee.compile code,
      bare: true
    .replace /\*\/[ \t]*\n\n(?!\/\*)/g, '*/\n'
    .replace /\n{3,}/g, '\n\n' # not more than one empty line
    "\n#{start} js#{addon}#{compiled.trim()}#{start}\n"
