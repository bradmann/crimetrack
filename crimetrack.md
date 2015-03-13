# crimetrack #

![https://lh3.googleusercontent.com/-dOCWvw5xyIs/Sjm2jJGWAdI/AAAAAAAAGHI/X6eP5v_PtwA/w1113-h824-no/main.png](https://lh3.googleusercontent.com/-dOCWvw5xyIs/Sjm2jJGWAdI/AAAAAAAAGHI/X6eP5v_PtwA/w1113-h824-no/main.png)


# Details #
The source box on the top right displays the currently selected source document. By default an empty source document is provided (/default.xml).

The application consists of 3 main parts:
  1. ### Map ###
> > The map is used for situational awareness. Crime events are displayed as markers on the map. The map can be panned/zoomed using a mouse/scrollwheel. Markers on the map can be selected.
  1. ### Results Set ###
> > The results window is used to display a list of the current working set. Initially all the events in a source are displayed. This view is updated when the user initiates a search, which causes only the matched results to be displayed. When an item in the results set is selected, the map automatically centers on it.
  1. ### Tabbed Control Center ###
    * Details: Displays details about the selected event.
    * Search: Enables searching within the currently selected source.
    * New Event: Interface for adding a new event. Drag the marker onto the map to start the process, or simply right-click on the main map.
    * Add Source: Provides ability to upload an xml file of events to the database.
    * Delete Source: Allows the user to delete the currently selected source from the database.
    * Export Results: Enables exporting of current results set to an xml file. Note that if the results set contains the results of a search, only those items are exported.