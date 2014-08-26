xquery version "1.0-ml";

module namespace test = "http://github.com/robwhitby/xray/test";
import module namespace assert = "http://github.com/robwhitby/xray/assertions" at "/ext/xquery/xray/src/assertions.xqy";

import module namespace fnstr = "http://bbc.co.uk/psi/b2b-exporter/modules/fnstr" at "/ext/b2b-exporter/modules/fnstr.xqy";

declare namespace xray = "http://github.com/robwhitby/xray";

declare %test:case function shouldHaveInvalidNonAlphaRemoved(){
  let $validString as xs:string := "Batman"
  let $invalidString as xs:string := "!!Batman"
  return assert:equal(fnstr:remove-non-alphanum($invalidString), $validString)
};

declare %test:case function shouldHaveNoCharsRemoved(){
  let $validString as xs:string := "Batman"
  return assert:equal(fnstr:remove-non-alphanum($validString), $validString)
};

declare %test:case function shouldReturnSubstringBefore(){
  let $delimitedString as xs:string := "Tomato:"
  let $delimiter as xs:string := ":"
  let $expected as xs:string := "Tomato"
  return assert:equal(fnstr:substring-before-if-contains($delimitedString, $delimiter), $expected)
};

declare %test:case function shouldNotReturnSubstringBefore1(){
  let $input as xs:string := "Tomato:"
  let $delimiter as xs:string := "?"
  let $expected as xs:string := "Tomato:"
  return assert:equal(fnstr:substring-before-if-contains($input, $delimiter), $expected)
};

declare %test:case function shouldNotReturnSubstringBefore2(){
  let $input as xs:string := "I'm eating a tomato"
  let $delimiter as xs:string := "?"
  let $expected as xs:string := "I'm eating a tomato"
  return assert:equal(fnstr:substring-before-if-contains($input, $delimiter), $expected)
};

declare %test:case function shouldNotStripArticles(){
  let $input as xs:string := "bookshop"
  let $expected as xs:string := "bookshop"
  return assert:equal(fnstr:clean-first-word($input), $expected)
};

declare %test:case function shouldStripArticles(){
  let $input as xs:string := "The bookshop"
  let $expected as xs:string := "bookshop"
  return assert:equal(fnstr:clean-first-word($input), $expected)
};

declare %test:case function shouldStripArticlesAndNonAlpha(){
  let $input as xs:string := "A !2012 odyssey"
  let $expected as xs:string := "2012 odyssey"
  return assert:equal(fnstr:clean-first-word($input), $expected)
};

declare %test:case function shouldStripAllArticle_ThE(){
  let $input as xs:string := "ThE bookshop"
  let $expected as xs:string := "bookshop"
  return assert:equal(fnstr:clean-first-word($input), $expected)
};

declare %test:case function shouldStripAllArticle_a(){
  let $input as xs:string := "a bookshop"
  let $expected as xs:string := "bookshop"
  return assert:equal(fnstr:clean-first-word($input), $expected)
};

declare %test:case function shouldStripAllArticle_aN(){
  let $input as xs:string := "aN bookshop"
  let $expected as xs:string := "bookshop"
  return assert:equal(fnstr:clean-first-word($input), $expected)
};

declare %test:case function shouldReturnEmptyStr(){
  let $input as xs:string := ""
  let $expected as xs:string := ""
  return assert:equal(fnstr:clean-first-word($input), $expected)
};