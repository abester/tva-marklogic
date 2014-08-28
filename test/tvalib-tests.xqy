xquery version "1.0-ml";

module namespace test = "http://github.com/robwhitby/xray/test";
import module namespace assert = "http://github.com/robwhitby/xray/assertions" at "/ext/xquery/xray/src/assertions.xqy";

import module namespace glb = "http://bbc.co.uk/psi/b2b-exporter/modules/globals" at "/ext/b2b-exporter/modules/globals.xqy";
import module namespace fnstr = "http://bbc.co.uk/psi/b2b-exporter/modules/fnstr" at "/ext/b2b-exporter/modules/fnstr.xqy";
import module namespace tvalib = "http://bbc.co.uk/psi/b2b-exporter/modules/tvalib" at "/ext/b2b-exporter/modules/tvalib.xqy";

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

declare %test:case function shouldRenderTitle(){
  let $title as xs:string := "!Girl By Any Other Name"
  let $titleCleaned as xs:string := fnstr:clean-first-word($title)
  let $presentation_title as xs:string := "Episode 2"

  let $sourceEpisode as element() := 
     <episode>
     <title>{$title}</title>
     <containers_title>Atlantis</containers_title>
     <presentation_title>{$presentation_title}</presentation_title>
     </episode>
  
  let $tva as element() := 
    <BasicDescription> 
    {tvalib:render-titles($sourceEpisode)}
    </BasicDescription>

  return (
    assert:equal(data($tva/Title/text()), $title),
    assert:equal(data($tva/ShortTitle[@type='secondary']/text()),$titleCleaned),
    assert:equal(data($tva/ShortTitle[@type='main']/text()), $presentation_title)
  )  
};

declare %test:case function shouldRenderShortSynopsis(){
  let $synopsisType := "short"
  let $expected as element() := <Synopsis xml:lang="en-GB" length="{$synopsisType}" xmlns="">{$sourceSynopsesShort}</Synopsis>
  return assert:equal(tvalib:render-synopses($sourceSynopses, $synopsisType), $expected)
};

declare %test:case function shouldRenderMediumSynopsis(){
  let $synopsisType := "medium"
  let $expected as element() := <Synopsis xml:lang="en-GB" length="{$synopsisType}" xmlns="">{$sourceSynopsesMedium}</Synopsis>
  return assert:equal(tvalib:render-synopses($sourceSynopses, $synopsisType), $expected)
};

declare %test:case function shouldRenderLongSynopsis(){
  let $synopsisType := "long"
  let $expected as element() := <Synopsis xml:lang="en-GB" length="{$synopsisType}" xmlns="">{$sourceSynopsesLong}</Synopsis>
  return assert:equal(tvalib:render-synopses($sourceSynopses, $synopsisType), $expected)
};

declare %test:case function shouldRenderIplayerGenre(){
  let $sourceGenres as element() := 
   <episode>
      <genres>
        <genre_group genre_id="C00035" type="iplayer_composite"><genre/><genre/></genre_group>
      </genres>
   </episode>

  let $expected as element() := <Genre href="{$glb:iplayerUrnPrefix}C00035" type="main" />
  return assert:equal(tvalib:render-iplayer-genres($sourceGenres), $expected)
};

declare %test:case function shouldNotRenderIplayerGenre(){
  let $sourceGenres as element() := 
   <episode>
      <genres>
        <genre_group genre_id="C00035" type="broadCast"><genre/><genre/></genre_group>
      </genres>
   </episode>

  let $expected as element() := <Genre href="{$glb:iplayerUrnPrefix}C00035" type="main" />
  return assert:not-equal(tvalib:render-iplayer-genres($sourceGenres), $expected)
};

declare %test:case function shouldRenderOtherGenre(){
  let $sourceGenres as element() := 
   <episode>
      <formats>
        <format format_id="P1000" type="other"></format>
      </formats>
   </episode>

  let $expected as element() := <Genre href="{$glb:iplayerUrnPrefix}P1000" type="other" />
  return assert:equal(tvalib:render-other-genres($sourceGenres), $expected)
};

declare %test:case function get-parent-pid() {

};

declare %test:case function get-crid() {

};

declare %test:case function get-ancestors() {

};

declare %test:case function add-ancestor() {

};