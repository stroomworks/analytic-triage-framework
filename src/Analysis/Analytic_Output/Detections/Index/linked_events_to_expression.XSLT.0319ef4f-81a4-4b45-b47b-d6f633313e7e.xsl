<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xpath-default-namespace="detection:1" xmlns="records:2" xmlns:stroom="stroom" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.0">
  <xsl:include href="stroom-json" />

  <!-- Helper function-->
  <!--<xsl:function name="stroom:linkedEventsToRef">-->
  <!--  <xsl:param name="linkedEvents" />-->
  <!--  <xsl:variable name="headEvent" select="$linkedEvents[1]" />-->
  <!--  <xsl:choose>-->
  <!--    <xsl:when test="count($linkedEvents)">-->
  <!--      <xsl:value-of select="concat($headEvent/streamId,':',$headEvent/eventId, ' ', stroom:linkedEventsToRef(subsequence($linkedEvents,2)))" />-->
  <!--    </xsl:when>-->
  <!--    <xsl:otherwise>-->
  <!--      <xsl:value-of select="concat($headEvent/streamId,':',$headEvent/eventId)" />-->
  <!--    </xsl:otherwise>-->
  <!--  </xsl:choose>-->
  <!--</xsl:function>-->

  <!-- Example stroom search expression follows (for reference)
  {
  "type" : "operator",
  "op" : "OR",
  "children" : [ {
  "type" : "operator",
  "children" : [ {
  "type" : "term",
  "field" : "StreamId",
  "condition" : "EQUALS",
  "value" : "8705"
  }, {
  "type" : "term",
  "field" : "EventId",
  "condition" : "EQUALS",
  "value" : "20407"
  } ]
  }, {
  "type" : "operator",
  "children" : [ {
  "type" : "term",
  "field" : "StreamId",
  "condition" : "EQUALS",
  "value" : "8705"
  }, {
  "type" : "term",
  "field" : "EventId",
  "condition" : "EQUALS",
  "value" : "20355"
  } ]
  } ]
  }
  -->

  <xsl:template name="linkedEventToExpression">
    <xsl:param name="linkedEvents" />
    <expression>
      <type>operator</type>
      <op>OR</op>
      <xsl:for-each select="$linkedEvents">
        <children>
          <type>operator</type>
          <op>AND</op>
          <children>
            <type>term</type>
            <field>StreamId</field>
            <condition>EQUALS</condition>
            <value>
              <xsl:value-of select="streamId" />
            </value>
            <enabled>true</enabled>
          </children>
          <children>
            <type>term</type>
            <field>EventId</field>
            <condition>EQUALS</condition>
            <value>
              <xsl:value-of select="eventId" />
            </value>
            <enabled>true</enabled>
          </children>
          <enabled>true</enabled>
        </children>
      </xsl:for-each>
      <enabled>true</enabled>
    </expression>
  </xsl:template>
  
  
  <!--Turn linked Events into an expression suitable for use with Stroom Search API
  The resulting expression is JSON, but with " symbol replaced by ¬ because double quotes are so often lost during marshalling-->
  <xsl:template name="linkedEventsToExpressionJson">
    <xsl:param name="linkedEvents" />
    <xsl:variable name="expression">
      <xsl:call-template name="linkedEventToExpression">
        <xsl:with-param name="linkedEvents" select="$linkedEvents//linkedEvent" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="expressionJsonArray" select="stroom:json($expression,'*/children')" />
    <xsl:value-of select="replace(substring($expressionJsonArray,2,string-length($expressionJsonArray)-2),'&quot;','¬')" />
  </xsl:template>
</xsl:stylesheet>
