<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xpath-default-namespace="detection:1" xmlns:stroom="stroom"  xmlns:stroom-meta="stroom-meta" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.0">

  <!--Template to form the overall shape of the HTML-->
  <xsl:template match="detection">
    
    <div>
      <div style="padding: 5px;">
        <h1>
          <xsl:value-of select="headline" />
        </h1>
        <xsl:if test="detailedDescription">
          <h2>
            <xsl:value-of select="detailedDescription" />
          </h2>
        </xsl:if>
        <br />
        <p>
          <h2>Details</h2>
        </p>
        <xsl:if test="fullDescription">
          <p>
            <xsl:value-of select="fullDescription" />
          </p>
          <br />
        </xsl:if>
        <xsl:apply-templates />
      </div>
    </div>
  </xsl:template>
  
  <!--The name/value pairs-->
  <xsl:template match="value">
    <div>
      <b>
        <xsl:value-of select="@name" />
      </b>
      <xsl:text>: </xsl:text>
      <xsl:value-of select="text()" />
    </div>
  </xsl:template>
  
  <!--Suppress other text-->
  <xsl:template match="text()" />
</xsl:stylesheet>
