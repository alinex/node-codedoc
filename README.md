Alinex CodeDoc: Readme
=================================================

[![Build Status](https://travis-ci.org/alinex/node-codedoc.svg?branch=master)](https://travis-ci.org/alinex/node-codedoc)
[![Coverage Status](https://coveralls.io/repos/alinex/node-codedoc/badge.png?branch=master)](https://coveralls.io/r/alinex/node-codedoc?branch=master)
[![Dependency Status](https://gemnasium.com/alinex/node-codedoc.png)](https://gemnasium.com/alinex/node-codedoc)
[![GitHub](https://assets-cdn.github.com/favicon.ico)](https://github.com/alinex/node-codedoc "Code on GitHub")
<!-- {.right} -->

A general code documentation tool based on the concepts of
[docco](https://jashkenas.github.io/docco/) or [docker.js](https://jbt.github.io/docker/src/docker.js.html).

This tool should help you create browsable documentation out of the comments written
in the code. It is a way between hand written documentation, structured api information
and code highlighting. Read my own thoughts below to know why it is like it is.

The main features are:

- useable for any language
- with easy markdown text
- powerful options like graphs
- additional support for javadoc like formatting
- responsive design through templates

To see what it will give you is shown here in [this documentation](https://alinex.github.io/node-codedoc)
which is completely made with it.

> It is one of the modules of the [Alinex Namespace](https://alinex.github.io/code.html)
> following the code standards defined in the [General Docs](https://alinex.github.io/develop).

__Read the complete documentation under
[https://alinex.github.io/node-codedoc](https://alinex.github.io/node-codedoc).__
<!-- {p: .hide} -->

As an example you can check this documentation at:
- [without code](https://alinex.github.io/node-codedoc/README.md.html)
- [with code](https://alinex.github.io/code-codedoc/README.md.html)


Philosophy
-------------------------------------------------
How important is documentation? How should it be structured? How to write it? This
all depends on who will write it and mostly who should use it.

In my projects I can answer the last statement easily because I write it and I will
use it and also some other guys using my modules. After getting that clear I saw that
mostly I have to decide how it should be.

Someone said good code didn't need any documentation but I disagree and will say
documentation may be extended with good code. I don't want to repeat to much information
already in the code. The documentation should also concentrate on the things the
user needs and don't mix internal developer API for mostly external use.

With all these thoughts I created this tool as in between. It should display markdown
documentation meant to explain how things go with external API. This all displayed in
a modern web interface viewable on any device. So I mixed the docco/docker.js concept
of doc + code with JsDoc tags for API and some minimal code analyzeation.  

As I sometimes also read documentation about the internal structure and API I added
another mode called code view which is designed for the internal module developer.


Workflow
-------------------------------------------------

$$$ plantuml {.right}
interface "CodeDoc" as CLI

folder "Input Directory" as Source {
  [Markdown]
  [CODE]
  [resources]
}

node Analyze
CLI -> Analyze
Markdown -> Analyze
CODE -> Analyze
[languages] ..> Analyze

package Data {
  [pages]
  [report]
  [symbols]
}
Analyze ..> pages
Analyze -> report
Analyze ..> symbols

node Transform
[template] ..> Transform
pages ..> Transform
report -> Transform
symbols ..> Transform

folder "Output Directory" as Doc {
  [index] ..> [html]
  [other] <.. [html]
}
Transform -> index
Transform -> html

node Copy
resources -> Copy
Copy -> other

skinparam node {
	backgroundColor peachpuff
}
$$$

Which files to use firstly depends on the selection of the input folder and the
filter conditions. These filter conditions can be set indirectly using the `.docignore`
or `.gitignore` files or be given in the API.

All files matching this conditions will be **analyzed**. Depending if you generate the normal
view or the developer view document elements are extracted. Therefore the predefined
language syntax is used. If some document parts are found
a report will be generated containing the documentation in markdown format and the page list
and symbols table are filled up, too.

The **transformation** will use the user definable template to make html reports.
A table of contents will be build out of the pages list and inline `@link` tags
will be replaced using the symbol table if possible. An index will also be created
redirecting to the first page of documentation. Each html page will be standalone
with all neccessary javascript, css and svg included. Only resources which are
coming through the template (some CDN resources in the default) and the images
you added as relative links are linked.

Resources like images, html or stylesheets will be **copied** directly to the output folder.
Because you may refer to them directly from your documentation.


Install
-------------------------------------------------

[![NPM](https://nodei.co/npm/alinex-codedoc.png?downloads=true&downloadRank=true&stars=true)
 ![Downloads](https://nodei.co/npm-dl/alinex-codedoc.png?months=9&height=3)
](https://www.npmjs.com/package/alinex-codedoc)

> See the {@link Changelog.md} for a list of changes in recent versions.

You may use it from the command line as CLI Tool or call it directly through the
API from your nodeJS code.

### CLI Tool

Install the package globally using npm:

``` sh
sudo npm install -g alinex-codedoc --production
codedoc --help
```

### API Integration

To do this you install it into your own module:

``` sh
# from within your module directory
sudo npm install --save alinex-codedoc
```


Usage
-------------------------------------------------

### CLI Tool

After global installation you may directly call `codedoc` from anywhere to work
in the current or defined directory.

See the {@link codedoc.1.md} for explanation of the command line use
and options.

### API Usage

You have to
1. include it into your project
2. call the setup method
3. call the {@link run()} method

See the following example using CoffeeScript or JavaScript:

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

Find more information about calling the code documentation in the {@link index.coffee}.

### Custom Layout / Style

If you want to use your own style templates within your app's config directory
and you're already using {@link alinex-config} you only have to register the
template type on it by putting the following on top:

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


Debugging
-------------------------------------------------
If you have any problems you may debug the code with the predefined flags. It uses
the [debug](https://github.com/visionmedia/debug/blob/master/Readme.md) module to
let you define what to debug.

Call it with the `DEBUG` environment variable set to the types you want to debug.
The most valueable flags will be:

``` sh
DEBUG=codedoc* codedoc  # more information what goes on
DEBUG=config* codedoc   # registering paths for template search
DEBUG=report* codedoc   # conversion into html
```

You can also combine them using comma or use only `DEBUG=*` to show all.


License
-------------------------------------------------

(C) Copyright 2016 Alexander Schilling

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

>  <https://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
