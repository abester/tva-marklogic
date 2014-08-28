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
 
  let $ancestors := <ancestors>{tvalib:get-ancestors($pid,$cid,())}</ancestors>
  let $segments as element()* := tva:render-all-segments($ancestors)
  let $content as element()? := 
    if (empty ($segments)) then ()
    else
      <TVAMain xml:lang="{$glb:locale}" xmlns="urn:tva:metadata:2010" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:mpeg7="urn:tva:mpeg7:2008">
        {$segments}
      </TVAMain>
  return $content
};

(: 
 : Given the ancestors sequence render all of the segments that make up the TVA XML
 :)
declare function tva:render-all-segments($ancestors as element()?) as element()? {
  <ProgramDescription>
    <ProgramInformationTable>
    { episode:render-content(data($ancestors/episode/@pid),data($ancestors/episode/@cid),())
      (: clip :) 
    }
    </ProgramInformationTable>

    <GroupInformationTable>
    {  (: all three could be missing :)
      brand:render-content(data($ancestors/brand/@pid), data($ancestors/brand/@cid),()), 
      series:render-content(data($ancestors/series/@pid), data($ancestors/series/@cid),()),
      series:render-content(data($ancestors/miniseries/@pid), data($ancestors/miniseries/@cid),())
    }
    </GroupInformationTable>
    <ProgramLocationTable>
    {(: version
      : clip-version
      :)
    }
    </ProgramLocationTable>
   </ProgramDescription>  
 };



