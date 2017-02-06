/* FoursquareCheckInMapper.pde - Final Project - Foursquare Check-In Mapper
 *
 * Joseph Fernandez - 12/20/2014
 *
 * All of the primary functions of the Check-In Mapper start here - application core, map, necessary classes and methods, and parameters.
 * Venue data loaded, stored, and handled here. controlP5 GUI buttons and objects and their respective functions for this application are also set up.
 */

import com.temboo.core.*; // for Foursquare OAuth
import com.temboo.Library.Foursquare.OAuth.*;
import de.fhpotsdam.unfolding.mapdisplay.*; // maps
import de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.unfolding.marker.*;
import de.fhpotsdam.unfolding.tiles.*;
import de.fhpotsdam.unfolding.interactions.*;
import de.fhpotsdam.unfolding.ui.*;
import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.core.*;
import de.fhpotsdam.unfolding.mapdisplay.shaders.*;
import de.fhpotsdam.unfolding.data.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.texture.*;
import de.fhpotsdam.unfolding.events.*;
import de.fhpotsdam.utils.*;
import de.fhpotsdam.unfolding.providers.*;
import controlP5.*; // GUI - buttons and text areas

/********************************************************************************************************************************************************************************************************/

UnfoldingMap map; // map
ControlP5 cp5; // GUI
Textfield query, qLoc; // text fields for query entry
Button searchButton, // search button
       loginButton, // login button to view and map user check-ins
       clearM, // button to clear everything on map
       zoomM, // button to zoom in to current mapping of selected venues
       viewCI; // if logged in, view check-ins again (esp. after they were cleared)
DropdownList timeOption; // drop-down list for time filter
JSONLoader jsl; // JSON loader to help load JSON files
OAuthManager oam; // OAuth management for logging in and out
Viewer theV; // view venue information

// venue data is split into Venues, venue locations (for markers), and markers (to display venue on map)
ArrayList <Location> vLocs; // venue locations
ArrayList <Location> vCheckInLocs; // locations of check-ins
ArrayList <Location> vMapLocs; // mapped locations (a following path of selected venues)
ArrayList <Marker> vMarkers; // markers denoting location of venue
ArrayList <Marker> vToNextVMarkers; // line markers connecting venue to next visited venues
ArrayList <Marker> vCheckInMarkers; // line markers connecting check-in to next visited venues
ArrayList <Marker> vMapMarkers; // markers of mapped locations
ArrayList <Venue> vResults; // loaded venues from search query/check-ins
ArrayList <Venue> vCheckIns; // check-in venues (loaded from logging in)
ArrayList <Venue> vMap; // mapped venues
Location selLoc; // location of currently selected venue on map
Marker selMarker; // marker of location of currently selected venue on map
SimpleLinesMarker mapMarker, // line marker connecting mapped venues
                  checkInMarker; // line marker connecting check-ins
Venue selVenue, // currently selected venue
      prevSelVenue; // previously selected venue
PImage logo; // Foursquare logo
PFont appfont, // body text
      appfontbig; // title text
color[] markerColors; // for distinguishing between markers
boolean photoViewMode; // view photos? (set in Viewer class)
String[] clientConfig; // client configuration
String logoLoc, //
       adjDate, // adjusted date for loading JSON - formatted as yyyymmdd
       cInfo, // client info
       vAPI, // venues API address
       sAPI, // search (explore) API address
       uAPI, // user API (address)
       sLim, // search limit to add to address for loading JSON
       sLimT, // search limit to add to address for loading JSON - for filtering by time period
       aT; // access token for OAuth
int appW, // defined width of app
    appH, // height
    mode, // 0 = empty map, ready; -1 = no results found; 1 = search results; 2 = search results w/ selected venue
    timeRange, // filters results according to defined time - 0 = anytime, 1 = morning, 2 = afternoon, 3 = evening
    setResultsCap; // how many results to return and display

/********************************************************************************************************************************************************************************************************/

// core functionality setup
void setup()
{
  appfont = createFont("Arial", 12);
  appfontbig = createFont("Arial", 24);
  textFont(appfont);
  appW = 1280; // 1280x720 view
  appH = 720;
  mode = timeRange = 0;
  setResultsCap = 5; // number of results to return when searching
  photoViewMode = false; // no photos to be displayed yet
  
  jsl = new JSONLoader();
  oam = new OAuthManager();
  theV = new Viewer(appW, appH, appfont, appfontbig, setResultsCap);
  
  clientConfig = loadStrings("data/clientConfig.txt");
  logoLoc = sketchPath + "\\data\\poweredByFoursquare_gray.png";
  // cInfo = "&client_id=CLIENT_ID&client_secret=CLIENT_SECRET&v=";
  cInfo = "client_id=" + clientConfig[0] + "&client_secret=" + clientConfig[1] + "&v=";
  adjDate = adjustedDate();
  sLim = "limit=5&";
  sLimT = "limit=15&";
  vAPI = "https://api.foursquare.com/v2/venues/";
  sAPI = "https://api.foursquare.com/v2/venues/explore?";
  uAPI = "https://api.foursquare.com/v2/users/";
  vLocs = new ArrayList <Location>();
  vMapLocs = new ArrayList <Location>();
  vCheckInLocs = new ArrayList <Location>();
  vMarkers = new ArrayList <Marker>();
  vToNextVMarkers = new ArrayList <Marker>();
  vMapMarkers = new ArrayList <Marker>();
  vCheckInMarkers = new ArrayList <Marker>();
  vResults = new ArrayList <Venue>();
  vMap = new ArrayList <Venue>();
  vCheckIns = new ArrayList <Venue>();
  
  // marker colors
  // 12 made in case
  markerColors = new color[12];
  markerColors[0] = color(#FF0000);
  markerColors[1] = color(#FFFF00);
  markerColors[2] = color(#00FF00);
  markerColors[3] = color(#00FFFF);
  markerColors[4] = color(#0000FF);
  markerColors[5] = color(#FF00FF);
  markerColors[6] = color(#FF8000);
  markerColors[7] = color(#80FF00);
  markerColors[8] = color(#00FF80);
  markerColors[9] = color(#0080FF);
  markerColors[10] = color(#8000FF);
  markerColors[11] = color(#FF008F);
  
  size(appW, appH, P2D);
  background(#000080);
  map = new UnfoldingMap(this, 0, 0, appW - 400, appH - 100, new Google.GoogleMapProvider());
  map.setZoomRange(UnfoldingMap.DEFAULT_ZOOM_LEVEL, 18);
  map.zoomAndPanTo(new Location(37.72f, -122.48f), 16);
  MapUtils.createDefaultEventDispatcher(this, map);
  logo = loadImage(logoLoc);
  cp5 = new ControlP5(this);
  
  // controlP5 GUI setup
  query = new Textfield(cp5, "searchQuery");
  qLoc = new Textfield(cp5, "queryLocation");
  searchButton = new Button(cp5, "startSearch");
  loginButton = new Button(cp5, "login4S");
  zoomM = new Button(cp5, "zoomToMapping");
  clearM = new Button(cp5, "clearMap");
  viewCI = new Button(cp5, "viewCheckIns");
  timeOption = new DropdownList(cp5, "timeOp");
  
  query.setPosition(50, appH - 85)
      .setSize(250, 20)
      .setLabel("")
      .setLabelVisible(false)
      .setAutoClear(false)
      .setColorBackground(#FFFFFF)
      .setColor(#000000)
      .setColorCursor(#000000)
      .setFont(appfont)
      ;
  qLoc.setPosition(50, appH - 60)
      .setSize(250, 20)
      .setLabel("")
      .setLabelVisible(false)
      .setAutoClear(false)
      .setColorBackground(#FFFFFF)
      .setColor(#000000)
      .setColorCursor(#000000)
      .setFont(appfont)
      ;
  searchButton.setPosition(50, appH - 35)
      .setLabel("Search")
      .setSize(120, 20)
      .setColorBackground(#FFFFFF)
      .setColorLabel(#000000)
      .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
      .setFont(appfont)
      ;
  clearM.setPosition(180, appH - 35)
      .setLabel("Clear Map")
      .setSize(120, 20)
      .setColorBackground(#FFFFFF)
      .setColorLabel(#000000)
      .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
      .setFont(appfont)
      ;
  loginButton.setPosition(580, appH - 85)
      .setLabel("Log In")
      .setSize(250, 20)
      .setColorBackground(#FFFFFF)
      .setColorLabel(#000000)
      .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
      .setFont(appfont)
      ;
  zoomM.setPosition(580, appH - 60)
      .setLabel("Zoom to Current Mapping")
      .setSize(250, 20)
      .setColorBackground(#FFFFFF)
      .setColorLabel(#000000)
      .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
      .setFont(appfont)
      ;
  viewCI.setPosition(580, appH - 35)
      .setLabel("View Check-Ins")
      .setSize(250, 20)
      .setColorBackground(#FFFFFF)
      .setColorLabel(#000000)
      .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
      .setFont(appfont)
      ;
  timeOption.setPosition(315, appH - 63)
      .setLabel("Popular Hours")
      .setSize(250, 60)
      .setColorBackground(#FFFFFF)
      .setColorLabel(#000000)
      .setItemHeight(20)
      .setBarHeight(20)
      .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
      .setFont(appfont)
      ;
      
  timeOption.addItem("Anytime", 0);
  timeOption.addItem("Morning (12 am - 11:59 am)", 1);
  timeOption.addItem("Afternoon (12 pm - 5:59 pm)", 2);
  timeOption.addItem("Evening (6 pm - 11:59 pm)", 3);
}

/********************************************************************************************************************************************************************************************************/

void draw()
{
  background(#000080); // blue
  if (!photoViewMode) // view photos? else just the map
  {
    map.draw();
    image(logo, appW - 635, appH - 145, 240, 60);
  }
  else theV.viewPhotos();
  text("Find...", 5, appH - 80, 50, 15);
  text("Near...", 5, appH - 55, 50, 15);
  
  if (mode == 1) theV.drawViewer(vResults);
  else if (mode == 2) theV.drawViewer(selVenue, vResults);
  else theV.drawViewer(mode);
}

/********************************************************************************************************************************************************************************************************/

// check, handle searches when entering query in "Find..." textfield
public void searchQuery(String theQuery)
{
  photoViewMode = false; // turn off photo view if photo view in progress
  
  // cannot search w/ query alone, must enter location to properly search...
  if (!qLoc.getText().isEmpty())
  {
    println(theQuery + " near " + qLoc.getText());
    clearMap();
    loadSearchResults(theQuery.replace(" ", "-"), qLoc.getText().replace(" ", "-"));
    query.clear();
  }
  else qLoc.setValue("Enter a location..."); // otherwise exception...
}

/********************************************************************************************************************************************************************************************************/

// check, handle searches when entering location query in "Near..." textfield
public void queryLocation(String theLocation)
{
  photoViewMode = false;
  // search w/ query entered?
  if (!query.getText().isEmpty())
  {
    println(query.getText() + " near " + theLocation);
    clearMap(); // clear out previous searches and analysis
    loadSearchResults(query.getText().replace(" ", "-"), theLocation.replace(" ", "-"));
    query.clear();
  }
  else
  {
    clearMap();
    loadSearchResults(theLocation.replace(" ", "-"));
  }
}

/********************************************************************************************************************************************************************************************************/

// technically runs both methods above (queryLocation, searchQuery), except this is for a simple search button
public void startSearch()
{
  photoViewMode = false;
  if (!query.getText().isEmpty()) // query entered?
  {
    if (!qLoc.getText().isEmpty()) // location entered?
    {
      println(query.getText() + " near " + qLoc.getText());
      clearMap();
      loadSearchResults(query.getText().replace(" ", "-"), qLoc.getText().replace(" ", "-"));
      query.clear();
    }
    else qLoc.setValue("Enter a location..."); // cannot search w/o entering location
  }
  else if (!qLoc.getText().isEmpty())
  {
    clearMap();
    loadSearchResults(qLoc.getText().replace(" ", "-"));
  }
}

/********************************************************************************************************************************************************************************************************/

// if time filter selected, filter return results according to time period
void trimResultsByTimeRange(int time)
{
  for (int i = 0; i < vResults.size(); i++)
  {
    if (time == 1 && !vResults.get(i).getPopAM()) vResults.remove(i);
    else if (time == 2 && !vResults.get(i).getPopDay()) vResults.remove(i);
    else if (time == 3 && !vResults.get(i).getPopNight()) vResults.remove(i);
  }
}

/********************************************************************************************************************************************************************************************************/

// clear everything on map + loaded venue data (venues, markers, locations)
public void clearMap()
{
  mode = 0;
  photoViewMode = false;
  map.getDefaultMarkerManager().clearMarkers();
  vLocs.clear();
  vMapLocs.clear();
  vMarkers.clear();
  vMapMarkers.clear();
  vResults.clear();
  vMap.clear();
  vToNextVMarkers.clear();
  selLoc = null;
  selMarker = null;
  mapMarker = null;
  prevSelVenue = selVenue = null;
}

/********************************************************************************************************************************************************************************************************/

// Foursquare log in, OAuth, log out buttons
// procedure: click "Log in," direct to Foursquare login page;
// confirm authorization, and all data from user displayed
// button labels change according to login procedure
// once logged out, label button back to "log in"
public void login4S()
{
  photoViewMode = false; // exit photo mode if in photo mode
  if (loginButton.getLabel() == "Log In") // logging in...
  {
    clearMap();
    try
    {
      oam.initializeOAuth(); // begin OAuth process
      loginButton.setLabel("Confirm Authorization");
    }
    catch (Exception e) {System.err.println("OAuth initalization failed.");}
  }
  else if (loginButton.getLabel() == "Confirm Authorization") // confirm authorization
  {
    try
    {
      aT = oam.finalizeOAuth(); // get access token
      loadCheckIns(aT);
      loginButton.setLabel("Log Out");
    }
    catch (Exception e) {System.err.println("OAuth finalization failed.");}
  }
  else if (loginButton.getLabel() == "Log Out")
  {
    clearMap();
    loginButton.setLabel("Log In");
  }
}

/********************************************************************************************************************************************************************************************************/

// zoom map according to mapped venues, if any
public void zoomToMapping()
{
  photoViewMode = false;
  if (!vMapLocs.isEmpty()) map.zoomAndPanToFit(vMapLocs);
}

/********************************************************************************************************************************************************************************************************/

// if logged in, load and view check-ins again
// - when logging in for the first time to load and display check-ins,
//   the check-ins (along with associated markers and locations) will be copied to another arraylist
//   to be loaded later in the discretion of the user
// - mapped venues and check-ins are removed from map following a new search
public void viewCheckIns()
{
  photoViewMode = false;
  if (loginButton.getLabel() == "Log Out" && !vCheckIns.isEmpty())
  {
    mode = 1;
    // clear out all markers, previous searches, venues
    map.getDefaultMarkerManager().clearMarkers();
    vLocs.clear();
    vMapLocs.clear();
    vMarkers.clear();
    vMapMarkers.clear();
    vResults.clear();
    vMap.clear();
    vToNextVMarkers.clear();
    
    // arraylist of check-ins already copied saved beforehand (while loading check-ins)
    // copy arraylist of check-ins to empty arraylist of venues
    // do the same w/ other venue data (locations and markers)
    for (int i = 0; i < vCheckIns.size(); i++)
    {
      vResults.add(vCheckIns.get(i));
      vMap.add(vCheckIns.get(i));
      vLocs.add(vCheckInLocs.get(i));
      vMapLocs.add(vCheckInLocs.get(i));
      vMarkers.add(vCheckInMarkers.get(i));
      vMapMarkers.add(vCheckInMarkers.get(i));
      map.addMarkers(vCheckIns.get(i).getNextVLineMarkers());
      map.addMarkers(vCheckIns.get(i).getNextVMarkers());
    }
    
    mapMarker = checkInMarker;
    
    // add markers to map
    map.addMarkers(mapMarker);
    map.addMarkers(vMarkers);
    map.zoomAndPanToFit(vLocs); // zoom map to fit list of returned locations
  }
}

/********************************************************************************************************************************************************************************************************/

// for Foursquare API formatting when loading JSON
String adjustedDate()
{
  String today = str(year());
  if (month() < 10) today += "0" + str(month());
  else today += str(month());
  if (day() < 10) today += "0" + str(day());
  else today += str(day());
  return today;
}

/********************************************************************************************************************************************************************************************************/

// load and save check-ins from JSON
void loadCheckIns(String access)
{
  JSONObject json = null;
  if (timeRange > 0) println(uAPI + "self/checkins?oauth_token=" + access + "&" + sLimT + "v=" + adjDate);
  else println(uAPI + "self/checkins?oauth_token=" + access + "&" + sLim + "v=" + adjDate);
  try
  {
    // check if able to load from JSON
    if (timeRange > 0) json = loadJSONObject(uAPI + "self/checkins?oauth_token=" + access + "&" + sLimT + "v=" + adjDate);
    else json = loadJSONObject(uAPI + "self/checkins?oauth_token=" + access + "&" + sLim + "v=" + adjDate);
  }
  catch (Exception e)
  {
    // return no results if JSON cannot be loaded
    System.err.println("Error in retrieving JSON.");
    mode = -1;
  }
  if (json != null) // if JSON loaded...
  {
    vResults = jsl.loadCheckIns(json); // load check-ins
    if (!vResults.isEmpty())
    {
      if (timeRange > 0)
      {
        trimResultsByTimeRange(timeRange);
        if (vResults.size() > setResultsCap) vResults.subList(setResultsCap, vResults.size()).clear();
      }
      
      // set up associated markers for loaded check-ins
      setUpCheckInMarkers(vResults);
      if (!vLocs.isEmpty() && !vMarkers.isEmpty())
      {
        // line marker to connect check-ins together
        mapMarker = new SimpleLinesMarker(vLocs);
        mapMarker.setColor(color(127, 127));
        mapMarker.setHighlightColor(color(127, 127));
        mapMarker.setStrokeColor(color(127, 127));
        mapMarker.setHighlightStrokeColor(color(127, 127));
        mapMarker.setStrokeWeight(5);
        map.addMarkers(mapMarker);
        
        // checkInMarker = copy of mapMarker meant to be loaded when "View Check-Ins" button is pressed to reload check-ins
        checkInMarker = new SimpleLinesMarker(vLocs);
        checkInMarker.setColor(color(127, 127));
        checkInMarker.setHighlightColor(color(127, 127));
        checkInMarker.setStrokeColor(color(127, 127));
        checkInMarker.setHighlightStrokeColor(color(127, 127));
        checkInMarker.setStrokeWeight(5);
        
        // copy 
        for (int i = 0; i < vResults.size(); i++)
        {
          vMapLocs.add(vLocs.get(i));
          vMapMarkers.add(vMarkers.get(i));
          vCheckIns.add(vResults.get(i));
          vCheckInLocs.add(vLocs.get(i));
          vCheckInMarkers.add(vMarkers.get(i));
        }
      }
      mode = 1;
    }
    else mode = -1;
  }
}

/********************************************************************************************************************************************************************************************************/

// load resulting venues from searching (via textfields)
// - this method goes when both query and location are provided
void loadSearchResults(String what, String near)
{
  JSONObject json = null;
  if (timeRange > 0) println(sAPI + sLimT + "query=" + what + "&near=" + near + "&" + cInfo + adjDate + "&m=foursquare");
  else println(sAPI + sLim + "query=" + what + "&near=" + near + "&" + cInfo + adjDate + "&m=foursquare");
  try
  {
    if (timeRange > 0) json = loadJSONObject(sAPI + sLimT + "query=" + what + "&near=" + near + "&" + cInfo + adjDate + "&m=foursquare");
    else json = loadJSONObject(sAPI + sLim + "query=" + what + "&near=" + near + "&" + cInfo + adjDate + "&m=foursquare");
  }
  catch (Exception e)
  {
    System.err.println("Error in retrieving JSON.");
    mode = -1;
  }
  if (json != null)
  {
    vResults = jsl.loadSearchResults(json);
    if (!vResults.isEmpty())
    {
      if (timeRange > 0)
      {
        trimResultsByTimeRange(timeRange);
        if (vResults.size() > setResultsCap) vResults.subList(setResultsCap, vResults.size()).clear();
      }
      setUpMarkers(vResults);
      mode = 1;
    }
    else mode = -1;
  }
}

/********************************************************************************************************************************************************************************************************/

// load resulting venues from searching (via textfields)
// - this method goes when only location is provided
void loadSearchResults(String near)
{
  JSONObject json = null;
  if (timeRange > 0) println(sAPI + sLimT + "near=" + near + "&" + cInfo + adjDate + "&m=foursquare");
  else println(sAPI + sLim + "near=" + near + "&" + cInfo + adjDate + "&m=foursquare");
  try
  {
    if (timeRange > 0) json = loadJSONObject(sAPI + sLimT + "near=" + near + "&" + cInfo + adjDate + "&m=foursquare");
    else json = loadJSONObject(sAPI + sLim + "near=" + near + "&" + cInfo + adjDate + "&m=foursquare");
  }
  catch (Exception e)
  {
    System.err.println("Error in retrieving JSON.");
    mode = -1;
  }
  if (json != null)
  {
    vResults = jsl.loadSearchResults(json);
    if (!vResults.isEmpty())
    {
      if (timeRange > 0)
      {
        trimResultsByTimeRange(timeRange);
        if (vResults.size() > setResultsCap) vResults.subList(setResultsCap, vResults.size()).clear();
      }
      setUpMarkers(vResults);
      mode = 1;
    }
    else mode = -1;
  }
}

/********************************************************************************************************************************************************************************************************/

// loads and displays the next venues for a selected venue
// - when a venue is selected from the map, this method runs to view the next visited venues for the selected venue
// - selected venue comes from selecting the marker on the map associated with the venue
void loadNextVenues()
{
  SimplePointMarker mPMark;
  boolean venueSelected = false; // was a venue already selected?
  int resultsIndex = 0; // in case venue selected was part of 
  if (!map.getMarkers().isEmpty())
  {
    selMarker = map.getFirstHitMarker(mouseX, mouseY);
    for (Marker marker : map.getMarkers()) {marker.setSelected(false);}
    if (selMarker != null)
    {
      if (selVenue != null) prevSelVenue = selVenue;
      selMarker.setSelected(true);
      if (!vMapLocs.isEmpty())
      {
        if (vMapLocs.contains(selMarker.getLocation()))
        {
          resultsIndex = vMapLocs.indexOf(selMarker.getLocation());
          venueSelected = true;
          selVenue = vMap.get(resultsIndex);
          if (prevSelVenue != selVenue)
          {
            vMapLocs.subList(resultsIndex, vMapMarkers.size()).clear();
            vMap.subList(resultsIndex, vMapMarkers.size()).clear();
            vMapMarkers.subList(resultsIndex, vMapMarkers.size()).clear();
          }
        }
      }
      if (!venueSelected && !vLocs.isEmpty())
      {
        if (vLocs.contains(selMarker.getLocation()))
        {
          resultsIndex = vLocs.indexOf(selMarker.getLocation());
          venueSelected = true;
          selVenue = vResults.get(resultsIndex);
        }
      }
      if (venueSelected && prevSelVenue != selVenue)
      {
        mode = 2;
        selLoc = selVenue.getVenueLocation();
        vResults.clear();
        vResults.add(selVenue);
        if (!selVenue.getNextVenues().isEmpty())
        {
          for (int i = 0; i < selVenue.getNextVenues().size(); i++) vResults.add(selVenue.getNextVenues().get(i));
        }
        setUpMarkers(vResults, selVenue);
        vMap.add(selVenue);
        vMapLocs.add(selLoc);
        
        mPMark = new SimplePointMarker(selLoc);
        mPMark.setColor(0);
        mPMark.setHighlightColor(127);
        mPMark.setStrokeColor(0);
        mPMark.setHighlightStrokeColor(127);
        mPMark.setStrokeWeight(10);
        vMapMarkers.add(mPMark);
        
        mapMarker = new SimpleLinesMarker(vMapLocs);
        mapMarker.setColor(color(127, 127));
        mapMarker.setHighlightColor(color(127, 127));
        mapMarker.setStrokeColor(color(127, 127));
        mapMarker.setHighlightStrokeColor(color(127, 127));
        mapMarker.setStrokeWeight(5);
        
        map.addMarkers(mapMarker);
        map.addMarkers(vMapMarkers);
      }
    }
  }
}

/********************************************************************************************************************************************************************************************************/

// set up markers for returned venues
// this method runs following a successful search for venues
void setUpMarkers(ArrayList<Venue> theVenues)
{
  Venue theVenue;
  Location vLoc;
  SimplePointMarker vPoint;
  map.getDefaultMarkerManager().clearMarkers();
  vLocs.clear();
  vMarkers.clear();
  vToNextVMarkers.clear();
  for (int i = 0; i < theVenues.size(); i++)
  {
    theVenue = theVenues.get(i);
    vLoc = theVenue.getVenueLocation();
    vLocs.add(vLoc);
    vPoint = new SimplePointMarker(vLoc);
    vPoint.setColor(markerColors[i % 11]);
    vPoint.setHighlightColor(127);
    vPoint.setStrokeColor(markerColors[i % 11]);
    vPoint.setHighlightStrokeColor(127);
    vPoint.setStrokeWeight(10);
    vMarkers.add(vPoint);
    
    theVenue.loadNextVenues((markerColors[i % 11] & 0xFFFFFF) | (63 << 24));
    map.addMarkers(theVenue.getNextVLineMarkers());
    map.addMarkers(theVenue.getNextVMarkers());
  }
  
  map.addMarkers(vMarkers);
  map.zoomAndPanToFit(vLocs);
}

/********************************************************************************************************************************************************************************************************/

// set up markers for returned venues
// this method runs when selecting a venue from the map
// line markers connect the selected venues together to form a mapping
void setUpMarkers(ArrayList<Venue> theVenues, Venue theOrigin)
{
  Venue theVenue;
  Location vLoc;
  SimplePointMarker vPoint;
  SimpleLinesMarker vLine;
  map.getDefaultMarkerManager().clearMarkers();
  vLocs.clear();
  vMarkers.clear();
  vToNextVMarkers.clear();
  
  vLoc = theOrigin.getVenueLocation();
  vLocs.add(vLoc);
  vPoint = new SimplePointMarker(vLoc);
  vPoint.setColor(0);
  vPoint.setHighlightColor(127);
  vPoint.setStrokeColor(0);
  vPoint.setHighlightStrokeColor(127);
  vPoint.setStrokeWeight(10);
  vMarkers.add(vPoint);
  
  for (int i = 1; i < theVenues.size(); i++)
  {
    theVenue = theVenues.get(i);
    vLoc = theVenue.getVenueLocation();
    vLocs.add(vLoc);
    
    vPoint = new SimplePointMarker(vLoc);
    vPoint.setColor(markerColors[(i - 1) % 11]);
    vPoint.setHighlightColor(127);
    vPoint.setStrokeColor(markerColors[(i - 1) % 11]);
    vPoint.setHighlightStrokeColor(127);
    vPoint.setStrokeWeight(10);
    vMarkers.add(vPoint);
    
    vLine = new SimpleLinesMarker(theOrigin.getVenueLocation(), vLoc);
    vLine.setColor((markerColors[(i - 1) % 11] & 0xFFFFFF) | (127 << 24));
    vLine.setHighlightColor((markerColors[(i - 1) % 11] & 0xFFFFFF) | (127 << 24));
    vLine.setStrokeColor((markerColors[(i - 1) % 11] & 0xFFFFFF) | (127 << 24));
    vLine.setHighlightStrokeColor((markerColors[(i - 1) % 11] & 0xFFFFFF) | (127 << 24));
    vLine.setStrokeWeight(5);
    vToNextVMarkers.add(vLine);
    
    theVenue.loadNextVenues((markerColors[(i - 1) % 11] & 0xFFFFFF) | (63 << 24));
    map.addMarkers(theVenue.getNextVLineMarkers());
    map.addMarkers(theVenue.getNextVMarkers());
  }
  
  map.addMarkers(vToNextVMarkers);
  map.addMarkers(vMarkers);
  map.zoomAndPanToFit(vLocs);
}

/********************************************************************************************************************************************************************************************************/

// set up markers when loading check-ins
void setUpCheckInMarkers(ArrayList<Venue> theVenues)
{
  Venue theVenue;
  Location vLoc;
  SimplePointMarker vPoint;
  map.getDefaultMarkerManager().clearMarkers();
  vLocs.clear();
  vMarkers.clear();
  vToNextVMarkers.clear();
  for (int i = 0; i < theVenues.size(); i++)
  {
    theVenue = theVenues.get(i);
    vLoc = theVenue.getVenueLocation();
    vLocs.add(vLoc);
    vPoint = new SimplePointMarker(vLoc);
    vPoint.setColor(markerColors[i % 11]);
    vPoint.setHighlightColor(127);
    vPoint.setStrokeColor(markerColors[i % 11]);
    vPoint.setHighlightStrokeColor(127);
    vPoint.setStrokeWeight(10);
    vMarkers.add(vPoint);
    
    // load and display the next visited venues of each of the next visited venues
    theVenue.loadNextVenues((markerColors[i % 11] & 0xFFFFFF) | (63 << 24));
    map.addMarkers(theVenue.getNextVLineMarkers());
    map.addMarkers(theVenue.getNextVMarkers());
  }
  
  map.addMarkers(vMarkers);
  map.zoomAndPanToFit(vLocs);
}

/********************************************************************************************************************************************************************************************************/

void mousePressed()
{
  loadNextVenues();
  theV.openListing(vResults);
  if (mode > 0)
  {
    if (mode == 2) theV.openWebsite(selVenue);
    photoViewMode = theV.openPhotos(vResults);
  }
}

/********************************************************************************************************************************************************************************************************/

// for retrieving time filter should one be selected
void controlEvent(ControlEvent theEvent)
{
  if (theEvent.isGroup())
  {
    if (theEvent.getGroup().getName() == "timeOp") timeRange = int(theEvent.getGroup().getValue());
  }
}
