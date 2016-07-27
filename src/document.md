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

See the following table for the detected styles per each language.

Like in the above languages a lot of other ones are supported, too:

|     Language       |    Doc Comment   | Internal API ^1^  | Code Comments ^2^ |
| ------------------ | ---------------- | ----------------- | ----------------- |
| CoffeeScript       | ### ... ###      | #...              | #...              |
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

In hash block comments a triple hash '###' is the end of the doc comment
so it cant be used as it's markdown format for a heading level 3. As workarround
you may use '#3...' which is no standard markdown but works here. The same goes
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
heading markdown. See the example below:

EXAMPLE

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

:   - [trim](trim.coffee) as alternative implementation

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
    - `@constructor` flag to define method as constructor
    - also the title from the auto heading also if not used there will be used
    - `@param` definition of possible parameter names

Definition List
:   Different definitions:
    - `@param`, `@arg`, `@argument` a method parameter with optional type
      given as: `@param {<type>} <name> <description>`
    - `@return`, `@returns` defining what will be returned
      given as: `@return {<type>} <description>`
    - `@throws`, `@exception` descripe possible excepzions
      given as: `@throws {<type>} <description>`
    - `@event`, `@fires` descripe events to be thrown
      given as: `@event {<type>} <name> <description>`
    - `@see` references additional information, use `{@link...}` within

Signature Line
:   Copyright and legal information which will be displayed as line at the end:
    - `@version` specific version
    - `@copyright` copyright noticr
    - `@author` name and possibly mail link to author and developers
    - `@license` license for this part

Other Specialities
:   `@internal` - lets you add some text at the bottom which is only displayed in
    codeview (use it in normal doc comments)

The `@todo` format also allows to easily define optional parameters and default values:
`@todo {integer} [max=5] maximum number of...`. You add square brackets to the variable
name to declare it as optional and you add an equal sign and default value if you want.

These are mostly based on CoffeeScript and JavaScript, but others will follow if needed.
Is something missing here? Don't hestitate and make an issue on the
[GitHub Page](https://github.com/alinex/node-codedoc/issues).
