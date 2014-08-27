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
    <brand>
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