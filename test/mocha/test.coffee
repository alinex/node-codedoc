chai = require 'chai'
expect = chai.expect
rewire = require 'rewire'
### eslint-env node, mocha ###

parse = rewire '../../src/helper/parse'

fn = parse.__get__ 'extractDocs'
