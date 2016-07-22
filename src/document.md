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
| CoffeeScript       | ### ... ###      | #...              | #...              | CS_DOC HASH_API
| JavaScript         | /** ... */       | /*...*/, // ...   | //... or /*..*/   | C_DOC C_API
| LiveScript         | /** ... */       | /*...*/, // ...   | //... or /*..*/   | C_DOC C_API
| Ruby               | =begin ... =end  | #...              | #...              | RB_DOC HASH_API
| Python             | ### + #... lines | #...              | #...              | HASH_DOC HASH_API
| Perl               | =pod ... =cut    | #...              | #...              | PL_DOC HASH_API
| C, C++, c#         | /** ... */       | /*...*/, // ...   | //... or /*..*/   | C_DOC C_API
| Java, JSP          | /** ... */       | /*...*/, // ...   | //... or /*..*/   | C_DOC C_API
| Groovy             | /** ... */       | /*...*/, // ...   | //... or /*..*/   | C_DOC C_API
| PHP                | /** ... */       | /*...*/, // ...   | //... or /*..*/   | C_DOC C_API
| Bash               | ### + #... lines | #...              | #...              | HASH_DOC HASH_API
| YAML               | ### + #... lines | #...              | #...              | HASH_DOC HASH_API
| SCSS               | /** ... */       | /*...*/, // ...   | //... or /*..*/   | C_DOC C_API
| Stylus, CSS, Less  | /** ... */       | /*...*/, // ...   | //... or /*..*/   | C_DOC C_API
| Makefile           | ### + #... lines | #...              | #...              | HASH_DOC HASH_API
| Apache             | ### + #... lines | #...              | #...              | HASH_DOC HASH_API

^1^ Internal API always need multiple contineous comment lines\
^2^ Inline comments are the same as internal API but have only one line

As you see we use the language specific styles here and most languages also use the
same style.

#### Fixtures

In CoffeeScript block comments a triple hash '###' is the end of the doc comment
so it cant be used as it's markdown format for a heading level 3. As workarround
you may use '#3...' which is no standard markdown but works here. The same goes
with the other deeper headings level 4, 5 and 6.


How to Write?
-------------------------------------------------
You write your documentation in the **markdown** format which is nearly as writing it
in pure text down. For the simplest styles you won't have to know anything, just
write it down.

> See my own short examples about __[Markdown Syntax](http://alinex.github.io/develop/lang/markdown.html)__
> as an example.

### First Heading

The first heading in each document will be the page title and also the name in the
menu list. So think of a good headline at least for the first heading.

To make menu entries more compact the heading will be split on ': ' and ' - ' in
parts and only the last part is used as menu entry.

### Extended Markdown

But to get more out of it look into the description of
[alinex-report](http://alinex.github.io/node-report) for examples and a detailed
descriptions of the basic styles as well as extended formats like:

- [tables](http://alinex.github.io/node-report/README.md.html#table)
- [fontawesome](http://alinex.github.io/node-report/README.md.html#font-awesome)
- [charts](http://alinex.github.io/node-report/README.md.html#charts)
- [UML diagrams](http://alinex.github.io/node-report/README.md.html#plantuml) using (plantuml)
- [and more...](http://alinex.github.io/node-report/README.md.html#report-elements)

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

The following list shows the currently supported tags. You will find further information
to each of them under [JsDoc](http://usejsdoc.org/).

Auto Heading

:   Define the name to be used for the heading if missing.
    - `@name` or `@alias` flags
    - alternatively extracted from first code line

Access Line

:   Specify how to access the code.
    - `@access <string>` to give a specific access level
    - `@private`, `@protected`, `@public` flags as predefined access levels
    - `@static` flag to define as static method
    - `@abstract`, `@virtual` flag to mark as abstract method
    - `@constant` flag to define as constant variable
    - `@constructor` flag to define method as constructor

Info Line

:   Comes soon...

Is something missing here? Don't hestitate and make an issue on the
[GitHub Page](https://github.com/alinex/node-codedoc/issues).
