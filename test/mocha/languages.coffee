chai = require 'chai'
expect = chai.expect
rewire = require 'rewire'
### eslint-env node, mocha ###
util = require 'util'
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
      test.extractDocs file, content, 1, 2, (err, doc, api) ->
        console.log doc
        cb()
    it "should get default view", (cb) ->
      test.report file, false, (err, report, symbols) ->
        cb()
    it "should get internal view", (cb) ->
      test.report file, true, (err, report, symbols) ->
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
    expect(detect.doc[0], "doc[0] type").to.be.a 'regexp'
    if detect.doc[1]
      expect(detect.doc[1], "doc[1] type").to.be.a 'function'
    # api parser
    expect(detect.api, 'api syntax defined').to.be.an 'array'
    expect(detect.doc[0], "api[0] type").to.be.a 'regexp'
    if detect.api[1]
      expect(detect.api[1], "api[1] type").to.be.a 'function'
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
    doc = extractDocs file, content, {}, lang
    expect(doc.length, 'found docs').to.equal numDoc
    api = extractDocs file, content, {code: true}, lang
    expect(api.length, 'found apis').to.equal numApi
    cb null, doc, api if cb

  report: (file, internal, cb) ->
    local = "/#{path.basename file}"
    symbols = {}
    parse.file file, local, {code: internal}, symbols, (err, report) ->
      expect(err, 'parse error').to.not.exist
      cb null, report, symbols
