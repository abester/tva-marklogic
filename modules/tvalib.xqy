xquery version "1.0-ml";

(:/ext/b2b-exporter/modules/tvalib.xqy :)
module namespace tvalib = "http://bbc.co.uk/psi/b2b-exporter/modules/tvalib";

import module namespace glb = "http://bbc.co.uk/psi/b2b-exporter/modules/globals" at "/ext/b2b-exporter/modules/globals.xqy";
import module namespace fnstr = "http://bbc.co.uk/psi/b2b-exporter/modules/fnstr" at "/ext/b2b-exporter/modules/fnstr.xqy";


(:
 : Returns the parent pid of a document
 :)
declare function tvalib:get-parent-pid($root as item()?) as xs:string?{
  if (($root)/ondemand/broadcast_of/link/@pid) then
      data(($root)/ondemand/broadcast_of/link/@pid)
  else if (($root)/version/version_of/link/@pid) then
      data(($root)/version/version_of/link/@pid)
  else if (($root)/clip/clip_of/link/@pid) then
      data(($root)/clip/clip_of/link/@pid)     
  else if (($root)//member_of/link/@pid) then (: episode, series, brand :)
      data(($root)//member_of/link/@pid)
  else 
      ( "" )
};

(: 
 : Returns all the ancestors for the given element, based on its pid
 :)
declare function tvalib:get-ancestors($pid as xs:string, $cid as xs:string, $segments as element()*) as element()* {
  let $root as item()?  := doc(concat($glb:docStoreEndPoint,$pid))
  let $parentPid as xs:string? := tvalib:get-parent-pid($root)
  let $segment as element()* := insert-before($segments, 1, tvalib:add-ancestor($pid,$cid,$root/element()))
  let $content as element()* := 
    if ($parentPid) then tvalib:get-ancestors($parentPid,$cid,$segment)
    else  $segment
  return $content 
};

(: 
 : Given an element return the related ancestor element
 :)
declare function tvalib:add-ancestor($pid as xs:string, $cid as xs:string, $e as element()?) as element()* {
  typeswitch($e)
  case element(ondemand) return <ondemand pid="{$pid}" cid="{$cid}" />
  case element(version)  return <version pid="{$pid}" cid="{$cid}" />
  case element(clip)     return <clip pid="{$pid}" cid="{$cid}" />
  case element(episode)  return <episode pid="{$pid}" cid="{$cid}" />
  case element(series)   return ( 
                          if ($e/member_of/link[@rel='pips-meta:series']) then
                              <miniseries pid="{$pid}" cid="{$cid}" />
                          else
                              <series pid="{$pid}" cid="{$cid}" />
                          )
  case element(brand)    return <brand pid="{$pid}" cid="{$cid}" />
  default return ()
};

(:  
 : Render - Title & Short Title 
 :)
declare function tvalib:render-titles($e as element()?) as element()* {
  let $secPreTitle as xs:string? := 
    if ($e/title/text()) then 
      fnstr:clean-first-word($e/title/text())
    else
      fnstr:clean-first-word($e/presentation_title/text())
  return (
      <Title xml:lang="{$glb:locale}" type="main">{$e/title/text()}</Title>,
      if ($e/presentation_title) then <ShortTitle xml:lang="{$glb:locale}" type="main" length="{string-length($e/presentation_title/text())}">{$e/presentation_title/text()}</ShortTitle> else (),
      <ShortTitle xml:lang="{$glb:locale}" type="secondary" length="{string-length($secPreTitle)}">{$secPreTitle}</ShortTitle>
  ) 
};

(: 
 : Render - Synopsis [short,medium,long] 
 :)
declare function tvalib:render-synopses($e as element()?, $len as xs:string) as element()? {
  if ($e/synopses/synopsis[@length=$len]/text()) then 
      <Synopsis xml:lang="{$glb:locale}" length="{$len}">{$e/synopses/synopsis[@length=$len]/text()}</Synopsis>
  else 
      ()
}; 

(: 
 : Render - Iplayer Genre(s) 
 :)
declare function tvalib:render-iplayer-genres($e as element()?) as element()* {
  for $genre_group in $e/genres/genre_group[@type="iplayer_composite"]
  where ( $genre_group[@type="iplayer_composite"] ) 
  return <Genre href="{$glb:iplayerUrnPrefix}{data($genre_group/@genre_id)}" type="main" />
};

(: 
 : Render - Other Genre(s) 
 :)
declare function tvalib:render-other-genres($e as element()?) as element()? {
  for $format in $e/formats/format
  return <Genre href="{$glb:iplayerUrnPrefix}{data($format/@format_id)}" type="other" />
};