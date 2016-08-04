test = require '../test'
path = require 'path'
### eslint-env node, mocha ###

FILE = path.resolve __dirname, '../../data/languages/coffee.coffee'

describe "CoffeeScript", ->

  it "detect language", ->
    test.language FILE, 'coffeescript'
