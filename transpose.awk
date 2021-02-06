#!/usr/bin/awk -f
#
# Transpose a data file so that the data that is stored in the rows is now
# stored in the columns.

BEGIN { numcols=NF; numrows=0; }

# Match a line with data
/\ *[0-9].*/ {

  # Extract the amount of data points
  numcols=NF;

  # There is now one extra row/column of data
  numrows=numrows+1

  # Store the data in an array so we can extract it later on
  for (i=1; i<=numcols; i++) {
    data[i, numrows]=$i;
  }
}

# Now show all the data that we stored in the array in a column-oriented way.
END {

  for (col=1; col<=numcols; col++) {

    for (row=1; row<=numrows; row++) {
      printf("%s ", data[col, row]);
    }

    printf("\n");
  }
}
