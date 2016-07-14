codedoc(1) - manpage
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

General Options:

    --help, -h      Show help                                            [boolean]
    --nocolors, -C  turn of color output                                 [boolean]
    --verbose, -v   run in verbose mode (multiple makes more verbose)      [count]
    --quiet, -q     don't output header and footer                       [boolean]

Examples:

    coffee src/cli.coffee  to create the default documentation

You may use environment variables prefixed with 'CODEDOC_' to set any of
the options like 'CODEDOC_VERBOSE' to set the verbose level.


License
-------------------------------------------------

Copyright 2016 Alexander Schilling

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

>  <http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
