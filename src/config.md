Configuration
====================================================

You may setup the output to your special needs by configuration. This is done
by giving some customization to the underlying {@link alinex-report} package.

See under {@link alinex-report/src/configSchema.coffee} for a complete information what
may be configured.

In fact you may create your own `report/format/html` settings to get your own layout
and adding an additional style sheet in an additional template folder references in the
configuration.

This has to be given in the style of {@link alinex-config} in one of their possible
directories including the application specific ones like:
- /etc/codedoc
- ~/.codedoc
- var/local (within the installation directory)
