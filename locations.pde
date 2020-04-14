/*
	locations.pde
	Holds our classes, which represent data obtained from the API.
    REQUIRES global instance "places".

	JSON data is formatted as follows:

    {
        "latest":{"confirmed":1691719,"deaths":102525,"recovered":0},
        "locations":
        [
            {"id":0, "country":"Afghanistan", "country_code":"AF", "country_population":29121286,"province":"","last_updated":"2020-04-11T23:58:53.948258Z","coordinates":{"latitude":"33.0","longitude":"65.0"}, "latest":{"confirmed":521,"deaths":15,"recovered":0}},
            {"id":1, "country":"Albania", "country_code":"AL", "country_population":2986952,"province":"","last_updated":"2020-04-11T23:58:53.953610Z","coordinates":{"latitude":"41.1533","longitude":"20.1683"}, "latest":{"confirmed":416,"deaths":23,"recovered":0}},
            ...
        ]
    }
    
*/

// ---------------------
// collection of regions
class Locations {
    ArrayList<Location> loc = new ArrayList<Location>();
    float maxdeath;

    Locations() {
	    String url;

        if (LOCAL) {
            url = "covid.json";
        } else {
            url = "https://coronavirus-tracker-api.herokuapp.com/v2/locations";
        }
        
        parser(url);
        sizer();
    }

	// internal method: parses JSON data
    // returns maximum mortality across all countries
    private void parser(String url) {
        maxdeath = 0;

        JSONObject data = null;

        try {
	        data = loadJSONObject(url);
        } catch (NullPointerException e) {
            e.printStackTrace();
            noLoop();
            return;
        }
  
        JSONArray locations = data.getJSONArray("locations");
    
        for (int i=0; i<locations.size(); i++) {
            JSONObject place = locations.getJSONObject(i);
            
            String country = place.getString("country");
            String province = place.getString("province");
            
            int population;
            try {
                population = place.getInt("country_population");
            } catch (RuntimeException e) {
                // population can be the string "null", which is non-conforming
                // so we set a value that conforms to the data type
                population = -1;
            }
            
            JSONObject coordinates = place.getJSONObject("coordinates");
            float lat = float( coordinates.getString("latitude") );
            float lon = float( coordinates.getString("longitude") );

            JSONObject latest = place.getJSONObject("latest");
            int cases = latest.getInt("confirmed");
            int deaths = latest.getInt("deaths");

            loc.add( new Location(country, province, lat, lon, population, cases, deaths) );
            
            maxdeath = max(deaths, maxdeath);
        }
    }
       
    // calculate size of all circles
    void sizer() {
        for (Location l : loc) {
            l.sizer(maxdeath);
        }
    }

    // render all locations
    void render() {
        for (Location l : loc) {
            l.render();
        }
    }

    // location closest to the mouse pointer
    Location proximal() {
	    float minima = width;		// start with largest possible extent

        Location result = null;
        
        // check every location
        for (Location l : loc) {
            // distance to mouse pointer
            float d = dist(l.x, l.y, mouseX, mouseY);
			
			// mouse must be within a red circle
            if (d < l.r && d < minima) {
                // store new minimum value plus our instance
                minima = d;
                result = l;
            }
        }
        
        return result;
    }
    
    // how many locations?
    int size() {
        return loc.size(); 
    }    
}

// -----------------
// region on the map
class Location {
    // pixel position and circle radius
    float x, y, r;
    
    // various properties
    String country, province;
    int population;
    float cases, deaths;

	// a label created from other properties for display purposes
    String label;

	// constructor
    Location(String country_, String province_, float lat_, float lon_, int population_, int cases_, int deaths_) {
        country = country_;
        province = province_;
    	population = population_;
    	cases = float(cases_);
    	deaths = float(deaths_);

        makeLabel();

		// convert coordinates
		float[] temp = geo2map(lat_, lon_);

		// scale to map dimensions
        x = temp[0] * map.width;
        y = temp[1] * map.height;

        // HACK: compensate for map projection   
        x *= 1.01;
        x -= 20;
        y *= 0.89;
        y -= 180;        
	}

	// internal method that creates label string
    private void makeLabel() {
        float pop = population;
        String poptxt = "";
    
        // simplify population string
        if (population > 1000000) {
            pop = population / 1000000.;
            poptxt = String.format(" (pop. %.1f million)", pop);
        } else if (population > 1000) {
            pop = population / 1000.;
            poptxt = String.format(" (pop. %.1f thousand)", pop);
        } else if (population > 0) {
            poptxt = String.format(" (pop. %.1f)", pop);
        }
    
    	if (province.equals("")) {
            label = country + poptxt; 
        } else {
            label = String.format("%s, %s %s", province, country, poptxt); 
        }
         
        label += String.format(" %s deaths in %s cases", Commas(int(deaths)), Commas(int(cases)));        
    }

    // calculate size of all circles
    void sizer(float maxdeath) {
	    // represent mortality in terms of area of the circle
		float CONSTANT = 1.;

        // enforce minimum radius, so we can see the dots
		float MINIM = 4.;

		if (population == 0) {
    		// in case of bad data
    		r = 0;    
		} else if (PERCAPITA) {
            // use mortality per capita
            CONSTANT = 2000.;
            r = CONSTANT * sqrt(deaths / population);
        } else {
            // use ratio of maximum mortality
            CONSTANT = 60.;
            r = CONSTANT * sqrt(deaths / maxdeath);
        }

		// check avoids error: "returns NaN (not a number)"
		if (r>0) {
			r = map(r, 0., CONSTANT, MINIM, CONSTANT);
		}
    }

	// draw circle for each region
    void render() {       
        if (PERCAPITA) {
	        fill(RED);
        } else {
            fill(PURPLE);
	    }

        circle(x, y, r);
   }
   
   // provide label information on mouse hover
   void hover() {
       textFont(f);
       fill(BLACK);
       text(label, 500, 650);
   }
}

// -----------------
// utility functions

// convert latitude and longitude to position on a Web Mercator projection
float[] geo2map(float lat, float lon) {
    float x, y;
    
    lat = radians(lat);

    x = (lon + 180.) / 360.;
    y = 1 - (log( tan(lat) + 1/cos(lat) ) / PI);

	return new float[] {x, y};
}

// format a positive integer as a string with thousands separators
String Commas(int n) {
    String result = "";

    while (n > 1000) {
        result = String.format(",%03d", n%1000) + result;
        n /= 1000;
    }
    result = String.format("%3d", n) + result;
    
    return result.trim();
}
