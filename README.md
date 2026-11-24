# dx7-xml
XML Schema and transformation utilities for the Yamaha DX7 patch model

## Validation

To validate the XML documents against the schema, use `xmllint`:

    xmllint --xinclude --noout --schema schema/cartridge-v1.xsd data/testcartridge.xml

This will process the XInclude elements first, and then validate the result against the XML Schema. The `--noout` parameter suppresses the output of the validated document.

To validate the schema itself, use the Python script `validate_schema.py` (you will need
the `xmlschema` package installed):

    python3 tools/validate_schema.py

Resolving XIncludes:

    xmllint --xinclude --output data/all-initvoice-cartridge-flat.xml data/all-initvoice-cartridge.xml

## XSL stylesheets

Some XSL stylesheets for transformation are found in the `stylesheets` directory.

### list-voices.xsl

Lists the names of the voices in a cartridge. Use an XSLT processor like `xsltproc`
to perform the transformation:

    xsltproc --xinclude stylesheets/list-voices.xsl data/testcartridge.xml

### voice-html.xsl

Generates an HTML page from a voice.

    xsltproc --xinclude stylesheets/voice-html.xsl data/brass1.xml

### flatten.xsl

Flattens the XML Schema definition into one file for convenience.

    xsltproc --xinclude stylesheets/flatten.xsl schema/cartridge-v1.xsd

Redirect the results to a file, maybe called `cartridge-v1-flat.xsd`.

### emit-sysex.xsl

Converts the cartridge data to binary SysEx format. Note that this stylesheet
uses XSLT 2.0 features, so it cannot be used with xsltproc. Instead, you need
an XSLT processor like Saxon to handle this task. It would be invoked with
something like

    java -cp ~/SaxonHE12-9J/saxon-he-12.9.jar net.sf.saxon.Transform \
    -s:data/testcartridge-no-xinclude.xml -xsl:stylesheets/emit-sysex.xsl

The output is hex-encoded bytes:

    f0 43 ... f7
    
## Compacting the schema

To "un-pretty-print" the schema to save bandwidth, first flatten the schema,
then use

    xmllint --noblanks schema/cartridge-v1-flat.xsd

to remove non-essential whitespace.

## Algorithm diagrams

The algorithm diagrams in SVG format were generated with [svgbob](https://github.com/ivanceras/svgbob). They are found in the `stylesheets/diagrams` directory.


## TODO

* Stylesheet or tool to transform a full cartridge and/or an
individual voice to the DX7 MIDI System Exclusive format (WIP)
* Stylesheet or tool to transform a DX7 MIDI System Exclusive
file to the XML format
* Tool to generate source code based on the schema, to process the data model
