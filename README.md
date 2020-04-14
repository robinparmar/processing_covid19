# processing_covid19
COVID-19 tracker

DESCRIPTION

This sketch maps current COVID-19 data.

Inspired by the Johns Hopkins University tracker:
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

The projection is slightly off, so compensation was made for the data points.
(Hack alert!)

DATA REPRESENTATION

The area of each circle indicates either:  
  a) deaths per capita
  b) deaths ranked relative to other regions

Toggle between the two representations with the spacebar.
