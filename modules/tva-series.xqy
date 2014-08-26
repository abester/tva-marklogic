xquery version "1.0-ml";

(:/ext/b2b-exporter/modules/tva-series.xqy :)
module namespace series = "http://bbc.co.uk/psi/b2b-exporter/modules/tva-series";

import module namespace glb = "http://bbc.co.uk/psi/b2b-exporter/modules/globals" at "/ext/b2b-exporter/modules/globals.xqy";
import module namespace tvalib = "http://bbc.co.uk/psi/b2b-exporter/modules/tvalib" at "/ext/b2b-exporter/modules/tvalib.xqy";

(:  
 : Main Renderer -  Generates TVA Series XML  
 :)
declare function series:render-content($pid as xs:string, $cid as xs:string, $overide as element()?) as element()? {

  let $root as element()? := doc(concat($glb:docStoreEndPoint,$pid))/element()

  let $pid  as xs:string? := $root/ids/id[@type='pid' and @authority='pips']/text()
  let $crid as xs:string? := $root/ids/id[@type='crid' and @authority='pips']/text()
  let $uid  as xs:string? := $root/ids/id[@type='uid' and @authority='pips']/text()
 
  let $seriesType as xs:string? :=
   if ( $root/member_of/link[@rel='pips-meta:series']  )  then
      "mini-series"
  else 
      "series"

  let $content as element()? :=
  if (empty ($root)) then ()
  else
    <GroupInformation groupId="{$crid}" xml:lang="{$glb:locale}" numOfItems="{$root/@stated_items}" fragmentId="{$pid}" fragmentVersion="{$cid}">
      <GroupType xsi:type="ProgramGroupTypeType" value="{$seriesType}" />
        <BasicDescription>
        { tvalib:render-titles($root),

          tvalib:render-synopses($root,"short"),
          tvalib:render-synopses($root,"medium"),
          tvalib:render-synopses($root,"long"),
            
          tvalib:render-iplayer-genres($root),
          tvalib:render-other-genres($root)
        }
        </BasicDescription>

        { series:render-member-of($root/member_of, $seriesType) }

      <OtherIdentifier type="PIPS_PID" organization="{$glb:organisation}" authority="{$glb:authority}">{$pid}</OtherIdentifier>
  </GroupInformation>
return $content

};

(: Render - MemberOf tag :)
declare function series:render-member-of($memberOf as element()?, $seriesType as xs:string) as element()? {
  let $parentMemberOfLink as element()? := 
    if ($seriesType = "mini-series") then $memberOf/link[@rel='pips-meta:series']
    else $memberOf/link[@rel='pips-meta:brand']
    
  let $parentPid as xs:string? := $parentMemberOfLink/@pid

  let $content as element()? :=
    if ($parentPid) then
        let $parentDoc as item()? := doc(concat($glb:docStoreEndPoint,$parentPid))
        let $parentCrid as xs:string? := $parentDoc//crid/@uri
        return  <MemberOf xsi:type="MemberOfType" crid="{$parentCrid}" index="{$parentMemberOfLink/@index}" />
  else ()

  return $content

};



