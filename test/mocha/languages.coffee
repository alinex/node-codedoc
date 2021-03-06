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

describe "Languages", ->

  describe "coffeescript", ->
    file = path.resolve __dirname, '../data/languages/coffee.coffee'
    content = fs.readFileSync file, 'utf8'
    it "should detect language", ->
      test.language file, content, 'coffeescript'
    it "should read doc blocks", (cb) ->
      test.extractDocs file, content, 1, 4, (err, doc, api) ->
        expect(api[2][2], 'default title in api#3').to.contain '### myCode()\n'
        expect(api[3][2], 'default title in api#4').to.contain '### myCode()\n'
        cb()
    it "should get default view", (cb) ->
      test.report file, false, (err, report, symbols) ->
        expect(Object.keys(symbols).length, 'symbols length').to.equal 0
        cb()
    it "should get internal view", (cb) ->
      test.report file, true, (err, report, symbols) ->
        expect(Object.keys(symbols).length, 'symbols length').to.equal 1
        expect(Object.keys(symbols), 'symbols').to.contain 'myCode()'
        cb()


# Test Helper
# -------------------------------------------------------------

test =

  language: (file, content, lang) ->
    detect = language file, content
    # language
    expect(detect?.name, 'detected language').to.equal lang
    # doc parser
    expect(detect.doc, 'doc syntax defined').to.be.an 'array'
    for entry, i in detect.doc
      expect(entry, "doc[#{i}] type").to.be.an 'array'
      expect(entry[0], "doc[#{i}][0] type").to.be.a 'regexp'
      if entry[1]
        expect(entry[1], "doc[#{i}][1] type").to.be.a 'function'
    # api parser
    expect(detect.api, 'api syntax defined').to.be.an 'array'
    for entry, i in detect.api
      expect(entry, "api[#{i}] type").to.be.an 'array'
      expect(entry[0], "api[#{i}][0] type").to.be.a 'regexp'
      if entry[1]
        expect(entry[1], "api[#{i}][1] type").to.be.a 'function'
    # tabs
    if detect.tab
      expect(detect.tab, 'tab size').to.be.an 'integer'
    # tags
    if detect.tags
      expect(detect.tags, 'tags parser').to.be.an 'object'
      if detect.tags.title
        expect(detect.tags.title, 'tags.title parser').to.be.a 'function'
      if detect.tags.access
        expect(detect.tags.access, 'tags.access parser').to.be.a 'function'
    return detect

  extractDocs: (file, content, numDoc, numApi, cb) ->
    lang = language file, content
    doc = extractDocs file, content, {}, lang, {}
    expect(doc.length, 'found docs').to.equal numDoc
    api = extractDocs file, content, {code: true}, lang, {}
    expect(api.length, 'found apis').to.equal numApi
    cb null, doc, api if cb

  report: (file, internal, cb) ->
    local = "/#{path.basename file}"
    symbols = {}
    parse.file file, local, {code: internal}, symbols, (err, report) ->
      expect(err, 'parse error').to.not.exist
      cb null, report, symbols
