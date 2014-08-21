xquery version "1.0-ml";

(:/ext/b2b-exporter/modules/tva.xqy :)
module namespace tva = "http://bbc.co.uk/psi/b2b-exporter/modules/tva";
   
(:  
 : Main Renderer -  Generates TVA XML  
 :)
declare function tva:render-content($pid as xs:string, $cid as xs:string, $overide as element()? ){
  <tva></tva>
};

