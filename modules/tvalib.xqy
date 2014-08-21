xquery version "1.0-ml";

(:/ext/b2b-exporter/modules/tvalib.xqy :)
module namespace tvalib = "http://bbc.co.uk/psi/b2b-exporter/modules/tvalib";

import module namespace glb = "http://bbc.co.uk/psi/b2b-exporter/modules/globals" at "/ext/b2b-exporter/modules/globals.xqy";
import module namespace fnstr = "http://bbc.co.uk/psi/b2b-exporter/modules/fnstr" at "/ext/b2b-exporter/modules/fnstr.xqy";

(:  
 : Render - Title & Short Title 
 :)
declare function tvalib:render-titles($e as element()?)  {
  let $secPreTitle := 
    if ($e/title/text() ) then 
        fnstr:clean-first-word($e/title/text())
    else
        fnstr:clean-first-word($e/presentation_title/text())
    return(
        <Title xml:lang="{$glb:locale}" type="main">{$e/title/text()}</Title>,
        <ShortTitle xml:lang="{$glb:locale}" type="main" length="{string-length($e/presentation_title/text())}">{$e/presentation_title/text()}</ShortTitle>,
        <ShortTitle xml:lang="{$glb:locale}" type="secondary" length="{string-length($secPreTitle)}">{$secPreTitle}</ShortTitle>
    ) 
};

(: 
 : Render - Synopsis [short,medium,long] 
 :)
declare function tvalib:render-synopses($e as element()?, $len as xs:string){
  if ($e/synopses/synopsis[@length=$len]/text() ) then 
      <Synopsis xml:lang="{$glb:locale}" length="{$len}">{$e/synopses/synopsis[@length=$len]/text()}</Synopsis>
  else ()
}; 

(: 
 : Render - Iplayer Genre(s) 
 :)
declare function tvalib:render-iplayer-genres($e as element()?){
  for $genre_group in $e/genres/genre_group[@type="iplayer_composite"]
  where ( $genre_group[@type="iplayer_composite"] ) 
  return <Genre href="{$glb:iplayerUrnPrefix}{$genre_group/@genre_id}" type="main" />
};

(: 
 : Render - Other Genre(s) 
 :)
declare function tvalib:render-other-genres($e as element()?){
  for $format in $e/formats/format
  return <Genre href="{$glb:iplayerUrnPrefix}{$format/@format_id}" type="other" />
};