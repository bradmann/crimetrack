xquery version "1.0-ml";
(:
 : CrimeTrack
 :
 : Copyright (c) 2009 Brad Mann. All Rights Reserved.
 :)

declare namespace evt = "my.crime.events";

let $source := xdmp:get-request-field("source", "/default.xml")
let $title := xdmp:get-request-field("title", "no title")
let $date := xdmp:get-request-field("date", "no date")
let $lat := xdmp:get-request-field("lat", "0.0")
let $lon := xdmp:get-request-field("lon", "0.0")
let $details := xdmp:get-request-field("details", "no details")
let $tags := xdmp:get-request-field("tags", "")

let $id := count(doc($source)/evt:events/child::*) + 1

let $node := <event id="{$id}" xmlns="my.crime.events">
                <title>{$title}</title>
                <lat>{$lat}</lat>
                <lon>{$lon}</lon>
                <details>{$details}</details>
                <date>{$date}</date>
                <tags>{$tags}</tags>
              </event>

let $x := xdmp:node-insert-child(doc($source)/evt:events, $node)

return (<tr>
       <td rowspan="2"><img id="marker_{$id}_image" style="width: 21px; height: 34px" /></td>
       <td><a href="javascript: void(0)" class="event_link" event_id="{$id}">{$title}</a>
            <input type="hidden" class="title" event_id="{$id}" value="{$title}"/>
            <input type="hidden" class="latlng" event_id="{$id}" value="{$lat},{$lon}"/>
            <input type="hidden" class="details" event_id="{$id}" value="{$details}"/>
            <input type="hidden" class="tags" event_id="{$id}" value="{$tags}"/>
            <input type="hidden" class="date" event_id="{$id}" value="{$date}"/>
       </td>
       </tr>,
       <tr>
        <td class="tag_text">[{$tags}]</td>
       </tr>)