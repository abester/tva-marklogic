xquery version "1.0-ml";

(:/ext/b2b-exporter/modules/fnstr.xqy :)
module namespace fnstr = "http://bbc.co.uk/psi/b2b-exporter/modules/fnstr";

declare private variable $articles := ("a ","an ","the ");
declare private variable $alphaNumeric as xs:string := "[^a-zA-Z0-9]";
declare private variable $spaceChar  as xs:string  := " ";

(: Removes ['A','An','The'] from the beginning of a sentence
 : AND removes *ALL* non alphanumeric characters from the first word of a string
 :
 : @param $s the input string
 : @return the whole string, with the first word free from non alphanumeric characters or entire string
 :)
declare function fnstr:clean-first-word($s as xs:string?) as xs:string? {
  let $articleFreeStr := fnstr:remove-articles($s)
  let $result :=
    if ( contains($articleFreeStr,$spaceChar) ) then
        (: clean first word and reconstruct the entire sentence :)
        concat( (fnstr:return-non-alphanum-word($articleFreeStr)),
                (substring-after($articleFreeStr, $spaceChar)) )
    else
      (: single word :)
      fnstr:remove-non-alphanum($articleFreeStr)
        
  return $result
};

(:  Removes all non alphanumeric characters from a string
 : 
 :  @param $s the input string
 :  @return string free from non alphanumeric characters
 :)
declare function fnstr:remove-non-alphanum($s as xs:string?) as xs:string? {
  replace($s, $alphaNumeric, "")
};

(:
 : Performs substring-before, returning the entire string if it does not contain the delimiter.
 :
 : @param $s the input string
 : @param $delim the delimiter
 : @return the converted string
 :)
declare function fnstr:substring-before-if-contains($s as xs:string?, $delim as xs:string) as xs:string? {
  if (contains($s,$delim)) then
      substring-before($s,$delim)
  else $s
};

(: 
 : Remove definite & indefinite articles from the beginning of a string.
 :)
declare private function fnstr:remove-articles($s as xs:string?) as xs:string?  {
  let $lowerS := lower-case($s)
  let $matched := 
    for $article in $articles
    where ( starts-with($lowerS, $article) ) 
    return substring($s, string-length($article) + 1 )

  let $result :=
    if ($matched) then
        $matched
     else
        $s
  return $result
};

(: Return the first word in a string free from non alphanumeric values.
 : A Space character will be appended to the word.
 :)
declare private function fnstr:return-non-alphanum-word($s as xs:string?) as xs:string? {
  let $firstWord := fnstr:remove-non-alphanum(fnstr:substring-before-if-contains($s, $spaceChar))
  let $result :=
    if (string-length($firstWord) > 0) then
        concat($firstWord, $spaceChar)
    else
        $firstWord
  return $result     
};

