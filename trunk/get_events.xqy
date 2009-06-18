xquery version "1.0-ml";
(:
 : CrimeTrack
 :
 : Copyright (c) 2009 Brad Mann. All Rights Reserved.
 :
 : This web service gets all the events from a source document.
 : Its request parameter is source. It outputs an XHTML span and
 : table with the requested document data.
 :)

declare namespace evt = "my.crime.events";


<span id="events_heading">Criminal Activity</span>,
<table id="events_table">
{

let $source := xdmp:get-request-field("source")
let $x := xdmp:set-session-field("source", $source)

for $event in doc($source)/evt:events/evt:event
let $title := data($event/evt:title)
let $id := data($event/@id)
let $date := data($event/evt:date)
let $lat := data($event/evt:lat)
let $lon := data($event/evt:lon)
let $details := data($event/evt:details)
let $tags := data($event/evt:tags)
order by $event/evt:id
return if (string-length($tags) = 0) then (<tr>
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
        <td class="tag_text">[no_tag]</td>
       </tr>)
       else
       (<tr>
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
}
</table>