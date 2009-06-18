xquery version "1.0-ml";
(:
 : CrimeTrack
 :
 : Copyright (c) 2009 Brad Mann. All Rights Reserved.
 :
 : This web service delets an event from the specified source file.
 : Its request parameters are source and event. After deletion,
 : the ids of all subsequent events are decremented by 1.
 : Returns an empty string.
 :)

declare namespace evt = "my.crime.events";

let $source := xdmp:get-request-field("source", "/default.xml")
let $id := xdmp:get-request-field("event", "0")

let $x := xdmp:node-delete(doc($source)/evt:events/evt:event[@id=$id])

let $nodes := (for $n in doc($source)/evt:events/evt:event[@id>$id]
               return $n)
               
let $y := (for $node in $nodes
    let $newid := number($node/@id) - 1
    let $newnode := <event id="{$newid}" xmlns="my.crime.events">
                        <title>{$node/title}</title>
                        <lat>{$node/lat}</lat>
                        <lon>{$node/lon}</lon>
                        <details>{$node/details}</details>
                        <date>{$node/date}</date>
                        <tags>{$node/tags}</tags>
                    </event>
    return xdmp:node-replace($node, $newnode))

return ""