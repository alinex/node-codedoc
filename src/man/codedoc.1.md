Alinex Development Utils
=================================================

The builder helps you to develop node modules.


Usage
-------------------------------------------------

    builder <command> [options] [dir]...

You can give the following commands:

    create   create a new package (interactive)  changes  show changes since last release
    clean    cleanup files
    compile  compile code
    doc      create api documentation
    link     replace released package with locally linked module
    publish  publish package in npm
    pull     pull newest version from repository
    push     push changes to remote repository
    test     run automatic tests

General Options:

    --help, -h      Show help                                            [boolean]
    --nocolors, -C  turn of color output                                 [boolean]
    --verbose, -v   run in verbose mode (multiple makes more verbose)      [count]
    --quiet, -q     don't output header and footer                       [boolean]

Examples:

    builder test -vb            to run the tests till first failure
    builder test -v --coverage  to run all the tests and also show
    --browser                   coverage info
    builder changes             show overview of changes
    builder publish --minor     to publish on npm new minor version

You may use environment variables prefixed with 'BUILDER_' to set any of
the options like 'BUILDER_VERBOSE' to set the verbose level.

For help for a specific command call:

    builder <command> --help

This will show also the specific options, only available for this command.


Commands and options
-------------------------------------------------

The tool will be called with

    builder [dirs] [general options] <command> [command options]

With the option `--help` a screen explaining all commands and options will be
displayed. The major commands will be described here.

Multiple directory names can be given. They specify on which project to work on.
It should point to the base package directory of a module. If not specified the
command will run from the current directory.
You may change the order of the options like you want but keep the directories
before them. If you give a directory just behind a command it is interpreted
as additional command instead as directory.

### General options

`-v` or `--verbose` will display a lot of information of what is going on.
This information will sometimes look discarded because of the parallel
processing of some tasks.

`-C` or `--no-colors` can be used to disable the colored output.

### Command `create`

Create a new package from scratch. This will create:

* the directory
* make some initial files
* init git repository
* setup github repository
* add and commit everything

The create task needs the `--password` setting to access github
through the api. And you may specify the `--package` setting for the npm name
of the package. The also mandatory path will be used as the github repository
name, too.

Some example calls will look like:

    > builder ./node-error create --package alinex-error
    > builder ./private-module create --private

This process is interactive and will ask you some more details. After that you
may directly start to add your code.


### Command `push`

This will push the changes to the origin repository. With the `--message` option
it will also add and commit all other changes before doing so.

    > builder push                  # from within the package directory
    > builder ./node-error push     # or from anywhere else

Options:

    --message, -m  Commit message for local changes                       [string]

### Command `pull`

Like `push` this will fetch the newest changes from git origin.

    > builder pull                  # from within the package directory
    > builder ./node-error pull     # or from anywhere else

    Pull from origin
    Von https://github.com/alinex/node-make
     * branch            master     -> FETCH_HEAD

### Command `link`

This task will link a local package installed in a parallel directory into the
packages node_modules directory.

    > builder link                  # link all node-... as alinex-...  packages
    > builder link --locale config  # or link only the config package

Options:

    --link, -l  package name to link                                      [string]
    --local     local path which is used                                  [string]

### Command `compile`

This task is used to compile the sources into for runtime optimized library.

    > builder compile               # from within the package directory
    > builder ./node-error compile  # or from anywhere else

Options:

    --uglify, -u  run uglify for each file                               [boolean]

Mostly this task will be added as prepublish script to the `package.json` like:

    "scripts": {
      "prepublish": "node_modules/.bin/builder compile -u"
    }

Also this will make man files from mardown documents in `src/man` if they
are referenced in the package.json.

### Command `test`

As a first test a coffeelint check will be run. Only if this won't have any
errors the automatic tests will be run.

If the [istanbul](http://gotwarlost.github.io/istanbul/) module is installed
a code coverage report will be build.

    > builder test                  # from within the package directory
    > builder ./node-error test     # or from anywhere else

Options:

    --bail, -b   stop on first error in unit tests                        [string]
    --coverage   create coverage reports                                 [boolean]
    --coveralls  send coverage to coveralls                              [boolean]
    --browser    open results in browser                                 [boolean]

### Command: `doc`

Generate the documentation this will create the documentation in the `doc`
folder. It includes the API documentation with code. Each module will get his
own documentation space with an auto generated index page.

This tool will extract the documentation from the markup and code files in
any language and generate HTML pages with the documentation beside the
code.

    > builder doc                   # from within the package directory
    > builder ./node-error doc      # or from anywhere else

Options:

    --publish  publish documentation                                     [boolean]
    --browser  open api in browser                                       [boolean]

### Command `changes`

This will list all changes (checkins) which are done since the last publication.
Use this to check if you should make a new publication or if it can wait.

    > builder changes

Options:

    --skip-unused, -s  Skip check for unused packages                    [boolean]

### Command `publish`

With the push command you can publish your newest changes to github and npm as a
new version. The version can be set by signaling if it should be a `--major`,
`--minor` or bugfix version if no switch given.

To publish the next bugfix version only call:

    > builder publish               # from within the package directory
    > builder ./node-error publish  # or from anywhere else

Options:

    --major    release next major version                                [boolean]
    --minor    release next minor version                                [boolean]
    --version  version to release                                         [string]
    --release  release message                                            [string]
    --force    force publish also on problems

And you may use the switches `--try` to not really publish but to check if it will
be possible and `--force` to always publish also if it is not possible because of
failed tests or not up-to-date dependent packages.

### Command: `clean`

Remove all automatically generated files. This will bring you to the initial
state of the system. To create a usable system you have to build it again.

To clean everything which you won't need for a production environment use
`--dist` or `--auto` to remove all automatically generated files in the
development environment.

To cleanup all safe files:

    > builder clean                 # from within the package directory
    > builder ./node-error clean    # or from anywhere else

Options:

    --auto, -a  Remove all automatically generated folders               [boolean]
    --dist      Remove unneccessary folders for production               [boolean]

Configuration
-------------------------------------------------

### Document Template

You may specify a different document layout by creating a file named like the
main part of your package (name till the first hyphen). Use the file
`/var/src/docstyle/default.css` as a default and store your own in
`/var/local/docstyle/<basename>.css`.

Also the javascript may be changed for each package basename in `<basename>.js`
like done for the css.


License
-------------------------------------------------

Copyright 2013-2014 Alexander Schilling

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

>  <http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
