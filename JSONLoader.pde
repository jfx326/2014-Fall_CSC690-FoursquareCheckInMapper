/* FoursquareCheckInMapper.pde - Final Project - Foursquare Check-In Mapper - JSON Loader class
 *
 * Joseph Fernandez - 12/20/2014
 *
 * Helps load JSON files to return array lists of venues based on given JSON files and other file data.
 */

class JSONLoader
{ 
  // constructor
  JSONLoader(){;}
  
  /********************************************************************************************************************************************************************************************************/
  
  ArrayList<Venue> loadCheckIns(JSONObject theJSON)
  {
    Location vLoc = null;
    JSONArray items = null;
    JSONObject checkIns = null,
               vInfo = null,
               vLocation = null;
    String vId = null,
           vName = "Unnamed Venue";
    String[] vAdd;
    int code = 0;
    ArrayList<Venue> vR = new ArrayList<Venue>();
    
    try {code = theJSON.getJSONObject("meta").getInt("code");}
    catch (Exception e) {System.err.println("Unable to retrieve JSON response code.");}
    
    println("JSON Status: " + str(code));
    if (code != 200) {return vR;}
    else
    {
      try
      {
        checkIns = theJSON.getJSONObject("response").getJSONObject("checkins");
        if (checkIns.getInt("count") > 0)
        {
          try
          {
            items = checkIns.getJSONArray("items");
            for (int i = 0; i < items.size(); i++)
            {
              try
              {
                vInfo = items.getJSONObject(i).getJSONObject("venue");
                vLocation = vInfo.getJSONObject("location");
                vId = vInfo.getString("id");
                try {vName = vInfo.getString("name");}
                catch (Exception e) {System.err.println("Venue " + i + " name does not exist. Skipped..");}
                try {vAdd = vLocation.getJSONArray("formattedAddress").getStringArray();}
                catch (Exception e)
                {
                  System.err.println("Venue " + i + " address information does not exist. Skipped..");
                  vAdd = new String[1];
                  vAdd[0] = "Unknown Address";
                }
                try
                {
                  vLoc = new Location(vLocation.getFloat("lat"), vLocation.getFloat("lng"));
                  vR.add(new Venue(vId, vName, vAdd, vLoc));
                }
                catch (Exception e) {System.err.println("Venue " + i + " coordinates do not exist. Skipped..");}
              }
              catch (Exception e) {System.err.println("Insufficient venue " + i + " information. Skipped..");}
            }
          }
          catch (Exception e) {System.err.println("Venue list does not exist. No venue results loaded and displayed.");}
        }
      }
      catch (Exception e) {System.err.println("List of next venues does not exist. No venue results loaded and displayed.");}
      return vR;
    }
  }
  
  /********************************************************************************************************************************************************************************************************/
  
  ArrayList<Venue> loadSearchResults(JSONObject theJSON)
  {
    Location vLoc = null;
    JSONArray items = null;
    JSONObject vInfo = null,
               vLocation = null;
    String vId = null,
           vName = "Unnamed Venue";
    String[] vAdd;
    int code = 0;
    ArrayList<Venue> vR = new ArrayList<Venue>();
    
    try {code = theJSON.getJSONObject("meta").getInt("code");}
    catch (Exception e) {System.err.println("Unable to retrieve JSON response code.");}
    
    println("JSON Status: " + str(code));
    if (code != 200) {return vR;}
    else
    {
      if (theJSON.getJSONObject("response").getInt("totalResults") > 0)
      {
        try
        {
          items = theJSON.getJSONObject("response").getJSONArray("groups").getJSONObject(0).getJSONArray("items");
          for (int i = 0; i < items.size(); i++)
          {
            try
            {
              vInfo = items.getJSONObject(i).getJSONObject("venue");
              vLocation = vInfo.getJSONObject("location");
              vId = vInfo.getString("id");
              try {vName = vInfo.getString("name");}
              catch (Exception e) {System.err.println("Venue " + i + " name does not exist. Skipped..");}
              
              try {vAdd = vLocation.getJSONArray("formattedAddress").getStringArray();}
              catch (Exception e)
              {
                System.err.println("Venue " + i + " address information does not exist. Skipped..");
                vAdd = new String[1];
                vAdd[0] = "Unknown Address";
              }
              try
              {
                vLoc = new Location(vLocation.getFloat("lat"), vLocation.getFloat("lng"));
                vR.add(new Venue(vId, vName, vAdd, vLoc));
              }
              catch (Exception e) {System.err.println("Venue " + i + " coordinates do not exist. Skipped..");}
            }
            catch (Exception e) {System.err.println("Insufficient venue " + i + " information. Skipped..");}
          }
        }
        catch (Exception e) {System.err.println("Venue list does not exist. No venue results loaded and displayed.");}
      }
      return vR;
    }
  }
  
  /********************************************************************************************************************************************************************************************************/
  
  ArrayList<Venue> loadNextVenues(JSONObject theJSON)
  {
    Location vLoc = null;
    JSONArray items = null;
    JSONObject nextV = null,
               vInfo = null,
               vLocation = null;
    String vId = null,
           vName = "Unnamed Venue";
    String[] vAdd;
    int code = 0;
    ArrayList<Venue> vR = new ArrayList<Venue>();
    
    try {code = theJSON.getJSONObject("meta").getInt("code");}
    catch (Exception e) {System.err.println("Unable to retrieve JSON response code.");}
    
    println("JSON Status: " + str(code));
    if (code != 200) {return vR;}
    else
    {
      try
      {
        nextV = theJSON.getJSONObject("response").getJSONObject("nextVenues");
        if (nextV.getInt("count") > 0)
        {
          try
          {
            items = nextV.getJSONArray("items");
            for (int i = 0; i < items.size(); i++)
            {
              try
              {
                vInfo = items.getJSONObject(i);
                vLocation = vInfo.getJSONObject("location");
                vId = vInfo.getString("id");
                try {vName = vInfo.getString("name");}
                catch (Exception e) {System.err.println("Venue " + i + " name does not exist. Skipped..");}
                
                try {vAdd = vLocation.getJSONArray("formattedAddress").getStringArray();}
                catch (Exception e)
                {
                  System.err.println("Venue " + i + " address information does not exist. Skipped..");
                  vAdd = new String[1];
                  vAdd[0] = "Unknown Address";
                }
                try
                {
                  vLoc = new Location(vLocation.getFloat("lat"), vLocation.getFloat("lng"));
                  vR.add(new Venue(vId, vName, vAdd, vLoc));
                }
                catch (Exception e) {System.err.println("Venue " + i + " coordinates do not exist. Skipped..");}
              }
              catch (Exception e) {System.err.println("Insufficient venue " + i + " information. Skipped..");}
            }
          }
          catch (Exception e) {System.err.println("Venue list does not exist. No venue results loaded and displayed.");}
        }
      }
      catch (Exception e) {System.err.println("List of next venues does not exist. No venue results loaded and displayed.");}
      return vR;
    }
  }
  
  /********************************************************************************************************************************************************************************************************/
  
  ArrayList<PImage> loadVenuePhotos(JSONObject theJSON)
  {
    JSONArray items = null;
    JSONObject photos = null;
    int code = 0;
    ArrayList<PImage> vP = new ArrayList<PImage>();
    PImage vPhoto;
    
    try {code = theJSON.getJSONObject("meta").getInt("code");}
    catch (Exception e) {System.err.println("Unable to retrieve JSON response code.");}
    
    println("JSON Status: " + str(code));
    if (code != 200) {return vP;}
    else
    {
      try
      {
        photos = theJSON.getJSONObject("response").getJSONObject("photos");
        if (photos.getInt("count") > 0)
        items = photos.getJSONArray("items");
        for (int i = 0; i < items.size(); i++)
        {
          try
          {
            vPhoto = loadImage(items.getJSONObject(i).getString("prefix") + "cap300" + items.getJSONObject(i).getString("suffix"));
            if (vPhoto != null) vP.add(vPhoto);
          }
          catch (Exception e) {System.err.println("This photo is unavailable or invalid. Skipped.");}
        }
      }
      catch (Exception e) {System.err.println("Venue photos do not exist.");}
      return vP;
    }
  }
}
