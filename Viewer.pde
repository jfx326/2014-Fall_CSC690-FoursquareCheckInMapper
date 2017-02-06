/* FoursquareCheckInMapper.pde - Final Project - Foursquare Check-In Mapper - Viewer class
 *
 * Joseph Fernandez - 12/20/2014
 *
 * Displays venue information - venue names, popular hours, addresses, websites, photos - on application.
 * Additionally, it checks whether or not the user clicked on a link to view either a selected venue's Foursquare listing or website, if available.
 * It also checks whether or not the user clicks on a photo in the venue information to view photos of the selected venue.
 */

class Viewer
{
  private JSONLoader pjsl = new JSONLoader(); // has its own JSONLoader to load venue photos from JSON on the fly
  private ArrayList <PImage> vPhotos;
  private PFont appfont,
                appfontbig;
  private String[] pClientConfig = loadStrings("data/clientConfig.txt"); // client configuration
  private String pAdjDate = adjustedDate(),
                 pcInfo = "client_id=" + pClientConfig[0] + "&client_secret=" + pClientConfig[1] + "&v=";
  // the following parameters are the same as that of the main
  private int appW, // app width
              appH, // app height
              mode, // 
              setResultsCap, // how many results to return and display
              setResultsLimit; // actual number of results to return and display
              // - the number is attained by comparing setResultsCap with number of returned venues
  
  /********************************************************************************************************************************************************************************************************/
  
  // constructor
  Viewer()
  {
    appfont = createFont("Arial", 12);
    appfontbig = createFont("Arial", 24);
    textFont(appfont);
    appW = 1280;
    appH = 720;
    setResultsCap = setResultsLimit = 5;
    vPhotos = new ArrayList <PImage>();
  }
  
  /********************************************************************************************************************************************************************************************************/
  
  Viewer(int dW, int dH, PFont theFont, PFont theBigFont, int resultsCap)
  {
    appfont = theFont;
    appfontbig = theBigFont;
    textFont(appfont);
    appW = dW;
    appH = dH;
    setResultsCap = setResultsLimit = resultsCap;
    vPhotos = new ArrayList <PImage>();
  }
  
  /********************************************************************************************************************************************************************************************************/
  
  // displays only welcome message
  void drawViewer()
  {
    fill(255);
    textFont(appfontbig);
    text("Welcome!", appW - 375, 5, 370, 30);
    textFont(appfont);
    text("Start by searching for venues." +
         "\n\nTo search, enter what you want to look for (i.e. malls, restaurants, SFSU) in \"Find...,\"" +
         "enter where you want to look for (i.e. city, town, San Francisco) in \"Near...,\" and press Enter/Return or click \"Search.\"" +
         "\n\nYou can also just enter where you want to look for." + 
         "\n\nYou can limit your search results according to popular visiting hours by selecting from the drop-down list." +
         "\n\nSelect a marked venue from the map to view venue information and the venues that people go after the venue you selected." +
         "\n\nFrom there, you can view venue photos and more information on your browser by clicking on the results displayed here." +
         "\n\nYou can log into your Foursquare/Swarm account to view and map your recent check-ins!", appW - 375, 29, 370, appH - 100);
  }
  
  /********************************************************************************************************************************************************************************************************/
  
  // displays text messages according to mode
  // mode = -1 -> no results found, so display "no results found," then ask to search again
  // mode = 0 -> same as argument-less drawViewer above (the "default")
  void drawViewer(int appMode)
  {
    mode = appMode;
    fill(255);
    if (appMode == -1)
    {
      textFont(appfontbig);
      text("Search Results", appW - 375, 5, 370, 30);
      textFont(appfont);
      text("No results found.\nPlease search again." +
           "\n\nTo search, enter what you want to look for (i.e. malls, restaurants, SFSU) in \"Find...,\"" +
           "enter where you want to look for (i.e. city, town, San Francisco) in \"Near...,\" and press Enter/Return or click \"Search.\"" +
           "\n\nYou can also just enter where you want to look for." + 
           "\n\nYou can limit your search results according to popular visiting hours by selecting from the drop-down list." +
           "\n\nSelect a marked venue from the map to view venue information and the venues that people go after the venue you selected." +
           "\n\nFrom there, you can view venue photos and more information on your browser by clicking on the results displayed here." +
           "\n\nYou can log into your Foursquare/Swarm account to view and map your recent check-ins!", appW - 375, 29, 370, appH - 100);
    }
    else
    {
      textFont(appfontbig);
      text("Welcome!", appW - 375, 5, 370, 30);
      textFont(appfont);
      text("Start by searching for venues." +
           "\n\nTo search, enter what you want to look for (i.e. malls, restaurants, SFSU) in \"Find...,\"" +
           "enter where you want to look for (i.e. city, town, San Francisco) in \"Near...,\" and press Enter/Return or click \"Search.\"" +
           "\n\nYou can also just enter where you want to look for." + 
           "\n\nYou can limit your search results according to popular visiting hours by selecting from the drop-down list." +
           "\n\nSelect a marked venue from the map to view venue information and the venues that people go after the venue you selected." +
           "\n\nFrom there, you can view venue photos and more information on your browser by clicking on the results displayed here." +
           "\n\nYou can log into your Foursquare/Swarm account to view and map your recent check-ins!", appW - 375, 29, 370, appH - 100);
    }
  }
  
  /********************************************************************************************************************************************************************************************************/
  
  // displays venue information - this is run following a successful search for venues
  void drawViewer(ArrayList<Venue> vResults)
  {
    mode = 1;
    textFont(appfontbig);
    text("Search Results", appW - 375, 5, 315, 30);
    textFont(appfont);
    if (setResultsCap > vResults.size()) setResultsLimit = vResults.size();
    for (int i = 0; i < setResultsLimit; i++)
    {
      fill(markerColors[i % 11]);
      stroke(255);
      ellipse(appW - 390, 38 + (75 * i), 12, 12);
      fill(255);
      text(vResults.get(i).getVenueName(), appW - 375, 29 + (75 * i), 315, 15);
      if (!vResults.get(i).getPhotoURL().isEmpty()) {image(loadImage(vResults.get(i).getPhotoURL()), appW - 55, 29 + (75 * i), 50, 50);}
      text("Popular Hours: " + vResults.get(i).getVenuePopHours(), appW - 375, 41 + (75 * i), 315, 15);
      for (int j = 0; j < vResults.get(i).getVenueAddress().length; j++) {text(vResults.get(i).getVenueAddress()[j], appW - 375, 53 + (75 * i) + (12 * j), 315, 15);}
    }
    setResultsLimit = 5; // in case of new search, reset limit (otherwise, fewer results accidentally returned)
  }
  
  /********************************************************************************************************************************************************************************************************/
  
  // displays venue information - this is run following selecting a venue from the map and loading the set of next visited venues
  void drawViewer(Venue selVenue, ArrayList<Venue> vResults)
  {
    mode = 2;
    
    // view information of selected venue
    textFont(appfontbig);
    text("Selected Venue", appW - 375, 5, 315, 30);
    textFont(appfont);
    fill(0);
    stroke(255);
    ellipse(appW - 390, 38, 12, 12);
    fill(255);
    text(selVenue.getVenueName(), appW - 375, 29, 315, 15);
    if (!selVenue.getPhotoURL().isEmpty()) image(loadImage(selVenue.getPhotoURL()), appW - 55, 29, 50, 50);
    text("Popular Hours: " + selVenue.getVenuePopHours(), appW - 375, 41, 315, 15);
    for (int j = 0; j < selVenue.getVenueAddress().length; j++) {text(selVenue.getVenueAddress()[j], appW - 375, 53 + (12 * j), 315, 15);}
    if (!selVenue.getPhone().isEmpty()) {text("Phone: " + selVenue.getPhone(), appW - 375, 89, 315, 15);}
    if (!selVenue.getWebsite().isEmpty()) {text("Website: " + selVenue.getWebsite(), appW - 375, 101, 315, 15);}
    
    // view information of next visited venues
    textFont(appfontbig);
    text("Venues Visited Next", appW - 375, 125, 315, 30);
    textFont(appfont);
    
    // the size of the results is one more because the selected venue is also added
    // - the addition is for ensuring that the selected venue is displayed on the map along with the next visited venues
    if (setResultsCap + 1 > vResults.size()) setResultsLimit = vResults.size();
    else setResultsLimit += 1;
    if (setResultsLimit == 1) // no next venues
    {
      text("No results found.\nPlease search again." +
           "\n\nTo search, enter what you want to look for (i.e. malls, restaurants, SFSU) in \"Find...,\"" +
           "enter where you want to look for (i.e. city, town, San Francisco) in \"Near...,\" and press Enter/Return or click \"Search.\"" +
           "\n\nYou can also just enter where you want to look for." + 
           "\n\nYou can limit your search results according to popular visiting hours by selecting from the drop-down list." +
           "\n\nSelect a marked venue from the map to view venue information and the venues that people go after the venue you selected." +
           "\n\nFrom there, you can view venue photos and more information on your browser by clicking on the results displayed here." +
           "\n\nYou can log into your Foursquare/Swarm account to view and map your recent check-ins!", appW - 375, 149, 370, appH - 270);
    }
    // display info of next visited venues
    else
    {
      for (int i = 1; i < setResultsLimit; i++)
      {
        fill(markerColors[(i - 1) % 11]);
        stroke(255);
        ellipse(appW - 390, 158 + (75 * (i - 1)), 12, 12);
        fill(255);
        text(vResults.get(i).getVenueName(), appW - 375, 149 + (75 * (i - 1)), 315, 15);
        if (!vResults.get(i).getPhotoURL().isEmpty()) {image(loadImage(vResults.get(i).getPhotoURL()), appW - 55, 149 + (75 * (i - 1)), 50, 50);}
        text("Popular Hours: " + vResults.get(i).getVenuePopHours(), appW - 375, 161 + (75 * (i - 1)), 315, 15);
        for (int j = 0; j < vResults.get(i).getVenueAddress().length; j++) {text(vResults.get(i).getVenueAddress()[j], appW - 375, 173 + (75 * (i - 1)) + (12 * j), 315, 15);}
      }
    }
    setResultsLimit = 5; // in case of new search, reset limit (otherwise, fewer results accidentally returned)
  }
  
  /********************************************************************************************************************************************************************************************************/
  
  // display photos in place of map on app
  void viewPhotos()
  {
    PImage photo;
    float aRatio;
    imageMode(CENTER);
    for (int i = 0; i < 2; i++)
    {
      for (int j = 0; j < 3; j++)
      {
        photo = vPhotos.get((3 * i) + j);
        aRatio = photo.width / photo.height; // aspect ratio correction
        if (aRatio > 1.0) image(photo, 160 + (j * 270), 165 + (i * 270), 250, (float)(250 / aRatio));
        else if (aRatio < 1.0) image(photo, 160 + (j * 270), 165 + (i * 270), (float)(250 * aRatio), 250); 
        else image(photo, 160 + (j * 270), 165 + (i * 270), 250, 250);
      }
    }
    imageMode(CORNER);
  }
  
  /********************************************************************************************************************************************************************************************************/
  
  // Did user click on venue photo beside the information on the venue to display the photos?
  boolean openPhotos(ArrayList<Venue> vR)
  {
    Venue theVenue;
    if (mode == 1)
    {
      for (int i = 0; i < vR.size(); i++)
      {
        theVenue = vR.get(i);
        if (!theVenue.getPhotoURL().isEmpty() && mouseX >= appW - 55 && mouseX <= appW - 5 && mouseY >= 29 + (75 * i) && mouseY <= 79 + (75 * i))
        {
          loadVenuePhotos(theVenue.getVenueID());
          return true;
        }
      }
    }
    else if (mode == 2)
    {
      theVenue = vR.get(0);
      if (!theVenue.getPhotoURL().isEmpty() && mouseX >= appW - 55 && mouseX <= appW - 5 && mouseY >= 29 && mouseY <= 79)
      {
        loadVenuePhotos(theVenue.getVenueID());
        return true;
      }
      for (int i = 1; i < vR.size(); i++)
      {
        theVenue = vR.get(i);
        if (!theVenue.getPhotoURL().isEmpty() && mouseX >= appW - 55 && mouseX <= appW - 5 && mouseY >= 149 + (75 * (i - 1)) && mouseY <= 199 + (75 * (i - 1)))
        {
          loadVenuePhotos(theVenue.getVenueID());
          return true;
        }
      }
    }
    return false;
  }
  
  /********************************************************************************************************************************************************************************************************/
  
  private void loadVenuePhotos(String id)
  {
    JSONObject json = null;
    println("https://api.foursquare.com/v2/venues/" + id + "/photos?" + "limit=12&" + pcInfo + pAdjDate + "&m=foursquare");
    try {json = loadJSONObject("https://api.foursquare.com/v2/venues/" + id + "/photos?" + "limit=24&" + pcInfo + pAdjDate + "&m=foursquare");}
    catch (Exception e) {System.err.println("Error in retrieving JSON.");}
    if (json != null) vPhotos = pjsl.loadVenuePhotos(json);
  }
  
  /********************************************************************************************************************************************************************************************************/
  
  // Did user click on the text area of venue information to view info of the venue on Foursquare?
  void openListing(ArrayList<Venue> vR)
  {
    String listing;
    if (mode == 1)
    {
      for (int i = 0; i < vR.size(); i++)
      {
        listing = vR.get(i).getListingURL();
        if (!listing.isEmpty() && mouseX >= appW - 375 && mouseX <= appW - 60 && mouseY >= 29 + (75 * i) && mouseY <= 79 + (75 * i)) link(listing);
      }
    }
    else if (mode == 2)
    {
      listing = vR.get(0).getListingURL();
      if (!listing.isEmpty() && mouseX >= appW - 375 && mouseX <= appW - 60 && mouseY >= 29 && mouseY < 101) link(listing);
      for (int i = 1; i < vR.size(); i++)
      {
        listing = vR.get(i).getListingURL();
        if (!listing.isEmpty() && mouseX >= appW - 375 && mouseX <= appW - 60 && mouseY >= 149 + (75 * (i - 1)) && mouseY <= 199 + (75 * (i - 1))) link(listing);
      }
    }
  }
  
  /********************************************************************************************************************************************************************************************************/
  
  // Did user click on the selected venue's website to view the venue's website?
  void openWebsite(Venue selVenue)
  {
    String website;
    if (mode == 2)
    {
      website = selVenue.getWebsite();
      if (!website.isEmpty() && mouseX >= appW - 375 && mouseX <= appW - 60 && mouseY >= 101 && mouseY <= 113) link(website);
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
