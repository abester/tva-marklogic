xquery version "1.0-ml";

(:/ext/b2b-exporter/modules/tva-series.xqy :)
module namespace series = "http://bbc.co.uk/psi/b2b-exporter/modules/tva-series";

import module namespace glb = "http://bbc.co.uk/psi/b2b-exporter/modules/globals" at "/ext/b2b-exporter/modules/globals.xqy";
import module namespace fnstr = "http://bbc.co.uk/psi/b2b-exporter/modules/fnstr" at "/ext/b2b-exporter/modules/fnstr.xqy";
import module namespace tvalib = "http://bbc.co.uk/psi/b2b-exporter/modules/tvalib" at "/ext/b2b-exporter/modules/tvalib.xqy";

(:  
 : Main Renderer -  Generates TVA Series XML  
 :)
declare function series:render-content($pid as xs:string, $cid as xs:string, $overide as element()? ){

  let $root := doc(concat("/pips/",$pid))/series

  let $pid := $root/ids/id[@type='pid']/text()
  let $crid := $root/ids/id[@type='crid']/text()
  let $uid := $root/ids/id[@type='uid']/text()
  let $changeEventId := $cid

  let $seriesType as xs:string :=
   if ( $root/member_of/link[@rel='pips-meta:series']  )  then
      "mini-series"
  else 
      "series"

 
  let $result :=
  if (empty ($root)) then ()
  else
    <GroupInformation groupId="{$crid}" xml:lang="{$glb:locale}" numOfItems="{$root/@stated_items}" fragmentId="{$pid}" fragmentVersion="{$changeEventId}">
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
return $result

};

(: Render - MemberOf tag :)
declare function series:render-member-of($memberOf, $seriesType as xs:string){
  let $parentMemberOfLink := 
    if ($seriesType eq "mini-series") then $memberOf/link[@rel='pips-meta:series']
    else $memberOf/link[@rel='pips-meta:brand']
    
  let $parentPid := $parentMemberOfLink/@pid

  let $result:=
    if ($parentPid) then
        let $parentDoc := doc(concat("/pips/",$parentPid))
        let $parentCrid := $parentDoc//crid/@uri
        return  <MemberOf xsi:type="MemberOfType" crid="{$parentCrid}" index="{$parentMemberOfLink/@index}" />
  else ()

  return $result

};



