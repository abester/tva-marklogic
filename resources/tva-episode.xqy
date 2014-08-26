(:?version=1.0&provider=BBC&title=B2B-Exporter-Tva-Episode-Xml&description=Provide%20TVA%20Episode%20Xml&method=get&get:cid=xs:string&get:pid=xs:string
:)
xquery version "1.0-ml";

module namespace rest = "http://marklogic.com/rest-api/resource/tva-episode";

import module namespace episode = "http://bbc.co.uk/psi/b2b-exporter/modules/tva-episode" at "/ext/b2b-exporter/modules/tva-episode.xqy";

declare function rest:get($context as map:map, $params as map:map) as document-node()* {
  let $pid as xs:string? := xdmp:url-decode(map:get($params,"pid"))
  let $cid as xs:string? := xdmp:url-decode(map:get($params,"cid"))

  let $output-types as map:map? := map:put($context,"output-types","application/xml") 
  (:let $input-types := map:get($context,"input-types")
   : let $negotiate := 
   :    if ($input-types = "application/xml")
   :    then () (: process, insert/update :) 
   :    else error((),"ACK",
   :      "Invalid type, accepts 'application/xml' only") 
   :)

let $content as element()? := episode:render-content($pid, $cid, ())
return document { $content } 
};