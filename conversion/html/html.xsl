<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  version="1.0" 
  xmlns:nlm="http://dtd.nlm.nih.gov/2.0/xsd/archivearticle" 
  xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="nlm xlink">

  <xsl:output nethod="xml" encoding="utf-8" omit-xml-declaration="yes" standalone="yes" indent="yes"/>

  <xsl:template match="/">
    <html>
      <head>
        <meta charset="utf-8"/>
        <title><xsl:value-of select="nlm:article/nlm:front/nlm:article-meta/nlm:title-group/nlm:article-title[1]"/></title>
      </head>
      <body>
        <xsl:apply-templates select="nlm:article/nlm:body"/>
      </body>
    </html>
  </xsl:template>

  <!-- inline elements -->
  <xsl:template match="nlm:italic | nlm:bold | nlm:sc | nlm:strike | nlm:sub | nlm:sup | nlm:underline | nlm:abbrev | nlm:surname | nlm:given-names | nlm:email | nlm:label | nlm:year | nlm:month | nlm:day">
    <span class="{local-name()}">
      <xsl:apply-templates select="node()|@*"/>
    </span>
  </xsl:template>

  <!-- links -->
  <xsl:template match="nlm:ext-link">
    <a class="{local-name()}" href="{@xlink:href}">
      <xsl:apply-templates select="node()|@*"/>
    </a>
  </xsl:template>

  <!-- remove references -->
  <xsl:template match="nlm:xref"></xsl:template>

  <!-- block elements -->
  <xsl:template match="*">
    <div class="{local-name()}">
      <xsl:apply-templates select="node()|@*"/>
    </div>
  </xsl:template>

  <!-- attributes -->
  <xsl:template match="@*">
    <xsl:if test="name() != 'class'">
      <xsl:copy-of select="."/>            
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
