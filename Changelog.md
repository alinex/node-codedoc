Version changes
=================================================

The following list gives a short overview about what is changed between
individual versions:

Version 1.2.11 (2016-08-24)
-------------------------------------------------
- Fix new bug in link search.
- Update alinex-core@0.2.10
- Allow include of schema documentation from code.
- Six error messages for unknown internal tag.
- Fix response buffer keeps connection open.
- Updated ignore files.
- Updated ignore files.
- Fix test of include.
- Remove .docignore from npm package.
- Update travis.
- Update travis.
- Optimize trim of code to work only on the end.
- Merge branch 'master' of https://github.com/alinex/node-codedoc
- Add changelog link in doc.

Version 1.2.10 (2016-08-19)
-------------------------------------------------
- Remove test output.
- Optimize cleanup of matched hash-api docs.
- Remove empty code elements.
- Change sort order to put manual before code doc.

Version 1.2.9 (2016-08-18)
-------------------------------------------------
- Fix hash-api parsing for multiple following comments.
- Removed comment.
- Update alinex-report@2.1.11, alinex-fs@3.0.0, yargs@5.0.0
- Update docs.
- Change bullet sign in sidebar navigation.
- Fix parsing indented hash-api doc comments.
- Update docs for parallel setting.
- Optimize style code display.
- New batches added with links.
- Change badges.
- Optimize debugging.
- Change fs calls for next generation alinex-fs.
- Use direct fs-copy method.
- Small fix in Readme.
- Change icon color in boxes.

Version 1.2.8 (2016-08-13)
-------------------------------------------------
- Upgrade alinex-util@2.4.0
- Add border radius to boxes in default style.
- Optimize box styling.
- Optimize the doc for the philosophy behind.
- Add coffee example for problematic doc block comment.
- Check only the first 5 MDN links.
- Check all entries from MDN search results list.

Version 1.2.7 (2016-08-12)
-------------------------------------------------
- Update tests for new language structures.
- Allow normal HASH_DOC additionally in CoffeeScript.
- Fix new bug in automatic title addition.
- Control parallel runs through API option or CLI argument.
- Optimized extraction of api to not collide with docs extraction.
- Fix to ignore @tags and headings in code and execute tags and ignore nested extracts.
- Reenable parallel run.
- Short circuit for link search implemented.
- Fix parser to not check for heading within code highlights.
- Add examples for link replacement.
- Search links seriesly makes it slightly slower but reduces requests.

Version 1.2.6 (2016-08-11)
-------------------------------------------------
- Fix trim of unused dash in parameter output.
- Update alinex-fs@2.0.7, alinex-builder@2.3.6
- Extended internal documentation.
- Remove unneccessary dashes in code specification.
- Get correct symbol name also for lazy typing.
- Add small spacing after tables.
- Update documentation.
- Remove support for setup.brand.

Version 1.2.5 (2016-08-09)
-------------------------------------------------
- Upgrade isbinaryfile@3.0.1
- Allow multiple #3 headings to occure in one document.
- Add test for npm linksearch.
- Add docu for npm linksearch.
- Add npm package link search.
- Documentation update.

Version 1.2.4 (2016-08-08)
-------------------------------------------------
- Remove end-of-toc marker.

Version 1.2.3 (2016-08-08)
-------------------------------------------------
- Small docu fix.
- Add example for tags to documentation.
- Fix normal display.
- Add sidebar to burger menu instead bottom links.
- Fix bug with multiple @link in one row.
- Allow parallel work, again.
- Remove test link from docu.

Version 1.2.2 (2016-08-07)
-------------------------------------------------
- Make tests for @include syntax.
- Cache the request results directly.
- Finished search for links in nodejs with tests.
- Search link cached.
- Add auto resolving of javascript links to MDN.
- Made internal optimize method async.
- Add basic methods for link search addition, later.

Version 1.2.1 (2016-08-05)
-------------------------------------------------
- Fix Changelog, remove special markup.
- Fix bug in include.

Version 1.2.0 (2016-08-05)
-------------------------------------------------
- Keep coffee-script because used by rewire.
- Add support for internal marks in markdown.
- Fix bug with detecting indented doc blocks.
- Extend documentation.
- Completed render tags.
- Make description in @param, @arg, @arguments, @throws, @exception optional.
- Test some tags.
- Update test data.
- Testing of coffee language parsing done.
- Add test possibility for parsing.
- Test: language definition and recognition.
- Create test structure.
- Add support for @include ... tag.
- Add titles to the inline links.
- Optimize floating styles.
- Allow multiple inline tags in report.
- Fix tag splitting.
- Fixed tag parser with inline tags and optimized page tree view.
- Modularize internal code.

Version 1.1.1 (2016-08-03)
-------------------------------------------------
- Upgraded to alinex-report@2.1.10, alinex-builder@2.3.4
- Fixed multiline tags.
- Extend documentation.
- Merge branch 'master' of https://github.com/alinex/node-codedoc
- Update graph.
- Add index in doc graph.
- Update documentation.
- Add support for inline @link tags.
- Add more coffee examples.
- Better error reporting on wrong param tags.
- Support depth also in general docs (default layout only from level 2).
- Fixed bug where code was above toc.
- Add @throw as alias for @throws.

Version 1.1.0 (2016-07-28)
-------------------------------------------------
- Add file write retry.
- Add print styles.
- Add coffeescript example.
- More doc changes.
- Added code documentation.
- Add philosophy section.
- Add @internal support.
- Add documentation for @internal tag.
- Document @param format with optional and default.
- Update docs for template changes.
- Update docs.
- At least two lines for coffee hash doc.
- Remove google ads.
- Add .es6 file extension for javascript.
- Allow alternative #3 heading syntax for all heading levels.
- Add ability to disable comments from documentation.
- Run multiple tries for file copy.
- Change some links to https.
- Fix plantuml graph.

Version 1.0.0 (2016-07-25)
-------------------------------------------------
- Update template docs.
- Use includes in handlebars templates.
- Descripe access parsing in language.
- Mark examples as code.
- Fix some language detection bugs for coffeescript.
- Fix decorator style.
- Fix access detection.
- Fix parsing of only tags.
- More API tags supported with some auto detection.
- Add deprecation and definitions from tags.
- Support first tags.
- Initial jsddoc help.
- Only check for headings 1-3 to add automatically.
- Add parsing for tags and auto add title if not there.
- Remove messages from debug if send for verbose mode.
- Fix scroll problem on table-of-contents.
- Upgrade alinex-builder@2.3.2

Version 0.5.2 (2016-07-21)
-------------------------------------------------
- Update alinex-report@2.1.8
- Position toc header.
- Add table of contents link for further pages.
- Be even more verbose.
- Allow verbose settings.
- Fix copy resource job.
- Scrollbars only vertical in toc.
- Update documentation.
- Optimize debug support.
- Bug: Sometimes not reaching finished state and without error.

Version 0.5.1 (2016-07-21)
-------------------------------------------------
- Fix line numbers in code.
- Fixed duplicate view of API comments.
- Optimize table-of-contents style.
- Fix link in index page.

Version 0.5.0 (2016-07-21)
-------------------------------------------------
- Fix optimizations of api code parsing.
- Fix inline API parsing.
- Fix use of new lang structure.
- Use the new doc extraction with optimizations.
- Update language doc parsing with three comment types.
- Use https anywhere.

Version 0.4.0 (2016-07-20)
-------------------------------------------------
- Update alinex-fs@2.0.6
- Copy resources to documentation.
- Also let js and css links untouched.
- Add google search.

Version 0.3.3 (2016-07-19)
-------------------------------------------------
- Fix package.

Version 0.3.2 (2016-07-19)
-------------------------------------------------
- Upgraded alinex-builder@2.3.0
- Add info about stylesheets.
- Fix anchor point of links.
- Add table of contents.
- Also keep image links untouched.
- Fix internal page linking.
- Create index page if not there.

Version 0.3.1 (2016-07-19)
-------------------------------------------------
- Add missing main link in package.json.

Version 0.3.0 (2016-07-19)
-------------------------------------------------
Now supporting the docuemntation and code view mode.

- Upgrade yargs@4.8.1
- Add description of handlebars template variables.
- Start documenting the templates.
- Add options in man and debug possibilities.
- Optimize API documentation.
- Update all language formats.
- Change style of headings.
- Optimize documentation.
- Add install and usage information for api.
- Add description for #3 headings.
- Fix link to examples.
- Only indent page links if code view enabled.
- Allow code display to be enabled.
- Add help about documenting.
- Add handlebars support and github link.
- Optimize documentation.
- Add link to doc page hidden there.
- Add link to doc page hidden there.
- Add stylus and css highlighting.
- Support javascript and local file links.
- Add correct line numbers.
- Better formating for code lists with line numbers.
- Remove line numbers in text code blocks.
- Allow full height if only code.
- CHange style of further links in small view.

Version 0.2.1 (2016-07-15)
-------------------------------------------------
- upgraded alinex-report@2.1.4

Version 0.2.0 (2016-07-15)
-------------------------------------------------
Enabled file tree with links.

Version 0.1.2 (2016-07-15)
-------------------------------------------------
- Add alinex-util, alinex-config and upgrade alinex-report@2.1.2, alinex-builder@2.2.1, async@2.0.0
- Allow line numbers in code view (but not correct, yet).
- Rename links to Alinex Namespace.
- Add heading to the file list.
- Import report templates into this package.
- Extract first block comments out of coffee files.
- Optimize style.
- Restructure filetree information for new templates.
- Update self documentation with first activity diagram.
- Add file tree to documents.
- Comments for missing data.
- Sort files and add to context for html.

Version 0.1.1 (2016-07-12)
-------------------------------------------------
- Upgraded alinex-report@2.1.1for new layout.
- Use own layout.

Version 0.1.0 (2016-07-11)
-------------------------------------------------
- Fix some lint errors.
- Updated documentation.
- Update help.
- Write html files of markdown.
- Finish language detection.
- File detection working.
- Add development packages: builder, chai.
- Read all text files.
- Setup cli application.
- Initial setup.
