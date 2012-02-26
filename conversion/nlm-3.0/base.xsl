<?xml version="1.0" encoding="UTF-8"?>

<!-- ==================================================	-->
<!--  	NLM Journal Archiving and Interchange Tag Suite
		Module: base.xsl
		Stylesheet Version:   0.1 	
		Date:      March 2008 	-->
<!-- ==================================================	-->

<!-- This stylesheet is intended to aid in bringing data tagged in the 
	NLM  Journal Archiving Tag Suite into compliance with the 
	non-backward-compatible version 3.0 release. 

	This module performs the following actions:
	
	Copy nodes to ouput (Lowest priority)
	Group alternate forms of elements in <alternatives>
	Update @dtd-version to 3.0
	Validate @id on def-list, list, list-item, tex-math
	Group journal-title elements
	Group trans-title elements
	Condolidate copyright and license info into permissions
	Rename license/p license-p
	Restructure contract-* and grant-* elements into 3.0 funding model
	Consolidate and rename custom-meta-wrap custom-meta-group
	Simplify meta-name to #PCDATA
	Wrap boxed-text/title inside caption
	Rename chem-struct-wrapper chem-struct-wrap
	Check contents of mml:annotation-xml
	Rename citation/page-count size
	Confirm presence of @id on target
	Restructure glossary without gloss-group
	If table-wrap has alt-version, group alternate-form-of with table
		inside alternatives
	Rename floats-wrap floats-group
	Rename citation mixed-citation or element-citation
	Generate new citation attributes
	Rename access-date and time-stamp date-in-citation -->

<!-- ================================================== -->

<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  
	xmlns:mml="http://www.w3.org/1998/Math/MathML" 
	xmlns:util="http://dtd.nlm.nih.gov/xsl/util"  
	exclude-result-prefixes="util">
	
	
	
	<!-- ================================================== -->
	<!-- TEMPLATE MATCH: @* | * | text() 
		
		Note: Default template for all elements and attributes is to 
		copy to output -->
	<!-- ================================================== -->
	
	<xsl:template match="* | @* | text()" priority="-1">
		<xsl:copy>
			<xsl:apply-templates select="@*|*|text()"/>
		</xsl:copy>
	</xsl:template>
	
	
	<!-- ================================================== -->
	<!-- TEMPLATE MATCH: *
		MODE: write-out
		
		Note: Output an exact copy of current node -->
	<!-- ================================================== -->
	
	<xsl:template match="*" mode="write-out">
		<xsl:copy>
			<xsl:apply-templates select="@* | * | text()"/>
		</xsl:copy>
	</xsl:template>
		
	
	<!-- ================================================== -->
	<!-- TEMPLATE MATCH: *
		MODE: strip-atts
		
		Note: Used to strip attributes from elements in trans-title-group  -->
	<!-- ================================================== -->
	
	<xsl:template match="*" mode="strip-atts">
		<xsl:copy>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
	
	
	<!-- ================================================== -->
	<!-- TEMPLATE MATCH: *[@id] PRIORITY: -0.5
	
		Note: Any element with specified @id may have an 
		alternate-form-of defined elsewhere in the document. Combine
		these elements into new tag <alternatives>	-->
	<!-- ================================================== -->
	
	<xsl:template match="*[@id]" priority="-0.5">
		<xsl:param name="id" select="@id"/>
		<xsl:param name="alt-forms" select="//*[@alternate-form-of=$id]"/>
		<xsl:choose>
			<xsl:when test="$alt-forms">
				<xsl:comment>===== Grouping alternate versions of objects =====</xsl:comment>
				<alternatives>
					<xsl:copy>
						<xsl:apply-templates select="@*|*|text()"/>
					</xsl:copy>
					<xsl:apply-templates select="$alt-forms" mode="write-out"/>
				</alternatives>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:apply-templates select="@*|*|text()"/>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>	
	
	
	<!-- ================================================== -->
	<!-- TEMPLATE MATCH: alternate-form-of, alt-version
		
		Note: Remove alternate-form-of and alt-version; Elements with 
		@alternate-form-of processed in new alternatives tag -->
	<!-- ================================================== -->
	
	<xsl:template match="*[@alternate-form-of]"/>	
	<xsl:template match="@alternate-form-of"/>
	<xsl:template match="@alt-version"/>

	
	<!-- ================================================== -->
	<!-- TEMPLATE MATCH: @dtd-version
	
		Note: Update to 3.0 -->
	<!-- ================================================== -->
	
	<xsl:template match="@dtd-version">
		<xsl:attribute name="dtd-version">
			<xsl:text>3.0</xsl:text>
		</xsl:attribute>
	</xsl:template>
	
	
	<!-- ================================================== -->
	<!-- TEMPLATE MATCH: @id
		
		Note: For elements list, list-item, def-list, tex-math, check that
		defined value is a valid ID -->
	<!-- ================================================== -->
	<xsl:template match="@id">
		<xsl:choose>
			<xsl:when test="parent::list or parent::list-item or parent::def-list or parent::tex-math">
				<xsl:variable name="parent-id" select="generate-id(parent::node())"/>
				<xsl:variable name="me" select="."/>
				<xsl:choose>
					<xsl:when test="//*[generate-id(.)!=$parent-id][@id=$me]">
						<xsl:comment>Duplicate @id value <xsl:value-of select="$me"/> in source</xsl:comment>
					</xsl:when>
					<xsl:when test="contains(.,' ')">
						<xsl:comment>Space in source @id value <xsl:value-of select="$me"/></xsl:comment>
					</xsl:when>
					<xsl:when test="not(contains($alphabet,substring(.,1,1)))">
						<xsl:comment>Source @id value <xsl:value-of select="$me"/> does not start with a letter</xsl:comment>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="id">
							<xsl:value-of select="."/>
						</xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="id">
					<xsl:value-of select="."/>
				</xsl:attribute>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
	<!-- ================================================== -->
	<!-- TEMPLATE MATCH: journal-meta
		
		Note: Move journal title elements into journal-title-group -->
	<!-- ================================================== -->
	
	<xsl:template match="journal-meta">
		<journal-meta>
			<xsl:apply-templates select="journal-id"/>
			<!-- Journal title and all variants are grouped inside journal-title-group -->
			<xsl:if test="journal-title | journal-subtitle | trans-title | trans-subtitle | abbrev-journal-title">
				<xsl:comment>===== Grouping journal title elements =====</xsl:comment>
				<journal-title-group>
					<xsl:apply-templates select="journal-title | journal-subtitle"/>
					<xsl:for-each select="trans-title">
						<xsl:call-template name="build-trans-title-group"/>
					</xsl:for-each>
					<xsl:apply-templates select="abbrev-journal-title"/>
				</journal-title-group>
			</xsl:if>
			<xsl:apply-templates select="issn | publisher | notes"/>
		</journal-meta>
	</xsl:template>
	

	<!-- ================================================== -->
	<!-- TEMPLATE MATCH: title-group
		
		Note: Move translated article title elements into trans-title-group -->
	<!-- ================================================== -->
	
	<xsl:template match="title-group">
		<title-group>
			<xsl:apply-templates select="article-title|subtitle"/>
			<xsl:for-each select="trans-title">
				<xsl:call-template name="build-trans-title-group"/>
			</xsl:for-each>
			<xsl:apply-templates select="alt-title | fn-group"/>
		</title-group>
	</xsl:template>
	

	<!-- ================================================== -->
	<!-- TEMPLATE NAME: build-trans-title-group
		
		Note: Group trans-title elements, move xml:lang attributes onto
		new group tag -->
	<!-- ================================================== -->
	
	<xsl:template name="build-trans-title-group">
		<xsl:comment>===== Grouping translated-title elements =====</xsl:comment>
		<trans-title-group>
			<xsl:attribute name="xml:lang">
				<xsl:value-of select="@xml:lang"/>
			</xsl:attribute>
			<xsl:apply-templates select="." mode="strip-atts"/>
			<xsl:if test="following-sibling::*[1][self::trans-subtitle]">
				<xsl:apply-templates select="following-sibling::*[1]" mode="strip-atts"/>
			</xsl:if>
		</trans-title-group>
	</xsl:template>
	

	<!-- ================================================== -->
	<!-- TEMPLATE MATCH: copyright-holder, copyright-statement, 
		copyright-year, license	
		CONDITION: parent is not permissions
		
		Note: Move elements into element permissions -->
	<!-- ================================================== -->
	
	<xsl:template match="copyright-statement[not(parent::permissions)] | 
		copyright-year[not(parent::permissions)] | 
		copyright-holder[not(parent::permissions)] | 
		license[not(parent::permissions)]">
		<xsl:choose>
			<xsl:when test="preceding-sibling::copyright-statement
				or preceding-sibling::copyright-year
				or preceding-sibling::copyright-holder
				or preceding-sibling::license"/>
			<xsl:otherwise>
				<xsl:comment>===== Grouping copyright info into permissions =====</xsl:comment>
				<permissions>
					<xsl:apply-templates select="." mode="write-out"/>
					<xsl:apply-templates select="following-sibling::copyright-statement
						| following-sibling::copyright-year
						| following-sibling::copyright-holder
						| following-sibling::license" mode="write-out"/>
				</permissions>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>	
	
	
	<!-- ================================================== -->
	<!-- TEMPLATE MATCH: license/p
		
		Note: Rename to license-p -->
	<!-- ================================================== -->
	
	<xsl:template match="license/p">
		<xsl:comment>===== Rename p to license-p =====</xsl:comment>
		<license-p>
			<xsl:apply-templates select="@* | * | text()"/>
		</license-p>
	</xsl:template>
	
	
	<!-- ================================================== -->
	<!-- TEMPLATE MATCH: contract-num
		
		Note: Contract-* and grant-* elements removed and replaced by 
		a richer funding model -->
	<!-- ================================================== -->
	
	<xsl:template match="contract-num">
		<xsl:choose>
			<xsl:when test="parent::article-meta">
				<xsl:comment>===== Rename contract-num to award-id =====</xsl:comment>
				<funding-group>
					<award-group>
						<xsl:apply-templates select="following-sibling::contract-sponsor" mode="write-out"/>
						<award-id>
							<xsl:apply-templates/>
						</award-id>
					</award-group>
				</funding-group>
			</xsl:when>
			<xsl:otherwise>
				<award-id>
					<xsl:apply-templates/>
				</award-id>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
	<!-- ================================================== -->
	<!-- TEMPLATE MATCH: contract-sponsor  -->
	<!-- ================================================== -->
	
	<xsl:template match="contract-sponsor" mode="write-out">
		<xsl:comment>===== Rename contract-sponsor to funding-source =====</xsl:comment>
		<funding-source>
			<xsl:apply-templates/>
		</funding-source>
	</xsl:template>
	
	
	<!-- ================================================== -->
	<!-- TEMPLATE MATCH: grant-num -->
	<!-- ================================================== -->
	
	<xsl:template match="grant-num">
		<xsl:choose>
			<xsl:when test="parent::article-meta">
				<xsl:comment>===== Rename grant-num to award-id =====</xsl:comment>
				<funding-group>
					<award-group>
						<xsl:apply-templates select="following-sibling::grant-sponsor" mode="write-out"/>
						<award-id>
							<xsl:apply-templates/>
						</award-id>
					</award-group>
				</funding-group>
			</xsl:when>
			<xsl:otherwise>
				<award-id>
					<xsl:apply-templates/>
				</award-id>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
	<!-- ================================================== -->
	<!-- TEMPLATE MATCH: grant-sponsor -->
	<!-- ================================================== -->
	
	<xsl:template match="grant-sponsor" mode="write-out">
		<xsl:comment>===== Rename grant-sponsor to funding-source =====</xsl:comment>
		<funding-source>
			<xsl:apply-templates/>
		</funding-source>
	</xsl:template>
	
	
	<!-- ================================================== -->
	<!-- TEMPLATE MATCH: contract-sponsor, grant-sponsor
		CONDITIONS: child of article-meta
		
		Note: Moved inside funding-group element -->
	<!-- ================================================== -->
	
	<xsl:template match="contract-sponsor[parent::article-meta] | grant-sponsor[parent::article-meta]"/>
	

	<!-- ================================================== -->
	<!-- TEMPLATE MATCH: custom-meta-wrap
		
		Note: Rename to custom-meta-group; Combine multiple
		custom-meta-wrap elements into a single custom-meta-group
		(Affects Publishing only) -->
	<!-- ================================================== -->
	
	<xsl:template match="custom-meta-wrap">
		<xsl:comment>===== Restructure custom-meta-wrap to custom-meta-group =====</xsl:comment>
		<custom-meta-group>
			<xsl:apply-templates/>
			<xsl:if test="following-sibling::custom-meta-wrap">
				<xsl:apply-templates select="following-sibling::custom-meta-wrap/custom-meta"/>
			</xsl:if>
		</custom-meta-group>
	</xsl:template>
	
	
	<!-- ================================================== -->
	<!-- TEMPLATE MATCH: custom-meta-wrap
		CONDITION: position > 1
		
		Note: Multiple custom-meta-wrap elements combined in
		previous template -->
	<!-- ================================================== -->
	
	<xsl:template match="custom-meta-wrap[position()>1]"/>	
	
	
	<!-- ================================================== -->
	<!-- TEMPLATE MATCH: meta-name
		
		Note: Minimized model to #PCDATA -->
	<!-- ================================================== -->
	
	<xsl:template match="meta-name">
		<xsl:copy>
			<xsl:apply-templates mode="notag"/>
		</xsl:copy>
	</xsl:template>


	<!-- ================================================== -->
	<!-- TEMPLATE MATCH: boxed-text/title
		
		Note: Must be wrapped inside element caption -->
	<!-- ================================================== -->
	<xsl:template match="boxed-text/title">
		<xsl:comment>===== Wrap title in caption element =====</xsl:comment>
		<caption>
			<title>
				<xsl:apply-templates/>
			</title>
		</caption>
	</xsl:template>
	
	
	<!-- ================================================== -->
	<!-- TEMPLATE MATCH: chem-struct-wrapper
		
		Note: Rename chem-struct-wrap; Check for alternate forms -->
	<!-- ================================================== -->
	
	<xsl:template match="chem-struct-wrapper">
		<xsl:param name="id" select="@id"/>
		<xsl:param name="alt-forms" select="//*[@alternate-form-of=$id]"/>
		<xsl:choose>
			<xsl:when test="$alt-forms">
				<xsl:comment>===== Group alternatives; rename chem-struct-wrapper to chem-struct-wrap =====</xsl:comment>
				<alternatives>
					<chem-struct-wrap>
						<xsl:apply-templates select="@*"/>
						<xsl:apply-templates/>
					</chem-struct-wrap>
					<xsl:apply-templates select="$alt-forms" mode="write-out"/>
				</alternatives>
			</xsl:when>
			<xsl:otherwise>
				<xsl:comment>===== Rename chem-struct-wrapper to chem-struct-wrap =====</xsl:comment>
				<chem-struct-wrap>
					<xsl:apply-templates select="@*"/>
					<xsl:apply-templates/>
				</chem-struct-wrap>
			</xsl:otherwise>
		</xsl:choose>		
	</xsl:template>
	
	
	<!-- ================================================== -->
	<!-- TEMPLATE MATCH: mml:annotation-xml
		
		Note: Model limited to p+; Confirm contents are valid within
		p element; Specific element lists maintained in tag set-specific
		XSL module. -->
	<!-- ================================================== -->
	
	<xsl:template match="mml:annotation-xml">
		<xsl:variable name="element-test">
			<xsl:call-template name="test-for-elements-allowed-in-p">
				<xsl:with-param name="nodes" select="*"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$element-test !='fail'">
				<xsl:copy>
					<p>
						<xsl:apply-templates/>
					</p>
				</xsl:copy>
			</xsl:when>
			<xsl:otherwise>
				<xsl:comment>Current structure is not allowed in p.</xsl:comment>
			</xsl:otherwise>
		</xsl:choose>					
	</xsl:template>
	
	
	<!-- ================================================== -->
	<!-- TEMPLATE MATCH: page-count
		CONDITIONS: Not in nlm-citation and not in counts
		
		Note: Element page-count is only allowed in counts and 
		nlm-citation; Use size with @units -->
	<!-- ================================================== -->
	<xsl:template match="page-count[not(parent::counts)]">
		<xsl:comment>===== Restruture page-count as size[@units="page"] =====</xsl:comment>
		<size units="page">
			<xsl:value-of select="@count"/>
		</size>
	</xsl:template>
	
	
	<!-- ================================================== -->
	<!-- TEMPLATE MATCH: target
		
		Note: Element target now requires @id -->
	<!-- ================================================== -->
	
	<xsl:template match="target">
		<target>
			<xsl:attribute name="id">
				<xsl:choose>
					<xsl:when test="@id">
						<xsl:value-of select="@id"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="generate-id()"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:for-each select="@*">
				<xsl:copy-of select="."/>
			</xsl:for-each>
			<xsl:apply-templates/>
		</target>
	</xsl:template>
	

	<!-- ================================================== -->
	<!-- TEMPLATE MATCH: glossary
		
		Note: Restructuring gloss-group into glossary                                         
		
		Convert gossary/gloss-group into a recursive glossary if:
			1. Glossary has more than 1 gloss-group
			2. Glossary has child other than title and gloss-group
			3. Glossary and child gloss-group have conflicting @content-types
			4. IDs of both glossary and gloss-group are reference elsewhere
				in the document
			5. Glossary and child gloss-group both have titles
		
		All other scenarios will be flattened into a single glossary.
			If both glossary and gloss-group have @id specified, use value of 
			glossary. -->
	<!-- ================================================== -->
	
	<xsl:template match="glossary">
		<xsl:variable name="content-type" select="@content-type"/>
		<xsl:variable name="id" select="@id"/>
		<xsl:choose>
			<!-- 1 -->
			<xsl:when test="count(gloss-group[2])=1">
				<glossary>
					<xsl:apply-templates select="@*"/>
					<xsl:apply-templates/>
				</glossary>
			</xsl:when>
			<!-- 2 -->
			<xsl:when test="*[not(self::title) and not(self::gloss-group)]">
				<glossary>
					<xsl:apply-templates select="@*"/>
					<xsl:apply-templates/>
				</glossary>
			</xsl:when>
			<!-- 3 -->
			<xsl:when test="gloss-group/@content-type!=$content-type">
				<glossary>
					<xsl:apply-templates select="@*"/>
					<xsl:apply-templates/>
				</glossary>
			</xsl:when>
			<!-- 4 -->
			<xsl:when test="//*/@id=$id and //*/@id=gloss-group/@id">
				<glossary>
					<xsl:apply-templates select="@*"/>
					<xsl:apply-templates/>
				</glossary>
			</xsl:when>
			<!-- 5 -->
			<xsl:when test="title and gloss-group/title">
				<glossary>
					<xsl:apply-templates select="@*"/>
					<xsl:apply-templates/>
				</glossary>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="gloss-group" mode="simplify-gloss-group"/>
			</xsl:otherwise>
		</xsl:choose>		
	</xsl:template>	
	
	
	<!-- ================================================== -->
	<!-- TEMPLATE MATCH: gloss-group 
	
		Note: Rename gloss-group glossary -->
	<!-- ================================================== -->
	
	<xsl:template match="gloss-group">
		<xsl:comment>===== Creating glossary from gloss-group =====</xsl:comment>
		<glossary>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates/>
		</glossary>
	</xsl:template>
		
	<!-- ================================================== -->
	<!-- TEMPLATE MATCH: gloss-group
		MODE: simplify-gloss-group
	
		Note: glossary/gloss-group structure can be flattened; carry
		over all titles and ids from all elements. -->
	<!-- ================================================== -->
	<xsl:template match="gloss-group" mode="simplify-gloss-group">
		<xsl:comment>===== Creating glossary from gloss-group =====</xsl:comment>
		<glossary>
			<xsl:if test="parent::glossary/@id">
				<xsl:attribute name="id">
					<xsl:value-of select="parent::glossary/@id"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="parent::glossary/title">
				<xsl:apply-templates select="parent::glossary/title"/>
			</xsl:if>
			<xsl:apply-templates/>
		</glossary>
	</xsl:template>



	
		
	<!-- ================================================== -->
	<!-- TEMPLATE MATCH: table-wrap 
		
		Note: If alternate-form-of table-wrap exists, move inside
		table-wrap/alternatives element, grouped with table element -->
	<!-- ================================================== -->	
	
	<xsl:template match="table-wrap">
		<xsl:param name="id" select="@id"/>
		<xsl:param name="alt-forms" select="//*[@alternate-form-of=$id]"/>
		<xsl:copy>
			<xsl:choose>
				<xsl:when test="$alt-forms">
					<xsl:for-each select="@*|*|text()">
						<xsl:choose>
							<xsl:when test="self::table">
								<xsl:apply-templates select="." mode="alternatives">
									<xsl:with-param name="alt-forms" select="$alt-forms"/>
								</xsl:apply-templates>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="."/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="@*|*|text()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:copy>
	</xsl:template>
	
	<!-- ================================================== -->
	<!-- TEMPLATE MATCH: table
		MODE: alternatives
		
		Note: Write out the table element with the alternate form inside
		element alternatives -->
	<!-- ================================================== -->
	
	<xsl:template match="table" mode="alternatives">
		<xsl:param name="alt-forms"/>
		<alternatives>
			<xsl:copy>
				<xsl:apply-templates select="@*|*|text()"/>
			</xsl:copy>
			<xsl:apply-templates select="$alt-forms" mode="write-out"/>
		</alternatives>
	</xsl:template>
	
	
	<!-- ================================================== -->
	<!-- TEMPLATE MATCH: floats-wrap
		
		Note: Rename floats-group -->
	<!-- ================================================== -->
	
	<xsl:template match="floats-wrap">
		<xsl:comment>===== Rename floats-wrap to floats-group =====</xsl:comment>
		<floats-group>
			<xsl:apply-templates/>
		</floats-group>
	</xsl:template>
	
		
	<!-- ================================================== -->
	<!-- TEMPLATE MATCH: citation, nlm-citation
				
		Note: Rename citation element-citation if element content or 
		mixed-citation if mixed content; Update citation-type attribute -->
	<!-- ================================================== -->
	
	<xsl:template match="citation | nlm-citation">
		<xsl:variable name="citation-type">
			<xsl:value-of select="@citation-type"/>
		</xsl:variable>
		<xsl:variable name="text">
			<xsl:for-each select="text()">
				<xsl:value-of select="."/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="oldname">
			<xsl:value-of select="name(.)"/>
		</xsl:variable>
		<xsl:variable name="newname">
			<xsl:choose>
				<xsl:when test="$oldname='nlm-citation'">
					<xsl:text>element-citation</xsl:text>
				</xsl:when>
				<xsl:when test="not(normalize-space($text))">
					<xsl:text>element-citation</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>mixed-citation</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:element name="{$newname}">		
			<xsl:if test="@citation-type">
				<xsl:choose>
					<xsl:when test="$citation-att[@source=$citation-type]/@attr">
						<xsl:attribute name="{$citation-att[@source=$citation-type]/@attr}">
							<xsl:value-of select="@citation-type"/>
						</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="publication-type">
							<xsl:value-of select="@citation-type"/>
						</xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<xsl:apply-templates select="@* | * | text()"/>	
		</xsl:element>
	</xsl:template>
	
	
	<!-- ================================================== -->
	<!-- TEMPLATE MATCH: @citation-type
		
		Note:  replaced by new attributes publication-type,  
		publication-format, and  publisher-type; Citation templates use
		$citation-att to calculate new attributes based on existing value -->
	<!-- ================================================== -->
	
	<xsl:template match="@citation-type"/>


	<!-- ================================================== -->
	<!-- TEMPLATE MATCH: access-date, time-stamp
		
		Note: Rename to date-in-citation; carry previous element name
		into @content-type -->
	<!-- ================================================== -->
	
	<xsl:template match="access-date | time-stamp">
		<xsl:comment>===== Rename element to date-in-citation =====</xsl:comment>
		<date-in-citation content-type="{name(.)}">
			<xsl:apply-templates/>
		</date-in-citation>
	</xsl:template>

</xsl:stylesheet>
