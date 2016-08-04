chai = require 'chai'
expect = chai.expect
rewire = require 'rewire'
fs = require 'alinex-fs'
util = require 'util'

language = rewire '../../src/helper/language'
parse = rewire '../../src/helper/parse'

#fn = parse.__get__ 'extractDocs'

exports.language = (file, lang) ->
  content = fs.readFileSync file, 'utf8'
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
