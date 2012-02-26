<?xml version="1.0" encoding="UTF-8"?>

<!-- ==================================================	-->
<!--  	NLM Journal Archiving and Interchange Tag Suite
		Module: new-citation-type.xsl
		Stylesheet Version:   0.1 	
		Date:      March 2008 	-->
<!-- ==================================================	-->

<!-- This module is used to map existing values of @citation-type
	to the new attributes on element-citation, mixed-citation, and
	nlm-citation. To substitute this list, create a new file with the 
	<util:map> structure containing the preferred values and update 
	the variable citation-att in 2archiving3.xsl, 2articleauthoring3.xsl, 
	or 2publishing3.xsl to call the new file. -->

<!-- ================================================== -->


<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:util="http://dtd.nlm.nih.gov/xsl/util" 
	exclude-result-prefixes="util">	
	
	<util:map id="citation-att">
		<item source="audio" attr="publication-format"/>
		<item source="audiocassette" attr="publication-format"/>
		<item source="blog" attr="publication-type"/>
		<item source="book" attr="publication-type"/>
		<item source="cd-rom" attr="publication-format"/>
		<item source="CD-ROM" attr="publication-format"/>
		<item source="chapter" attr="publication-type"/>
		<item source="commercial" attr="publisher-type"/>
		<item source="commun" attr="publication-type"/>
		<item source="conf-proc" attr="publication-type"/>
		<item source="confproc" attr="publication-type"/>
		<item source="court-case" attr="publication-type"/>
		<item source="discussion" attr="publication-type"/>
		<item source="disk" attr="publication-format"/>
		<item source="dvd" attr="publication-format"/>
		<item source="DVD" attr="publication-format"/>
		<item source="email" attr="publication-format"/>
		<item source="gov" attr="publisher-type"/>
		<item source="journal" attr="publication-type"/>
		<item source="list" attr="publication-format"/>
		<item source="microfiche" attr="publication-format"/>
		<item source="microfilm" attr="publication-format"/>
		<item source="mpic" attr="publication-format"/>
		<item source="newspaper" attr="publication-type"/>
		<item source="ngo" attr="publisher-type"/>
		<item source="non-profit" attr="publisher-type"/>
		<item source="paper" attr="publication-type"/>
		<item source="patent" attr="publication-type"/>
		<item source="personal" attr="publisher-type"/>
		<item source="poster-session" attr="publication-type"/>
		<item source="print" attr="publication-format"/>
		<item source="report" attr="publication-type"/>
		<item source="slide" attr="publication-format"/>
		<item source="society" attr="publisher-type"/>
		<item source="software" attr="publication-type"/>
		<item source="std" attr="publication-type"/>
		<item source="stds-body" attr="publisher-type"/>
		<item source="thesis" attr="publication-type"/>
		<item source="video" attr="publication-format"/>
		<item source="videocassette" attr="publication-format"/>
		<item source="videodisc" attr="publication-format"/>
		<item source="web" attr="publication-format"/>
		<item source="webpage" attr="publication-type"/>
		<item source="wiki" attr="publication-type"/>
	</util:map>	

</xsl:stylesheet>
