xquery version "1.0-ml";

module namespace test = "http://github.com/robwhitby/xray/test";
import module namespace assert = "http://github.com/robwhitby/xray/assertions" at "/xray/src/assertions.xqy";

declare namespace xray = "http://github.com/robwhitby/xray";

import module namespace fnStr = "http://bbc.co.uk/psi/b2b-exporter/modules/fnstr" at "/xqy/fnstr.xqy";



declare %test:case function shouldHaveInvalidNonAlphaRemoved(){
  let $validString := "Batman"
  let $invalidString := "!!Batman"
  
  return assert:equal(fnStr:remove-non-alphanum($invalidString), $validString)
};

declare %test:case function shouldHaveNoCharsRemoved(){
  let $validString := "Batman"
  
  return assert:equal(fnStr:remove-non-alphanum($validString), $validString)
};

declare %test:case function shouldReturnSubstringBefore(){
	let $delimitedString := "Tomato:"
	let $delimiter := ":"
	let $expected := "Tomato"
	return assert:equal(fnStr:substring-before-if-contains($delimitedString, $delimiter), $expected)
};

declare %test:case function shouldNotReturnSubstringBefore1(){
	let $input := "Tomato:"
	let $delimiter := "?"
	let $expected := "Tomato:"
	return assert:equal(fnStr:substring-before-if-contains($input, $delimiter), $expected)
};

declare %test:case function shouldNotReturnSubstringBefore2(){
	let $input := "I'm eating a tomato"
	let $delimiter := "?"
	let $expected := "I'm eating a tomato"
	return assert:equal(fnStr:substring-before-if-contains($input, $delimiter), $expected)
};

declare %test:case function shouldNotStripArticles(){
	let $input := "bookshop"
	let $expected := "bookshop"
	return assert:equal(fnStr:clean-first-word($input), $expected)
};

declare %test:case function shouldStripArticles(){
	let $input := "The bookshop"
	let $expected := "bookshop"
	return assert:equal(fnStr:clean-first-word($input), $expected)
};

declare %test:case function shouldStripArticlesAndNonAlpha(){
	let $input := "A !2012 odyssey"
	let $expected := "2012 odyssey"
	return assert:equal(fnStr:clean-first-word($input), $expected)
};

declare %test:case function shouldStripAllArticle_ThE(){
	let $input := "ThE bookshop"
	let $expected := "bookshop"
	return assert:equal(fnStr:clean-first-word($input), $expected)
};

declare %test:case function shouldStripAllArticle_a(){
	let $input := "a bookshop"
	let $expected := "bookshop"
	return assert:equal(fnStr:clean-first-word($input), $expected)
};

declare %test:case function shouldStripAllArticle_aN(){
	let $input := "aN bookshop"
	let $expected := "bookshop"
	return assert:equal(fnStr:clean-first-word($input), $expected)
};

declare %test:case function shouldReturnEmptyStr(){
	let $input := ""
	let $expected := ""
	return assert:equal(fnStr:clean-first-word($input), $expected)
};