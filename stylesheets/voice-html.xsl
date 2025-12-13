<xsl:stylesheet 
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method="html"/>

    <xsl:template match="/">
        <xsl:apply-templates select="voice"/>
    </xsl:template>

    <xsl:template match="voice">
        <xsl:variable name="alg"><xsl:number value="@algorithm" format="01"/></xsl:variable>
        <xsl:variable name="algorithm-diagram-file">
            <xsl:text>diagrams/alg</xsl:text><xsl:number 
                value="@algorithm" format="01"/><xsl:text>.svg</xsl:text>
        </xsl:variable>
        <html>
            <head>
                <title><xsl:value-of select="@name"/></title>
            </head>
            <body>
                <h1><xsl:value-of select="@name"/></h1>

                <p>Algorithm: <xsl:value-of select="@algorithm"/></p>

<xsl:copy-of select="document($algorithm-diagram-file)"/>

            </body>
        </html>
    </xsl:template>

</xsl:stylesheet>
