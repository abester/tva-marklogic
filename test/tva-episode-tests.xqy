xquery version "1.0-ml";

module namespace test = "http://github.com/robwhitby/xray/test";
import module namespace assert = "http://github.com/robwhitby/xray/assertions" at "/ext/xquery/xray/src/assertions.xqy";

import module namespace glb = "http://bbc.co.uk/psi/b2b-exporter/modules/globals" at "/ext/b2b-exporter/modules/globals.xqy";
import module namespace episode = "http://bbc.co.uk/psi/b2b-exporter/modules/tva-episode" at "/ext/b2b-exporter/modules/tva-episode.xqy";   

declare namespace xray = "http://github.com/robwhitby/xray";

declare private variable $sourceSynopsesShort as xs:string := "The heroes are entangled";
declare private variable $sourceSynopsesMedium as xs:string := "Drama series. The heroes face a race against time.";
declare private variable $sourceSynopsesLong as xs:string := "Despite their newfound fame. With the hopes and life.";

declare private variable $sourceSynopses as element() := 
  <episode xmlns="http://ns.webservices.bbc.co.uk/2006/02/pips">
    <synopses>
      <synopsis length="short">{$sourceSynopsesShort}</synopsis>
      <synopsis length="medium">{$sourceSynopsesMedium}</synopsis>
      <synopsis length="long">{$sourceSynopsesLong}</synopsis>
    </synopses>
  </episode>;

declare %test:case function shouldRenderRequiredIds(){
  let $crid as xs:string := "crid://bbc.co.uk/b/96952213"
  let $pid  as xs:string := "b03czdsr"
  let $uid  as xs:string := "DRRB202X"

  let $sourceEpisode as element() := 
    <episode xmlns="http://ns.webservices.bbc.co.uk/2006/02/pips">
      <ids>
       <id type="crid" authority="pips">{$crid}</id>
       <id type="pid" authority="pips">{$pid}</id>
       <id type="uid" authority="pips">{$uid}</id>
      </ids>
    </episode>
  
  let $tva as element() := episode:render-content("", "", $sourceEpisode)
  return (
  assert:equal(data($tva/@programId), $crid ),
  assert:equal(data($tva/@fragmentId), $pid ),
  assert:equal(data($tva/OtherIdentifier[@type='PIPS_PID']/text()), $pid)
  )

};

declare %test:case function shouldRenderLanguage(){
 let $language as xs:string := "EN"
  let $sourceEpisode as element() := 
    <episode xmlns="http://ns.webservices.bbc.co.uk/2006/02/pips">
      <languages>
        <language>{$language}</language>
      </languages>
    </episode>
  
  let $tva as element() := episode:render-content("", "", $sourceEpisode)
  return (
  assert:equal(data($tva/BasicDescription/Language/text()), $language )
  )

};

declare %test:case function shouldRenderReleaseYear(){
  let $year as xs:string := "2013"
  let $sourceEpisode as element() := 
   <episode xmlns="http://ns.webservices.bbc.co.uk/2006/02/pips">
    <release_date month="10" day="5" year="{$year}"/>
   </episode>
  
  let $tva := episode:render-content("", "", $sourceEpisode)
  return (
  assert:equal(data($tva/BasicDescription/Genre[@href=$glb:releaseDateUrn]/Definition/text()), $year )
  )

};
declare %test:case function shouldRenderParentSeries(){
  let $parentPid as xs:string := "b00zpdc9"
  let $parentCrid as xs:string := "crid://bbc.co.uk/b/28343123"
  let $sourceEpisode as element() := 
   <member_of xmlns="http://ns.webservices.bbc.co.uk/2006/02/pips">
    <link rel="pips-meta:series" index="1" pid="{$parentPid}"></link>
   </member_of>

  let $sourceSeries as element() := 
  <series pid="{$parentPid}" xmlns="http://ns.webservices.bbc.co.uk/2006/02/pips">
    <crid uri="{$parentCrid}">
    </crid>
  </series>

  let $result as element() := episode:render-episode-of($sourceEpisode, $sourceSeries)

  return (
    assert:equal(data($result/@crid), $parentCrid)
  )

};