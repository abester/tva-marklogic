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

declare private variable $sourceSynopses as element() := 
  <episode xmlns="http://ns.webservices.bbc.co.uk/2006/02/pips">
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
     <episode xmlns="http://ns.webservices.bbc.co.uk/2006/02/pips">
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
   <episode xmlns="http://ns.webservices.bbc.co.uk/2006/02/pips">
      <genres>
        <genre_group genre_id="C00035" type="iplayer_composite"><genre/><genre/></genre_group>
      </genres>
   </episode>

  let $expected as element() := <Genre href="{$glb:iplayerUrnPrefix}C00035" type="main" />
  return assert:equal(tvalib:render-iplayer-genres($sourceGenres), $expected)
};

declare %test:case function shouldNotRenderIplayerGenre(){
  let $sourceGenres as element() := 
   <episode xmlns="http://ns.webservices.bbc.co.uk/2006/02/pips">
      <genres>
        <genre_group genre_id="C00035" type="broadCast"><genre/><genre/></genre_group>
      </genres>
   </episode>

  let $expected as element() := <Genre href="{$glb:iplayerUrnPrefix}C00035" type="main" />
  return assert:not-equal(tvalib:render-iplayer-genres($sourceGenres), $expected)
};

declare %test:case function shouldRenderOtherGenre(){
  let $sourceGenres as element() := 
   <episode xmlns="http://ns.webservices.bbc.co.uk/2006/02/pips">
      <formats>
        <format format_id="P1000" type="other"></format>
      </formats>
   </episode>

  let $expected as element() := <Genre href="{$glb:iplayerUrnPrefix}P1000" type="other" />
  return assert:equal(tvalib:render-other-genres($sourceGenres), $expected)
};

declare %test:case function get-parent-pid() {
  <todo></todo>
};

declare %test:case function get-crid() {
  <todo></todo>
};

declare %test:case function get-ancestors() {
  <todo></todo>
};

declare %test:case function shouldRenderAllElementsWhenCallingAddAncestor() {
  let $pid as xs:string := "b013pqnm"
  let $cid as xs:string := "3434234234"

  let $srcOndemand as element() := <ondemand xmlns="http://ns.webservices.bbc.co.uk/2006/02/pips"></ondemand>
  let $resultOndemand as element() := tvalib:add-ancestor($pid, $cid, $srcOndemand)

  let $srcVersion as element() := <version xmlns="http://ns.webservices.bbc.co.uk/2006/02/pips"></version>
  let $resultVersion as element() := tvalib:add-ancestor($pid, $cid, $srcVersion)

  let $srcClip as element() := <clip xmlns="http://ns.webservices.bbc.co.uk/2006/02/pips"></clip>
  let $resultClip as element() := tvalib:add-ancestor($pid, $cid, $srcClip)

  let $srcEpisode as element() := <episode xmlns="http://ns.webservices.bbc.co.uk/2006/02/pips"></episode>
  let $resultEpisode as element() := tvalib:add-ancestor($pid, $cid, $srcEpisode)

  let $srcSeries as element() := <series xmlns="http://ns.webservices.bbc.co.uk/2006/02/pips"></series>
  let $resultSeries as element() := tvalib:add-ancestor($pid, $cid, $srcSeries)

  let $srcMiniSeries as element() := <series xmlns="http://ns.webservices.bbc.co.uk/2006/02/pips"><member_of><link rel="pips-meta:series"/></member_of></series>
  let $resultMiniSeries as element() := tvalib:add-ancestor($pid, $cid, $srcMiniSeries)

  let $srcBrand as element() := <brand xmlns="http://ns.webservices.bbc.co.uk/2006/02/pips"></brand>
  let $resultBrand as element() := tvalib:add-ancestor($pid, $cid, $srcBrand)

  return (
    assert:equal(data($resultOndemand/name()), "ondemand"),
    assert:equal(data($resultOndemand/@pid), $pid),
    assert:equal(data($resultOndemand/@cid), $cid),

    assert:equal(data($resultVersion/name()), "version"),
    assert:equal(data($resultVersion/@pid), $pid),
    assert:equal(data($resultVersion/@cid), $cid),

    assert:equal(data($resultClip/name()), "clip"),
    assert:equal(data($resultClip/@pid), $pid),
    assert:equal(data($resultClip/@cid), $cid),

    assert:equal(data($resultEpisode/name()), "episode"),
    assert:equal(data($resultEpisode/@pid), $pid),
    assert:equal(data($resultEpisode/@cid), $cid),

    assert:equal(data($resultSeries/name()), "series"),
    assert:equal(data($resultSeries/@pid), $pid),
    assert:equal(data($resultSeries/@cid), $cid),

    assert:equal(data($resultMiniSeries/name()), "miniseries"),
    assert:equal(data($resultMiniSeries/@pid), $pid),
    assert:equal(data($resultMiniSeries/@cid), $cid),

    assert:equal(data($resultBrand/name()), "brand"),
    assert:equal(data($resultBrand/@pid), $pid),
    assert:equal(data($resultBrand/@cid), $cid)

    )
};