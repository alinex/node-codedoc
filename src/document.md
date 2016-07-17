Doumneting - How to write it?
=================================================

To use codedoc you have to write your documentation into documentation files
or/and within the code as comment blocks. The format should be simple or extended
markdown maybe with jsDoc/JavaDoc like annotations.


Files
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


JsDoc/JavaDoc
-------------------------------------------------
In the near future a lot of JsDoc/JavaDoc Tags will be supported, too.
