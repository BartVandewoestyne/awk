#!/usr/bin/awk -f
#
# This awk script reduces a data-file of the following format...
#
#  <x_value1> <y_value1,1> <y_value1,2> ...
#  <x_value2> <y_value2,1> <y_value1,2> ...
#  <x_value3> <y_value3,1> <y_value1,2> ...
#     ...        ...           ...      ...
#
# for example:
#
#      2 1.39E-01 3.45E-01
#      3 1.62E-01 5.24E-01
#      4 1.16E-01 7.23E-01
#      ...
#
# ... to a much smaller data-file that is plotted exactly the same as the
# original data-file.  The new data-file should be plotted with gnuplot
# to an EPS-file (set terminal postscript eps enhanced) with a certain
# scale (set size <gnuplot_x_scale>,<gnuplot_y_scale>) and in a LOGLOG graph.
# The user must also specify how much dpi the final plot should be.
#
# Run this script as:
#
#  ./reduce.awk mydata.dat <dpi> <gnuplot_x_scale> <gnuplot_y_scale> <x_start> <x_end> <y_start> <y_end> > mydata_reduced.dat
#
#
# Written by Bart Vandewoestyne <Bart.Vandewoestyne OOPSIEWOOPSIE telenet.be>
#
# TODO:
#
#   * gnuplot_std_width and gnuplot_std_height are the width and height
#     of the *complete* EPS-figure.  The actual drawing area (and thus the
#     amount of dots used for plotting the data) is less.  If we can find
#     a way to get the width and height of the *actual* drawing area, this
#     would allow us to make the reduced data set and the resulting .eps
#     even smaller in size...

BEGIN {

  if (ARGC < 9) {
    print "ERROR: Not enough input parameters!"
    print
    print "Usage: ./reduce.awk mydata.dat <dpi> <gnuplot_x_scale> <gnuplot_y_scale> <x_start> <x_end> <y_start> <y_end> > mydata_reduced.dat"
  }

  # ARGV[0] = awk
  # ARGV[1] = mydata.dat

  dpi = ARGV[2];                # the resolution the user wants
  gnuplot_x_scale = ARGV[3];    # the X-scale applied in the gnuplot script
                                # with the `set size <xscale>,<yscale>' command
  gnuplot_y_scale = ARGV[4];    # the Y-scale applied in the gnuplot script
                                # with the `set size <xscale>,<yscale>' command
  x_start = ARGV[5];            # starting X-value on the plot
  x_end = ARGV[6];              # ending X-value on the plot
  y_start = ARGV[7];            # starting Y-value on the plot
  y_end = ARGV[8];              # ending Y-value on the plot

  # We don't want to process the extra parameters as files... so after we got
  # them, we set them to the NULL string.
  for (i=2; i<=8; i++) {
    ARGV[i] = ""
  }

  # CONSTANTS
  gnuplot_std_width = 360;      # standard gnuplot width in PostScript dots
                                # for terminal `postscript eps enhanced'
  gnuplot_std_height = 252;     # standard gnuplot height in PostScript dots
                                # for terminal `postscript eps enhanced'

  # calculate real width and height in dots of the resulting .eps file
  # (1 PostScript point = 1/72 inches)
  nb_x_dots = int(gnuplot_std_width*gnuplot_x_scale/72*dpi + 0.5);
  nb_y_dots = int(gnuplot_std_height*gnuplot_y_scale/72*dpi + 0.5);

  # Some constants we're going to need during our algorithm...
  log10_width = (log(x_end) - log(x_start))/log(10);
  log10_height = (log(y_end) - log(y_start))/log(10);
  log10_x_start = log(x_start)/log(10);
  log10_x_end = log(x_end)/log(10);
  indexfactor_x = nb_x_dots/log10_width
  indexfactor_y = nb_y_dots/log10_height

  # initialize the two-dimensional array that will keep track of the already
  # plotted dots.
  for (i = 0; i < nb_x_dots; i++) {
    for (j = 0; j < nb_y_dots; j++) {
      picture[i, j] = 0;
    }
  }

  # There are no points in our picture yet...
  nb_new_datapoints = 0;

}

{
  # Get X value and its base 10 logarithm from the first column in the data file
  x = $1;
  log10_x = log(x)/log(10);

  # Loop over all possible Y-values and keep this datafile-line if
  # at least one of the Y-values covers an unoccupied dot.
  for (i=2; i <= NF; i++) {

    y = $i;
    log10_y = log(y)/log(10);

    # Only do something if the dot is within the current plot-window...
    if (x<x_start || x > x_end || y<y_start || y>y_end) {

      # do nothing

    } else {

      # calculate this point's X and Y index into the picture-buffer-array
      x_index = int((log10_x-log10_x_start)*indexfactor_x);
      y_index = int((log10_y-log10_y_start)*indexfactor_y);

      # if the location is still free, then use this dot!  If not, skip it.
      if (picture[x_index, y_index] == 0) {

        # the dot is now occupied and we keep the datafile-entry...
        picture[x_index, y_index] = 1;
        print $0
        nb_new_datapoints = nb_new_datapoints+1;

      }

    }

  }

}

END {
  printf("# Reduced the number of data-points from %d to %d.\n", NR, nb_new_datapoints);
  printf("# The resulting data-file is %.2f percent of the original data-file.\n", nb_new_datapoints/NR*100);
}
