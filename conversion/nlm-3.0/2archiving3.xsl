<?xml version="1.0" encoding="UTF-8"?>

<!-- ==================================================	-->
<!--  	NLM Journal Archiving and Interchange Tag Suite
		Archiving (Green) Tag Set Conversion into v3.0
		Stylesheet Version:   0.1
		Date:      March 2008 	-->
<!-- ==================================================	-->

<!-- This stylesheet is intended to aid in bringing data tagged in the 
	NLM Archiving Tag Set into compliance with the 
	non-backward-compatible version 3.0 release.			

	This module performs the following actions:
	
	Include module base.xsl
	Declare variable citation-att, used to translate citation atts
	Declare variable alphabet, used to test value of @id
	Process document element
	Rename font styled-content with specified font color
	Define elements allowed in p for mml:annotation-xml test -->

<!-- ==================================================	-->


<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  
	xmlns:mml="http://www.w3.org/1998/Math/MathML" 
	xmlns:util="http://dtd.nlm.nih.gov/xsl/util" 
	exclude-result-prefixes="util">
	
	
	<xsl:output method="xml" indent="no" encoding="UTF-8"
		doctype-public="-//NLM//DTD Journal Archiving and Interchange DTD v3.0 20080202//EN"
		doctype-system="archivearticle3.dtd"/>
	
	
	<!-- ==================================================	-->
	<!-- INCLUDE: base.xsl 
		
		Note: Defines templates standard across tag sets -->
	<!-- ==================================================	-->
	
	<xsl:include href="base.xsl"/>


	<!-- ==================================================	-->
	<!-- VARIABLE: citation-att
		
		Note: Defines new citation attributes based on value of existing
		@citation-type. Defined in file new-citation-type.xsl -->
	<!-- ==================================================	-->
	
	<xsl:variable name="citation-att" 
		select="document('new-citation-type.xsl')/*/util:map[@id='citation-att']/item"/>
	

	<!-- ==================================================	-->
	<!--  VARIABLE: alphabet
		
		Note: Used to test first character of @id on list, list-item, def-list, 
		tex-math. -->	
	<!-- ==================================================	-->
	<xsl:variable name="alphabet">
		<xsl:text>ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz</xsl:text>
	</xsl:variable>

	
	<!-- ==================================================	-->	
	<xsl:template match="/">
		<xsl:apply-templates/>
	</xsl:template>
	

	<!-- ######################### ARCHIVING-SPECIFIC TEMPLATES ######################### -->
	
	<!-- ==================================================	-->
	<!-- TEMPLATE MATCH: font 
		
		Note: Element removed from tag suite; use styled-content
		Font change information captured as CSS value in @style -->
	<!-- ==================================================	-->
	
	<xsl:template match="font">
		<xsl:comment>===== Restructure font as styled-content =====</xsl:comment>
		<styled-content>
			<xsl:attribute name="style">
				<xsl:text>color: </xsl:text><xsl:value-of select="@color"/>
			</xsl:attribute>
			<xsl:apply-templates/>
		</styled-content>
	</xsl:template>
	
	
	<!-- ==================================================	-->
	<!-- TEMPLATE NAME: test-for-elements-allowed-in-p
		
		Note: 3.0 changed model of mml:annotation-xml to p+
		
		Used by template match="mml:annotation-xml" to test that
		contents are valid children of element p. -->
	<!-- ==================================================	-->
	
	<xsl:template name="test-for-elements-allowed-in-p">
		<xsl:param name="nodes"/>
		<xsl:variable name="p-eles">
			<xsl:text>|email|ext-link|uri|inline-supplementary-material|related-article|font|hr|bold|italic|monospace|overline|overline-start|overline-end|sans-serif|sc|strike|underline|underline-start|underline-end|inline-graphic|private-char|inline-formula|tex-math|mml:math|abbrev|milestone-end|milestone-start|named-content|fn|target|xref|sub|sup|array|boxed-text|chem-struct|chem-struct-wrapper|fig|fig-group|graphic|media|preformat|supplementary-material|table-wrap|table-wrap-group|disp-formula|citation|nlm-citation|contract-num|contract-sponsor|grant-num|grant-sponsor|def-list|list|ack|disp-quote|speech|statement|verse-group|x|</xsl:text>
		</xsl:variable>
		<xsl:if test="$nodes">
			<xsl:choose>
				<xsl:when test="contains($p-eles,concat('|',name($nodes[1]),'|'))">
					<xsl:call-template name="test-for-elements-allowed-in-p">
						<xsl:with-param name="nodes" select="$nodes[position()!=1]"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>fail</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	
	
</xsl:stylesheet>
