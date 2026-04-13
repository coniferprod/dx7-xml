<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema">

  <xsl:output method="xml" indent="yes"/>

  <!-- Identity transform -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- Replace xs:include with contents -->
  <xsl:template match="xs:include">
    <xsl:apply-templates select="document(@schemaLocation)/xs:schema/*"/>
  </xsl:template>

</xsl:stylesheet>
