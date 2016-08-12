### eslint-env node, mocha ###
chai = require 'chai'
expect = chai.expect
rewire = require 'rewire'
# require 'coffee-script' used by rewire
fs = require 'alinex-fs'
path = require 'path'

language = rewire '../../src/helper/language'
parse = rewire '../../src/helper/parse'
extractDocs = parse.__get__ 'extractDocs'

FILE = '../data/tags.coffee'


describe "Tags", ->

  doc = null
  api = null
  num = 0
  before ->
    file = path.resolve __dirname, FILE
    content = fs.readFileSync file, 'utf8'
    lang = language file, content
    doc = extractDocs file, content, {code: false}, lang, {}
    .map (e) -> e[2]
    api = extractDocs file, content, {code: true}, lang, {}
    .map (e) -> e[2]
#    console.log api

  describe "heading", ->
    it "should interpret @name, @alias", ->
      test api, num++, /### test\(\)\n/
      test api, num++, /### other\(\)\n/

  describe "warning", ->
    it "should interpret @deprecated", ->
      test api, num++, /\n::: warning\n\*\*Deprecated!\*\* Will be removed in the future.\n:::\n/

  describe "usage", ->
    it "should interpret @access", ->
      test api, num++, '\n> **Usage:** private `test()`\n'
    it "should interpret @private", ->
      test api, num++, '\n> **Usage:** private `test()`\n'
    it "should interpret @protected", ->
      test api, num++, '\n> **Usage:** protected `test()`\n'
    it "should interpret @public but do not show", ->
      test api, num++, '\n> **Usage:** `test()`\n'
    it "should interpret @static", ->
      test api, num++, '\n> **Usage:** static `test()`\n'
    it "should interpret @constant", ->
      test api, num++, '\n> **Usage:** `const test()`\n'
    it "should interpret @construct, @constructor", ->
      test api, num++, '\n> **Usage:** `new test()`\n'
      test api, num++, '\n> **Usage:** `new test()`\n'

  describe "definition", ->
    it "should interpret @param, @arg, @argument", ->
      test api, num++, '\nParameter\n:   - `test1`\n    - `test2`\n    - `test3`\n'
      test api, num++, '\nParameter\n:   - `test1` - `String`\n    - `test2` - `String`\n    - `test3` - `String`\n'
      test api, num++, '\nParameter\n:   - `test1` - `String` a parameter\n    - `test2` - `String` a parameter\n    - `test3` - `String` a parameter\n'
    it "should interpret @return, @returns", ->
      test api, num++, '\nReturn\n:   a number\n'
      test api, num++, '\nReturn\n:   a number\n'
      test api, num++, '\nReturn\n:   `Integer` a number\n'
      test api, num++, '\nReturn\n:   `Integer` a number\n'
    it "should interpret @throws, @exception", ->
      test api, num++, '\nThrows\n:   - a number\n'
      test api, num++, '\nThrows\n:   - a number\n'
      test api, num++, '\nThrows\n:   - `Integer` a number\n'
      test api, num++, '\nThrows\n:   - `Integer` a number\n'
    it "should interpret @event, @fires", ->
      test api, num++, '\nEvent\n:   - `event1`\n    - `event2`\n'
      test api, num++, '\nEvent\n:   - `event1` - `String`\n    - `event2` - `String`\n'
      test api, num++, '\nEvent\n:   - `event1` - `String` a parameter\n    - `event2` - `String` a parameter\n'
    it "should interpret @see", ->
      test api, num++, '\nSee also\n:   - the manual\n'

  describe "special", ->
    it "should interpret @describe, @description", ->
      test api, num++, /Parameter\n[\s\S]*This is a test/
      test api, num++, /Parameter\n[\s\S]*This is a test/
    it "should interpret @internal", ->
      test doc, num, '\nParameter\n:   - `test1`\n    \n'
      test api, num++, '\nParameter\n:   - `test1`\n    - `test2`\n    \n'
      test doc, num, '\nParameter\n:   - `test1`\n    \n'
      test api, num++, /Parameter\n[\s\S]*Some internal note/


# Test Helper
# -------------------------------------------------------------

test = (api, i, check) ->
  if typeof check is 'string'
    expect(~api[i].indexOf check, "api##{i} contain #{check}").to.not.equal 0
  else
    expect(api[i].match check, "api##{i} match #{check}").to.exist
