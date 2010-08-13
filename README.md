New Zealand Historic Places Register Scraper
============================================

Scrapes the NZ Historic Places register from http://www.historic.org.nz/register.html and produces a JSON data file.

This is a Ruby implementation of Rob Coup's Python version here - http://code.google.com/p/nz-geodata-scripts/wiki/HistoricPlaces. It has been updated to use the new format of the historic places register html.

Please be considerate of their site.

Requirements
------------

Ruby
HTTParty for fetching the data
Nokogiri for parsing the HTML
Proj for converting NZMG to WGS84 - http://trac.osgeo.org/proj/
Python if you want to tidy the json output

In addition, the script has only been tested/run under Mac OSX.

Documentation
-------------

Check out the source:

git clone http://github.com/opennewzealand/historic_places.git

There are several Rake tasks

### download_records

Downloads the records from the website and places them into a folder called raw. We cache all records locally so we do not hit the server constantly.

### list_attributes

This looks at the cache and searches for any fields in the HTML that may contain content. Good to check periodically to see if we have any missing ones.
 
### json:all_from_cache

Writes out a file all.json with the data in json format.

### json:single_from_cache

Writes out a single json formatted record from the cache.
