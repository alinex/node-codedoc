chai = require 'chai'
expect = chai.expect
rewire = require 'rewire'
### eslint-env node, mocha ###
fs = require 'alinex-fs'
path = require 'path'

language = rewire '../../src/helper/language'
parse = rewire '../../src/helper/parse'
extractDocs = parse.__get__ 'extractDocs'

FILE = '../data/tags.coffee'


describe.only "Tags", ->

  api = null
  num = 0
  before ->
    file = path.resolve __dirname, FILE
    content = fs.readFileSync file, 'utf8'
    lang = language file, content
    api = extractDocs file, content, {code: true}, lang, {}
    .map (e) -> e[2]
    console.log api

  describe "heading", ->
    it "should interpret @name, @alias", ->
      test api, num++, /### test\(\)\n\n/
      test api, num++, /### other\(\)\n\n/

  describe "warning", ->
    it "should interpret @deprecated", ->
      test api, num++, /\n::: warning\n\*\*Deprecated!\*\* Will be removed in the future.\n:::\n/

  describe "usage", ->
    it "should interpret @access", ->
      test api, num++, /\n> \*\*Usage:\*\* private `test\(\)`\n/
    it "should interpret @private", ->
      test api, num++, /\n> \*\*Usage:\*\* private `test\(\)`\n/
    it "should interpret @protected", ->
      test api, num++, /\n> \*\*Usage:\*\* protected `test\(\)`\n/
    it "should interpret @public", ->
      test api, num++, /\n> \*\*Usage:\*\* public `test\(\)`\n/
    it "should interpret @static", ->
      test api, num++, /\n> \*\*Usage:\*\* static `test\(\)`\n/
    it "should interpret @constant", ->
      test api, num++, /\n> \*\*Usage:\*\* `const test\(\)`\n/
    it "should interpret @construct, @constructor", ->
      test api, num++, /\n> \*\*Usage:\*\* `new test\(\)`\n/
      test api, num++, /\n> \*\*Usage:\*\* `new test\(\)`\n/

#  describe "definition", ->
#    it "should interpret @access", ->
#      test api, num++, /\n> \*\*Usage:\*\* private `test\(\)`\n/
#    - `@param`, `@arg`, `@argument` a method parameter with optional type
#      given as: `@param {<type>} <name> <description>`
#    - `@return`, `@returns` defining what will be returned
#      given as: `@return {<type>} <description>`
#    - `@throws`, `@exception` descripe possible excepzions
#      given as: `@throws {<type>} <description>`
#    - `@event`, `@fires` descripe events to be thrown
#      given as: `@event {<type>} <name> <description>`
#    - `@see` references additional information, use `{@link...}` within

# Test Helper
# -------------------------------------------------------------

test = (api, i, re) ->
  expect(api[i].match re, "api##{i} match #{re}").to.exist
