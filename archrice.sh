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

function exitMsg() {
	dialog --title "Arch auto config" --msgbox "Setup done" 0 0
	return 1
}

#  ---------------
# | Configuration |
#  ---------------

# Editing pacman configuration file
function configurePacman() {
	dialog --title "Configuring Pacman" --infobox "Updating Pacman configuration file" 0 0 && sleep 2
	cd /etc/ && sed -i '33s/#//' pacman.conf; sed -i '37s/#//' pacman.conf; sed -i '93s/#//' pacman.conf; sed -i '94s/#//' pacman.conf
}

#  -------------
# | Main Script |
#  -------------

while [ $? == 0 ]; do
	welcomeMsg
	configurePacman
	exitMsg
done
