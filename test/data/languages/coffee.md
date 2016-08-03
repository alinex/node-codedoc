Example: CoffeeScript
=================================================

> In the following examples I will use code from the codedoc package. But it is slightly
> changed to see more of the possibilities.

Main Documentation
--------------------------------------------------

First things always are the general files:
- [README.md](https://raw.githubusercontent.com/alinex/node-codedoc/master/README.md) - \
  the index page in markdown
- [Changelog.md](https://raw.githubusercontent.com/alinex/node-codedoc/master/Changelog.md) - \
  the changes per each version

Next you should add the main headding with some explanation:

``` coffee
###
Controller - Package Main
=================================================
This module is used as the base API. If you load the package you will get a reference
to the exported methods, here. Also the CLI works through this API.
###
```

Next maybe some more explanation as subheadings with detailed description, graphs and
overall examples:

```
Workflow
-------------------------------------------------

The following graph will show you the basic steps in creating the documentation:

> Plantuml is cut out to make example shorter!

#3 Sorting

The file links are sorted in a natural way. This is from upper to lower directories
and alphabetically but with some defined orders. This means that 'index.*' always
comes before 'README.md' and the other files.
###
```

As you see above the `#3`-heading syntax is special an no propper markup, it should be
`###` but because this will collide with the doc block delimiter we use a special syntax
here.


External API
--------------------------------------------------
The external API is also put in such doc block comments with some annotation tags
just before the function definition:

``` coffee
###
@param {object} setup defining the document creation
- `input` - path to read from
- `òutput`- output directory to store to
- `find` - source search pattern
  - `include` - files to include see [alinex-fs](https://alinex.github.io/node-fs)
  - `exclude` - files to exclude see [alinex-fs](https://alinex.github.io/node-fs)
- `brand` - branding name to remove from automatic titles
- `verbose` - level of verbose mode
@param {function(err)} cb function to be called after done
###
exports.run = (setup, cb) ->
  # set up system
  setup.input = path.resolve setup.input ? '.'
  # code goes on...
```

As there is no heading it will be auto created as 'run()' from the first code line.
As you see there are alos some parameter described.


Internal API
--------------------------------------------------
This is wwritten as normal command lines.

``` coffee
# Sorting the page map is done by generating sort strings for each page from the
# order in the lists above, the file depth and file name. The keys will be sorted
# and a new object is generated in this sort order.
#
# @param {object} map map of pages
# - `parts` is used to calculate the order
# @param {boolean} [reverse=false] flag for reversed sorting
# @return {object} the sorted map of pages
sortMap = (map) ->
  # code goes on...
```

The parameter for reversed sorting also shows you how to mark an parameter as optional
and give it some default values.


Tricks and Tips
--------------------------------------------------

### Problem with name detection

If the system can't autoatically detect the element name you may use the `@name`
tag to add it yourself:

``` coffee
###
@name stat()
@param {String|Buffer} path local path to check
@param {function(err, stats)} cb callback which gets an `Error` or a `Stats` object.
###
module.exports.stat = memoizee fs.stat
```

### Parameters partly internal

Sometimes you have methods, which use some additional internal parameters mostly
in resursive calls. Add them after an `@internal` tag. Everything after this
tag will be ignored for normal View nut added in the internal documentation generation.

``` coffee
###
@param {String} search source path to be searched in
@param {Object} [options] specifications for check which define which files to list
@param {function(err, list)} [cb] callback which is called after done with an `Èrror`
or the complete list of files found as `Àrray`
@internal The `depth` parameter is only used internally.
@param {Integer} [depth=0] current depth in file tree
###
find = module.exports.find = (source, options, cb , depth = 0 ) ->
```

It doesn't matter that the different type of tags are scrambled, they will be output
ordered by type.
