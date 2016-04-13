#!/bin/bash

# retain          weekly  4

# call weekly 4x after daily 3x after 2x hourly

SLEEP=5

./dd.sh
./weekly
sleep $SLEEP


./dd.sh
./weekly
sleep $SLEEP


./dd.sh
./weekly
sleep $SLEEP


./dd.sh
./weekly
sleep $SLEEP



