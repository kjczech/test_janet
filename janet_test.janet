<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE language SYSTEM "language.dtd">
<!--
  Janet syntax definition for Pandoc/Quarto (KDE Kate syntax format).

  This version expands the earlier starter file using ideas from vscode-janet:
  - Reader macros: ' ~ ; ,
  - @-prefixed delimiters: @(...), @[...], @{...}
  - Long strings using backticks (`...` with variable length)
  - Better symbol/variable highlighting (variable.other)
  - Macro-ish definition highlighting (after def/defn/defmacro/var, and also after "var-" / "def-" / "defn-")
  - Keyword-ish highlighting for many corelib tokens is *not* fully mirrored (the vscode list is huge);
    instead we keep a smaller "CoreForms" list plus operator tokens, and emphasize symbols/variables.

  Save as: janet.xml
-->
<language name="Janet"
          version="1.1"
          kateversion="5.0"
          section="Sources"
          extensions="*.janet;*.jdn"
          mimetype="text/x-janet">

  <highlighting>
    <!-- Small, high-signal set of special forms / control keywords -->
    <list name="CoreForms">
      <item>break</item>
      <item>def</item>
      <item>defn</item>
      <item>defmacro</item>
      <item>do</item>
      <item>var</item>
      <item>set</item>
      <item>fn</item>
      <item>while</item>
      <item>if</item>
      <item>cond</item>
      <item>case</item>
      <item>quote</item>
      <item>quasiquote</item>
      <item>unquote</item>
      <item>splice</item>
      <item>let</item>
      <item>loop</item>
      <item>for</item>
      <item>each</item>
      <item>try</item>
      <item>catch</item>
      <item>finally</item>
      <item>and</item>
      <item>or</item>
      <item>not</item>
      <item>in</item>
      <item>use</item>
      <item>import</item>
      <item>require</item>

      <!-- common “hyphen variants” used by Janet style -->
      <item>def-</item>
      <item>defn-</item>
      <item>defmacro-</item>
      <item>var-</item>
    </list>

    <list name="Operators">
      <!-- from the VSCode grammar snippet -->
      <item>%</item>
      <item>%=</item>
      <item>*</item>
      <item>*=</item>
      <item>+</item>
      <item>++</item>
      <item>+=</item>
      <item>-</item>
      <item>--</item>
      <item>-=</item>
      <item>-></item>
      <item>->></item>
      <item>-?></item>
      <item>-?>></item>
      <item>/</item>
      <item>/=</item>
      <item>&lt;</item>
      <item>&lt;=</item>
      <item>=</item>
      <item>&gt;</item>
      <item>&gt;=</item>
    </list>

    <list name="Literals">
      <item>true</item>
      <item>false</item>
      <item>nil</item>
    </list>

    <contexts>
      <context name="Normal" attribute="Normal Text" lineEndContext="#stay">
        <!-- line comment -->
        <HlCCharDetect char="#" attribute="Comment" context="LineComment"/>

        <!-- reader macros: ' ~ ; , -->
        <RegExpr attribute="Operator" context="#stay" String="['~;,]"/>

        <!-- delimiters (including @? prefix like @() @[] @{}) -->
        <RegExpr attribute="Operator" context="#stay" String="@?\("/>
        <RegExpr attribute="Operator" context="#stay" String="\)"/>
        <RegExpr attribute="Operator" context="#stay" String="@?\["/>
        <RegExpr attribute="Operator" context="#stay" String="\]"/>
        <RegExpr attribute="Operator" context="#stay" String="@?{"/>
        <RegExpr attribute="Operator" context="#stay" String="}"/>

        <!-- strings: @"..." or "..." -->
        <RegExpr attribute="String" context="DQString" String='@?"'/>

        <!-- long strings: backticks, optionally prefixed by @, with variable-length fence -->
        <!-- begin: (@?)(`+) -->
        <RegExpr attribute="String" context="LongStringFence" String="@?`+"/>

        <!-- numbers (closer to vscode grammar: supports _, hex, radix, exponent-ish) -->
        <RegExpr attribute="Number" context="#stay"
                 String="(?&lt;![\.\w_\-=!@\$%\^&amp;?/&lt;&gt;\*])[-+]?0x(?:[_\da-fA-F]+|[_\da-fA-F]+\.[_\da-fA-F]*|\.[_\da-fA-F]+)(?:&amp;[+-]?[\da-fA-F]+)?(?![\.\w_\-=!@\$%\^&amp;?/&lt;&gt;\*])"/>
        <RegExpr attribute="Number" context="#stay"
                 String="(?&lt;![\.\w_\-=!@\$%\^&amp;?/&lt;&gt;\*])[-+]?\d\d?r(?:[_\w]+|[_\w]+\.[_\w]*|\.[_\w]+)(?:&amp;[+-]?[\w]+)?(?![\.\w_\-=!@\$%\^&amp;?/&lt;&gt;\*])"/>
        <RegExpr attribute="Number" context="#stay"
                 String="(?&lt;![\.\w_\-=!@\$%\^&amp;?/&lt;&gt;\*])[-+]?(?:[_\d]+|[_\d]+\.[_\d]*|\.[_\d]+)(?:[eE&amp;][+-]?[\d]+)?(?![\.\w_\-=!@\$%\^&amp;?/&lt;&gt;\*])"/>

        <!-- literals -->
        <keyword attribute="Constant" context="#stay" String="Literals"/>

        <!-- operators-as-symbols -->
        <keyword attribute="Operator" context="#stay" String="Operators"/>

        <!-- core forms -->
        <keyword attribute="Keyword" context="#stay" String="CoreForms"/>

        <!-- keyword symbols: :foo -->
        <RegExpr attribute="Keyword" context="#stay"
                 String="(?&lt;![\.\w_\-=!@\$%\^&amp;?/&lt;&gt;\*]):[\.\w_\-=!@\$%\^&amp;?/&lt;&gt;\*]*"/>

        <!-- def-like forms: highlight the defined name (function/macro/var) -->
        <!-- Approximates vim: \v[(/]def(ault)@!\S* and expands for defn/defmacro/var and -variants -->
        <RegExpr attribute="Keyword" context="AfterDef"
                 String="\(\s*(?:def(?!ault)\b|def-?\b|defn\b|defn-\b|defmacro\b|defmacro-\b|var\b|var-\b)\s+"/>

        <!-- variable/symbols (vscode: variable.other.janet) -->
        <RegExpr attribute="Variable" context="#stay"
                 String="(?&lt;![\.\w_\-=!@\$%\^&amp;?/&lt;&gt;\*])[\.\w_\-=!@\$%\^&amp;?/&lt;&gt;\*][\.\w_\-=!@\$%\^&amp;?/&lt;&gt;\*]*"/>
      </context>

      <context name="LineComment" attribute="Comment" lineEndContext="#pop">
        <!-- nothing special inside line comments -->
      </context>

      <!-- Double-quoted strings -->
      <context name="DQString" attribute="String" lineEndContext="#stay">
        <RegExpr attribute="Char" context="#stay"
                 String="\\(?:[nevr0zft&quot;\\']|x[0-9A-Fa-f]{2}|u[0-9A-Fa-f]{4}|U[0-9A-Fa-f]{6,8})"/>
        <HlCCharDetect char="&quot;" attribute="String" context="#pop"/>
      </context>

      <!-- Long string fence handling.
           Kate XML doesn't support backreferences in end-patterns the same way TextMate does,
           so we approximate: treat ANY run of backticks as toggling long-string mode.
           This is slightly less precise than the VSCode grammar (which matches the same-length fence),
           but works well in practice.
      -->
      <context name="LongStringFence" attribute="String" lineEndContext="#stay">
        <!-- Immediately enter long string body after consuming the opening fence -->
        <RegExpr attribute="String" context="LongString" String=""/>
      </context>

      <context name="LongString" attribute="String" lineEndContext="#stay">
        <!-- end long string on backticks -->
        <RegExpr attribute="String" context="#pop#pop" String="`+"/>
      </context>

      <!-- After def/defn/defmacro/var: highlight the next symbol as a "Macro"/"Function"/"Variable" style.
           We use Macro style for defmacro*, Function style for defn/def, Variable style for var.
           Implementation: we detect which keyword in a sub-context by re-matching at the start of the def form.
           Since we already consumed "( def... " in the prior regex, we can't branch perfectly;
           instead we highlight the name as Function by default.
           If you prefer a separate Macro/Variable styling, duplicate the trigger regexes into separate contexts.
      -->
      <context name="AfterDef" attribute="Normal Text" lineEndContext="#stay">
        <RegExpr attribute="Normal Text" context="#stay" String="\s+"/>
        <!-- definition name -->
        <RegExpr attribute="Function" context="#pop"
                 String="[\.\w_\-=!@\$%\^&amp;?/&lt;&gt;\*]+"/>
        <RegExpr attribute="Normal Text" context="#pop" String=""/>
      </context>
    </contexts>

    <itemDatas>
      <itemData name="Normal Text" defStyleNum="dsNormal"/>
      <itemData name="Comment" defStyleNum="dsComment"/>
      <itemData name="String" defStyleNum="dsString"/>
      <itemData name="Char" defStyleNum="dsChar"/>
      <itemData name="Number" defStyleNum="dsDecVal"/>
      <itemData name="Keyword" defStyleNum="dsKeyword"/>
      <itemData name="Constant" defStyleNum="dsConstant"/>
      <itemData name="Function" defStyleNum="dsFunction"/>
      <itemData name="Variable" defStyleNum="dsVariable"/>
      <itemData name="Operator" defStyleNum="dsOperator"/>
    </itemDatas>
  </highlighting>

  <general>
    <comments>
      <comment name="singleLine" start="#"/>
    </comments>
  </general>
</language>
