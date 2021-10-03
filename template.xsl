<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml" />
    <xsl:template match="/">
        <root>
            <xsl:for-each select="//data/item">
                <line>
                    <xsl:variable name="v_url" select="attachments/media_keys/item" />
                    <text type='text'>
                        <xsl:value-of select="text"/>
                    </text>                    
                    <url><xsl:value-of select="//includes/media/item[media_key=$v_url]/preview_image_url|//includes/media/item[media_key=$v_url]/url"/></url>
                    <user_mentions>
                        <xsl:call-template name="extract_eta">
                            <xsl:with-param name="pText">
                                <xsl:call-template name="string-replace-all">
                                    <xsl:with-param name="text" select="concat(text, ' ,')" />
                                    <xsl:with-param name="replace">\n</xsl:with-param>
                                    <xsl:with-param name="by"> </xsl:with-param>
                                </xsl:call-template>
                            </xsl:with-param>
                        </xsl:call-template>
                    </user_mentions>
                    <hashtags>
                        <xsl:call-template name="extract_hash">
                            <xsl:with-param name="pText">
                                <xsl:call-template name="string-replace-all">
                                    <xsl:with-param name="text" select="concat(text, ' ,')" />
                                    <xsl:with-param name="replace">\n</xsl:with-param>
                                    <xsl:with-param name="by"> </xsl:with-param>
                                </xsl:call-template>
                            </xsl:with-param>
                        </xsl:call-template>
                    </hashtags>
                    <conversation_id>
                        <xsl:value-of select="conversation_id"/>
                    </conversation_id>
                    <id>
                        <xsl:value-of select="id"/>
                    </id>
                    <in_reply_to_user_id>
                        <xsl:value-of select="in_reply_to_user_id"/>
                    </in_reply_to_user_id>
                    <author_id>
                        <xsl:value-of select="author_id"/>
                    </author_id>
                    <created_at>
                        <xsl:value-of select="created_at"/>
                    </created_at>
                    <retweet_count>
                        <xsl:value-of select="public_metrics/retweet_count"/>
                    </retweet_count>
                    <reply_count>
                        <xsl:value-of select="public_metrics/reply_count"/>
                    </reply_count>
                    <like_count>
                        <xsl:value-of select="public_metrics/like_count"/>
                    </like_count>
                    <quote_count>
                        <xsl:value-of select="public_metrics/quote_count"/>
                    </quote_count>
                    <place_id>
                        <xsl:value-of select="geo/place_id"/>
                    </place_id>
              
                    <lang>
                        <xsl:value-of select="lang"/>
                    </lang>
                    
                    <referenced_tweets>
                        <xsl:value-of select="referenced_tweets"/>
                    </referenced_tweets>
                
                </line>
            </xsl:for-each>
        </root>
    </xsl:template>

    <xsl:template match="text()" name="extract_hash">
        <xsl:param name="pText" select="."/>
        <xsl:if test="contains($pText,'#')">
            <xsl:value-of select="substring-before(substring-after($pText,'#'), ' ')"/>
            <xsl:text>, </xsl:text>
            <xsl:call-template name="extract_hash">
                <xsl:with-param name="pText" select="substring-after($pText,'#')"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    
    <xsl:template match="text()" name="extract_eta">
        <xsl:param name="pText" select="."/>
        <xsl:if test="contains($pText,'@')">
            <xsl:value-of select="substring-before(substring-after($pText,'@'), ' ')"/>
            <xsl:text>, </xsl:text>
            <xsl:call-template name="extract_eta">
                <xsl:with-param name="pText" select="substring-after($pText,'@')"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template name="string-replace-all">
        <xsl:param name="text" />
        <xsl:param name="replace" />
        <xsl:param name="by" />
        <xsl:choose>
            <xsl:when test="$text = '' or $replace = ''or not($replace)">
                <!-- Prevent this routine from hanging -->
                <xsl:value-of select="$text" />
            </xsl:when>
            <xsl:when test="contains($text, $replace)">
                <xsl:value-of select="substring-before($text,$replace)" />
                <xsl:value-of select="$by" />
                <xsl:call-template name="string-replace-all">
                    <xsl:with-param name="text" select="substring-after($text,$replace)" />
                    <xsl:with-param name="replace" select="$replace" />
                    <xsl:with-param name="by" select="$by" />
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$text" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>