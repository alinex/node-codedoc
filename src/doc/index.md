Writing Docs
=================================================

To use codedoc you have to write your documentation into **documentation files**
or/and **within the code** as comment blocks. The format should be **simple or extended
markdown** maybe with jsDoc/JavaDoc like annotations.


Where to write documentation?
--------------------------------------------------

### Extra Documents

If you write some documents into separate files name them with a markdown extension
of `*.md` like:

    README.md
    Changelog.md

Add `<!--` `internal -->` at the start of a document to mark the complete document as
meant for the internal view only.

### Code Documentation

Additionally you can document within the code. That allows you to edit your documentation
where it belongs to and to also make an API documentation.

You have the possibility between three types of documenttation:

- __Documentation and external API__

  This is a top level documentation which goes always into the documentation. Write
  it in the language specific doc comment style.

- __Internal API__

  This is normally ignored in the documentation creation. Only in the 'code view'
  this will be displayed alongside the code itself. The style will be the same as
  for external API. It is written as block comment.

- __Code Comments__

  And at last you may use normal single line comments in the language which won't be
  extracted but shown highlighted within the code view.

The concrete style for each type of comment differs on the used language. See the
following examples for CoffeeScript and JavaScript:

::: detail
``` coffee
###
Document comment for general documentation or to document external API.
###

#
# Document comment for internal function
#
x = ->
  # inline code comment
```
:::

::: detail
``` js
/**
 *  Document comment for general documentation or to document external API.
 */

 /*
  *  Document comment for internal function
  */
x = function () {
  // inline code comment
  /* as single line it's the same */
}
```
:::

See the following table for the detected styles per each language.

Like in the above languages a lot of other ones are supported, too:

|     Language       |    Doc Comment   | Internal API ^1^  | Code Comments ^2^ |
| ------------------ | ---------------- | ----------------- | ----------------- |
| CoffeeScript       | ### ... ### or #### + #... lines | #...              | #...              |
| JavaScript         | /** ... */       | /*...*/, // ...   | //... or /*..*/   |
| LiveScript         | /** ... */       | /*...*/, // ...   | //... or /*..*/   |
| Ruby               | =begin ... =end  | #...              | #...              |
| Python             | ### + #... lines | #...              | #...              |
| Perl               | =pod ... =cut    | #...              | #...              |
| C, C++, c#         | /** ... */       | /*...*/, // ...   | //... or /*..*/   |
| Java, JSP          | /** ... */       | /*...*/, // ...   | //... or /*..*/   |
| Groovy             | /** ... */       | /*...*/, // ...   | //... or /*..*/   |
| PHP                | /** ... */       | /*...*/, // ...   | //... or /*..*/   |
| Bash               | ### + #... lines | #...              | #...              |
| YAML               | ### + #... lines | #...              | #...              |
| SCSS               | /** ... */       | /*...*/, // ...   | //... or /*..*/   |
| Stylus, CSS, Less  | /** ... */       | /*...*/, // ...   | //... or /*..*/   |
| Makefile           | ### + #... lines | #...              | #...              |
| Apache             | ### + #... lines | #...              | #...              |

^1^ Internal API always need multiple contineous comment lines\
^2^ Inline comments are the same as internal API but have only one line

As you see we use the language specific styles here and most languages also use the
same style.

### Exclude Block

If you want a comment block in your code but not in the documentation you can do just
this by adding an exclamation mark after the opening block syntax:
- Hash Docs: `###! ... ###`
- Hash API: `#! ... #`
- C Doc: `/**! ... */`
- C API: `/*! ... */`

#### Hash Doc Fixture

In hash block comments a triple hash `###` is the end of the doc comment
so it cant be used as it's markdown format for a heading level 3. As workarround
you may use `#3...` which is no standard markdown but works here. The same goes
with the other deeper headings level 4, 5 and 6.

How to Write?
-------------------------------------------------
You write your documentation in the **markdown** format which is nearly as writing it
in pure text down. For the simplest styles you won't have to know anything, just
write it down.

> See my own short examples about __[Markdown Syntax](https://alinex.github.io/develop/lang/markdown.html)__
> as an example.

### First Heading

The first heading in each document will be the page title and also the name in the
menu list. So think of a good headline at least for the first heading.

To make menu entries more compact the heading will be split on ': ' and ' - ' in
parts and only the last part is used as menu entry.

### Extended Markdown

But to get more out of it look into the description of
[alinex-report](https://alinex.github.io/node-report) for examples and a detailed
descriptions of the basic styles as well as extended formats like:

- [tables](https://alinex.github.io/node-report/README.md.html#table)
- [fontawesome](https://alinex.github.io/node-report/README.md.html#font-awesome)
- [charts](https://alinex.github.io/node-report/README.md.html#charts)
- [UML diagrams](https://alinex.github.io/node-report/README.md.html#plantuml) using (plantuml)
- [and more...](https://alinex.github.io/node-report/README.md.html#report-elements)

### Internal Sections

If you mark some parts within the document as internal it will only be included in
the internal view (using the `--code` switch):
- add a single `<!--` `internal -->` tag to mark the text from there till the end
- use `<!--` `internal -->` and `<!--` `end internal -->` to mark only a part

The same can be also done using tags (see below) but this is the more general
method working in all markdown sections.

### Automatic Headings in Code

If in programing language files a line of code will follow directly the documentation
block it will be used as heading. The heading will be of level 3 but only added if
no heading level 1-3 is already included.

### Use of Tags

Additionally you can use the default `@xxx`-tags from jsDoc/JavaDoc to document your
code. They will be replaced with properly formated description.

Not all possible tags are supported because this tool won't do a real language agnostic
parsing and therefore mostly code independent tags are supported.  
To use them you have to add them at the start or separated by an empty line from the
heading markdown. See the examples below:

- [CoffeeScript](example/coffee.md)

The HTML layout of the additional information should look like:

::: detail

> **Usage** private: new method(text, cb)

Parameter

:   - text (string) - text to transform
    - cb (function) - callback function

Return

:   (string) transformed text

Throws

:   - `Error` - with code 11 if given text is empty

Event

:   - `error` - if something goes wrong
    - `data` - with additional text info

See also

:   - {@link String.trim()} as alternative implementation

Version 0.1.3 (C) 2016 Alexander Schilling - License: Apache 2.0

:::

### Possible Tags

The following list shows the currently supported tags. You will find further information
to each of them under [JsDoc](http://usejsdoc.org/).

Auto Heading
:   Define the name to be used for the heading if missing.
    - `@name` or `@alias` flags
    - alternatively extracted from first code line

Deprecation Warning
:   `@deprecated` flag defines this part as outdated and you should no longer use
    it because it may be removed in the next versions

Usage Line
:   Specify how to access the code.
    - `@access <string>` to give a specific access level
    - `@private`, `@protected`, `@public` flags as predefined access levels
    - `@static` flag to define as static method
    - `@constant` flag to define as constant variable
    - `@construct`, `@constructor` flag to define method as constructor
    - also the title from the (auto) heading and the names of `@param` definition
      of possible parameter names are used

Definition List
:   Different definitions:
    - `@param`, `@arg`, `@argument` a method parameter with optional type
      given as: `@param {<type>} <name> [<description>]`
    - `@type` defining the type of variables or attributes
      given as: `@type {<type>} <description>`
    - `@return`, `@returns` defining what will be returned
      given as: `@return {<type>} <description>`
    - `@throws`, `@exception` descripe possible excepzions
      given as: `@throws {<type>} <description>`
    - `@event`, `@fires` descripe events to be fired
      given as: `@event {<type>} <name> [<description>]`
    - `@see` references additional information, use `{@link...}` within

Signature Line
:   Copyright and legal information which will be displayed as line at the end:
    - `@version` specific version
    - `@copyright` copyright noticr
    - `@author` name and possibly mail link to author and developers
    - `@license` license for this part

Other Specialities
:   - `@describe`, `@description` adds some more description after the API specification
    - `@internal` - lets you add some text at the bottom which is only displayed in
      codeview (use it in normal doc comments)

Inline Tags
:   - `@link` allows short linking to other pages in this doocumentation by using the
      symbol name (heading of code) or the filename (from source) with anchor and an
      optional title: `{` `@link <symbol> <text>}`.
    - `@include` can be used to include some lines from another source given as
      filename with optional line reference like: `{` `@include <file>#<from>-<to>}`
    - `@schema` can be used to describe data structures based on {@link alinex-validator}
      schema definitions like: `{` `@schema <file>#<access/person>}`. The anchor defines
      the path to the schema from the exported object.

The `@param` format also allows to easily define optional parameters and default values:
`@param {integer} [max=5] maximum number of...`. You add square brackets to the variable
name to declare it as optional and you add an equal sign and default value if you want.

These are mostly based on CoffeeScript and JavaScript, but others will follow if needed.
Is something missing here? Don't hestitate and make an issue on the
[GitHub Page](https://github.com/alinex/node-codedoc/issues).

This applied, your method may look like:

``` coffee
# Sorting the page map is done by generating sort strings for each page from the
# order in the lists above, the file depth and file name. The keys will be sorted
# and a new object is generated in this sort order.
#
# @param {object} map map of pages
# - `parts` is used to calculate the order
# @return {object} the sorted map of pages
sortMap = (map) ->
  # the method content...
```

### Inline Link Posibilities

The inline link feature `{` `@link <uri> <text>}` allows you two get the link from
different sources in the following order (first takes precedence):
- **known symbols** - if the uri is exactly defined as symbol (from parsing documentation)
  a link to this documentation is added
- **documented files** - the path and the filename is checked against all input files
  which are integrated in the documentation
- **alinex packages** - if the name starts with 'alinex-' it will automatically get
  a link to an alinex package of this name
- **internet links** - they are transformed directly to markdown syntax
- **reference** - if nothing of the above matches the link target is searched in
  appropriate references. Which reference to use can be given at the start before a
  colon like: `javascript:String.match()` or if the reference name is missing the
  default for the language of the file (or project for markdowns) will be used.
- else it is kept as text

Possible references are:
- javascript - using the Mozilla Developer Network
- nodejs - using the nodeJS documentation, the npm package list and the Mozilla
  Developer Network

__Examples:__

Here you see some tags with the converted markdown just below (no space between
`{` and `@` allowed, this is only to don't interpret here):

    # internal symbol
    { @link test()}
    [`test()`](../../test.coffee.html#test "File: test.coffee Element: test()")

    # internal symbol (lazy written)
    { @link test}
    [`test()`](../../test.coffee.html#test "File: test.coffee Element: test()")

    # local documentation file
    { @link /src/test.coffee}
    [Test Page](test.coffee.html "File: /src/test.coffee")

    # local documentation file (without full path)
    { @link test.coffee}
    [Test Page](test.coffee.html "File: test.coffee")

    # alinex package name
    { @link alinex-config}
    [alinex-config](https://alinex.github.io/node-config)

    # internet address
    { @link http://heise.de}
    [http://heise.de](http://heise.de)

    # javascript reference
    { @link String.match()}
    [String.prototype.match()](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/match)

    # nodeJS reference
    { @link fs.readFile()}
    [fs.readFile()](https://nodejs.org/dist/latest-v6.x/docs/api/fs.html#fs_fs_readfile_file_options_callback)

    # NPM package
    { @link async}
    [async](https://www.npmjs.com/package/async)

    # all other things (not linked)
    { @link thisisnotanythere}
    thisisnotanythere

### Include Inline Images

Through a small trick you may add images as inline data. Add them as local file link
`file://...` and the report component will embed them.

### Describe alinex-validator Schema

If you already made a schema definition for technical checking your input data you
may also use the same information to automatically generate your documentation for
it:

``` coffee Schema to be used in file.coffee
exports.selfcheck =
  title: "Float"
  description: "a float schema definition"
  type: 'object'
  allowedKeys: true
  keys: util.extend rules.baseSchema,
    default:
      title: "Default Value"
      description: "the default value use if nothing given"
      type: 'float'
      optional: true
    sanitize:
      title: "Sanitize"
      description: "a flag which allows removing of non numeric characters before evaluating"
      type: 'boolean'
      optional: true
    unit:
      title: "Source Unit"
      description: "the unit in which an only numeric value is given, will transform to base unit"
      type: 'string'
      optional: true
      minLength: 1
```

This may be included in your doc like:

``` markdown
Schema Specification
---------------------------------------------------
{ @schema #selfcheck}
```

This is all to be used to generate the following markdown automatically:

``` markdown
Schema Specification
---------------------------------------------------
An object. And the following keys are allowed: title, description, key, type, optional, default, sanitize, unit, round, decimals, min, max, toUnit, format, locale. The following entries have a specific format:

- default: A numeric floating point number which is optional.
- sanitize: A boolean value, which will be true for ‘true’, ‘1’, ‘on’, ‘yes’, ‘+’, 1, true and will be considered as false for ‘false’, ‘0’, ‘off’, ‘no’, ‘-’, 0, false. It’s optional.
- unit: A text entry which is optional.Control characters will be removed. It has to be at least 1 characters long.
```

### Automatic Code Transformation

It is also possible to transform your code automatically itself or into a copy.

At the moment the possible transformators are:
- coffee2js

To use it use the transformator name as language in the markdown code block (without
the spaces between the backquotes):

```` markdown
``` coffee2js
x = (a) -> a*2
```
````

You may also add the code in a copy to show both versions. Here it is also put in tabbed
boxes by give the transformer an empty code:

```` markdown
### detail
``` coffee
x = (a) -> a*2
```
###

### detail
``` coffee2js
```
###
````

This will result in both being displayed as tabs in a box.


Sort Order
------------------------------------------------------------------
Sorting the file's documents is based on a fixed ruleset. This will sort everything
in order using the following rules:

1. Readme, Manual
2. Documents
3. Code documentation
4. Additional data files
5. Changelog

Within each type the 'index.*' files will be put first and one level higher in
the tree than the rest of the same folder.
