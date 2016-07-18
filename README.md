Alinex CodeDoc: Readme
=================================================

[![Build Status](https://travis-ci.org/alinex/node-codedoc.svg?branch=master)](https://travis-ci.org/alinex/node-codedoc)
[![Coverage Status](https://coveralls.io/repos/alinex/node-codedoc/badge.png?branch=master)](https://coveralls.io/r/alinex/node-codedoc?branch=master)
[![Dependency Status](https://gemnasium.com/alinex/node-codedoc.png)](https://gemnasium.com/alinex/node-codedoc)
[![GitHub](https://assets-cdn.github.com/favicon.ico)](https://github.com/alinex/node-codedoc "Code on GitHub")
<!-- {.right} -->

A general code documentation tool based on the concepts of
[docco](http://jashkenas.github.io/docco/) or [docker.js](https://jbt.github.io/docker/src/docker.js.html).

This tool should help you create browsable documentation out of the comments written
in the code. At first it is no general tool for everybody but a helper for myself to
get a documentation for my own projects.

The main features are:

- useable for any language
- with easy markdown text
- powerful options like graphs
- additional support for javadoc like formatting
- responsive design through templates

To see what it will give you is shown here in [this documentation](http://alinex.github.io/node-codedoc)
which is completely made with it.

> It is one of the modules of the [Alinex Namespace](http://alinex.github.io/code.html)
> following the code standards defined in the [General Docs](http://alinex.github.io/develop).

__Read the complete documentation under
[http://alinex.github.io/node-codedoc](http://alinex.github.io/node-codedoc).__
<!-- {p: .hide} -->

As an example you can check this documentation:
- [without code](http://alinex.github.io/node-codedoc/README.md.html)
- [with code](http://alinex.github.io/code-codedoc/README.md.html)


Install
-------------------------------------------------

[![NPM](https://nodei.co/npm/alinex-codedoc.png?downloads=true&downloadRank=true&stars=true)
 ![Downloads](https://nodei.co/npm-dl/alinex-codedoc.png?months=9&height=3)
](https://www.npmjs.com/package/alinex-codedoc)

### As Standalone Tool

Install the package globally using npm:

``` sh
sudo npm install -g alinex-codedoc --production
codedoc --help
```

### Integrate into your Node Project

To do this you install it into your own module:

``` sh
# from within your module directory
sudo npm install --save alinex-codedoc
```


Usage
-------------------------------------------------

### As Standalone Tool

After global installation you may directly call `codedoc` from anywhere to work
in the current or defined directory.

See the [man page](src/man/codedoc1.md) for explanation of the command line use
and options.

### Integrate into your Node Project

You have to include it into your project:

``` coffee
codedoc = require 'alinex-codedoc'
# setup the template search paths
codedoc.setup (err) ->
  # do something on error like exit or reporting
  if err
    console.error err.message
    process.exit 1
  # run documentation generation
  codedoc.run
    input: argv.input
    find:
      exclude: list
    output: argv.output
    style: argv.style
    code: argv.code
  , (err) ->
    if err
      console.error err.message
      process.exit 16  
    console.log 'Documents created.'
```

``` js
codedoc = require('alinex-codedoc');
// setup the template search paths
codedoc.setup(function(err) {
  // do something on error like exit or reporting
  if (err) {
    console.error(err.message);
    process.exit(1);
  }
  // run documentation generation
  return codedoc.run({
    input: argv.input,
    find: { exclude: list },
    output: argv.output,
    style: argv.style,
    code: argv.code
  }, function(err) {
    if (err) {
      console.error(err.message);
      process.exit(16);
    }
    return console.log('Documents created.');
  });
});
```

Find more information about calling the code documentation in the [API](src/index.coffee).

If you want to use your own style templates within your app's config directory
and your already using [alinex-config](http://alinex.github.io/node-config)
you only have to register the template type on it by putting the following on top:

``` coffee
config = require 'alinex-config'
# set module search path
# (with paths for calling in the upper directory)
config.register 'codedoc', __dirname,
  folder: 'template'
  type: 'template'
```

``` js
config = require('alinex-config');
// set module search path
// (with paths for calling in the upper directory)
config.register('codedoc', __dirname, {
  folder: 'template',
  type: 'template'
});
```

This allows you to put your templates also under:
- var/src/template/report/...
- var/local/template/report/...
- /etc/<yourapp>/template/report/...
- ~/.<yourapp>/template/report/...


License
-------------------------------------------------

(C) Copyright 2016 Alexander Schilling

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

>  <http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
