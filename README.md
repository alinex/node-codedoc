Alinex CodeDoc: Readme
=================================================

[![Build Status](https://travis-ci.org/alinex/node-codedoc.svg?branch=master)](https://travis-ci.org/alinex/node-codedoc)
[![Coverage Status](https://coveralls.io/repos/alinex/node-codedoc/badge.png?branch=master)](https://coveralls.io/r/alinex/node-codedoc?branch=master)
[![Dependency Status](https://gemnasium.com/alinex/node-codedoc.png)](https://gemnasium.com/alinex/node-codedoc)
[![GitHub](https://assets-cdn.github.com/favicon.ico)](https://github.com/alinex/node-codedoc)
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


Install
-------------------------------------------------

[![NPM](https://nodei.co/npm/alinex-codedoc.png?downloads=true&downloadRank=true&stars=true)
 ![Downloads](https://nodei.co/npm-dl/alinex-codedoc.png?months=9&height=3)
](https://www.npmjs.com/package/alinex-codedoc)

Install the package globally using npm:

``` sh
sudo npm install -g alinex-codedoc --production
codedoc --help
```

After global installation you may directly call `codedoc` from anywhere to work
in the current or defined directory:

``` sh
codedoc --help
```


Usage
-------------------------------------------------

See the online help for now:

``` sh
codedoc --help
```


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
