<?xml version="1.0" encoding="UTF-8"?>

<!-- TODO check/cast types when sorting/filtering -->

<xsl:transform version="1.0"
	       xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	       xmlns:exsl="http://exslt.org/common"
               extension-element-prefixes="exsl">
  <xsl:output indent="yes" />

  <!-- LANGUAGE SELECTION AND PRIVACY FILTER ==========================-->

  <!-- Parameters -->
  <xsl:param name="language" select="'FR'" />
  <xsl:param name="privacy" select="'private'" />
  <xsl:param name="brevity" select="10" />

  <!-- Pipeline -->
  <xsl:template match="/">
    <xsl:variable name="after_cont_select">
      <xsl:apply-templates select="." mode="filter_content" />
    </xsl:variable>
    <xsl:variable name="after_lang_select">
      <xsl:apply-templates select="exsl:node-set($after_cont_select)" mode="filter_lang_priv" />
    </xsl:variable>
    <xsl:apply-templates select="exsl:node-set($after_lang_select)/cv" />
  </xsl:template>

  <!-- Call content filter or copy -->
  <xsl:template match="/" mode="filter_content">
    <xsl:choose>
      <xsl:when test="$brevity">
	<xsl:call-template name="filter_content">
	  <xsl:with-param name="brevity" select="$brevity" />
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<xsl:copy-of select="." />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Call language and privacy filter or copy -->
  <xsl:template match="/" mode="filter_lang_priv">
    <xsl:choose>
      <xsl:when test="$language or $privacy">
	<xsl:call-template name="filter_language_priv">
	  <xsl:with-param name="language" select="$language" />
	  <xsl:with-param name="privacy" select="$privacy" />
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<xsl:copy-of select="." />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Content filter -->
  <xsl:template name="filter_content">
    <xsl:param name="brevity" select="10" />
    <xsl:if test="not(@tresh) or @tresh &gt;= $brevity">
      <xsl:copy>
	<xsl:for-each select="node()|@*">
	  <xsl:call-template name="filter_content">
	      <xsl:with-param name="brevity" select="$brevity" />
	  </xsl:call-template>
	</xsl:for-each>
      </xsl:copy>
    </xsl:if>
  </xsl:template>

  <!-- Language and privacy filter -->
  <xsl:template name="filter_language_priv">
    <xsl:param name="language" select="'FR'" />
    <xsl:param name="privacy" select="'public'" />
    <xsl:if test="not(@lang) or @lang=$language">
      <xsl:if test="not(@private) or ($privacy='public' and @private!='true') or ($privacy!='public' and @private!='replace')">
	<xsl:copy>
	  <xsl:for-each select="node()|@*">
	    <xsl:call-template name="filter_language_priv">
	      <xsl:with-param name="language" select="$language" />
	      <xsl:with-param name="privacy" select="$privacy" />
	    </xsl:call-template>
	</xsl:for-each>
	</xsl:copy>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <!-- ==================================================================== -->

  <!-- TRANSLATION TO XHTML =============================================== -->

  <xsl:template match="cv">
	<div class="master_container">
	  <xsl:apply-templates select="info" />
	  <xsl:apply-templates select="skills" />

	  <!-- Find section importance -->
	  <xsl:variable name="annotated">
	    <xsl:for-each select="section[experience]">
	      <xsl:copy>
		<xsl:if test="@prio">
		  <xsl:attribute name="prio">
		    <xsl:call-template name="max">
		      <xsl:with-param name="nodes" select="experience/@prio|experience/@tresh[not(../@prio)]" />
		    </xsl:call-template>
		  </xsl:attribute>
		</xsl:if>
		<xsl:apply-templates select="node()|@*" mode="copy" />
	      </xsl:copy>
	    </xsl:for-each>
	  </xsl:variable>

	  <xsl:apply-templates select="exsl:node-set($annotated)/section[experience]">
	    <!-- Sort sections by maximum children importance -->
	    <xsl:sort select="@prio" order="descending" data-type="number" />
	  </xsl:apply-templates>

	  <xsl:apply-templates select="interests" />
	</div>
  </xsl:template>

  <xsl:template match="info">
    <div class="info">
      <h1><xsl:copy-of select="name/*|name/text()" /></h1>
      <div class="address">
	<p><xsl:apply-templates select="address" /></p>
      </div>
      <div class="contacts">
	<p>
	  <xsl:copy-of select="telephone/*|telephone/text()" /> <br />
	  <xsl:copy-of select="email/*|email/text()" />
	</p>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="address">
    <xsl:copy-of select="line1/*|line1/text()" />
    <xsl:if test="city|province|zip"><br /></xsl:if>
    <xsl:if test="city">
      <xsl:copy-of select="city/*|city/text()" />,
    </xsl:if>
    <xsl:copy-of select="province/*|province/text()" /> <xsl:text> </xsl:text>
    <xsl:copy-of select="zip/*|zip/text()" />
  </xsl:template>

  <xsl:template match="skills">
    <xsl:call-template name="section">
      <xsl:with-param name="contents" select="skillset" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="skillset">
    <div class="skillset_container">
      <div class="skillset">
	<xsl:if test="@title">
	  <h3><xsl:value-of select="@title" /></h3>
	</xsl:if>
	<div class="skill_list">
	  <xsl:choose>
	    <xsl:when test="skill">
	      <xsl:call-template name="comma_sep">
		<xsl:with-param name="select" select="skill" />
	      </xsl:call-template>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:for-each select="skill_line">
		<xsl:copy-of select="./*|./text()" /> <br />
	      </xsl:for-each>
	    </xsl:otherwise>
	  </xsl:choose>
	</div>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="section" name="section">
    <xsl:param name="contents" select="experience" />
    <div class="section">
      <div class="title_container">
	<h2><xsl:copy-of select="title/*|title/text()" /></h2>
      </div>
      <div class="contents_container">
	<xsl:apply-templates select="$contents[not(finish or year)]">
	  <xsl:sort select="start" order="descending" data-type="number" />
	  <xsl:sort select="@prio|@tresh[not(../@prio)]" order="descending" data-type="number" />
	</xsl:apply-templates>
	<xsl:apply-templates select="$contents[finish or year]">
	  <xsl:sort select="finish|year" order="descending" data-type="number" />
	  <xsl:sort select="@prio|@tresh[not(../@prio)]" order="descending" data-type="number" />
	</xsl:apply-templates>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="experience">
    <div class="experience">
      <xsl:call-template name="line" />
      <xsl:apply-templates select="line" />
      <xsl:for-each select="institution">
	<div class="institution_line">
	  <xsl:copy-of select="./*|./text()" />
	  <xsl:if test="@note">
	    <xsl:text>, </xsl:text>
	    <xsl:value-of select="@note" />
	  </xsl:if>
	</div>
      </xsl:for-each>
      <xsl:if test="detail">
	<ul class="detail">
	  <xsl:for-each select="detail">
	    <li><xsl:copy-of select="./*|./text()" /></li>
	  </xsl:for-each>
	</ul>
      </xsl:if>
    </div>
  </xsl:template>

  <xsl:template match="line" name="line">
    <div class="experience_line">
      <div class="time">
	<xsl:choose>
	  <xsl:when test="year">
	    <xsl:copy-of select="year/*|year/text()" />
	  </xsl:when>
	  <xsl:when test="start">
	    <span class="time_start"><xsl:copy-of select="start/*|start/text()" /></span>
	    <xsl:text> - </xsl:text>
	    <span class="time_finish"><xsl:copy-of select="finish/*|finish/text()" /></span>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:text> </xsl:text>
	  </xsl:otherwise>
	</xsl:choose>
      </div>
      <div class="description">
	<xsl:choose>
	  <xsl:when test="title">
	    <xsl:copy-of select="title/*|title/text()" />
	  </xsl:when>
	  <xsl:when test="short|rest">
	    <span class="short">
	      <xsl:copy-of select="short/*|short/text()" />
	    </span>
	    <xsl:text> </xsl:text>
	    <xsl:copy-of select="rest/*|rest/text()" />
	  </xsl:when>
	</xsl:choose>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="interests">
    <xsl:call-template name="section">
      <xsl:with-param name="contents" select="list" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="list">
    <div class="lists_container">
      <div class="list_container">
	<xsl:if test="@title">
	  <h3><xsl:value-of select="@title" /></h3>
	</xsl:if>
	<div class="list">
	  <xsl:choose>
	    <xsl:when test="element">
	      <xsl:call-template name="comma_sep">
		<xsl:with-param name="select" select="element" />
	      </xsl:call-template>
	    </xsl:when>
	    <xsl:when test="line"> <!-- TODO merge skillset into here -->
	      <xsl:for-each select="line">
		<xsl:copy-of select="./*|./text()" /> <br />
	      </xsl:for-each>
	    </xsl:when>
	  </xsl:choose>
	</div>
      </div>
    </div>
  </xsl:template>

  <!-- UTILITY TEMPLATES =========================================== -->

  <xsl:template name="max">
    <xsl:param name="nodes" select="/.."/>
    <xsl:choose>
      <xsl:when test="not($nodes)">NaN</xsl:when>
      <xsl:otherwise>
	<xsl:for-each select="$nodes">
	  <xsl:sort data-type="number" order="descending"/>
	  <xsl:if test="position() = 1">
	    <xsl:value-of select="number(.)"/>
	  </xsl:if>
	</xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="node()|@*" mode="copy">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*" mode="copy" />
    </xsl:copy>
  </xsl:template>

  <xsl:template name="comma_sep">
    <xsl:param name="select" select="*" />
    <xsl:for-each select="$select">
      <xsl:value-of select="." />
      <xsl:if test="position() != last()">
	<xsl:text>, </xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

</xsl:transform>
