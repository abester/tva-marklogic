xquery version "1.0-ml";

(:/ext/b2b-exporter/modules/tva.xqy :)
module namespace tva = "http://bbc.co.uk/psi/b2b-exporter/modules/tva";

import module namespace glb = "http://bbc.co.uk/psi/b2b-exporter/modules/globals" at "/ext/b2b-exporter/modules/globals.xqy";
import module namespace tvalib = "http://bbc.co.uk/psi/b2b-exporter/modules/tvalib" at "/ext/b2b-exporter/modules/tvalib.xqy";
import module namespace brand = "http://bbc.co.uk/psi/b2b-exporter/modules/tva-brand" at "/ext/b2b-exporter/modules/tva-brand.xqy";
import module namespace series = "http://bbc.co.uk/psi/b2b-exporter/modules/tva-series" at "/ext/b2b-exporter/modules/tva-series.xqy";
import module namespace episode = "http://bbc.co.uk/psi/b2b-exporter/modules/tva-episode" at "/ext/b2b-exporter/modules/tva-episode.xqy";
   
(:  
 : Main Renderer -  Generates TVA XML  
 :)
declare function tva:render-content($pid as xs:string, $cid as xs:string, $overide as element()?) as element()? {
 
  let $segments as element()* := tva:assemble-segments($pid, $cid,())
  let $content as element()? := 
    if (empty ($segments)) then ()
    else
      <TVAMain xml:lang="{$glb:locale}" xmlns="urn:tva:metadata:2010" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:mpeg7="urn:tva:mpeg7:2008">
        <ProgramDescription>
          <ProgramInformationTable>
          {$segments}
          </ProgramInformationTable>
        </ProgramDescription>
      </TVAMain>
  return $content
};

(: 
 : Assembler - Responsible for joining brand, series, epispode, etc. into the TVA XML document 
 :)
declare function tva:assemble-segments($pid as xs:string, $cid as xs:string, $segments as element()* ) {
  let $root as item()?  := doc(concat($glb:docStoreEndPoint,$pid))
  let $parentPid as xs:string? := tvalib:get-parent-pid($root)
  let $segment as element()* := insert-before($segments, 1, tva:render-segment($pid,$cid,$root/element()))
  let $content as element()* := 
    if ($parentPid) then tva:assemble-segments($parentPid,$cid,$segment)
    else  $segment
  return $content 
};

(: 
 : Given the qualifying element, render accordingly  
 :)
declare function tva:render-segment($pid as xs:string, $cid as xs:string, $e as element()?) as element()?{
  typeswitch($e)
  case element(ondemand) return ()
  case element(version) return ()
  case element(clip) return ()
  case element(episode) return episode:render-content($pid, $cid, ())
  case element(series) return series:render-content($pid, $cid, ())
  case element(brand) return brand:render-content($pid, $cid, ())
  default return ()
};

