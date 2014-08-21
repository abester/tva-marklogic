xquery version "1.0-ml";

module namespace test = "http://github.com/robwhitby/xray/test";
import module namespace assert = "http://github.com/robwhitby/xray/assertions" at "/xray/src/assertions.xqy";

import module namespace glb = "http://bbc.co.uk/psi/b2b-exporter/modules/globals" at "/xqy/globals.xqy";
import module namespace fnStr = "http://bbc.co.uk/psi/b2b-exporter/modules/fnstr" at "/xqy/fnstr.xqy";
import module namespace tvaEpisode = "http://bbc.co.uk/psi/b2b-exporter/modules/tvaEpisode" at "/xqy/tva-episode.xqy";

declare namespace xray = "http://github.com/robwhitby/xray";

declare private variable $sourceSynopsesShort := "The heroes are entangled";
declare private variable $sourceSynopsesMedium := "Drama series. The heroes face a race against time.";
declare private variable $sourceSynopsesLong := "Despite their newfound fame. With the hopes and life.";

declare private variable $sourceSynopses as element() := <episode>
  <synopses>
    <synopsis length="short">{$sourceSynopsesShort}</synopsis>
    <synopsis length="medium">{$sourceSynopsesMedium}</synopsis>
    <synopsis length="long">{$sourceSynopsesLong}</synopsis>
  </synopses>
 </episode>;


declare %test:case function shouldRenderShortSynopsis(){
  let $synopsisType := "short"
  let $expected as element() := <Synopsis xml:lang="en-GB" length="{$synopsisType}" xmlns="">{$sourceSynopsesShort}</Synopsis>
  return assert:equal(tvaEpisode:renderSynopses($sourceSynopses, $synopsisType), $expected)
};

declare %test:case function shouldRenderMediumSynopsis(){
  let $synopsisType := "medium"
  let $expected as element() := <Synopsis xml:lang="en-GB" length="{$synopsisType}" xmlns="">{$sourceSynopsesMedium}</Synopsis>
  return assert:equal(tvaEpisode:renderSynopses($sourceSynopses, $synopsisType), $expected)
};

declare %test:case function shouldRenderLongSynopsis(){
  let $synopsisType := "long"
  let $expected as element() := <Synopsis xml:lang="en-GB" length="{$synopsisType}" xmlns="">{$sourceSynopsesLong}</Synopsis>
  return assert:equal(tvaEpisode:renderSynopses($sourceSynopses, $synopsisType), $expected)
};


declare %test:case function shouldRenderIplayerGenre(){
  let $sourceGenres as element() := 
   <episode>
      <genres>
        <genre_group genre_id="C00035" type="iplayer_composite"><genre/><genre/></genre_group>
      </genres>
   </episode>

  let $expected as element() := <Genres href="{$glb:iplayerUrnPrefix}C00035" type="main" />


  return assert:equal(tvaEpisode:renderIplayerGenres($sourceGenres), $expected)
};


declare %test:case function shouldNotRenderIplayerGenre(){
  let $sourceGenres as element() := 
   <episode>
      <genres>
        <genre_group genre_id="C00035" type="broadCast"><genre/><genre/></genre_group>
      </genres>
   </episode>

  let $expected as element() := <Genres href="{$glb:iplayerUrnPrefix}C00035" type="main" />
  return assert:not-equal(tvaEpisode:renderIplayerGenres($sourceGenres), $expected)
};



declare %test:case function shouldRenderOtherGenre(){
  let $sourceGenres as element() := 
   <episode>
      <formats>
        <format format_id="P1000" type="other"></format>
      </formats>
   </episode>

  let $expected as element() := <Genres href="{$glb:iplayerUrnPrefix}P1000" type="other" />

  return assert:equal(tvaEpisode:renderOtherGenres($sourceGenres), $expected)
};

declare %test:case function shouldRenderRequiredIds(){
  
  let $crid as xs:string := "crid://bbc.co.uk/b/96952213"
  let $pid as xs:string := "b03czdsr"
  let $uid as xs:string := "DRRB202X"

  let $sourceEpisode as element() := 
   <episode>
     <ids>
       <id type="crid" authority="bds">{$crid}</id>
       <id type="pid" authority="pips">{$pid}</id>
       <id type="uid" authority="onair">{$uid}</id>
    </ids>
   </episode>
  
  let $tva := tvaEpisode:renderContent($sourceEpisode)
  return (
  assert:equal(data($tva/ProgramInformationTable/ProgramInformation/@programId), $crid ),
  assert:equal(data($tva/ProgramInformationTable/ProgramInformation/EpisodeOf/@crid), $crid ),

  assert:equal(data($tva/ProgramInformationTable/ProgramInformation/@fragmentId), $pid ),
  assert:equal(data($tva/ProgramInformationTable/ProgramInformation/OtherIdentifier[@type='PIPS_PID']/text()), $pid)
  )

};


declare %test:case function shouldRenderLanguage(){

  let $language := "EN"

  let $sourceEpisode as element() := 
   <episode>
    <languages>
      <language>{$language}</language>
    </languages>
   </episode>
  
  let $tva := tvaEpisode:renderContent($sourceEpisode)
  return (
  assert:equal(data($tva/ProgramInformationTable/ProgramInformation/BasicDescription/Language/text()), $language )
  )

};

declare %test:case function shouldRenderReleaseYear(){

  let $year := "2013"

  let $sourceEpisode as element() := 
   <episode>
    <release_date month="10" day="5" year="{$year}"/>
   </episode>
  
  let $tva := tvaEpisode:renderContent($sourceEpisode)
  return (
  assert:equal(data($tva/ProgramInformationTable/ProgramInformation/BasicDescription/ProductionDate/TimePoint/@year), $year )
  )

};

declare %test:case function shouldRenderTitle(){

  let $title := "!Girl By Any Other Name"
  let $titleCleaned := fnStr:clean-first-word($title)
  let $presentation_title := "Episode 2"

  let $sourceEpisode as element() := 
   <episode>
     <title>{$title}</title>
     <containers_title>Atlantis</containers_title>
     <presentation_title>{$presentation_title}</presentation_title>
   </episode>
  
  let $tva := tvaEpisode:renderContent($sourceEpisode)
  return (
    assert:equal(data($tva/ProgramInformationTable/ProgramInformation/BasicDescription/Title), $title ),
    assert:equal(data($tva/ProgramInformationTable/ProgramInformation/BasicDescription/ShortTitle[@type='secondary']/text()), $titleCleaned ),
    assert:equal(data($tva/ProgramInformationTable/ProgramInformation/BasicDescription/ShortTitle[@type='main']/text()), $presentation_title)
  )

};


declare %test:ignore function xmlVisualiser(){
let $crid := "crid://bbc.co.uk/b/96952213"
  let $pid := "b03czdsr"
  let $uid := "DRRB202X"
  let $title := "!Girl By Any Other Name"
  let $presentation_title := "Episode 2"

  let $sourceEpisode as element() := 
   <episode>
     <ids>
       <id type="crid" authority="bds">{$crid}</id>
       <id type="pid" authority="pips">{$pid}</id>
       <id type="uid" authority="onair">{$uid}</id>
    </ids>
     <title>{$title}</title>
     <containers_title>Atlantis</containers_title>
     <presentation_title>{$presentation_title}</presentation_title>
        <languages>
      <language>EN</language>
    </languages>
    <release_date month="10" day="5" year="2013"/>
   </episode>
  
  let $tva := tvaEpisode:renderContent($sourceEpisode)
  return (  assert:empty($tva) )
 }; 



