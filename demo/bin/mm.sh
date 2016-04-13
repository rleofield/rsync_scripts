#!/bin/bash

# retain          monthly 5

# call monthly 5x after weekly 4x after daily 3x after 2x hourly



./ww.sh
./monthly


./ww.sh
./monthly


./ww.sh
./monthly


./ww.sh
./monthly


./ww.sh
./monthly

# call 2x hourly at end to restore hourly entries
./hh.sh





