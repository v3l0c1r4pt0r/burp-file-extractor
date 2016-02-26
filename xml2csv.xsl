<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text"/>
<xsl:template match="/"><xsl:apply-templates select="/items/item" /></xsl:template>
<xsl:template match="/items/item">
    <xsl:value-of select="path" />,<xsl:value-of select="response" />
    <xsl:text>&#xa;</xsl:text>
</xsl:template>
</xsl:stylesheet>