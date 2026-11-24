<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema">

    <!-- This stylesheet emits a SysEx message for a DX7 cartridge.
    It converts the voice data in the XML to hexadecimal values
    and formats them according to the SysEx specification. -->

  <xsl:output method="text"/>

  <!-- Convert decimal numbers to hexadecimal -->
  <!-- Adapted from "XSLT Cookbook" by Sal Mangano (O'Reilly, 2003)-->
  <xsl:variable name="hex-digits-lower" select="'0123456789abcdef'"/>
  <xsl:template name="dec-to-hex">
    <xsl:param name="number"/>
    <xsl:param name="result"/>

    <xsl:variable name="to-hex-digit"
      select="substring($hex-digits-lower, ($number mod 16) + 1, 1)"/>

    <xsl:choose>
      <xsl:when test="$number >= 16">

        <!-- Local variable to hold the result that should be left-padded-->
        <xsl:variable name="new-result">
          <xsl:call-template name="dec-to-hex">
            <xsl:with-param name="number" select="floor($number div 16)"/>
            <xsl:with-param name="result"
              select="concat($to-hex-digit, $result)"/>
          </xsl:call-template>
        </xsl:variable>

        <xsl:call-template name="left-pad-hex">
          <xsl:with-param name="hex" select="$new-result"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="left-pad-hex">
          <xsl:with-param name="hex" select="concat($to-hex-digit, $result)"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Template to left-pad hexadecimal values to two digits with leading zeros -->
  <xsl:template name="left-pad-hex">
    <xsl:param name="hex"/>
    <xsl:choose>
      <xsl:when test="string-length($hex) = 1">
        <xsl:value-of select="concat('0', $hex)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$hex"/>
      </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- Convert decimal numbers to binary -->
  <xsl:variable name="binary-digits" select="'01'"/>

  <xsl:template name="dec-to-bin">
    <xsl:param name="number"/>
    <xsl:param name="result"/>

    <xsl:variable name="to-binary-digit"
      select="substring($binary-digits, ($number mod 2) + 1, 1)"/>

    <xsl:choose>
      <xsl:when test="$number >= 2">

        <!-- Local variable to hold the result that should be left-padded-->
        <xsl:variable name="new-result">
          <xsl:call-template name="dec-to-bin">
            <xsl:with-param name="number" select="floor($number div 2)"/>
            <xsl:with-param name="result"
              select="concat($to-binary-digit, $result)"/>
          </xsl:call-template>
        </xsl:variable>

        <xsl:call-template name="left-pad-bin">
          <xsl:with-param name="bin" select="$new-result"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="left-pad-bin">
          <xsl:with-param name="bin" select="concat($to-binary-digit, $result)"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Template to left-pad binary values to eight digits with leading zeros -->
  <xsl:template name="left-pad-bin">
    <xsl:param name="bin"/>
    <xsl:choose>
      <!-- If the binary string is less than 8 characters, prepend a leading zero -->
      <xsl:when test="string-length($bin) &lt; 8">
        <xsl:value-of select="concat('0', $bin)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$bin"/>
      </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="/">
    <xsl:text>f0&#x20;</xsl:text> <!-- start of SysEx message-->
    <xsl:text>43&#x20;</xsl:text> <!-- Yamaha ID-->
    <xsl:text>00&#x20;</xsl:text> <!-- DX7 ID-->
    <xsl:text>09&#x20;</xsl:text> <!-- Data format ID-->
    <xsl:text>20&#x20;</xsl:text> <!-- Data format version-->
    <xsl:apply-templates select="cartridge" />
    <xsl:text>f7</xsl:text> <!-- end of SysEx message-->

    <!-- Just for testing, add a number in binary -->
    <xsl:call-template name="dec-to-bin">
      <xsl:with-param name="number" select="42"/>
      <xsl:with-param name="result" select="''"/>
    </xsl:call-template>

    <xsl:text>&#x0A;</xsl:text> <!-- newline -->
</xsl:template>

<!-- Pack the voice data. FIXME: this is work in progress! -->
<xsl:template name="pack-voice">
    <xsl:param name="voice"/>
    <xsl:variable name="voice-data">
        <xsl:apply-templates select="$voice" />
    </xsl:variable>

    <!-- Remove spaces from the voice data (just for testing the template) -->
    <xsl:variable name="packed-voice-data" select="replace($voice-data, '\s+', '')"/>

    <!-- Note that the operator data needs to be packed as well -->

    <!-- Output the packed voice data -->
    <xsl:value-of select="$packed-voice-data"/>
</xsl:template>

<xsl:template match="cartridge">
    <xsl:apply-templates select="voices" />
</xsl:template>

<xsl:template match="voices">
    <xsl:for-each select="voice">
        <xsl:call-template name="pack-voice">
            <xsl:with-param name="voice" select="."/>
        </xsl:call-template>
    </xsl:for-each>
</xsl:template>

<!-- Emits the raw voice data. It needs to be packed for a cartridge. -->
<xsl:template match="voice">
    <xsl:apply-templates select="operators" />
    <xsl:apply-templates select="peg" />

    <xsl:call-template name="dec-to-hex">
      <!-- algorithm is 1-based in the XML, but 0-based in the SysEx message -->
      <xsl:with-param name="number" select="xs:integer(@algorithm) - 1"/> 
      <xsl:with-param name="result" select="''"/>
    </xsl:call-template>
    <xsl:text>&#x20;</xsl:text> <!-- space between hex values -->

    <xsl:call-template name="dec-to-hex">
      <!-- feedback is 0...7, no adjustment needed -->
        <xsl:with-param name="number" select="xs:integer(@feedback)"/>
        <xsl:with-param name="result" select="''"/>
    </xsl:call-template>
    <xsl:text>&#x20;</xsl:text> <!-- space between hex values -->

    <!-- oscillator sync is true or false, so convert it to 0 or 1 -->
    <xsl:value-of select="format-number(number(@oscillatorSync='true'), '00')"/>
    <xsl:text>&#x20;</xsl:text> <!-- space between hex values -->

    <xsl:apply-templates select="lfo" />

    <xsl:call-template name="dec-to-hex">
      <!-- PMS is 0...7, no adjustment needed -->
        <xsl:with-param name="number" select="xs:integer(@pitchModulationSensitivity)"/>
        <xsl:with-param name="result" select="''"/>
    </xsl:call-template>
    <xsl:text>&#x20;</xsl:text> <!-- space between hex values -->

    <xsl:call-template name="dec-to-hex">
      <!-- transpose is -24...24, 0...48 in SysEx -->
        <xsl:with-param name="number" select="xs:integer(@transpose) + 24"/>
        <xsl:with-param name="result" select="''"/>
    </xsl:call-template>
    <xsl:text>&#x20;</xsl:text> <!-- space between hex values -->

    <!-- Convert the characters in the name of the voice to hexadecimal 
         using the XSLT 2.0 string-to-codepoints function and the dec-to-hex template. -->
    <xsl:for-each select="string-to-codepoints(@name)">
        <xsl:call-template name="dec-to-hex">
            <xsl:with-param name="number" select="."/>
            <xsl:with-param name="result" select="''"/>
        </xsl:call-template>
        <xsl:text>&#x20;</xsl:text> <!-- space between hex values -->
    </xsl:for-each>
</xsl:template>

<xsl:template match="operators">
    <!-- The operators are processed in reverse order, OP6 first, OP1 last -->  
  <xsl:for-each select="reverse(operator)">
    <xsl:apply-templates select="." />
  </xsl:for-each>
</xsl:template>

<xsl:template match="operator">
    <xsl:apply-templates select="eg" />
    <xsl:apply-templates select="keyboard-level-scaling" />

  <xsl:call-template name="dec-to-hex">
    <xsl:with-param name="number" select="xs:integer(@keyboardRateScaling)"/>
    <xsl:with-param name="result" select="''"/>
  </xsl:call-template>
  <xsl:text>&#x20;</xsl:text> <!-- space between hex values -->

  <xsl:call-template name="dec-to-hex">
    <xsl:with-param name="number" select="xs:integer(@amplitudeModulationSensitivity)"/>
    <xsl:with-param name="result" select="''"/>
  </xsl:call-template>
  <xsl:text>&#x20;</xsl:text> <!-- space between hex values -->

  <xsl:call-template name="dec-to-hex">
    <xsl:with-param name="number" select="xs:integer(@keyVelocitySensitivity)"/>
    <xsl:with-param name="result" select="''"/>
  </xsl:call-template>
  <xsl:text>&#x20;</xsl:text> <!-- space between hex values -->

  <!-- Output level of operator-->
  <xsl:call-template name="dec-to-hex">
    <xsl:with-param name="number" select="xs:integer(@level)"/>
    <xsl:with-param name="result" select="''"/>
  </xsl:call-template>
  <xsl:text>&#x20;</xsl:text> <!-- space between hex values -->

  <!-- Operator output mode (ratio or fixed) -->
  <xsl:choose>
    <xsl:when test="@outputMode = 'ratio'">
      <xsl:text>00</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:text>01</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:text>&#x20;</xsl:text> <!-- space between hex values -->

  <!-- Coarse and fine -->
  <xsl:call-template name="dec-to-hex">
    <xsl:with-param name="number" select="xs:integer(@coarse)"/>
    <xsl:with-param name="result" select="''"/>
  </xsl:call-template>
  <xsl:text>&#x20;</xsl:text> <!-- space between hex values -->
  <xsl:call-template name="dec-to-hex">
    <xsl:with-param name="number" select="xs:integer(@fine)"/>
    <xsl:with-param name="result" select="''"/>
  </xsl:call-template>
  <xsl:text>&#x20;</xsl:text> <!-- space between hex values -->

  <xsl:call-template name="dec-to-hex">
    <!-- detune is -7...+7, 0...14 in SysEx -->
    <xsl:with-param name="number" select="xs:integer(@detune) + 7"/>
    <xsl:with-param name="result" select="''"/>
  </xsl:call-template>
  <xsl:text>&#x20;</xsl:text> <!-- space between hex values -->

</xsl:template>

<!-- Common template for operator envelope generators and voice PEG -->
<xsl:template name="envelope-generator">
  <xsl:param name="eg"/>

  <xsl:for-each select="tokenize(rates, ' ')">
    <xsl:call-template name="dec-to-hex">
      <xsl:with-param name="number" select="number(.)"/>
      <xsl:with-param name="result" select="''"/>
    </xsl:call-template>
    <xsl:text>&#x20;</xsl:text> <!-- space between hex values -->
  </xsl:for-each>

  <xsl:for-each select="tokenize(levels, ' ')">
    <xsl:call-template name="dec-to-hex">
      <xsl:with-param name="number" select="number(.)"/>
      <xsl:with-param name="result" select="''"/>
    </xsl:call-template>
    <xsl:text>&#x20;</xsl:text> <!-- space between hex values -->
  </xsl:for-each>
</xsl:template>

<!-- Use the common template for both EG and PEG -->

<xsl:template match="eg">
  <xsl:call-template name="envelope-generator">
    <xsl:with-param name="eg" select="."/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="peg">
  <xsl:call-template name="envelope-generator">
    <xsl:with-param name="eg" select="."/>
  </xsl:call-template>
</xsl:template>

<!-- LFO waveform template -->
<xsl:template name="lfo-waveform">
  <xsl:param name="waveform"/>

  <xsl:variable name="numeric-waveform">
    <xsl:choose>
      <xsl:when test="$waveform = 'triangle'">0</xsl:when>
      <xsl:when test="$waveform = 'saw-down'">1</xsl:when>
      <xsl:when test="$waveform = 'saw-up'">2</xsl:when>
      <xsl:when test="$waveform = 'square'">3</xsl:when>
      <xsl:when test="$waveform = 'sine'">4</xsl:when>
      <xsl:when test="$waveform = 'sample-and-hold'">5</xsl:when>
    </xsl:choose>
  </xsl:variable>

  <xsl:call-template name="dec-to-hex">
    <xsl:with-param name="number" select="$numeric-waveform"/>
    <xsl:with-param name="result" select="''"/>
  </xsl:call-template>
</xsl:template>

<!-- Velocity curve style template -->
<xsl:template name="velocity-curve-style">
  <xsl:param name="style"/>

  <xsl:variable name="numeric-style">
    <xsl:choose>
      <xsl:when test="$style = '-LIN'">0</xsl:when>
      <xsl:when test="$style = '+EXP'">2</xsl:when>
      <xsl:when test="$style = '-EXP'">1</xsl:when>
      <xsl:when test="$style = '+LIN'">3</xsl:when>
    </xsl:choose>
  </xsl:variable>

  <xsl:call-template name="dec-to-hex">
    <xsl:with-param name="number" select="$numeric-style"/>
    <xsl:with-param name="result" select="''"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="lfo">
  <xsl:call-template name="dec-to-hex">
    <xsl:with-param name="number" select="xs:integer(@speed)"/>
    <xsl:with-param name="result" select="''"/>
  </xsl:call-template>
  <xsl:text>&#x20;</xsl:text> <!-- space between hex values -->

  <xsl:call-template name="dec-to-hex">
    <xsl:with-param name="number" select="xs:integer(@delay)"/>
    <xsl:with-param name="result" select="''"/>
  </xsl:call-template>
  <xsl:text>&#x20;</xsl:text> <!-- space between hex values -->

  <xsl:call-template name="dec-to-hex">
    <xsl:with-param name="number" select="xs:integer(@pmd)"/>
    <xsl:with-param name="result" select="''"/>
  </xsl:call-template>
  <xsl:text>&#x20;</xsl:text> <!-- space between hex values -->

  <xsl:call-template name="dec-to-hex">
    <xsl:with-param name="number" select="xs:integer(@amd)"/>
    <xsl:with-param name="result" select="''"/>
  </xsl:call-template>
  <xsl:text>&#x20;</xsl:text> <!-- space between hex values -->

  <!-- LFO sync is true or false, so convert it to 0 or 1 -->
  <xsl:value-of select="format-number(number(@sync='true'), '00')"/>
  <xsl:text>&#x20;</xsl:text> <!-- space between hex values -->

  <!-- LFO waveform -->
  <xsl:call-template name="lfo-waveform">
    <xsl:with-param name="waveform" select="@wave"/>
  </xsl:call-template>
  <xsl:text>&#x20;</xsl:text> <!-- space between hex values -->
</xsl:template>

<!-- Keyboard level scaling -->
<xsl:template match="keyboard-level-scaling">
  <!-- Output the breakpoint key MIDI note -->
  <xsl:call-template name="dec-to-hex">
    <xsl:with-param name="number" select="xs:integer(breakpoint)"/>
    <xsl:with-param name="result" select="''"/>
  </xsl:call-template>
  <xsl:text>&#x20;</xsl:text> <!-- space between hex values -->

  <!-- Left and right depths-->
  <xsl:call-template name="dec-to-hex">
    <xsl:with-param name="number" select="xs:integer(depth/@left)"/>
    <xsl:with-param name="result" select="''"/>
  </xsl:call-template>
  <xsl:text>&#x20;</xsl:text> <!-- space between hex values -->

  <xsl:call-template name="dec-to-hex">
    <xsl:with-param name="number" select="xs:integer(depth/@right)"/>
    <xsl:with-param name="result" select="''"/>
  </xsl:call-template>
  <xsl:text>&#x20;</xsl:text> <!-- space between hex values -->

  <!-- Left and right curves -->
  <xsl:call-template name="dec-to-hex">
    <xsl:with-param name="number" select="xs:integer(curve/@left)"/>
    <xsl:with-param name="result" select="''"/>
  </xsl:call-template>
  <xsl:text>&#x20;</xsl:text> <!-- space between hex values -->

  <xsl:call-template name="dec-to-hex">
    <xsl:with-param name="number" select="xs:integer(curve/@right)"/>
    <xsl:with-param name="result" select="''"/>
  </xsl:call-template>
  <xsl:text>&#x20;</xsl:text> <!-- space between hex values -->
</xsl:template>

</xsl:stylesheet>
