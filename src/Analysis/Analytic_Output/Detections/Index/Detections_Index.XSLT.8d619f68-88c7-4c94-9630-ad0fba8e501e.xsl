<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xpath-default-namespace="detection:1" xmlns="records:2" xmlns:stroom="stroom" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.0">
  <xsl:include href="linked-events-to-expression" />

  <!--Find the dashboard for Triage -->
  <xsl:variable name="triageDashDictionary">

    <!--Only do for Search Extraction - not indexing-->
    <xsl:choose>
      <xsl:when test="ends-with(stroom:pipeline-name(),'Search Extraction')">
        <xsl:value-of select="stroom:dictionary('Triage Dashboard Mapping')" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:text />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="triageDashTokens" select="tokenize($triageDashDictionary,'\n')" />
  <xsl:variable name="triageDash">
    <xsl:for-each select="$triageDashTokens">
      <xsl:variable name="triageLineTokens" select="tokenize(.,'¬')" />
      <xsl:if test="not(starts-with(.,'#'))">
        <xsl:element name="Dash">
          <xsl:attribute name="regex">
            <xsl:value-of select="$triageLineTokens[1]" />
          </xsl:attribute>
          <xsl:if test="count($triageLineTokens) eq 3">
            <xsl:attribute name="escalationComment">
              <xsl:value-of select="$triageLineTokens[3]" />
            </xsl:attribute>
          </xsl:if>
          <xsl:value-of select="$triageLineTokens[2]" />
        </xsl:element>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>

  <!-- Main template -->
  <xsl:template match="/detections">
    <records xsi:schemaLocation="records:2 file://records-v2.0.xsd" version="2.0">
      <xsl:apply-templates select="*" />
    </records>
  </xsl:template>
  <xsl:template match="detection">
    <record>
      <data name="StreamId">
        <xsl:attribute name="value" select="@StreamId" />
      </data>
      <data name="EventId">
        <xsl:attribute name="value" select="@EventId" />
      </data>

      <!-- Add feed -->
      <data name="Feed">
        <xsl:attribute name="value" select="stroom:feed-name()" />
      </data>
      <xsl:apply-templates select="*" />
    </record>
  </xsl:template>
  <xsl:template match="detectorName">
    <data name="Detector Name">
      <xsl:attribute name="value" select="." />
    </data>
  </xsl:template>

  <!-- Index the time -->
  <xsl:template match="detectTime">
    <data name="EventTime">
      <xsl:attribute name="value" select="." />
    </data>
  </xsl:template>

  <!-- Index the headline -->
  <xsl:template match="headline">
    <xsl:variable name="headline" select="." />
    <data name="Headline">
      <xsl:attribute name="value" select="$headline" />
    </data>

    <!--find the triage dashboard-->
    <xsl:if test="ends-with(stroom:pipeline-name(),'Search Extraction')">
       <xsl:variable name="triageMatch">
          <xsl:for-each select="$triageDash">
            <xsl:if test="matches($headline, *:Dash/@regex)">
              <xsl:copy-of select="." />
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>
      <data name="TriageDashboard">
       

        <!--Get the first match-->
        <xsl:attribute name="value" select="$triageMatch[1]/*:Dash/text()" />
      </data>
      <data name="TriageEscalationComment">
       

        <!--Get the first match-->
        <xsl:attribute name="value" select="$triageMatch[1]/*:Dash/@escalationComment" />
      </data>
    </xsl:if>
  </xsl:template>

  <!-- Index the description -->
  <xsl:template match="detailedDescription">
    <data name="Description">
      <xsl:attribute name="value" select="." />
    </data>
  </xsl:template>

  <!-- Index the full detail -->
  <xsl:template match="fullDescription">
    <data name="Detail">
      <xsl:attribute name="value" select="." />
    </data>
  </xsl:template>

  <!--Turn linked Events into an expression suitable for use with Stroom Search API-->
  <xsl:template match="linkedEvents">

    <!--Only do for Search Extraction - not indexing-->
    <xsl:if test="ends-with(stroom:pipeline-name(),'Search Extraction')">
      <xsl:variable name="expressionJson">
        <xsl:call-template name="linkedEventsToExpressionJson">
          <xsl:with-param name="linkedEvents" select="." />
        </xsl:call-template>
      </xsl:variable>
      <data name="LinkedEventExpression">
        <xsl:attribute name="value">
          <xsl:value-of select="$expressionJson" />
        </xsl:attribute>
      </data>
    </xsl:if>
  </xsl:template>

  <!-- Suppress other text -->
  <xsl:template match="text()" />
</xsl:stylesheet>
