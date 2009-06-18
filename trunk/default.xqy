xquery version "1.0-ml";
(:
 : CrimeTrack
 :
 : Copyright (c) 2009 Brad Mann. All Rights Reserved.
 :
 : This is the main page for CrimeTrack and the default entry point.
 :)

declare namespace evt = "my.crime.events";

xdmp:set-response-content-type("text/html; charset=utf-8")
,
'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">',
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
  <script type="text/javascript" src="http://maps.google.com/maps?file=api&amp;v=2&amp;sensor=false"></script>
  <script type="text/javascript" src="js/mapiconmaker.js"></script>
  <script type="text/javascript" src="js/jquery-1.3.2.js"></script>
  <script type="text/javascript" src="js/jquery-ui-1.7.2.custom.min.js"></script>
  <script type="text/javascript" src="js/crimeTrack.js"></script>
  <link rel="stylesheet" href="css/crimetrack.css" />
  <link rel="stylesheet" href="css/ui-lightness/jquery-ui-1.7.2.custom.css" />
  <title>crimetrack</title>
  </head>
  <body>
    <div id="header">
        <img src="images/crimetrack.png" />
        <div id="source_div">
        Source
        <select id="data_source" name="data_source">
            {
            (: Get all the data sources in our database and display them. If there aren't any, make one! :)
            let $y := count(doc())
            let $x := if ($y < 1) then xdmp:document-insert("/default.xml", <events xmlns="my.crime.events"></events>) else ""
            let $z := if (empty(xdmp:get-session-field("source"))) then xdmp:set-session-field("source", "/default.xml") else ""
            return if ($y < 1)
                   then (<option value="/default.xml">/default.xml</option>)
                   else
                   for $doc in doc()
                    return
                        if (document-uri($doc) = xdmp:get-session-field("source")) then
                            <option value="{document-uri($doc)}" selected="selected">{document-uri($doc)}</option>
                        else
                            <option value="{document-uri($doc)}">{document-uri($doc)}</option>
            }
        </select>
        
        </div>
    </div>
    <div id="content">
	   <div id="map_canvas"></div>
	   <div id="events_column">
	       Events
	   </div>
	   <div id="bottom_div">
	       <ul>
	            <li><a href="#details_div">Details</a></li>
                <li><a href="#search_div">Search</a></li>
                <li><a href="#new_event_div">New Event</a></li>
                <li><a href="#addsource_div">Add Source</a></li>
                <li><a href="#delsource_div">Delete Source</a></li>
                <li><a href="#exportsource_div">Export Results</a></li>
           </ul>
           <div id="details_div">
                <img id="detail_map" />
                <div id="detail_div">
                    <span id="title_span"></span>&nbsp;<span id="tags_span"></span><br />
                    <a href="javascript: void(0)" id="delete_event_link">[delete event]</a><br />
                    <span id="date_span"></span><br />
                    <span id="details_span"></span>
                </div>
           </div>
           <div id="new_event_div">
                <div id="left_creation_div">
                   <div id="marker_home">
                        <img id="marker_image" />
                   </div>
                   Drag the marker or right-click on the map to create a new event.
                </div>
			       <table>
		           <tr>
		               <td class="left_col">Location</td>
		               <td colspan="3"><input type="text" disabled="disabled" id="latlon_input"></input></td>
		           </tr>
		           <tr>
		               <td class="left_col">Title</td>
		               <td><input type="text" id="event_title"></input></td>
                       <td rowspan="3">Details<br /><textarea id="event_details"></textarea></td>
		           </tr>
		           <tr>
		               <td class="left_col">Date</td>
		               <td><input type="text" id="event_date"></input></td>
		           </tr>
		           <tr>
		               <td class="left_col">Tags</td>
		               <td><input type="text" id="event_tags"></input></td>
		           </tr>
		           <tr>
		               <td></td>
		               <td></td>
		               <td></td>
                       <td><button id="cancel_button">reset</button>&nbsp;<button id="save_button" disabled="disabled">save</button></td>
		           </tr>
		           </table>
		           
		    </div>
		    <div id="search_div">
		    Search <input type="text" id="search_input"></input>&nbsp;<button id="search_button">search</button>
		    </div>
		    <div id="addsource_div">
		       <form id="file_upload_form" method="post" enctype="multipart/form-data" action="add_source.xqy">
	           Add new source <input type="file" id="file_upload" name="upload"></input> <input type="submit" value="Upload"></input>
	           </form>
            </div>
            <div id="delsource_div">
                <button id="delete_source_button">delete current source</button>
            </div>
            <div id="exportsource_div">
                <button id="export_results_button">export current results</button>
            </div>
	   </div>
	</div>
  </body>
</html>
