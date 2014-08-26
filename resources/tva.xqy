(:?version=1.0&provider=BBC&title=B2B-Exporter-Tva-Xml&description=Provide%20TVA%20Xml&method=get&get:cid=xs:string&get:pid=xs:string
:)
xquery version "1.0-ml";

module namespace rest = "http://marklogic.com/rest-api/resource/tva";

import module namespace tva = "http://bbc.co.uk/psi/b2b-exporter/modules/tva" at "/ext/b2b-exporter/modules/tva.xqy";

declare function rest:get($context as map:map, $params as map:map) as document-node()* {
  let $pid as xs:string? := xdmp:url-decode(map:get($params,"pid"))
  let $cid as xs:string? := xdmp:url-decode(map:get($params,"cid"))

  let $output-types as map:map? := map:put($context,"output-types","application/xml") 

  let $content as element()? := tva:render-content($pid, $cid, ())
  return document {$content} 
};
