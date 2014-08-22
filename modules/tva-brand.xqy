xquery version "1.0-ml";

(:/ext/b2b-exporter/modules/tva-brand.xqy :)
module namespace brand = "http://bbc.co.uk/psi/b2b-exporter/modules/tva-brand";
    
import module namespace glb = "http://bbc.co.uk/psi/b2b-exporter/modules/globals" at "/ext/b2b-exporter/modules/globals.xqy";
import module namespace fnstr = "http://bbc.co.uk/psi/b2b-exporter/modules/fnstr" at "/ext/b2b-exporter/modules/fnstr.xqy";
import module namespace tvalib = "http://bbc.co.uk/psi/b2b-exporter/modules/tvalib" at "/ext/b2b-exporter/modules/tvalib.xqy";

(:  
 : Main Renderer -  Generates TVA Brand XML  
 :)
declare function brand:render-content($pid as xs:string, $cid as xs:string, $overide as element()? ){

  let $root := doc(concat("/pips/",$pid))/brand

  let $pid := $root/ids/id[@type='pid']/text()
  let $crid := $root/ids/id[@type='crid']/text()
  let $uid := $root/ids/id[@type='uid']/text()
  let $changeEventId := $cid

  let $result :=
  if (empty ($root)) then ()
  else
    <GroupInformation groupId="{$crid}" xml:lang="{$glb:locale}" fragmentId="{$pid}" fragmentVersion="{$changeEventId}">
      <GroupType xsi:type="ProgramGroupTypeType" value="show" />
        <BasicDescription>
          
        {  tvalib:render-titles($root),

           tvalib:render-synopses($root,"short"),
           tvalib:render-synopses($root,"medium"),
           tvalib:render-synopses($root,"long"),
            
           tvalib:render-iplayer-genres($root),
           tvalib:render-other-genres($root)
        }
          
        <OtherIdentifier type="PIPS_PID" organization="{$glb:organisation}" authority="{$glb:authority}">{$pid}</OtherIdentifier>
        { if ($uid) then 
               <OtherIdentifier type="CORE_NUMBER" organization="{$glb:organisation}" authority="{$glb:authority}">{$uid}</OtherIdentifier>
            else ()
        }
      </BasicDescription>
    </GroupInformation>
  return $result

};

