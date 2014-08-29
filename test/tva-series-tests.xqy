xquery version "1.0-ml";

module namespace test = "http://github.com/robwhitby/xray/test";
import module namespace assert = "http://github.com/robwhitby/xray/assertions" at "/ext/xquery/xray/src/assertions.xqy";

import module namespace glb = "http://bbc.co.uk/psi/b2b-exporter/modules/globals" at "/ext/b2b-exporter/modules/globals.xqy";
import module namespace series = "http://bbc.co.uk/psi/b2b-exporter/modules/tva-series" at "/ext/b2b-exporter/modules/tva-series.xqy";   

declare namespace xray = "http://github.com/robwhitby/xray";

declare %test:case function shouldRenderRequiredIds(){
  let $crid as xs:string := "crid://bbc.co.uk/b/28343123"
  let $pid  as xs:string := "b00zpdc9"

  let $sourceSeries as element() := 
    <brand xmlns="http://ns.webservices.bbc.co.uk/2006/02/pips">
      <ids>
       <id type="crid" authority="pips">{$crid}</id>
       <id type="pid" authority="pips">{$pid}</id>
      </ids>
    </brand>
  
  let $tva as element() := series:render-content("", "", $sourceSeries)
  return (
  assert:equal(data($tva/@groupId), $crid ),
  assert:equal(data($tva/@fragmentId), $pid ),
  assert:equal(data($tva/OtherIdentifier[@type='PIPS_PID']/text()), $pid)
  )

};

(: Mini series, with series as the parent :)
declare %test:case function shouldRenderParentSeries(){
  let $parentPid as xs:string := "b00zpdc9"
  let $parentCrid as xs:string := "crid://bbc.co.uk/b/28343123"
  let $sourceMiniSeries as element() := 
   <member_of xmlns="http://ns.webservices.bbc.co.uk/2006/02/pips">
    <link rel="pips-meta:series" index="1" pid="{$parentPid}"></link>
   </member_of>

  let $sourceSeries as element() := 
  <series pid="{$parentPid}" xmlns="http://ns.webservices.bbc.co.uk/2006/02/pips">
    <crid uri="{$parentCrid}">
    </crid>
  </series>

  let $result as element() := series:render-member-of($sourceMiniSeries, $sourceSeries)

  return (
    assert:equal(data($result/@crid), $parentCrid)
  )

};

(: Series, with brand as the parent :)
declare %test:case function shouldRenderParentBrand(){
  let $parentPid as xs:string := "b00zpdc9"
  let $parentCrid as xs:string := "crid://bbc.co.uk/b/28343123"
  let $sourceSeries as element() := 
   <member_of xmlns="http://ns.webservices.bbc.co.uk/2006/02/pips">
    <link rel="pips-meta:brand" index="1" pid="{$parentPid}"></link>
   </member_of>

  let $sourceBrand as element() := 
  <brand pid="{$parentPid}" xmlns="http://ns.webservices.bbc.co.uk/2006/02/pips">
    <crid uri="{$parentCrid}">
    </crid>
  </brand>

  let $result as element() := series:render-member-of($sourceSeries, $sourceBrand)

  return (
    assert:equal(data($result/@crid), $parentCrid)
  )

};