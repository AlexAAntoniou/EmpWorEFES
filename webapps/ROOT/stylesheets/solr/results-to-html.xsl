<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:h="http://apache.org/cocoon/request/2.0"
  xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
  xmlns:str="http://exslt.org/strings">


  <xsl:import href="../defaults.xsl"/>
  <xsl:include href="cocoon://_internal/url/reverse.xsl"/>
  <xsl:include href="results-pagination.xsl"/>

  <xsl:param name="min-year"/>
  <xsl:param name="max-year"/>
  

  <!-- query-string is escaped, but according to different rules than
       both XPath's encode-for-uri and escape-html-uri
       functions. encode-for-uri being the standard to compare
       against, the query string has the following characters not
       escaped: "," (there may be others) -->
  <xsl:variable name="query-string">
      <xsl:for-each select="/aggregation/h:request/h:requestParameters/h:parameter/h:value">
        <xsl:value-of select="../@name" />
        <xsl:text>=</xsl:text>
        <xsl:value-of select="." />
        <xsl:if test="not(position() = last())">
          <xsl:text>&amp;</xsl:text>
        </xsl:if>
      </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="escaped-query-string">
    <xsl:value-of
      select="replace(if($query-string = '') then 'start=0' else $query-string , ',', '%2C')"/>
  </xsl:variable>
  <xsl:variable name="default_search_query" select="'dt:inscription'"/>

  <xsl:template name="search_form">
    <form id="search_form" action="." method="get">
      <input name="fq:text" placeholder="Search terms" type="search"/>
    </form>
  </xsl:template>

  <xsl:template match="int" mode="search-results">
    <!-- A facet's count. -->
    <xsl:variable name="fq">
      <xsl:text>&amp;fq=</xsl:text>
      <xsl:value-of select="../@name"/>
      <xsl:text>:"</xsl:text>
      <xsl:value-of select="encode-for-uri(@name)"/>
      <xsl:text>"</xsl:text>
    </xsl:variable>
    <xsl:variable name="escaped-fq">
      <xsl:value-of select="substring-before($fq, '&quot;')"/>
      <xsl:value-of select="encode-for-uri(substring-after($fq, ':'))"/>
    </xsl:variable>

    <li>
      <a>
        <xsl:attribute name="href">
          <xsl:text>?</xsl:text>
          <xsl:call-template name="create_facet_button_url">
            <xsl:with-param name="r_q_name">fq</xsl:with-param>
            <xsl:with-param name="r_q_value">
              <xsl:value-of select="$escaped-fq"/>
            </xsl:with-param>
            <xsl:with-param name="start" select="'0'"/>
            <xsl:with-param name="context" select="/"/>
          </xsl:call-template>
          <xsl:value-of select="$fq"/>
        </xsl:attribute>
        <xsl:attribute name="class">
          <xsl:if test="contains($escaped-query-string, $escaped-fq)">
            <xsl:text>disabled</xsl:text>
          </xsl:if>
        </xsl:attribute>
        <xsl:value-of select="replace(@name, '_', ' ')"/>
        <xsl:if test="@name = ''">
          <xsl:text>Empty</xsl:text>
        </xsl:if>
      </a>
      <xsl:text> </xsl:text>

      <xsl:variable name="label_type">
        <xsl:if test="contains($escaped-query-string, $escaped-fq)">
          <xsl:text>secondary</xsl:text>
        </xsl:if>
        <xsl:text> </xsl:text>
      </xsl:variable>

      <span class="round label {$label_type}">
        <xsl:value-of select="."/>
      </span>
    </li>

  </xsl:template>

  <xsl:template match="lst[@name='facet_fields']/lst[@name='not-after']"
    mode="outside-search-results">
    <section>
      <h4>
        <xsl:text>Date</xsl:text>
        <xsl:text> </xsl:text>
        <span id="date-slider-label">
          <xsl:value-of select="$min-year"/>
          <xsl:text> - </xsl:text>
          <xsl:value-of select="$max-year"/>
          <xsl:text> A.D.</xsl:text>
        </span>
      </h4>

      <div id="date-slider-range" data-range-max="{$kiln:max-year}"
        data-range-min="{$kiln:min-year}" data-value-min="{$min-year}" data-value-max="{$max-year}"
        i18n:attr="data-label-suffix" data-label-suffix="A.D.">
        <xsl:attribute name="data-query">
          <xsl:call-template name="create_facet_button_url"/>
        </xsl:attribute>
        <xsl:text>&#160;</xsl:text>
      </div>
      <p class="muted">
        <xsl:text>Use sliders to select date range</xsl:text>
      </p>
    </section>
  </xsl:template>

  <xsl:template match="lst[@name='facet_fields']" mode="search-results">
    <xsl:if test="lst/int">
      <h3>Facets</h3>

      <xsl:apply-templates mode="outside-search-results"/>

      <xsl:variable name="order"
        select="'location', 'document-type', 'evidence', 'persnames', 'monument-type', 'material', 'execution', 'institution'"/>

      <div class="section-container accordion" data-section="accordion"
        data-options="one_up: false;">
        <xsl:apply-templates select="current()//lst" mode="search-results">
          <xsl:sort select="index-of($order, substring-before(@name, concat('-', $lang)))"
            order="ascending"/>
        </xsl:apply-templates>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template name="defaultFacet">
    <section>
      <p class="title" data-section-title="">
        <a>
          <xsl:attribute name="href">
            <xsl:text>#section-</xsl:text>
            <xsl:value-of select="@name"/>
          </xsl:attribute>
          <xsl:apply-templates mode="search-results" select="@name"/>
        </a>
      </p>
      <div class="content" data-section-content="">
        <ul class="no-bullet">
          <xsl:apply-templates mode="search-results"/>
        </ul>
      </div>
    </section>
  </xsl:template>

  <xsl:template match="lst[@name='facet_fields']/lst" mode="search-results">
    <xsl:choose>
      <xsl:when test="./@name='not-after' or @name='not-before'"/>
      <xsl:otherwise>
        <xsl:call-template name="defaultFacet"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="lst[@name='facet_fields']/lst/@name" mode="search-results">
    <xsl:choose>
      <xsl:when test="starts-with(., 'institution')">
        <xsl:text>repository</xsl:text>
      </xsl:when>
      <xsl:when test="starts-with(., 'monument-type')">
        <xsl:text>monument</xsl:text>
      </xsl:when>
      <xsl:when test="starts-with(., 'evidence')">
        <xsl:text>dating criteria</xsl:text>
      </xsl:when>
      <xsl:when test="starts-with(., 'execution')">
        <xsl:text>technique</xsl:text>
      </xsl:when>
      <xsl:when test="starts-with(., 'persnames')">
        <xsl:text>names</xsl:text>
      </xsl:when>
      <xsl:when test="starts-with(., 'material')">
        <xsl:text>material</xsl:text>
      </xsl:when>
      <xsl:when test="starts-with(., 'location')">
        <xsl:text>origin of text</xsl:text>
      </xsl:when>
      <xsl:when test="starts-with(., 'document-type')">
        <xsl:text>category of text</xsl:text>
      </xsl:when>

      <xsl:otherwise>
        <xsl:for-each select="tokenize(., '_')">
          <xsl:value-of select="upper-case(substring(., 1, 1))"/>
          <xsl:value-of select="substring(., 2)"/>
          <xsl:if test="not(position() = last())">
            <xsl:text> </xsl:text>
          </xsl:if>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <xsl:template match="result/doc" mode="search-results">

    <xsl:variable name="id" select="str[@name = 'tei-id']" />
    <li>
      <a>
        <xsl:attribute name="href">
          <xsl:value-of select="kiln:url-for-match('local-tei-display-html',
                                (str[@name='url_path']))" />
        </xsl:attribute>

        <xsl:choose>
          <xsl:when test="contains($id, '.')">
            <strong>
              <xsl:value-of select="substring-before($id, '.')"/>
            </strong>
            <xsl:text>.</xsl:text>
            <xsl:value-of select="substring-after($id, '.')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$id"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text> </xsl:text>
        <xsl:value-of select="arr[@name=concat('document-title-', $lang)]/str[1]"/>


      </a>
    </li>
  </xsl:template>

  <xsl:template match="response/result" mode="search-results">
    <xsl:variable name="start" select="/aggregation/response/result/@start"/>
    <xsl:variable name="rows"
      select="/aggregation/response/lst/lst[@name = 'params']/str[@name = 'rows']"/>
    <xsl:variable name="page" select="count(/aggregation/response/result/doc)"/>
    <xsl:variable name="total" select="/aggregation/response/result/@numFound"/>

    <xsl:choose>
      <xsl:when test="number(@numFound) = 0">
        <h3>
          <xsl:text>No results found</xsl:text>
        </h3>
      </xsl:when>
      <xsl:when test="doc">
        <h2>
          <xsl:text>Results</xsl:text>
          <xsl:text> </xsl:text>
          <small>
            <xsl:text>Showing </xsl:text>
            <xsl:value-of select="$start + 1"/>
            <xsl:text> to </xsl:text>
            <xsl:value-of select="$start + count(doc)"/>
            <xsl:text> of </xsl:text>
            <xsl:value-of select="$total"/>
          </small>
        </h2>

        <ul class="no-bullet">
          <xsl:apply-templates mode="search-results" select="doc"/>
        </ul>
        <xsl:call-template name="navigation">
          <xsl:with-param name="start" select="$start"/>
          <xsl:with-param name="rows" select="$rows"/>
          <xsl:with-param name="total" select="$total"/>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="navigation">
    <xsl:param name="start" required="yes"/>
    <xsl:param name="rows" required="yes"/>
    <xsl:param name="total" required="yes"/>

    <xsl:variable name="context" select="/"/>

    <div class="row">
      <div class="large-12 columns">
        <ul class="pagination pagination-centered">
          <xsl:choose>
            <xsl:when test="$start = 0">
              <li class="unavailable arrow">
                <a href="">&lt;</a>
              </li>
            </xsl:when>
            <xsl:otherwise>
              <li class="arrow">
                <a>
                  <xsl:attribute name="href">
                    <xsl:text>?</xsl:text>
                    <xsl:call-template name="create_facet_button_url">
                      <xsl:with-param name="start">
                        <xsl:value-of select="$start - $rows"/>
                      </xsl:with-param>
                    </xsl:call-template>
                  </xsl:attribute>
                  <xsl:text>&lt;</xsl:text>
                </a>
              </li>
            </xsl:otherwise>
          </xsl:choose>

          <xsl:for-each select="1 to xs:integer(ceiling($total div $rows))">
            <xsl:variable name="cur" select="$rows * . - $rows"/>
            <li>
              <xsl:if test="$cur = $start">
                <xsl:attribute name="class">current</xsl:attribute>
              </xsl:if>
              <a>
                <xsl:attribute name="href">
                  <xsl:text>?</xsl:text>
                  <xsl:call-template name="create_facet_button_url">
                    <xsl:with-param name="start">
                      <xsl:value-of select="$cur"/>
                    </xsl:with-param>
                    <xsl:with-param name="context" select="$context"/>
                  </xsl:call-template>
                </xsl:attribute>
                <xsl:value-of select="."/>
              </a>
            </li>
          </xsl:for-each>

          <xsl:choose>
            <xsl:when test="$start + $rows > $total">
              <li class="arrow unavailable">
                <a href="">&gt;</a>
              </li>
            </xsl:when>
            <xsl:otherwise>
              <li class="arrow">
                <a>
                  <xsl:attribute name="href">
                    <xsl:text>?</xsl:text>
                    <xsl:call-template name="create_facet_button_url">
                      <xsl:with-param name="start">
                        <xsl:value-of select="$start + $rows"/>
                      </xsl:with-param>
                    </xsl:call-template>
                  </xsl:attribute>
                  <xsl:text>&gt;</xsl:text>
                </a>
              </li>
            </xsl:otherwise>
          </xsl:choose>
        </ul>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="*[@name='fq']" mode="search-results">
    <xsl:choose>
      <xsl:when test="local-name(.) = 'str'">
        <xsl:call-template name="display-applied-facet"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="str">
          <xsl:call-template name="display-applied-facet"/>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="display-applied-facet">

    <xsl:variable name="label">
      <xsl:choose>
        <xsl:when test="starts-with(., 'text')">
          <xsl:value-of select="replace(replace(., '[^:]+:(.*)$', '$1'), '_', ' ')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="replace(replace(., '[^:]+:&quot;(.*)&quot;$', '$1'), '_', ' ')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="type">
      <!-- get parameter type and remove language suffix by using non-greedy regex -->
      <xsl:value-of select="replace(., '([^:]+?)(-\w{2})?:.*$', '$1')"/>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$type = 'not-before' or $type = 'not-after'"/>
      <xsl:otherwise>
        <li>
          <ul class="button-group">
            <li>
              <a class="info secondary button small">
                <xsl:attribute name="href">
                  <xsl:text>?fq=</xsl:text>
                  <xsl:value-of select="text()"/>
                </xsl:attribute>
                <xsl:value-of select="$type"/>
                <xsl:text>:</xsl:text>
                <xsl:value-of select="$label"/>
                <xsl:if test="$label = ''">
                  <xsl:text>Empty</xsl:text>
                </xsl:if>
              </a>
            </li>
            <li>
              <a class="info secondary button small">
                <xsl:attribute name="href">
                  <xsl:text>?</xsl:text>
                  <xsl:call-template name="create_facet_button_url">
                    <xsl:with-param name="r_q_name">fq</xsl:with-param>
                    <xsl:with-param name="r_q_value">
                      <xsl:value-of select="text()"/>
                    </xsl:with-param>
                    <xsl:with-param name="start" select="'0'"/>
                  </xsl:call-template>
                </xsl:attribute>
                <!-- Create a link to unapply the facet. -->
                <i class="fa fa-times" ><xsl:text> </xsl:text></i>
              </a>
            </li>
          </ul>
        </li>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="text()" mode="search-results"/>
  <xsl:template match="text()" mode="outside-search-results"/>


  <xsl:template name="create_facet_button_url">
    <xsl:param name="r_q_name" select="'q'"/>
    <xsl:param name="r_q_value" select="$default_search_query"/>
    <xsl:param name="start" select="'none'"/>
    <xsl:param name="context" select="/"/>

    <xsl:text>start=</xsl:text>
    <xsl:choose>
      <xsl:when test="not($start='none')">
        <xsl:value-of select="$start"/>
      </xsl:when>
      <xsl:when
        test="count($context/aggregation/response/lst[@name='responseHeader']/lst[@name='params']/str[@name='start']) = 1">
        <xsl:value-of
          select="$context/aggregation/response/lst[@name='responseHeader']/lst[@name='params']/str[@name='start']"
        />
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>0</xsl:text>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:for-each
      select="$context/aggregation/response/lst[@name='responseHeader']/lst[@name='params']/*[@name='fq']">
      <xsl:choose>
        <xsl:when test="local-name(.) = 'str'">
          <xsl:if test="not(@name=$r_q_name and text() = $r_q_value)">
            <xsl:call-template name="build_url_param_pair"/>
          </xsl:if>
        </xsl:when>
        <xsl:when test="local-name(.) = 'arr'">
          <xsl:for-each select="str">
            <xsl:if test="not(parent::node()[@name=$r_q_name] and text() = $r_q_value)">
              <xsl:call-template name="build_url_param_pair"/>
            </xsl:if>
          </xsl:for-each>
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="build_url_param_pair">
    <xsl:variable name="param_name">
      <xsl:value-of select="parent::node/@name"/>
    </xsl:variable>
    <xsl:variable name="param_type">
      <xsl:value-of select="replace(., '([^:]+):.*$', '$1')"/>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$param_type = 'not-before' or $param_type = 'not-after'"/>
      <xsl:otherwise>
        <xsl:text>&amp;</xsl:text>
        <xsl:value-of select="parent::node()/@name"/>
        <xsl:text>=</xsl:text>
        <xsl:value-of select="text()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="searchMenuLanguages">
    <li class="lang en">
      <a class="en" href="../../../en/{$min-year}/{$max-year}/?{$query-string}" title="English"
        >en</a>
    </li>

    <li class="lang py">
      <a class="py" href="../../../ru/{$min-year}/{$max-year}/?{$query-string}" title="Русский"
        >pу</a>
    </li>
  </xsl:template>

</xsl:stylesheet>
