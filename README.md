# dx7-xml
XML Schema and transformation utilities for the Yamaha DX7 patch model

## Validation

To validate the XML documents against the schema, use `xmllint`:

    xmllint --xinclude --noout --schema schema/cartridge-0.1.xsd data/testcartridge.xml

This will process the XInclude elements first, and then validate the result against the XML Schema. The `--noout` parameter suppresses the output of the validated document.

## XSL stylesheets

Some XSL stylesheets for transformation are found in the `stylesheets` directory.

### list-voices.xsl

Lists the names of the voices in a cartridge. Use an XSLT processor like `xsltproc`
to perform the transformation:

    xsltproc --xinclude stylesheets/list-voices.xsl data/testcartridge.xml


## TODO

* Stylesheet or tool to transform a full cartridge and/or an
individual voice to the DX7 MIDI System Exclusive format
* Stylesheet or tool to transform a DX7 MIDI System Exclusive
file to the XML format
* Stylesheet to transform a cartridge or voice in the XML format
to HTML or other displayable format
* Tool to generate source code based on the schema, to process the data model
