var g_marker_hash = {};
var g_new_marker = null;
var g_selected_marker = null;
var g_current_search = "";
var map = null;

//Entry point
$(document).ready(function () {
	initialize_objects();
	
    initialize_map();
    
    var text = $("#data_source :selected").text();
	$.post("get_events.xqy", {source: text}, load_events, "html");
});

//Exit point
$(window).unload( function () { GUnload(); } );

//Initialize all the static objects on the page
function initialize_objects()
{
	//***Configure static objects***
	$("#bottom_div").tabs();
	$("#marker_image").attr("src", MapIconMaker.createLabeledMarkerIcon({primaryColor: "#fd766a"}).image);
	$("#marker_image").draggable({revert: 'invalid'});
	$("#map_canvas").droppable({
		drop: function(event, ui) {
			var mapoffset = $("#map_canvas").offset();
			var markeroffset = ui.offset;
			var left = parseInt(markeroffset["left"] - mapoffset["left"] + 10);
			var top = parseInt(markeroffset["top"] - mapoffset["top"] + 34);
			
			var latlng = map.fromContainerPixelToLatLng(new GPoint(left, top));
			g_new_marker = create_marker(latlng, {draggable: true});
			$("#marker_image").hide();
	    	$("#latlon_input").val(latlng.lat() + ", " + latlng.lng());
	    	map.addOverlay(g_new_marker);
		}
	});
	$("#event_date").datepicker({dateFormat: 'yy-mm-dd'});
	
	//***EVENT HANDLERS***
	$("#data_source").change(function(obj) {
		var text = $("#data_source :selected").text();
		$.post("get_events.xqy", {"source": text}, load_events, "html");
	});
	$("#cancel_button").click(function() {
		if (g_new_marker)
		{
			map.removeOverlay(g_new_marker);
			g_new_marker = null;
		}
		
		reset_creation();
	});
	$("#save_button").click(function () {
		if (g_new_marker)
		{
			g_new_marker.disableDragging();
			var lat = g_new_marker.getLatLng().lat();
			var lon = g_new_marker.getLatLng().lng();
			$.post("add_event.xqy", {"source": $("#data_source :selected").text(), "title": $("#event_title").val(), "date": $("#event_date").val(),
				"lat": lat, "lon": lon, "details": $("#event_details").val(), "tags": $("#event_tags").val()}, creation_callback);
			reset_creation();
		}
	});
	$("#search_button").click(function() {
		g_current_search = $("#search_input").val();
		$.post("search_events.xqy", {"source": $("#data_source :selected").text(), "search": g_current_search}, load_events, "html");
	});
	$("#file_upload_form").submit(function() {
		if ($("#file_upload").val() == "")
			return false;
	});
	$("#delete_event_link").click(function() {
		var id = g_selected_marker.id;
		$.post("delete_event.xqy", {"source": $("#data_source :selected").text(), "event": id.toString()}, delete_event_callback, "html");
	});
	$("#delete_source_button").click(function() {
		var source = $("#data_source :selected").text();
		
		if (source == "/default.xml")
		{
			alert("Cannot delete default source.");
			return;
		}
		
		var answer = confirm("Are you sure you want to delete the current data source?");
		if (answer)
			$.post("delete_source.xqy", {"source": $("#data_source :selected").text()}, function() {window.location = window.location});
	});
	$("#export_results_button").click(function() {
		window.location = "export_results.xqy?source=" + $("#data_source :selected").text() + "&search=" + g_current_search;
	});
	$("#search_input").keyup(function(e) {
		if (e.keyCode == 13)
			$("#search_button").click();
	});
	
	//Disable save button if not all information is provided
	$("#event_title,#event_date,#event_tags,#event_details,#latlon_input").bind("change keyup", function() {
		var emptyfield = false;
		$("#event_title,#event_date,#event_tags,#event_details,#latlon_input").each(function() {
			if ($(this).val() == "")
				emptyfield = true
		});
		
		if (emptyfield)
			$("#save_button").attr("disabled", "disabled");
		else
			$("#save_button").attr("disabled", "");
	});
}

//Initialize Google Map object
function initialize_map()
{
	map = new GMap2(document.getElementById("map_canvas"));
	map.setCenter(new GLatLng(0,0));
    map.addControl(new GLargeMapControl3D());
    map.addControl(new GHierarchicalMapTypeControl());
    map.enableScrollWheelZoom();
    
    GEvent.addListener(map, "singlerightclick", function (point) {
    	if (g_new_marker != null) return;
    	var latlng = map.fromContainerPixelToLatLng(point);
    	g_new_marker = create_marker(latlng, {draggable: true});
    	$("#latlon_input").val(latlng.lat() + ", " + latlng.lng());
    	map.addOverlay(g_new_marker);
    	$("#marker_image").css("display", "none");
    	$("#bottom_div").tabs('select', 2);
    });
}

function create_marker(point, options, id)
{	
	if (id == null)
		id = "";
	
	var icon = MapIconMaker.createLabeledMarkerIcon({label: id.toString(), primaryColor: "#fd766a"});
	options.icon = icon;
	var marker = new GMarker(point, options);
	
	marker.highlight_icon = MapIconMaker.createLabeledMarkerIcon({label: id.toString(), primaryColor: "#ffff00"});
	marker.selected_icon = MapIconMaker.createLabeledMarkerIcon({label: id.toString(), primaryColor: "#00ff00"});
	
	if (id != null)
		marker.id = id;
	
	if (options["draggable"])
	{
		GEvent.addListener(marker, "dragend", function (point) {
			var latlng = marker.getLatLng();
			$("#latlon_input").val(latlng.lat() + ", " + latlng.lng());
		});
	}
	
	GEvent.addListener(marker, "mouseover", function (point) {
		event_highlight(id);
	});
	GEvent.addListener(marker, "mouseout", function (point) {
		event_unhighlight(id);
	});
	GEvent.addListener(marker, "click", function (point) {
		event_clicked(id, false);
	});
	
	return marker;
}

function creation_callback(data)
{	
	var id = parseInt($(data).find(".event_link").attr("event_id"));
	var marker = create_marker(g_new_marker.getLatLng(), {}, id);
	map.removeOverlay(g_new_marker);
	map.addOverlay(marker);
	g_marker_hash[id] = marker;
	g_new_marker = null;
	
	$("#events_column > table > tbody").append(data);
	$("#marker_" + id + "_image").attr("src", marker.getIcon().image);
	$(".event_link[event_id='" + id + "']").click(function(obj) {
		var id = parseInt($(this).attr("event_id"));
		event_clicked(id);
	});
	
	$(".event_link[event_id='" + id + "']").hover(function() {
		var id = parseInt($(this).attr("event_id"));
		event_highlight(id);
	},
		function() {
		var id = parseInt($(this).attr("event_id"));
		event_unhighlight(id);
	}
	);
}

function delete_event_callback(data)
{
	var text = $("#data_source :selected").text();
	$.post("get_events.xqy", {"source": text}, load_events, "html");
}

function reset_creation()
{
	$("#marker_image").show();
	$("#marker_image").css("left", "0px");
	$("#marker_image").css("top", "0px");
	$("#event_title,#event_date,#event_tags,#event_details,#latlon_input").val("");
	$("#save_button").attr("disabled", "disabled");
}

function show_marker_detail(marker)
{
	var lat = marker.getLatLng().lat();
	var lon = marker.getLatLng().lng();
	var id  = marker.id;
	var url = "http://maps.google.com/staticmap?center=" + lat
		+ "," + lon + "&zoom=18&size=200x150&maptype=satellite&markers="
		+ lat + "," + lon + ",red" + id + "&key=MAPS_API_KEY&sensor=false";
	$("#detail_map").attr("src", url);
	$("#title_span").html($(".title[event_id='" + id + "']").val());
	$("#date_span").html($(".date[event_id='" + id + "']").val());
	$("#tags_span").html("[" + $(".tags[event_id='" + id + "']").val() + "]");
	$("#details_span").html($(".details[event_id='" + id + "']").val());
	
	$("#details_div").css("visibility", "visible");
	$("#bottom_div").tabs('select', 0); 
}

function clear_marker_detail()
{
	$("#details_div").css("visibility", "hidden");
}

function event_clicked(id, panTo)
{
	if (panTo == null)
		panTo = true;
	
	var marker = g_marker_hash[id];
	if (g_selected_marker == marker)
	{
		g_selected_marker = null;
		event_unhighlight(id);
		clear_marker_detail();
		return;
	}
	
	var tempMarker = null;
	if (g_selected_marker != null)
		tempMarker = g_selected_marker;
	
	g_selected_marker = marker;
	
	if (tempMarker != null)
		event_unhighlight(tempMarker.id);
	
	marker.setImage(marker.selected_icon.image);
	$("#marker_" + id + "_image").attr("src", marker.selected_icon.image);
	
	if (panTo)
		map.panTo(marker.getLatLng());
	
	show_marker_detail(marker);
}

function event_highlight(id)
{
	var marker = g_marker_hash[id];
	if (g_selected_marker == marker)
		return;
	marker.setImage(marker.highlight_icon.image);
	$("#marker_" + id + "_image").attr("src", marker.highlight_icon.image);
}

function event_unhighlight(id)
{
	var marker = g_marker_hash[id];
	if (g_selected_marker == marker)
		return;
	marker.setImage(marker.getIcon().image);
	$("#marker_" + id + "_image").attr("src", marker.getIcon().image);
}

function load_events(data)
{
	map.checkResize();
	
	for (var k in g_marker_hash)
	{
		map.removeOverlay(g_marker_hash[k]);
	}
	g_marker_hash = {};
	
	clear_marker_detail();
	g_selected_marker = null;
	
	$("#events_column").html(data);
	
	if ($("#events_table").html() == "")
	{
		map.setCenter(new GLatLng(0.0, 0.0), 1);
		return;
	}
	
	var bounds = new GLatLngBounds();
	$(".latlng").each(function(i) {
		var str = $(this).val();
		var id = parseInt($(this).attr("event_id"));
		var lat = parseFloat(str.split(",")[0]);
		var lon = parseFloat(str.split(",")[1]);
		var latlng = new GLatLng(lat, lon);
		var marker = create_marker(latlng, {}, id);
		bounds.extend(latlng);
		map.addOverlay(marker);
		
		$("#marker_" + id + "_image").attr("src", marker.getIcon().image);
		
		g_marker_hash[id] = marker;
	});
	
	$(".event_link").click(function(obj) {
		var id = parseInt($(this).attr("event_id"));
		event_clicked(id);
	});
	
	$(".event_link").hover(function() {
		var id = parseInt($(this).attr("event_id"));
		event_highlight(id);
	},
		function() {
		var id = parseInt($(this).attr("event_id"));
		event_unhighlight(id);
	}
	);
	
	$("#remove_search_link").click(function() {
		g_current_search = "";
		var text = $("#data_source :selected").text();
		$.post("get_events.xqy", {"source": text}, load_events, "html");
	});
	
	var zoom = map.getBoundsZoomLevel(bounds);
	
	map.setCenter(bounds.getCenter(), zoom);
}