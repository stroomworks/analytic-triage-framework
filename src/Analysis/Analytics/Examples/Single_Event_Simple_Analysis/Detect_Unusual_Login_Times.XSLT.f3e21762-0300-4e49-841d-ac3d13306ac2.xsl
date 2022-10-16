<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xpath-default-namespace="event-logging:3" xmlns="detection:1" xmlns:stroom="stroom" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.0">
  <xsl:template match="/Events">
    <detections xsi:schemaLocation="detection:1 file://detection-v1.0.xsd">
      <xsl:apply-templates />
    </detections>
  </xsl:template>
  <xsl:template match="Event[EventDetail/Authenticate/Action eq 'Logon']">
    <xsl:variable name="hour" select="number(substring(EventTime/TimeCreated,12,2))" />
    <xsl:if test="$hour ge 19 or $hour lt 6">
      <detection>
        <detectTime>
          <xsl:value-of select="stroom:current-time()" />
        </detectTime>
        <detectorName>Detect Unusual Login Times</detectorName>
        <detectorEnvironment>
          <xsl:value-of select="stroom:pipeline-name()" />
        </detectorEnvironment>
        <headline>Unusual Login Time Detected</headline>
        <detailedDescription>
          <xsl:value-of select="concat(' Attempted login to account with id ', EventDetail/Authenticate/User/Id, ' outside standard hours.')" />
        </detailedDescription>
        <fullDescription>
          <xsl:variable name="device">
            <xsl:choose>
              <xsl:when test="EventSource/Client/HostName">
                <xsl:value-of select="EventSource/Client/HostName" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>an unknown device</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:value-of select="concat(EventDetail/Authenticate/User/Id, ' attempted login from ', $device, ' between ', $hour, ' and ', $hour + 1, ' hours, which outside standard working hours.')" />
        </fullDescription>
        <value name="hour">
          <xsl:value-of select="$hour" />
        </value>
        <value name="account">
          <xsl:value-of select="EventDetail/Authenticate/User/Id" />
        </value>
        <linkedEvents>
          <linkedEvent>
            <streamId>
              <xsl:value-of select="@StreamId" />
            </streamId>
            <eventId>
              <xsl:value-of select="@EventId" />
            </eventId>
          </linkedEvent>
        </linkedEvents>
      </detection>
    </xsl:if>
  </xsl:template>

  <!-- Suppress other text -->
  <xsl:template match="text()" />
</xsl:stylesheet>
