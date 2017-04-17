Alinex CodeDoc: Readme
=================================================

[![GitHub watchers](
  https://img.shields.io/github/watchers/alinex/node-codedoc.svg?style=social&label=Watch&maxAge=2592000)](
  https://github.com/alinex/node-codedoc/subscription)<!-- {.hidden-small} -->
[![GitHub stars](
  https://img.shields.io/github/stars/alinex/node-codedoc.svg?style=social&label=Star&maxAge=2592000)](
  https://github.com/alinex/node-codedoc)
[![GitHub forks](
  https://img.shields.io/github/forks/alinex/node-codedoc.svg?style=social&label=Fork&maxAge=2592000)](
  https://github.com/alinex/node-codedoc)<!-- {.hidden-small} -->
<!-- {p:.right} -->

[![npm package](
  https://img.shields.io/npm/v/alinex-codedoc.svg?maxAge=2592000&label=latest%20version)](
  https://www.npmjs.com/package/alinex-codedoc)
[![latest version](
  https://img.shields.io/npm/l/alinex-codedoc.svg?maxAge=2592000)](
  #license)<!-- {.hidden-small} -->
[![Travis status](
  https://img.shields.io/travis/alinex/node-codedoc.svg?maxAge=2592000&label=develop)](
  https://travis-ci.org/alinex/node-codedoc)
[![Coveralls status](
  https://img.shields.io/coveralls/alinex/node-codedoc.svg?maxAge=2592000)](
  https://coveralls.io/r/alinex/node-codedoc?branch=master)
[![Gemnasium status](
  https://img.shields.io/gemnasium/alinex/node-codedoc.svg?maxAge=2592000)](
  https://gemnasium.com/alinex/node-codedoc)
[![GitHub issues](
  https://img.shields.io/github/issues/alinex/node-codedoc.svg?maxAge=2592000)](
  https://github.com/alinex/node-codedoc/issues)<!-- {.hidden-small} -->


A general code documentation tool based on the concepts of
[docco](https://jashkenas.github.io/docco/) or [docker.js](https://jbt.github.io/docker/src/docker.js.html).

This tool should help you create browsable documentation out of the comments written
in the code. It is a way between hand written documentation, structured api information
and code highlighting. Read my own thoughts below to know why it is like it is.

The main features are:

- useable for any language
- written as easy markdown text
- additional support for javadoc like formatting
- responsive design through templates
- show api and internal developer info with code
- automatic generation helper

To see what it will give you see at this documentation which is completely made
with itself.

> It is one of the modules of the [Alinex Namespace](https://alinex.github.io/code.html)
> following the code standards defined in the [General Docs](https://alinex.github.io/develop).

__Read the complete documentation under
[https://alinex.github.io/node-codedoc](https://alinex.github.io/node-codedoc).__
<!-- {p: .hidden} -->

### Alinex Layout
You find the top bar which contains the alinex core links. The tree of pages on the left
with an icon to switch between **User API Documentation** and **Developer Code Documentation**.

To navigate within the page you may use the table-of-contents on the top right corner.


Philosophy
-------------------------------------------------
How important is documentation? How should it be structured? How to write it? This
all depends on who will write it and mostly who should use it.

In my projects I can answer the last statement easily because I write it and I will
use it and some other guys may be using my modules. After getting that clear I saw that
mostly I have to decide how it should be.

Someone said good code didn't need any documentation but I disagree and will say
documentation may be extended with good code. I don't want to repeat to much information
already in the code. The documentation should also concentrate on the things the
user needs and don't mix internal developer API for mostly external users.
Good examples are very useful because developers will often look at them
and search the details in the text arround afterwards.

With all these thoughts I created this tool as in between of the existing tools.
The documentation should be easy to write and be right beside the code (it may get
not updated if I have to do it in a separate file). I decided to use markdown
as documentation format and write extra files meant to explain how things go
in general. But if it goes deeper and alongside the code I put the markdown just
above the code in comment blocks.
To get a consistent API display for all methods and functions I allow to use JsDoc
tags for API and add some autodetected information from code analyzation.  
This all have to be transformed to be displayed in a modern web interface viewable
on any device and searchable (at least through google).

As I sometimes also read documentation about the internal structure and API I added
another mode called code view which is designed for the internal module developer.
To decide which documentation element belongs to the internal developer and which
to the general documentation I used different comment blocks in each language.
I also mixed the docco/docker.js concept of doc + code for the internal documentation.


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

Always have a look at the latest changes in the {@link Changelog.md}


CLI Usage
-------------------------------------------------

After global installation you may directly call `codedoc` from anywhere to work
in the current or defined directory.

See the {@link codedoc.1.md} for explanation of the command line call and its
options.

### Setup

Which files to use firstly depends on the selection of the input folder and the
filter conditions. These filter conditions can be set indirectly using the `.docignore`
or `.gitignore` files.

Resources like images, html or stylesheets will be **copied** directly to the output folder.
Because you may refer to them directly from your documentation.
Additional resources in other directories not included in code (ignored by above) can be
given as `.docresource` list.


API Usage
-------------------------------------------------

You have to
1. include it into your project (as described above)
2. call the {@link setup()} method
3. call the {@link run()} method

See the following example using CoffeeScript or JavaScript:

::: detail CoffeeScript
``` coffee
# load modules
codedoc = require 'alinex-codedoc'
config = require 'alinex-config'
# setup the template search paths and config
codedoc.setup (err) -> config.init (err) -> main()

# running the document generation
main = ->
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
::: detail JavaScript
<!-- {selected} -->
``` coffee2js
```
:::
<!-- {container:size=max} -->

Find more information about calling the code documentation in the {@link index.coffee}.


Workflow
-------------------------------------------------

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






Custom Layout / Style
-------------------------------------------------

If you want to use your own style templates within your app's config directory
and you're already using {@link alinex-config} you only have to register the
template type on it by putting the following on top:

::: detail
``` coffee
config = require 'alinex-config'
# set module search path
# (with paths for calling in the upper directory)
config.register 'codedoc', __dirname,
  folder: 'template'
  type: 'template'
```
:::

::: detail
``` js
config = require('alinex-config');
// set module search path
// (with paths for calling in the upper directory)
config.register('codedoc', __dirname, {
  folder: 'template',
  type: 'template'
});
```
:::

This allows you to put your templates also under:
- var/src/template/report/...
- var/local/template/report/...
- /etc/<yourapp>/template/report/...
- ~/.<yourapp>/template/report/...


Debugging
-------------------------------------------------
If you have any problems you may debug the code with the predefined flags. It uses
the {@link debug} module to let you define what to debug.

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

(C) Copyright 2016-2017 Alexander Schilling

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

>  <https://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
