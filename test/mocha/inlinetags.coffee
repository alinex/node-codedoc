### eslint-env node, mocha ###
chai = require 'chai'
expect = chai.expect

render = require '../../src/helper/render'


describe "Inline Tags", ->

  describe "link", ->

    it "should resolve symbol link", (cb) ->
      test "{@link test()}", null, {'test()': ['test.coffee', 'test']},
        '[`test()`](../../test.coffee.html#test "File: test.coffee Element: test()")', cb

    it "should resolve absolute file", (cb) ->
      test "{@link /src/test.coffee}", null, null, [
        path: "#{__dirname}/src/test.coffee"
        title: 'Test Page'
        url: 'test.coffee.html'
      ], '[Test Page](test.coffee.html "File: /src/test.coffee")', cb
    it "should resolve filename", (cb) ->
      test "{@link test.coffee}", null, null, [
        path: "#{__dirname}/src/test.coffee"
        title: 'Test Page'
        url: 'test.coffee.html'
      ], '[Test Page](test.coffee.html "File: test.coffee")', cb

    it "should resolve alinex link", (cb) ->
      test "{@link alinex-config}", '[alinex-config](https://alinex.github.io/node-config)', cb

    it "should use internet link", (cb) ->
      test "{@link http://heise.de}", '[http://heise.de](http://heise.de)', cb

    it "should search mdn link", (cb) ->
      test "{@link String.match}", null, null, null, 'javascript',
      '[String.prototype.match()](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/match)', cb
    it "should search nodejs link", (cb) ->
      test "{@link fs.readFile()}", null, null, null, 'nodejs',
      '[fs.readFile()](https://nodejs.org/dist/latest-v6.x/docs/api/fs.html#fs_fs_readfile_file_options_callback)', cb

    it "should keep unknown text the same", (cb) ->
      test "{@link thisisnotanythere}", "thisisnotanythere", cb
    it "should keep unknown text the same (with search)", (cb) ->
      test "{@link thisisnotanythere}", null, null, null, 'nodejs', "thisisnotanythere", cb


test = () ->
  args = Array.prototype.slice.call arguments
  [goal, cb] = args[-2..]
  [md, file, symbols, pages, search] = arguments
  file ?= __filename
  symbols ?= {}
  pages ?= []
  render.optimize md, file, symbols, pages, search, (err, res) ->
    expect(res).to.equal goal
    cb()
