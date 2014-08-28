xquery version "1.0-ml";

module namespace test = "http://github.com/robwhitby/xray/test";
import module namespace assert = "http://github.com/robwhitby/xray/assertions" at "/ext/xquery/xray/src/assertions.xqy";

import module namespace glb = "http://bbc.co.uk/psi/b2b-exporter/modules/globals" at "/ext/b2b-exporter/modules/globals.xqy";
import module namespace tva = "http://bbc.co.uk/psi/b2b-exporter/modules/tva" at "/ext/b2b-exporter/modules/tva.xqy";   

declare namespace xray = "http://github.com/robwhitby/xray";

declare %test:case function shouldRenderRootElement(){
  let $pid  as xs:string := "b00zpdc9675483920379624"
  let $cid  as xs:string := "1234"

  let $tva as element() := tva:render-content($pid, $cid)
  return (
    assert:equal($tva/name(), "TVAMain")
  )
};

declare %test:case function shouldRenderLanguage(){
  let $pid  as xs:string := "b00zpdc9675483920379624"
  let $cid  as xs:string := "1234"

  let $tva as element() := tva:render-content($pid, $cid)
  return (
    assert:equal(data($tva/@xml:lang), $glb:locale)
  )
};

declare %test:case function shouldRenderProgramDescription(){
  let $pid  as xs:string := "b00zpdc9675483920379624"
  let $cid  as xs:string := "1234"

  let $tva as element() := tva:render-content($pid, $cid)
  return (
    assert:not-empty($tva/ProgramDescription)
  )
};

declare %test:case function shouldRenderProgramInformationTable(){
  let $pid  as xs:string := "b00zpdc9675483920379624"
  let $cid  as xs:string := "1234"

  let $tva as element() := tva:render-content($pid, $cid)
  return (
    assert:not-empty($tva/ProgramDescription/ProgramInformationTable)
  )
};

declare %test:case function shouldRenderGroupInformationTable(){
  let $pid  as xs:string := "b00zpdc9675483920379624"
  let $cid  as xs:string := "1234"

  let $tva as element() := tva:render-content($pid, $cid)
  return (
    assert:not-empty($tva/ProgramDescription/GroupInformationTable)
  )
};


declare %test:case function shouldRenderProgramLocationTable(){
  let $pid  as xs:string := "b00zpdc9675483920379624"
  let $cid  as xs:string := "1234"

  let $tva as element() := tva:render-content($pid, $cid)
  return (
    assert:not-empty($tva/ProgramDescription/ProgramLocationTable)
  )
};