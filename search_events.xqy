xquery version "1.0-ml";
(:
 : CrimeTrack
 :
 : Copyright (c) 2009 Brad Mann. All Rights Reserved.
 :
 : This web service searches elements in the specified source 
 : document and returns those that contain the search text.
 : Its request parameters are source and search. It outputs an
 : XHTML span and table with the results.
 :)

declare namespace my = "my.function.namespace";
declare namespace evt = "my.crime.events";

declare function my:textSearch($text as xs:string, $source as xs:string) as node()*
{
    let $results := cts:search(//evt:event,
    cts:and-query((cts:document-query($source),
    cts:word-query($text, ("case-insensitive", "punctuation-insensitive")))))
    
    for $event in $results
    let $title := data($event/evt:title)
	let $id := data($event/@id)
	let $date := data($event/evt:date)
	let $lat := data($event/evt:lat)
	let $lon := data($event/evt:lon)
	let $details := data($event/evt:details)
	let $tags := data($event/evt:tags)
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
};

let $source := xdmp:get-request-field("source")
let $search := xdmp:get-request-field("search")
return (<span id="events_heading">Search Results <a href="javascript: void(0)" id="remove_search_link">[remove search]</a></span>,<table id="events_table">{my:textSearch($search, $source)}</table>)

