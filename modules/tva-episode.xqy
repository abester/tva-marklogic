xquery version "1.0-ml";

(:/ext/b2b-exporter/modules/tva-episode.xqy :)
module namespace episode = "http://bbc.co.uk/psi/b2b-exporter/modules/tva-episode";
    
import module namespace glb = "http://bbc.co.uk/psi/b2b-exporter/modules/globals" at "/ext/b2b-exporter/modules/globals.xqy";
import module namespace tvalib = "http://bbc.co.uk/psi/b2b-exporter/modules/tvalib" at "/ext/b2b-exporter/modules/tvalib.xqy";

(:  
 : Main Renderer -  Generates TVA Episode XML  
 :)
declare function episode:render-content($pid as xs:string, $cid as xs:string, $overide as element()?) as element()? {

  let $root as element()? := if (empty($overide)) then doc(concat($glb:docStoreEndPoint,$pid))/element() else $overide

  let $pid  as xs:string? := $root/ids/id[@type='pid' and @authority='pips']/text()
  let $crid as xs:string? := $root/ids/id[@type='crid' and @authority='bds']/text()
  let $uid  as xs:string? := $root/ids/id[@type='uid' and @authority='pips']/text()

  let $content as element()? := 
  if (empty ($root)) then ()
  else
      <ProgramInformation programId="{$crid}" xml:lang="{$glb:locale}" fragmentId="{$pid}" fragmentVersion="{$cid}">
        <BasicDescription>
        { tvalib:render-titles($root),

          tvalib:render-synopses($root,"short"),
          tvalib:render-synopses($root,"medium"),
          tvalib:render-synopses($root,"long"),
            
          tvalib:render-iplayer-genres($root),
          tvalib:render-other-genres($root)
        }
        { if ($root/release_date/@year) then 
              <Genre href="{$glb:releaseDateUrn}" type="other">
                <Name xml:lang="en-GB">ReleaseDate</Name>
                <Definition>{data($root/release_date/@year)}</Definition>
              </Genre>
          else ()
        } 
        { if ($root/languages/language[1]/text()) then 
              <Language>{$root/languages/language[1]/text()}</Language>
          else ()
        } 
          <CreditsList>
            <CreditsItem role="urn:eventis:metadata:cs:RoleCS:2010:CONTENT-PROVIDER">
              <OrganizationName xml:lang="{$glb:locale}">{data($root/master_brand/link/@mid)}</OrganizationName>
            </CreditsItem>
          </CreditsList>
          
        </BasicDescription>

        { episode:render-episode-of($root/member_of,()) }

        <OtherIdentifier type="PIPS_PID" organization="{$glb:organisation}" authority="{$glb:authority}">{$pid}</OtherIdentifier>
        { if ($uid) then 
              <OtherIdentifier type="CORE_NUMBER" organization="{$glb:organisation}" authority="{$glb:authority}">{$uid}</OtherIdentifier>
          else ()
        }
      </ProgramInformation>
    return $content

};

(: Render - EpisodeOf tag :)
declare function episode:render-episode-of($memberOf as element()?, $parentOveride as element()?) as element()? {

  let $parentMemberOfLink as element()? :=
     if ( $memberOf/link[@rel='pips-meta:series'] )  then
      $memberOf/link[@rel='pips-meta:series']
    else if ( $memberOf/link[@rel='pips-meta:brand'] )  then
      $memberOf/link[@rel='pips-meta:brand']
    else  
      ()

  let $parentPid as xs:string? := $parentMemberOfLink/@pid

  let $content as element()? :=
    if ($parentPid) then
        let $parentDoc as item()? :=  if (empty($parentOveride)) then doc(concat($glb:docStoreEndPoint,$parentPid)) else $parentOveride
        let $parentCrid as xs:string? := $parentDoc//crid/@uri
        return  <EpisodeOf xsi:type="EpisodeOfType" crid="{$parentCrid}" index="{$parentMemberOfLink/@index}" />
  else ()

  return $content

};



