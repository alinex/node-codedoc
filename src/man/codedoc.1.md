codedoc(1) - Manpage
=================================================

A code documentation extractor used to create browsable documentation out of your inline
documentation.


Usage
-------------------------------------------------

    codedoc [options] [dir]

Document Options:

    --input, -i   directory to analyse code                               [string]
    --output, -o  directory to write html site to      [string] [default: "./doc"]
    --style, -s   set layout style to use                                 [string]
    --code, -c    add highlighted code                                   [boolean]

General Options:

    --help, -h      Show help                                            [boolean]
    --nocolors, -C  turn of color output                                 [boolean]
    --verbose, -v   run in verbose mode (multiple makes more verbose)      [count]
    --quiet, -q     don't output header and footer                       [boolean]

Examples:

    coffee src/cli.coffee  to create the default documentation

You may use environment variables prefixed with `CODEDOC_` to set any of
the options like `CODEDOC_VERBOSE` to set the verbose level.


Define Ignores
-------------------------------------------------

To define which files to ignore while parsing for documentation the system will use
the same format as git in two possible files:

    .docignores
    .gitignores

The format is more described at [gitignore](https://git-scm.com/docs/gitignore).


Include the Code
-------------------------------------------------
To get a developer documentation with code display use the additional `--code`
switch to add them. If not only the files which contain doc comments and only they
will be displayed.

See this documentation:

- [without code](http://alinex.github.io/node-codedoc/src/man/codedoc.1.md.html)
- [with code](http://alinex.github.io/code-codedoc/src/man/codedoc.1.md.html)

The links to the pages are also only indented based on the file level depth if
code is enabled.


Use other Styles
-------------------------------------------------
The standard 'codedoc' style used for this documentation can be found in the
following files:

- `var/src/template/report/codedoc.hbs`
- `var/src/template/report/codedoc.css`

To change it, make a copy or new files with your own style name under:

- global:
  - `/etc/alinex/template/report/yourstyle.hbs`
  - `/etc/alinex/template/report/yourstyle.css`
- install dir:
  - `var/local/template/report/yourstyle.hbs`
  - `var/local/template/report/yourstyle.css`

You may also use your apps directory if you init it with the `register()` method
of the [alinex-config](http://alinex.github.io/node-config) with the `template`
type.

The changed directory to the source is essential to make them stay while updating
the system.


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
