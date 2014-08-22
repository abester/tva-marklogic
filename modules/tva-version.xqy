xquery version "1.0-ml";

(:/ext/b2b-exporter/modules/tva-version.xqy :)
module namespace version = "http://bbc.co.uk/psi/b2b-exporter/modules/tva-version";
   
(:  
 : Main Renderer -  Generates TVA Version XML  
 :)
declare function version:render-content($pid as xs:string, $cid as xs:string, $overide as element()? ){
<tva-version></tva-version>
};

