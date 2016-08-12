codedoc(1) - Manpage
=================================================

A code documentation extractor used to create browsable documentation out of your inline
documentation.

__Read the complete documentation under
[https://alinex.github.io/node-codedoc](https://alinex.github.io/node-codedoc).__
<!-- {p: .hide} -->


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
    --parallel, -p  estimated max parallel runs            [number] [default: 100]

Examples:

    coffee src/cli.coffee  to create the default documentation

You may use environment variables prefixed with `CODEDOC_` to set any of
the options like `CODEDOC_VERBOSE` to set the verbose level.


Parameters
-------------------------------------------------

### Document Options

--input, -i

:   Defines the input directory to read as source for the documentation. If nothing
    specified the current directory will be used.

--output, -o  

:   Defines the path where to write the html documentation. The directory will be
    created if it didn't exist. But keep in mind that it won't alert but overwrite
    maybe existing files. The default will be the subdirectory `doc` below the input
    directory.

--style, -s   

:   Give a report layout name (basename of file without extension) to use for the
    document pages. The default ones are 'default' for a content only page layout
    or 'codedoc' (the default) as a responsive layout with header, sidebar. You
    may also define your own, see the full documentation.

--code, -c    

:   Switch between normal mode and code view mode. If set to true the code view is
    enabled in which the source is also output within the code. This makes the
    documentation more appropriate for internal use and for the developer which also
    wan't to extend or change the source.
    But for all other the default view without code should be the more compact and
    there fore better to read version (default).

### General Options

--help, -h      

:   Show the short usage information as a quick help.

--nocolors, -C  

:   Turn of color output. The color output will only be enabled if it is run
    through a terminal and there you may disable it. If called through a cron or
    other automatic process color display is already switched off.

--verbose, -v   

:   Show verbode output. This will show which files are detected and which have some
    problems. Set multiple times for higher verbosity:
    - `-v` - info what parts are running or finished
    - `-vv` - also show files being processed
    - `-vvv` - show information about the files

--quiet, -q     

:   Don't output header and footer. But output everything else like defined.

--parallel, -p

:   Set the maximum number of parallel runs. This is not a fix value but more an
    estimation, because of multiple level of asynchroneous calls the real value may
    be higher in some circumstances. The default is to use 100 or if DEBUG is set to
    use 1 (meaning no parallelism).


Define Ignores
-------------------------------------------------

To define which files to ignore while parsing for documentation the system will use
the same format as git in two possible files:

    /.docignores
    /.gitignores

Only the first file found will be used. It lists files or paths which should be ignored
for documentation. Each line in that file specifies a pattern.
- You may specify files or folders.
- `*` may be used as wildcard
- If the pattern starts with `/` it is matched from the input folder else anywhere
  within the path.

The format is more described at [gitignore](https://git-scm.com/docs/gitignore).


Include the Code
-------------------------------------------------
To get a developer documentation with code display use the additional `--code`
switch to add them. If not only the files which contain doc comments and only they
will be displayed.

See this documentation:
- [without code](https://alinex.github.io/node-codedoc/src/man/codedoc.1.md.html)
- [with code](https://alinex.github.io/code-codedoc/src/man/codedoc.1.md.html)

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
of the [alinex-config](https://alinex.github.io/node-config) with the `template`
type.

The changed directory to the source is essential to make them stay while updating
the system.


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
