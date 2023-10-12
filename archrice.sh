#!/bin/sh

# Custom script for automatic Arch Linux configuration after base install
# Created by: Kostas Ereksonas
# License: GPLv3

#  ------------------
# | Global variables |
#  ------------------

homedir= 
username= 

#  ------
# | Misc |
#  ------

function welcomeMsg() {
	dialog --title "Arch auto config" --msgbox "Press Ok to start" 0 0
}

#  ---------------
# | Configuration |
#  ---------------

#  -------------
# | Main Script |
#  -------------

while [ $? == 0 ]; do
	welcomeMsg
done
