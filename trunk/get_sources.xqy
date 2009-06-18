xquery version "1.0-ml";
(:
 : CrimeTrack
 :
 : Copyright (c) 2009 Brad Mann. All Rights Reserved.
 :
 : This web service returns the uri of each document in the database.
 : No inputs.
 :)

for $doc in doc()
return document-uri($doc)