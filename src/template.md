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
The template is a basic HTML with [Handlebars](https://alinex.github.io/develop/lang/handlebars.html)
markup language and the [alinex-handlebars](https://alinex.github.io/node-handlebars/README.md.html)
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

### Default codedoc Template

This template is exactly the one used for my own documentation. So if you won't
change anything you will get the alinex layout with logo and links to my site.

> This is done on purpose to show you how to do it. But you may easily remove it
> and change it to your liking.

The default style is called codedoc and is represented within the 4 files:
- codedoc.hbs - base template
- codedoc-logo.hbs - extracted logo part
- codedoc-links.hbs - extracted top links
- codedoc-search-results.hbs - extracted search engine

The layout is divided into 4 files to make overwriting easier. To change something
you may copy the included template files (all or only some) from
`<install-dir>/var/src/template/report` into
`/etc/codedoc/template/report` or `~/.codedoc/template/report` and change them there.

What you may do:
- To remove the headerline completely you only have to remove it in the `codedoc.hbs`
  file.
- To exchange logo and link use `codedoc-logo.hbs` and reference your logo at a public
  url like your site or github raw.
- To let the search work on your site use Googles [site search](https://cse.google.com/cse/all)
  which you can customize and use freely. Use 'results only' as layout and copy the
  html code into `codedoc-search-results.hbs`.
- To add your own top links do so in `codedoc-links.hbs`.
- To remove the search or top links completely remove the html tags from `codedoc.hbs`.


CSS Stylesheet
--------------------------------------------------
The second part is the stylesheet which may get very complex. You can do everything
here. But you need a normal stylesheet.

__Preprocessor__

If you want you may use some preprocessor like styles, less or scssto create the
stylesheets on your own. The default stylesheets are generated using stylus.

### Default codedoc Style

To change the complete layout of the pages you mostly won't have to do much to the
template most things can be changed in the stylesheet.

But to read it better use the commented source under `<install-dir>/var/src/template/report/codedoc.styl`.
