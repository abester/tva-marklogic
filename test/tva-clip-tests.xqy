xquery version "1.0-ml";

module namespace test = "http://github.com/robwhitby/xray/test";
import module namespace assert = "http://github.com/robwhitby/xray/assertions" at "/ext/xquery/xray/src/assertions.xqy";

import module namespace glb = "http://bbc.co.uk/psi/b2b-exporter/modules/globals" at "/ext/b2b-exporter/modules/globals.xqy";
import module namespace clip = "http://bbc.co.uk/psi/b2b-exporter/modules/tva-clip" at "/ext/b2b-exporter/modules/tva-clip.xqy";   

declare namespace xray = "http://github.com/robwhitby/xray";

declare %test:case function shouldRenderRequiredIds(){
  let $crid as xs:string := "crid://bbc.co.uk/p/12443237"
  let $pid  as xs:string := "p00fgp6q"

  let $sourceClip as element() := 
    <clip xmlns="http://ns.webservices.bbc.co.uk/2006/02/pips">
      <ids>
       <id type="crid" authority="pips">{$crid}</id>
       <id type="pid" authority="pips">{$pid}</id>
      </ids>
    </clip>
  
  let $tva as element() := clip:render-content("", "", $sourceClip)
  return (
  assert:equal(data($tva/@programId), $crid ),
  assert:equal(data($tva/@fragmentId), $pid ),
  assert:equal(data($tva/OtherIdentifier[@type='PIPS_PID']/text()), $pid)
  )

};

declare %test:case function shouldRenderTitle(){
  let $crid as xs:string := "crid://bbc.co.uk/p/12443237"
  let $pid  as xs:string := "p00fgp6q"
  let $title as xs:string := "Boyd Is Informed He Will Be Getting A New Team Member"

  let $sourceClip as element() := 
    <clip xmlns="http://ns.webservices.bbc.co.uk/2006/02/pips">
      <title>{$title}</title>
    </clip>
  
  let $tva as element() := clip:render-content("", "", $sourceClip)
  return assert:equal(data($tva/BasicDescription/Title/text()), $title )
};