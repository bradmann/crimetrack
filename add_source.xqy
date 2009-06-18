xquery version "1.0-ml";
(:
 : CrimeTrack
 :
 : Copyright (c) 2009 Brad Mann. All Rights Reserved.
 :)

let $filename := xdmp:get-request-field-filename("upload")
let $filedata := xdmp:get-request-field("upload")
(: Had to fix the following part for IE, which provides the full file path :)
let $pathparts := tokenize($filename, "\\")
let $uri := concat("/", $pathparts[count($pathparts)])


let $x := xdmp:document-insert($uri, xdmp:unquote($filedata))
let $y := xdmp:set-session-field("source", $uri)

return xdmp:redirect-response("/")