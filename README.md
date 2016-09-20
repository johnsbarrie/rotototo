# RotoToto

> RotoToto a small mac application designed to allow Dragonframe to synchronise a video projector for rotoscopy animation.


### Install 
You will scripts necessary to get Rototo to work with Dragonframe in the dragonscripts folder.

Run the following three commands in the terminal to make the script run correctly

cd [path_to_dragonscript_folder]
chmod u+x dragonframe_script.sh
chmod u+x dragon_pilot.rb

### Configure DRAGONFRAME


Then in Dragonframe, go to the Advanced tab of Preferences
and choose this file for Action Script.

To Test if the script works by running run the follow command in the terminal

./dragonframe_script.sh test test test POSITION 10


Rotototo should move frame to 10

###TROUBLE SHOOTING

run the following command in the terminal

./dragon_pilot.rb 5

Look at the error, try to understand what it concerns.
If you are stuck, copy the error and contact john@lamenagerie.com
He may reply.
Offer him a beer (or some money) and he probably will. ;)
