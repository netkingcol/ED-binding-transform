<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:foo="http://www.foo.org/" xmlns:bar="http://www.bar.org">
<xsl:param name="delimiter" select=" ',' " />
<xsl:strip-space elements="*" />
<xsl:output method="text" />

<xsl:template match="/*">
  <html>
    <style>
      table, th, td { border: 1px solid black; border-collapse: collapse;}
      th, td { padding: 3px; }
</style>
  <body>
  <h2>Bindings</h2>
    <table border="1">
      <tr bgcolor="#9acd32">
        <th>Action</th>
        <th>Device</th>
        <th>Key</th>
        <th>Device</th>
        <th>Key</th>
      </tr>
       <xsl:apply-templates select="*"/>
    </table>
  </body>
  </html>
   
</xsl:template>

  <!-- Process all child nodes -->
<xsl:template match="*">
  
  <!-- If the node has children -->
  <xsl:if test="count(*) != 0">
       
      <!--process any <Binding> element if present -->
      <xsl:apply-templates select="Binding">
        <xsl:with-param name="action" select="local-name()"/>
      </xsl:apply-templates>

    <!-- process <Primary> element if present-->
      <xsl:apply-templates select="Primary">
        <xsl:with-param name="action" select="local-name()"/>
      </xsl:apply-templates>
   
  </xsl:if>

</xsl:template>
  
<!-- Handle Nodes with <Binding> element -->  
<xsl:template match="Binding" >
  <xsl:param name="action"/>
  
  <xsl:choose>
    
    <!-- If a <Device> is present -->
    <xsl:when  test="@Device != '{NoDevice}'">


      <!-- Add a row to the table for this binding -->
      <tr>
        <td><xsl:value-of select="$action"/></td>
              
        <!-- Output Device -->
       <td><xsl:value-of select="@Device"/></td>

        <!-- Check it's a Keyboard key -->
        <xsl:choose> 
          <xsl:when test="starts-with(@Key,'Key_')">
            
            <!-- omit the Key_ string -->
            <td>
              <xsl:value-of select="substring-after(@Key,'Key_')"/>
            </td>
          </xsl:when>
          
          <!-- Else output it as is -->
          <xsl:otherwise>
            <td><xsl:value-of select="@Key"/></td>  
          </xsl:otherwise>
        </xsl:choose>
      </tr>
    </xsl:when>
    <xsl:otherwise>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Handle <Primary> nodes (and then the <Secondary> -->  
<xsl:template match="Primary" >
   <xsl:param name="action"/>
 
      <xsl:choose>
        
        <!-- If a Device is present -->
        <xsl:when test="@Device != '{NoDevice}'">
          
          <!-- Add a row to the table -->
          <tr>  
                <!-- Output the Primary binding -->
                <td><xsl:value-of select="$action"/></td>                               
                <xsl:call-template name="OutputBinding">
                  <xsl:with-param name="node" select="."/>
                </xsl:call-template>
            
            <!-- Call template to check Secondary binding -->
            <xsl:call-template name="SecondaryDevice">
              <xsl:with-param name="primary" select="."/>
            </xsl:call-template>              
          </tr>

        </xsl:when>
        <xsl:otherwise>
        </xsl:otherwise>
    </xsl:choose>


  <!-- Template to output Secondary binding -->
</xsl:template>
  <xsl:template name="SecondaryDevice" >
    <xsl:param name="primary"/>
    
    <!-- Locate the <Secondary> node -->
    <xsl:variable name="SecondDevice" select="$primary/following-sibling::Secondary"/>
    
    <xsl:choose>
      
      <!--If a secondary device is present -->
      <xsl:when test="$SecondDevice/@Device != '{NoDevice}'">
        
          <!-- Call template to output Secondary binding -->
          <xsl:call-template name="OutputBinding">
            <xsl:with-param name="node" select="$SecondDevice"/>
          </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Template to output a Device/Key pair -->
<xsl:template name="OutputBinding" >
    <xsl:param name="node"/>
  
    <!-- Output Device -->
    <td>
      <xsl:value-of select="$node/@Device"/>
    </td>

    <xsl:choose>

      <!--If it's a Keyboard key -->
      <xsl:when test="starts-with($node/@Key,'Key_')">

        <!-- omit the Key_ string -->
        <td>
          <xsl:value-of select="substring-after($node/@Key,'Key_')"/>
        </td>
      </xsl:when>

        <!-- Else output key as is -->
      <xsl:otherwise>
        <td>
          <xsl:value-of select="$node/@Key"/>
        </td>
      </xsl:otherwise>
    </xsl:choose>


</xsl:template>
</xsl:stylesheet>