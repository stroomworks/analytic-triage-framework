<?xml version="1.1" encoding="UTF-8" ?>

<!-- UK Crown Copyright © 2019 -->
<xsl:stylesheet xpath-default-namespace="records:2" xmlns="detection:1" xmlns:stroom="stroom" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3">
  <xsl:template match="records">
    <detections  xsi:schemaLocation="detection:1 file://detection-v1.1.xsd" >
    
      <xsl:apply-templates />
    </detections>
  </xsl:template>
  <xsl:variable name="type" select="substring-before(substring-after(stroom:feed-name(),'-'),'-')" />

  <!--Main template-->
  <xsl:template match="record">
    <xsl:variable name="tuples">
      <xsl:call-template name="createtuples">
        <xsl:with-param name="input" select="data[position() > 4]/@value" />
      </xsl:call-template>
    </xsl:variable>
    <detection>
      <detectTime>
        <xsl:value-of select="data[1]/@value" />
      </detectTime>
      <headline>
        <xsl:value-of select="data[2]/@value" />
      </headline>
      <detailedDescription>
        <xsl:value-of select="data[3]/@value" />
      </detailedDescription>
      <fullDescription>
        <xsl:value-of select="data[4]/@value" />
      </fullDescription>
       <xsl:for-each select="$tuples/*:Tuple[*:Name!='eventref']">
        <value>
          <xsl:attribute name="name">
            <xsl:value-of select="*:Name" />
          </xsl:attribute>
          
            <xsl:value-of select="*:Value" />
          
        </value>
      </xsl:for-each>
      <linkedEvents>
        <xsl:for-each select="$tuples/*:Tuple[*:Name='eventref']">
          <xsl:analyze-string select="*:Value" regex="\d+:\d+">
            <xsl:matching-substring>
              <linkedEvent>
                <streamId>
                  <xsl:value-of select="substring-before(.,':')" />
                </streamId>
                <eventId>
                  <xsl:value-of select="substring-after(.,':')" />
                </eventId>
              </linkedEvent>
            </xsl:matching-substring>
          </xsl:analyze-string>
        </xsl:for-each>
      </linkedEvents>
     
    </detection>
  </xsl:template>

  <!--Turn consecutive pairs into tuples-->
  <xsl:template name="createtuples">
    <xsl:param name="input" />
    <xsl:variable name="tupleString">
      <xsl:value-of select="$input" separator="¬" />
    </xsl:variable>
    <xsl:analyze-string select="$tupleString" regex="([^¬]+¬[^¬]+)*">
      <xsl:matching-substring>
        <xsl:if test="string-length(.) gt 3">
          <Tuple>
            <Name>
              <xsl:value-of select="substring-before(.,'¬')" />
            </Name>
            <Value>
              <xsl:value-of select="substring-after(.,'¬')" />
            </Value>
          </Tuple>
        </xsl:if>
      </xsl:matching-substring>
    </xsl:analyze-string>
  </xsl:template>
</xsl:stylesheet>
