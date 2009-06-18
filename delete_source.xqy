xquery version "1.0-ml";
(:
 : CrimeTrack
 :
 : Copyright (c) 2009 Brad Mann. All Rights Reserved.
 :)

let $source := xdmp:get-request-field("source")
let $x := xdmp:document-delete($source)

return ""