<xsl:stylesheet version="2.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:my="my:my">
 <xsl:output omit-xml-declaration="yes"/>
 
<xsl:template match="/">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="number">
    <xsl:call-template name="dec-to-hex">
        <xsl:with-param name="number" select="xs:integer(number(.))"/>
    </xsl:call-template>
</xsl:template>

 <xsl:template name="dec-to-hex">
    <xsl:param name="number"/>
    <xsl:value-of select="my:dec-to-hex($number)"/>
</xsl:template>

<xsl:function name="my:dec-to-hex" as="xs:string">
    <xsl:param name="input" as="xs:integer"/>
    
    <xsl:sequence select="if ($input eq 0)
then '0'
else
concat(if ($input gt 16)
then my:dec-to-hex($input idiv 16)
else '',
substring('0123456789ABCDEF',
($input mod 16) + 1, 1))"/>
</xsl:function>

</xsl:stylesheet>
