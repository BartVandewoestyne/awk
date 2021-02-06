#!/usr/bin/awk -f

# Set the field separator to the character from the Dexia csv format, namely ";"
BEGIN { FS=";"; }

# Select the fields:
#   Naam en adres tegenpartij
#   Mededeling
#   Bedrag
/775-5978939-74/ {
          printf("%s, %s, %s\n", $5, $8, $10);
        }

END {}
