//  Introduction to Processing by Robin Parmar. MIT License.

/*  LESSON T09: COVID-19 tracker

	DESCRIPTION
    	This sketch maps current COVID-19 data.
    
    	Inspired by the John Hopkins University tracker:
    		https://www.arcgis.com/apps/opsdashboard/index.html#/bda7594740fd40299423467b48e9ecf6

    	The code demonstrates:
        	* parsing of JSON data
        	* transforming geographical coordinates to a canvas
    		* tracking mouse position proximity to data points

	DATA SOURCES
		Data is obtained from the coronavirus tracker API:
			https://github.com/ExpDev07/coronavirus-tracker-api

	MAP SOURCE
    	Mercator Projection map obtained from here:
    		https://sv.wikipedia.org/wiki/Fil:Mercator_Projection.svg
    
    	Info on Spherical Mercator here: 
    		https://en.wikipedia.org/wiki/Web_Mercator_projection
        	http://docs.openlayers.org/library/spherical_mercator.html
        
        Coordinate conversion algorithm here:
            https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames
       
   		The projection is slightly off, so compensation was made for 
   		the data points. Yes, it's hacky!
   
   DATA REPRESENTATION
   		The area of each circle indicates either:  
   			a) deaths per capita
   			b) deaths ranked relative to other regions

   		Toggle between the two representations with the spacebar.
*/

// colour constants
int WHITE = 255;
int BLACK = 0;
int GREY = 200;
int RED = color(256, 0, 0, 80);
int PURPLE = color(256, 0, 120, 80);

// use local data?
boolean LOCAL = false;

// render in proportion to population?
boolean PERCAPITA = true;

PImage map;
PFont f, ff;

// current date stamp as a string
String now;

Locations places;

void setup() {
    // canvas is large enough for the map image plus a panel
    size(1200, 680);
    
    map = loadImage("map.png");  

    f = createFont("SourceSerifPro-Regular.ttf", 14);
    ff = createFont("SourceSerifPro-Bold.ttf", 18);
    noStroke();
    textAlign(LEFT);

	// this accesses data and does all parsing
	places = new Locations();

	// timestamp and confirmation
    now = String.format("at %d.%02d.%02d %02d:%02d", year(), month(), day(), hour(), minute());
    println("processed " + places.size() + " data points " + now);
}

void draw() {
    background(WHITE);
	image(map, 0, 0);

    captions();

    // red dots
    places.render();

    // context info
    if (mouseX<map.width && mouseY<map.height) {
        Location l = places.proximal();

        // required in case the mouse is not over a location
        if (l != null) {
            l.hover();
        }
    }
}

// display panel on the map
void captions() {
    String title;
    
    if (PERCAPITA) {
		title = "deaths per capita";
    } else {
        title = "relative ordering of regions";
    }

    fill(BLACK);
	textFont(ff);
    text("COVID-19 cumulative mortality", 500, 580);
    text(title, 500, 600);
    textFont(f);
    text(now, 500, 620);
    text("Tap spacebar to toggle modes.", 20, 630);
    text("Mouse over circles for info.", 20, 650);
}

void keyPressed() {
    // spacebar toggles mode
    if (key == ' ') {
        PERCAPITA = !PERCAPITA;
        places.sizer();
    }
}
