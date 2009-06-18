xquery version "1.0-ml";
(:
 : CrimeTrack
 :
 : Copyright (c) 2009 Brad Mann. All Rights Reserved.
 :
 : This web service deletes a source document from the database.
 : Its request parameter is source.
 :)

let $source := xdmp:get-request-field("source")
let $x := xdmp:document-delete($source)

return ""