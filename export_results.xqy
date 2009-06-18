xquery version "1.0-ml";
(:
 : CrimeTrack
 :
 : Copyright (c) 2009 Brad Mann. All Rights Reserved.
 :)

declare namespace my = "my.function.namespace";
declare namespace evt = "my.crime.events";

declare function my:textSearch($text as xs:string, $source as xs:string) as node()*
{
    let $results := cts:search(//evt:event,
    cts:and-query((cts:document-query($source),
    cts:word-query($text, ("case-insensitive", "punctuation-insensitive")))))
    
    return <events xmlns="my.crime.events">{$results}</events>
};
'<?xml version="1.0" encoding="UTF-8"?>',
xdmp:add-response-header("content-disposition", "attachment; filename=export.xml"),
xdmp:set-response-content-type("application/octet-stream; charset=utf-8"),
let $source := xdmp:get-request-field("source")
let $search := xdmp:get-request-field("search")

return if (string-length($search) = 0) then doc($source) else my:textSearch($search, $source)
