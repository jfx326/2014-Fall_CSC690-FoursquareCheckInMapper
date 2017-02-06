Foursquare Check-in Mapper
By Joseph Fernandez
Under the guidance of Dr. William Hsu

A final project at San Francisco State University's CSC690 -
Interactive Multimedia Application Development class.

FoursquareCheckInMapper.pde

Description:

The Foursquare Check-in Mapper is a simple app that connects venues (locations)
to the venues that people most often visit next, according to the check-ins of
Foursquare and Swarm (Foursquare's accompanying check-in app) users, visually
on a map. The app's basic purpose is to analyze the traveling habits and
inclinations of people who visit a particular location — where they typically go
after visiting the aforementioned location in question. Additionally, the app
allows Foursquare and Swarm users to map their own traveling habits and inclinations
based on their recent check-ins. The app also displays basic information of
each venue, such as the venue's name, address, website, total number of likes,
total number of check-ins, and photos upon searching the venue or selecting
the venue from the map.

Requirements:

Windows, Mac OS
Processing 2.0
- Download at https://processing.org/download/
An Internet connection

Required Libraries:

Unfolding
- Download at http://unfoldingmaps.org/
controlP5
- Download at http://www.sojamo.de/libraries/controlP5/
Temboo
- Download at https://temboo.com/download

Please follow the documentation provided with each library to install each of
the required libraries. Generally, the libraries come archived (as a ZIP or similar),
so they just need to be unzipped and moved to the "libraries" folder of your
Processing folder.

How to use:

Once opened via Processing, begin with searching for a shop, a business,
a restaurant, or any other landmark and the location for where to locate
the landmark (San Francisco, San Jose, Toronto) by entering them respectively
in the text fields on the bottom of the application. Enter the landmark or business,
specific or not, under "Find...," and enter the location under "Near..."
Click "Search" or press Enter/Return in either text field to begin searching.

Only the location needs to be entered to start searching.

You can filter searches by popular hours by selecting one of the options in the
"Popular Hours" dropdown list.

After a successful search, the application will return and display the results
on the provided map, plus information for each venue on the right side of the
application. Each resulting location is color-coded to denote which location
corresponds to which location information and vice-versa.

From here (and from any other main operation on the application):
- You can start a new search.
- Click on one of the marked locations on the map to view expanded information
  on the venue and a new set of results representing the locations most often
  visited following the selected location on the map.
- Click on one of the location's information on the right side to view the
  location's listing on Foursquare.
- When provided, click on the photo that accompanies each of the location's
  information on the right side to view photos of the corresponding location.
- Clear the map.
- Log in to Foursquare to map your recent check-ins.
- Close the application.

When you select one of the marked locations on the map, the map will be updated
with the selected location marked in black and a lines that connect to each
of the resulting set of next-visited locations, as well as the next-visited
locations of each location of the first set of next-visited locations. From here,
you can do any of the possible steps above.

Selecting subsequent locations will create a "map" starting from the first selected
location to the recently selected location, marked and lined in black.

Once you created such a "map," click the "Zoom to Current Mapping" button to zoom
and pan the map to display and fit the mapped locations.

Also, should the website of the selected location be provided, you can click on
the website to view the website in your default Internet browser.

To log in, you must, of course, have a Foursquare/Swarm account. Logging in takes
three easy steps:

1. Click on the "Log In" button to open your default Internet browser and log in
   to Foursquare.
2. Once logged in, if you have not authorized this application before, then
   you will be prompted to authorize. Authorize the app, and you will be redirected
   to Foursquare's home page, signaling success. If you have authorized the
   application already, then you will be redirected to the home page right away.
3. Return to the application, and click on "Confirm Authorization" (in place of
   "Log In") to confirm authorization. Your recent check-ins will be loaded and
   mapped momentarily.

When viewing recent check-ins, each check-in will be mapped to each other from
most recently visited to the least recently visited. On the map, the marked
check-in locations will be connected accordingly with black lines. The information
corresponding to each check-in on the right side of the application will list
the check-ins in the same fashion with the results on the top denoting the most
recent check-ins and the bottom the least recent check-ins. From here, you can
do any of the above operations above.

While you're logged in, clicking on the "View Check-ins" button will display again
your most recent check-ins, in case they're cleared for entering another search
or performing any of the aforementioned operations above.

When viewing photos, click anywhere or perform another operation to display
the map again.