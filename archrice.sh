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

# Create and configure a new system user
function createUser() {
	# Pick an username (cannot be empty)
	while [ -z $name ]; do
		name=$(dialog --stdout --title "User Creation" --inputbox "User Name:" 0 0)
		if [ -z $name ]; then
			dialog --title "User Creation" --msgbox "Username cannot be empty. Try again" 0 0
		else
			useradd -m $name && homedir=/home/$name && username=$name
		fi
	done

	# Choose groups to add the user to
	groups=$(dialog --stdout --title "User Creation" \
			--checklist "Choose groups where the user $username should be added to:" 0 0 0 \
			wheel wheel on \
			adm adm off \
			ftp ftp off \
			games games off \
			http http off \
			log log off \
			rfkill rfkill off \
			sys sys off \
			systemd-journal systemd-journal off \
			uucp uucp off \
			libvirt libvirt on \
			dbus dbus off \
			kmem kmem off \
			locate locate off \
			lp lp off \
			mail mail off \
			nobody nobody off \
			proc proc off \
			root root off \
			smmsp smmsp off \
			tty tty off \
			utmp utmp off \
			audio audio on \
			disk disk off \
			floppy floppy off \
			input input off \
			kvm kvm off \
			video video on \
			optical optical on \
			storage storage on | sed 's/ /,/g') && usermod -aG $groups $name

	# Create a password for new user
	while [ $password != $passcheck ]; do
		password=$(dialog --stdout --title "User Creation" --passwordbox "Enter password for user $name:" 0 0)
		passcheck=$(dialog --stdout --title "User Creation" --passwordbox "Re-enter password for user $name:" 0 0)
		if [ $password != $passcheck ]; then
			unset $passcheck && userError $name || break
		else
			unset $passcheck && echo "$name:$password" | chpasswd
		fi
	done
}

function createDirectories() {
	dialog --title "Creating Directories" --infobox "Creating directories" 0 0 && sleep 2
	cd $homedir/
	while read dirname others; do
		mkdir -p "$dirname"
	done < /Archrice/directories.txt
}

# Editing pacman configuration file
function configurePacman() {
	dialog --title "Configuring Pacman" --infobox "Updating Pacman configuration file" 0 0 && sleep 2
	cd /etc/ && sed -i '33s/#//' pacman.conf; sed -i '37s/#//' pacman.conf; sed -i '93s/#//' pacman.conf; sed -i '94s/#//' pacman.conf
}

# Install system fonts
function installFonts() {
	title="Font Configuration"
	dialog --title "$title" --infobox "Installing fonts" 0 0 && sleep 2
	cd $homedir/.local/share/fonts/
	dialog --title "$title" --infobox "Installing Hack Nerd Font" 0 0
	wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Hack.zip
	7z x Hack.zip && rm Hack.zip
}

#  -------------
# | Main Script |
#  -------------

while [ $? == 0 ]; do
	welcomeMsg
	createUser
	createDirectories
	configurePacman
	installFonts
	exitMsg
done
