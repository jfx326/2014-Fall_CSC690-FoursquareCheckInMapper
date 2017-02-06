/* FoursquareCheckInMapper.pde - Final Project - Foursquare Check-In Mapper - Venue class
 *
 * Joseph Fernandez - 12/20/2014
 *
 * Constructs venues. Loads any remaining venue information, including a photo, website, and popular hours. Also loads next visited venues for this venue.
 */

class Venue
{
  private JSONLoader vjsl = new JSONLoader(); // has its own JSONLoader to automatically load venue info from JSON
  private Location loc; // location of venue
  private String[] add, // address information
                   vClientConfig = loadStrings("data/clientConfig.txt"); // client configuration
  private String id,
                 name,
                 phone,
                 website,
                 popHours, // popular hours to visit
                 photoURL, // URL of photo to display in results
                 listingURL, // foursquare listing URL
                 vAdjDate = adjustedDate(), // adjusted date - same as that of main
                 // client info - same as that of main
                 vcInfo = "client_id=" + vClientConfig[0] + "&client_secret=" + vClientConfig[1] + "&v=";
  private boolean popAM, // popular to visit in morning?
                  popDay, // afternoon?
                  popNight; // evening?
                  
  // data for probable next venues to be analyzed
  private ArrayList <Location> nextVLocs;
  private ArrayList <Marker> nextVMarkers;
  private ArrayList <Marker> nextVLineMarkers;
  private ArrayList <Venue> nextVenues;
  
  /********************************************************************************************************************************************************************************************************/
  
  Venue(String vId, String vName, String[] vAdd, Location vLoc)
  {
    id = vId;
    name = vName;
    add = vAdd;
    loc = vLoc;
    phone = website = photoURL = "";
    website = "";
    popHours = "24 Hours";
    listingURL = "https://foursquare.com/";
    popAM = false;
    popDay = false;
    popNight = false;
    nextVLocs = new ArrayList <Location>();
    nextVMarkers = new ArrayList <Marker>();
    nextVLineMarkers = new ArrayList <Marker>();
    nextVenues = new ArrayList <Venue>();
    loadVenueInfo();
  }
  
  /********************************************************************************************************************************************************************************************************/
  
  String getVenueID() {return id;}
  String getVenueName() {return name;}
  String[] getVenueAddress() {return add;}
  Location getVenueLocation() {return loc;}
  float getVenueLat() {return loc.getLat();}
  float getVenueLong() {return loc.getLon();}
  String getPhone() {return phone;}
  String getWebsite() {return website;}
  String getVenuePopHours() {return popHours;}
  String getPhotoURL() {return photoURL;}
  String getListingURL() {return listingURL;}
  boolean getPopAM() {return popAM;}
  boolean getPopDay() {return popDay;}
  boolean getPopNight() {return popNight;}
  
  ArrayList<Location> getNextVLocs() {return nextVLocs;}
  ArrayList<Marker> getNextVMarkers() {return nextVMarkers;}
  ArrayList<Marker> getNextVLineMarkers() {return nextVLineMarkers;}
  ArrayList<Venue> getNextVenues() {return nextVenues;}
  
  /********************************************************************************************************************************************************************************************************/
  
  // load the venues user visit next after this one
  // - these venues are essentially preloaded so the app can immediately laoded these venues as the next venues
  //   should this venue be selected on the map
  // - point and line markers connecting the next venues to this venue included
  void loadNextVenues(color markerColor)
  {
    JSONObject json = null;
    Location vLoc;
    SimplePointMarker vPoint;
    SimpleLinesMarker vLine;
    println("https://api.foursquare.com/v2/venues/" + id + "/nextvenues?" + vcInfo + vAdjDate + "&m=foursquare");
    try {json = loadJSONObject("https://api.foursquare.com/v2/venues/" + id + "/nextvenues?" + vcInfo + vAdjDate + "&m=foursquare");}
    catch (Exception e) {System.err.println("Error in retrieving JSON.");}
    if (json != null)
    {
      nextVenues = vjsl.loadNextVenues(json);
      if (!nextVenues.isEmpty())
      {
        for (int i = 0; i < nextVenues.size(); i++)
        {
          vLoc = nextVenues.get(i).getVenueLocation();
          nextVLocs.add(vLoc);
          
          vPoint = new SimplePointMarker(vLoc);
          vPoint.setColor(markerColor);
          vPoint.setHighlightColor(markerColor);
          vPoint.setStrokeColor(markerColor);
          vPoint.setHighlightStrokeColor(markerColor);
          vPoint.setStrokeWeight(5);
          nextVMarkers.add(vPoint);
          
          vLine = new SimpleLinesMarker(loc, vLoc);
          vLine.setColor(markerColor);
          vLine.setHighlightColor(markerColor);
          vLine.setStrokeColor(markerColor);
          vLine.setHighlightStrokeColor(markerColor);
          vLine.setStrokeWeight(2);
          nextVLineMarkers.add(vLine);
        }
      }
    }
  }
  
  /********************************************************************************************************************************************************************************************************/
  
  // load missing venue information - popular hours, website, photo
  // - this is a complete version of venue information compared to the "compact" info returned in searches
  private void loadVenueInfo()
  {
    JSONObject json = null, vInfo = null, vPhoto = null;
    JSONArray vPopHours = null;
    String hours = "";
    int code = 0, hour = 0, dash = 0;
    
    println("https://api.foursquare.com/v2/venues/" + id + "?" + vcInfo + vAdjDate + "&m=foursquare");
    try {json = loadJSONObject("https://api.foursquare.com/v2/venues/" + id + "?" + vcInfo + vAdjDate + "&m=foursquare");}
    catch (Exception e) {System.err.println("Error in retrieving JSON.");}
    if (json != null)
    {
      try {code = json.getJSONObject("meta").getInt("code");}
      catch (Exception e) {System.err.println("Unable to retrieve JSON response code.");}
      
      println("JSON Status: " + str(code));
      if (code == 200)
      {
        try
        {
          vInfo = json.getJSONObject("response").getJSONObject("venue");
          try {phone = vInfo.getJSONObject("contact").getString("formattedPhone");}
          catch (Exception e) {System.err.println(name + "'s phone number unavailable or not provided. Skipped.");}
          try {website = vInfo.getString("url");}
          catch (Exception e) {System.err.println(name + "'s website unavailable or not provided. Skipped.");}
          try {listingURL = vInfo.getString("canonicalUrl");}
          catch (Exception e) {System.err.println(name + "'s Foursquare listing unavailable or not provided. Skipped.");}
          try
          {
            vPhoto = vInfo.getJSONObject("photos").getJSONArray("groups").getJSONObject(0).getJSONArray("items").getJSONObject(0);
            if (loadImage(vPhoto.getString("prefix") + "cap100" + vPhoto.getString("suffix")) != null)
            {
              photoURL = vPhoto.getString("prefix") + "cap100" + vPhoto.getString("suffix");
            }
          }
          catch (Exception e) {System.err.println(name + "'s photos unavailable or not provided. Skipped.");}
          try
          {
            vPopHours = vInfo.getJSONObject("popular").getJSONArray("timeframes").getJSONObject(0).getJSONArray("open");
            for (int i = 0; i < vPopHours.size(); i++)
            {
              hours = vPopHours.getJSONObject(i).getString("renderedTime");
              println(hours);
              if (hours.contains("AM"))
              {
                popAM = true;
                println("Popular in AM? " + str(popAM));
              }
              if (hours.contains("PM"))
              {
                if (popAM) popDay = true;
                else
                {
                  hour = Character.getNumericValue(hours.charAt(0));
                  if ((hour >= 6 && hour <= 9) || (hour == 1 && hours.charAt(1) != ':')) popNight = true;
                  else popDay = true;
                }
                
                dash = hours.indexOf('–');
                hour = Character.getNumericValue(hours.charAt(dash + 1));
                if ((hour >= 6 && hour <= 9) || (hour == 1 && hours.charAt(dash + 2) != ':')) popNight = true;
                
                println("Popular in afternoon? " + str(popDay));
                println("Popular in evening? " + str(popNight));
              }
              if (i > 0) popHours = popHours + ", " + hours;
              else popHours = hours;
            }
          }
          catch (Exception e)
          {
            System.err.println("Unable to retrieve " + name + "'s popular hours or popular hours not provided.");
            popAM = popDay = popNight = true;
          }
        }
        catch (Exception e) {System.err.println("Unable to retrieve venue information for " + name + ".");}
      }
    }
  }
  
  /********************************************************************************************************************************************************************************************************/
  
  // formatted date for loading JSON
  private String adjustedDate()
  {
    String today = str(year());
    if (month() < 10) today += "0" + str(month());
    else today += str(month());
    if (day() < 10) today += "0" + str(day());
    else today += str(day());
    return today;
  }
}
