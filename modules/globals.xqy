xquery version "1.0-ml";

(:/ext/b2b-exporter/modules/globals.xqy :)
module namespace glb = "http://bbc.co.uk/psi/b2b-exporter/modules/globals";

(:
 : Ubiquitous values used throughout the TVA XML components
 :)
declare variable $locale as xs:string := "en-GB";
declare variable $organisation as xs:string  := "bbc";
declare variable $authority as xs:string  := "bbc";

declare variable $iplayerUrnPrefix as xs:string :=  "urn:bbc:metadata:cs:iPlayerFormatCS:2007:";

declare variable $docStoreEndPoint as xs:string := "/pips/"; (: end point used to read all pips documents :)