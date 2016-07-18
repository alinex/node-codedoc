Writing Docs
=================================================

To use codedoc you have to write your documentation into documentation files
or/and within the code as comment blocks. The format should be simple or extended
markdown maybe with jsDoc/JavaDoc like annotations.


Documents
-------------------------------------------------
If you write some documents into separate files name them with a markdown extension
of `*.md` like:

    README.md
    Changelog.md


Comment Blocks
-------------------------------------------------
Additionally you can document within the code. Here we decide between code comments
and documentation comments. They differ in the used style for comment. Most languages
know such different types for documentation code:

``` javascript
/**
 *  Document comment for function
 */
x = function () {
  // inline code comment
  /* multiline code comment */
}
```

``` coffee
###
Document comment for function
###
x = ->
  # inline code comment
```

Only the documentation code is extracted and formated as markdown. All other lines
will be displayed as code with highlights.

Like in the above languages a lot of other ones are supported, too:

|   Language   | Doc Comment | Other Comments  |
| ------------ | ----------- | --------------- |
| CoffeeScript | ### ... ### | #...            |
| JavaScript   | /** ... */  | //... or /*..*/ |
| LiveScript   | /** ... */  | //... or /*..*/ |

### Fixtures

In CoffeeScript block comments a triple hash '###' is the end of the doc comment
so it cant be used as it's markdown format for a heading level 3. As workarround
you may use '#3...' which is no standard markdown but works here. The same goes
with the other deeper headings level 4, 5 and 6.


Markdown
-------------------------------------------------
You write your documentation in the markdown format which is nearly as writing it
in pure text down. For the simplest styles you won't have to know anything, just
write it down. But to get more out of it look into the description of
[alinex-report](http://alinex.github.io/node-report) for examples and a detailed
descriptions of the basic styles as well as extended formats like:

- tables
- fontawesome
- graphs
- UML diagrams using (plantuml)
- and more...

### First Heading

The first heading in each document will be the page title and also the name in the
menu list. So think of a good headline at least for the first heading.

To make menu entries more compact the heading will be split on ': ' and ' - ' in
parts and only the last part is used as menu entry.


JsDoc/JavaDoc
-------------------------------------------------
In the near future a lot of JsDoc/JavaDoc Tags will be supported, too.
