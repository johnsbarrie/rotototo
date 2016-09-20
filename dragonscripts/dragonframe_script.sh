#!/bin/bash
# ROTOTOSCRIPT

# Test if the script works by running
# ./dragonframe_script.sh test test test POSITION 10
# Rotototo should move frame to 10


SCRIPT_DIR=$(dirname $0)
cd $SCRIPT_DIR;
if [ "$4" == "POSITION" ]
then
echo "Move ROTOTO to frame $5" >> ./dragonframe_script_log.txt
    ./dragon_pilot.rb $5
fi

# uncomment these lines to create logs
# echo "Take       : $3" >> ./dragonframe_script_log.txt
# echo "Action     : $4" >> ./dragonframe_script_log.txt
# echo "Frame      : $5" >> ./dragonframe_script_log.txt


