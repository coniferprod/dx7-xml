<xsl:stylesheet 
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method="text"/>

    <xsl:template match="/">
        <xsl:apply-templates select="cartridge"/>
    </xsl:template>

    <xsl:template match="cartridge">
        <xsl:apply-templates select="voices/voice"/>
    </xsl:template>

    <xsl:template match="voice">
        <!-- Generate a row like "01 BRASS   1" -->
        <xsl:number value="position()" format="01"/>
        <xsl:text>&#x20;</xsl:text>
        <xsl:value-of select="@name"/>
        <xsl:text>&#x0A;</xsl:text>
    </xsl:template>
</xsl:stylesheet>
