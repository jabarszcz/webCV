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
<!--    <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"&gt;</xsl:text> -->
    
    <html> <!-- xmlns="http://www.w3.org/1999/xhtml">-->
      <head>
	<link rel="stylesheet" type="text/css" href="cv.css" />
	<link rel="shortcut icon" href="favicon.ico" />
	<title><xsl:value-of select="info/title" /></title>
      </head>
      <body>
	<div class="master_container">
	  <xsl:apply-templates select="info" />
	  <xsl:apply-templates select="skills" />

	  <!-- Find section importance -->
	  <xsl:variable name="annotated">
	    <xsl:for-each select="section[experience and not(@prio)]">
	      <xsl:copy>
		<xsl:attribute name="prio">
		  <xsl:call-template name="max">
		    <xsl:with-param name="nodes" select="experience/@prio|experience/@tresh[not(../@prio)]" />
		  </xsl:call-template>
		</xsl:attribute>
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
      </body>
    </html>  
  </xsl:template>

  <xsl:template match="info">
    <div class="info">
      <h1><xsl:value-of select="name" /></h1>
      <div class="address">
	<p><xsl:apply-templates select="address" /></p>
      </div>
      <div class="contacts">
	<p>
	  <xsl:value-of select="telephone" /> <br />
	  <xsl:value-of select="email" />
	</p>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="address">
    <xsl:value-of select="line1" />
    <xsl:if test="city|province|zip"><br /></xsl:if>
    <xsl:if test="city">
      <xsl:value-of select="city" />,
    </xsl:if>
    <xsl:value-of select="province" /> <xsl:text> </xsl:text>
    <xsl:value-of select="zip" />    
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
		<xsl:value-of select="." /> <br />
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
	<h2><xsl:value-of select="title" /></h2>
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
	  <xsl:value-of select="." />
	  <xsl:if test="@note">
	    <xsl:text>, </xsl:text>
	    <xsl:value-of select="@note" />
	  </xsl:if>
	</div>
      </xsl:for-each>
      <ul class="detail">
	<xsl:for-each select="detail">
	  <li><xsl:value-of select="." /></li>
	</xsl:for-each>
      </ul>
    </div>
  </xsl:template>
  
  <xsl:template match="line" name="line">
    <div class="experience_line">
      <div class="time">
	<xsl:choose>
	  <xsl:when test="year">
	    <xsl:value-of select="year" />
	  </xsl:when>
	  <xsl:when test="start">
	    <span class="time_start"><xsl:value-of select="start" /></span>
	    <xsl:text> - </xsl:text>
	    <span class="time_finish"><xsl:value-of select="finish" /></span>
	  </xsl:when>
	</xsl:choose>
      </div>
      <div class="description">
	<xsl:choose>
	  <xsl:when test="title">
	    <xsl:value-of select="title" />
	  </xsl:when>
	  <xsl:when test="short|rest">
	    <span class="short">
	      <xsl:value-of select="short" />
	    </span>
	    <xsl:text> </xsl:text>
	    <xsl:value-of select="rest" />
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
		<xsl:value-of select="." /> <br />
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
