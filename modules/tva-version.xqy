xquery version "1.0-ml";

(:/ext/b2b-exporter/modules/tva-version.xqy :)
module namespace version = "http://bbc.co.uk/psi/b2b-exporter/modules/tva-version";

declare namespace p = "http://ns.webservices.bbc.co.uk/2006/02/pips";
   
(:  
 : Main Renderer -  Generates TVA Version XML  
 :)
declare function version:render-content($pid as xs:string, $cid as xs:string, $overide as element()?) as element()? {
<tva-version></tva-version>
};

