xquery version "1.0-ml";

(:/ext/b2b-exporter/modules/tva-brand.xqy :)
module namespace brand = "http://bbc.co.uk/psi/b2b-exporter/modules/tva-brand";

declare namespace p = "http://ns.webservices.bbc.co.uk/2006/02/pips";

import module namespace glb = "http://bbc.co.uk/psi/b2b-exporter/modules/globals" at "/ext/b2b-exporter/modules/globals.xqy";
import module namespace tvalib = "http://bbc.co.uk/psi/b2b-exporter/modules/tvalib" at "/ext/b2b-exporter/modules/tvalib.xqy";

(:  
 : Main Renderer -  Generates TVA Brand XML  
 :)
declare function brand:render-content($pid as xs:string, $cid as xs:string, $overide as element()?) as element()? {

  let $root as element()? := if (empty($overide)) then doc(concat($glb:docStoreEndPoint,$pid))/element() else $overide

  let $pid  as xs:string? := $root/p:ids/p:id[@type='pid' and @authority='pips']/text()
  let $crid as xs:string? := tvalib:get-crid($root/p:ids)

  let $content as element()? := 
  if (empty ($root)) then ()
  else
    <GroupInformation groupId="{$crid}" xml:lang="{$glb:locale}" fragmentId="{$pid}" fragmentVersion="{$cid}">
      <GroupType xsi:type="ProgramGroupTypeType" value="show" />
      <BasicDescription>
        {  tvalib:render-titles($root),

           tvalib:render-synopses($root,"short"),
           tvalib:render-synopses($root,"medium"),
           tvalib:render-synopses($root,"long"),
            
           tvalib:render-iplayer-genres($root),
           tvalib:render-other-genres($root)
        }
      </BasicDescription>
      <OtherIdentifier type="PIPS_PID" organization="{$glb:organisation}" authority="{$glb:authority}">{$pid}</OtherIdentifier>
    </GroupInformation>
  return $content

};

