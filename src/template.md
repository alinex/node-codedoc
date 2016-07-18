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
- __moduleName__
- __files__
  - __depth__
  - __title__
  - __path__
  - __link__
  - __url__
  - __active__


CSS Stylesheet
--------------------------------------------------
