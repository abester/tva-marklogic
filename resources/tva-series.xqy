(:?version=1.0&provider=BBC&title=B2B-Exporter-Tva-Series-Xml&description=Provide%20TVA%20Series%20Xml&method=get&get:cid=xs:string&get:pid=xs:string
:)
xquery version "1.0-ml";

module namespace rest = "http://marklogic.com/rest-api/resource/tva-series";

import module namespace series = "http://bbc.co.uk/psi/b2b-exporter/modules/tva-series" at "/ext/b2b-exporter/modules/tva-series.xqy";

declare function rest:get($context as map:map, $params as map:map) as document-node()* {
  let $pid as xs:string? := xdmp:url-decode(map:get($params,"pid"))
  let $cid as xs:string? := xdmp:url-decode(map:get($params,"cid"))

  let $output-types as map:map? := map:put($context,"output-types","application/xml") 

  let $content as element()? := series:render-content($pid, $cid, ())
  return document { $content } 
};