/* FoursquareCheckInMapper.pde - Final Project - Foursquare Check-In Mapper - OAuthManager class
 *
 * Joseph Fernandez - 12/20/2014
 *
 * Manages and eases the OAuth process for logging into Foursquare.
 * Uses the API wrapper Temboo.
 */

class OAuthManager
{
  private TembooSession ts;
  private String[] tc = loadStrings("data/tembooConfig.txt"), // Temboo session configuration
                   cc = loadStrings("data/clientConfig.txt"); // client configuration
  private String cid, // client ID
                 cs, // client secret
                 furl, // forwarding URL (where to redirect when login is successful)
                 aL, // authorization link for logging in
                 cbid, // callback ID to check login procedure
                 aT; // access token
  
  // constructor
  OAuthManager()
  {
    ts = new TembooSession(tc[0], tc[1], tc[2]);
    cid = cc[0];
    cs = cc[1];
    furl = "https://foursquare.com/";
  }
  
  /********************************************************************************************************************************************************************************************************/
  
  // starts the OAuth process
  // returns an authorization link for the user to login when successful
  void initializeOAuth()
  {
    InitializeOAuth iOAuth = new InitializeOAuth(ts);
    
    iOAuth.setClientID(cid);
    iOAuth.setForwardingURL(furl);
    InitializeOAuthResultSet iOAuthResult = iOAuth.run();
    aL = iOAuthResult.getAuthorizationURL();
    cbid = iOAuthResult.getCallbackID();
    
    println("Authorization URL: " + aL);
    println("Callback ID: " + cbid);
    link(aL);
  }
  
  /********************************************************************************************************************************************************************************************************/
  
  // finishes the OAuth process
  // returns the access token for utilizing login-required APIs
  String finalizeOAuth()
  {
    FinalizeOAuth fOAuth = new FinalizeOAuth(ts);
    
    fOAuth.setCallbackID(cbid);
    fOAuth.setClientSecret(cs);
    fOAuth.setClientID(cid);
    FinalizeOAuthResultSet fOAuthResult = fOAuth.run();
    aT = fOAuthResult.getAccessToken();
    println("Token: " + aT);
    return aT;
  }
}
