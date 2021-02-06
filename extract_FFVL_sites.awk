#!/usr/bin/awk -f
#
# This script converts a .csv file generated from
#
#   http://federation.ffvl.fr/search/sites
#
# and puts it in the appropriate format for Garmin's POILoader program.  The
# description of POILoader's .csv format is available at
#
#   http://www8.garmin.com/products/poiloader/creating_custom_poi_files.jsp

BEGIN {

  # The fields in the output .csv file from the FFVL website are separated
  # by a semicolumn, so make this the field separator.
  FS = ";"

}

{

  if (NR != 1) { # We don't need the first line with the column headers.

    # Uncomment this if you want comments.
    #printf("%8.5f,%8.5f,\"%s (%s, %dm, %s)\",\"%s %s\"\n", 
    #        $4, $3, $2, $8, $5, $6, $16, $17)

    # Uncomment this if you don't want comments.
    printf("%8.5f,%8.5f,\"%s (%s, %dm, %s)\"\n", $4, $3, $2, $8, $5, $6)

  }

}
