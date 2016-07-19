Templates
=================================================

As described in the [Usage](../README.md#Usage) and [Manpage](man/codedoc1.md)
you may not only select a predefined template but also add your own.

The template consists of two parts:
- the HTML Template - defining the page structure
- the CSS Stylesheet - style up everything to your liking

Maybe you need also some third party resources like Bootstrap or jQuery. This won't
be included in your documentation. Often you can use them from some CDN (Content
Delivery Network) which will be faster.


HTML Template
--------------------------------------------------
The template is a basic HTML with [Handlebars](http://alinex.github.io/develop/lang/handlebars.html)
markup language and the [alinex-handlebars](http://alinex.github.io/node-handlebars/README.md.html)
extension.

Within the template you may use the following variables:
- __title__ - page title
  This is meant for the header within the title: `<title>{{title}}</title`.
- __locale__ - language setting
  You may use this in the html-tag: `<html lang="{{locale}}">`
- __header__  - additional header tags
  This is a collection of tags for the header like scripts or style includes. They
  are collected while creating the html, add them in the head-tag as: `{{{join header ""}}}`
- __content__ - the main part
  The content is a string of html therefore you have to use triple braces to
  include: `{{{content}}}`
- __moduleName__ - name of the module itself
  Use `{{moduleName}}` as a heading or name tag within your layout.
- __pages__ - all pages in sorted order
  The list contains different information for each displayable page. Best is to
  iterate over it using `{{#iterate pages}}...{{/iterate}}`. Provides the following fields:
  - __depth__ - of file in tree
    This goes from 0 (main directory) to the number of subdirectories but is only
    set in code view.
  - __title__ - title of the page
    This contains the title from the first heading within the page.
  - __path__ - absolute file path
    Not really useful within the browser but already there because used internally.
  - __link__ - short text (short version of title)
    This is the text you should use in your menu or sidebar because it is mostly
    shorter than the title.
  - __url__ - relative link to it
    The link you have to use to get to this page.
  - __active__ - flag
    Set to `true` if this is the actual page.


CSS Stylesheet
--------------------------------------------------
