(:?version=1.0&provider=BBC&title=B2B-Exporter-Tva-Xml&description=Provide%20TVA%Clip%20Xml&method=get&get:cid=xs:string&get:pid=xs:string
:)
xquery version "1.0-ml";

module namespace rest = "http://marklogic.com/rest-api/resource/b2b-exporter-tva-clip";

import module namespace clip = "http://bbc.co.uk/psi/b2b-exporter/modules/tva-clip" at "/ext/b2b-exporter/modules/tva-clip.xqy";

declare function rest:get($context as map:map, $params as map:map) as document-node()* {
  let $pid as xs:string? := xdmp:url-decode(map:get($params,"pid"))
  let $cid as xs:string? := xdmp:url-decode(map:get($params,"cid"))

  let $output-types as map:map? := map:put($context,"output-types","application/xml") 

  let $content as element()? := clip:render-content($pid, $cid, ())
  return document {$content} 
};
