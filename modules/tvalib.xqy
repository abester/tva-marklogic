xquery version "1.0-ml";

(:/ext/b2b-exporter/modules/tvalib.xqy :)
module namespace tvalib = "http://bbc.co.uk/psi/b2b-exporter/modules/tvalib";

declare namespace p = "http://ns.webservices.bbc.co.uk/2006/02/pips";

import module namespace glb = "http://bbc.co.uk/psi/b2b-exporter/modules/globals" at "/ext/b2b-exporter/modules/globals.xqy";
import module namespace fnstr = "http://bbc.co.uk/psi/b2b-exporter/modules/fnstr" at "/ext/b2b-exporter/modules/fnstr.xqy";


(:
 : Returns the parent pid of a document
 :)
declare function tvalib:get-parent-pid($root as item()?) as xs:string?{
  if (($root)/p:ondemand/p:broadcast_of/p:link/@pid) then
    data(($root)/p:ondemand/p:broadcast_of/p:link/@pid)
  else if (($root)/p:version/p:version_of/p:link/@pid) then
    data(($root)/p:version/p:version_of/p:link/@pid)
  else if (($root)/p:clip/p:clip_of/p:link/@pid) then
    data(($root)/p:clip/p:clip_of/p:link/@pid)     
  else if (($root)//p:member_of/p:link/@pid) then (: episode, series, brand :)
    data(($root)//p:member_of/p:link/@pid)
  else 
    ( "" )
};

declare function tvalib:get-crid($ids as element()) as xs:string?{
  let $crid := $ids/p:id[@type='crid' and @authority='bds']
  return
    if ($crid) then 
      data($crid/text())
    else 
      data($ids/p:id[@type='crid' and @authority='pips']/text())
};

(: 
 : Returns all the ancestors for the given element, based on its pid
 :)
declare function tvalib:get-ancestors($pid as xs:string, $cid as xs:string, $segments as element()*, $depth as xs:integer ) as element()* {
  let $root as item()?  := doc(concat($glb:docStoreEndPoint,$pid))
  let $parentPid as xs:string? := tvalib:get-parent-pid($root)
  let $segment as element()* := insert-before($segments, 1, tvalib:add-ancestor($pid,$cid,$root/element()))
  let $content as element()* := 
    if (($parentPid) and ($depth < $glb:maxRecursionDepth)) then tvalib:get-ancestors($parentPid,$cid,$segment, $depth+1 )
    else  $segment
  return (
    if ($depth >= $glb:maxRecursionDepth) then
    <error><description>circular reference error</description></error>
    else $content 
    )
};

(: 
 : Given an element return the related ancestor element
 :)
declare function tvalib:add-ancestor($pid as xs:string, $cid as xs:string, $e as element()?) as element()* {
  typeswitch($e)
  case element(p:ondemand) return <ondemand pid="{$pid}" cid="{$cid}" />
  case element(p:version)  return <version pid="{$pid}" cid="{$cid}" />
  case element(p:clip)     return <clip pid="{$pid}" cid="{$cid}" />
  case element(p:episode)  return <episode pid="{$pid}" cid="{$cid}" />
  case element(p:series)   return ( 
                          if ($e/p:member_of/p:link[@rel='pips-meta:series']) then
                              <miniseries pid="{$pid}" cid="{$cid}" />
                          else
                              <series pid="{$pid}" cid="{$cid}" />
                          )
  case element(p:brand)    return <brand pid="{$pid}" cid="{$cid}" />
  default return ()
};

(:  
 : Render - Title & Short Title 
 :)
declare function tvalib:render-titles($e as element()?) as element()* {
  let $secPreTitle as xs:string? := 
    if ($e/p:title/text()) then 
      fnstr:clean-first-word($e/p:title/text())
    else
      fnstr:clean-first-word($e/p:presentation_title/text())
  return (
      <Title xml:lang="{$glb:locale}" type="main">{$e/p:title/text()}</Title>,
      if ($e/p:presentation_title) then <ShortTitle xml:lang="{$glb:locale}" type="main" length="{string-length($e/p:presentation_title/text())}">{$e/p:presentation_title/text()}</ShortTitle> else (),
      <ShortTitle xml:lang="{$glb:locale}" type="secondary" length="{string-length($secPreTitle)}">{$secPreTitle}</ShortTitle>
  ) 
};

(: 
 : Render - Synopsis [short,medium,long] 
 :)
declare function tvalib:render-synopses($e as element()?, $len as xs:string) as element()? {
  if ($e/p:synopses/p:synopsis[@length=$len]/text()) then 
      <Synopsis xml:lang="{$glb:locale}" length="{$len}">{$e/p:synopses/p:synopsis[@length=$len]/text()}</Synopsis>
  else 
      ()
}; 

(: 
 : Render - Iplayer Genre(s) 
 :)
declare function tvalib:render-iplayer-genres($e as element()?) as element()* {
  for $genre_group in $e/p:genres/p:genre_group[@type="iplayer_composite"]
  where ( $genre_group[@type="iplayer_composite"] ) 
  return <Genre href="{$glb:iplayerUrnPrefix}{data($genre_group/@genre_id)}" type="main" />
};

(: 
 : Render - Other Genre(s) 
 :)
declare function tvalib:render-other-genres($e as element()?) as element()? {
  for $format in $e/p:formats/p:format
  return <Genre href="{$glb:iplayerUrnPrefix}{data($format/@format_id)}" type="other" />
};