#!/bin/sh

# Custom script for automatic Arch Linux configuration after base install
# Created by: Kostas Ereksonas
# License: GPLv3

#  -----------------------------
# | Variables and software list |
#  -----------------------------

homedir= 
username= 
logfile=/var/log/archrice.log

# Directories for the new user
directories=(.local/share/fonts/ \
		.config/ \
		.local/bin/ \
		Desktop/ \
		Documents/aur/ \
		Documents/git/ \
		Documents/Phone/ \
		Downloads/ \
		Music/ \
		Pictures/Screenshots/ \
		Videos/OBS/ \
		Wine/)

# Custom suckless dwm window manager and it's utilities
suckless_utilities=(dwm-kostas dwmblocks-kostas dmenu-kostas st-kostas slock-kostas)

aur_packages=(xurls vim-youcompleteme-git picom-jonaburg-git fastfetch-git)

# Plugins for Vim text editor
vim_plugins=(preservim/nerdtree \
		vim-airline/vim-airline \
		vim-airline/vim-airline-themes \
		altercation/vim-colors-solarized \
		tmsvg/pear-tree)

# Additional themes for Vim
themes_solarized=(solarized8 solarized8_flat solarized8_high solarized8_low)
themes_gruvbox=(gruvbox8 gruvbox8_hard gruvbox8_soft)

#  ---------------
# | Configuration |
#  ---------------

# Editing pacman configuration file
function configurePacman () {
	dialog --title "Configuring Pacman" --infobox "Updating Pacman configuration file" 0 0 && sleep 2
	cd /etc/ && sed -i '33s/#//' pacman.conf; sed -i '37s/#//' pacman.conf; sed -i '93s/#//' pacman.conf; sed -i '94s/#//' pacman.conf

	return $?
}

# Configure pass utility to store passwords
function configurePass () {
	dialog --title "Pass Configuration" --msgbox "Now you will be prompted to create a GPG keypair." 0 0
	# Change terminal ownership to $username to get the passphrase for GPG key, as sugessted here:
	# https://github.com/MISP/MISP/issues/3702#issuecomment-443371431
	chown -R $username:$username /dev/tty1
	runuser -u $username -- gpg --full-gen-key 2>>$logfile 1>&2 && sleep 5
	email=$(grep @ $logfile | tail -1 | cut -d " " -f 25 | tr -d "<>")
	dialog --title "Pass Configuration" --infobox "Initializing password store for $email" 0 0 && sleep 2
	runuser -u $username -- pass init $email 2>>$logfile
	chown -R root:root /dev/tty1 && return $?
}

function cloneDotfiles () {
	title="Cloning Dotfiles" && isAUR="False" && isGIT="True" && MAKE="False"
	cd $homedir/Documents/git/ && Install "$title" "$isAUR" "$isGIT" "$MAKE" "Archrice"

	return $?
}

# Configure bashrc file
function configureBashrc () {
	alias="" && SSID="" && title="Configuring Bashrc"
	cd $homedir/ && cp $homedir/Documents/git/Archrice/dotfiles/.bashrc $homedir/.bashrc 2>>$logfile 1>&2

	dialog --title "$title" --infobox "Appending $homedir/.local/bin/ to PATH" 0 0 && sleep 2
	sed -i "13s/username/$username/" .bashrc 2>>$logfile 1>&2

	# Create an alias for connecting to Wi-Fi network and add it's password to password store
	dialog --title "$title" --yesno "Add an alias for connecting to wireless/hotspot network? " 0 0
	if [ $? == 0 ]; then
		printf "\n\n#  -------\n# | Wi-Fi |\n#  -------" >> .bashrc
		mkdir -p $homedir/.password-store/wifi/ && chown -R $username:$username $homedir/.password-store/wifi/
		while [ $? == 0 ]; do
			unset alias && unset SSID
			alias=$(dialog --stdout --title "$title" --inputbox "Enter name of an alias:" 0 0)
			SSID=$(dialog --stdout --title "$title" --inputbox "Enter SSID of your Wireless network:" 0 0)
			dialog --title "$title" --msgbox "Now You will be prompted to enter a password for $SSID" 0 0
			chown -R $username:$username /dev/tty1 && runuser -u $username -- pass add $SSID && chown -R root:root /dev/tty1
			mv $homedir/.password-store/$SSID.gpg $homedir/.password-store/wifi/$SSID.gpg
			dialog --title "$title" --infobox "Creating an $alias alias for $SSID" 0 0 && sleep 1
			printf "\n\nalias $alias=\'nmcli device wifi connect $SSID password \`pass wifi/$SSID\`\'" >> .bashrc
			dialog --title "$title" --yesno "Do you want to add an alias for another Wireless network?" 0 0
			if [ $? != 0 ]; then break; fi
		done
	fi

	dialog --title "$title" --yesno "Do you want to add alias to list all available Wireless networks?" 0 0
	if [ $? == 0 ]; then
		unset alias
		alias=$(dialog --stdout --title "$title" --inputbox "Enter name of an alias:" 0 0)
		printf "\n\nalias $alias=\'nmcli device wifi list\'" >> .bashrc
	fi

	dialog --title "$title" --yesno "Do you want to add alias to turn Bluetooth on/off?" 0 0
	if [ $? == 0 ]; then
		title="Installing Bluetooth" && isAUR="False" && isGIT="False" && MAKE="False"
		bluetooth=(bluez bluez-utils)
		Install "$title" "$isAUR" "$isGIT" "$MAKE" "${bluetooth[@]}"	# Install bluetooth utils

		title="Configuring Bashrc"
		# Add a Bluetooth banner
		printf "\n\n#  -----------\n# | Bluetooth |\n#  -----------"
		# Alias to turn bluetooth on
		unset alias
		alias=$(dialog --stdout --title "$title" --inputbox "Enter an alias to turn Bluetooth on:" 0 0)
		printf "alias $alias=\'systemctl start bluetooth.service\'\n\n" >> .bashrc

		# Alias to turn bluetooth off
		unset alias
		alias=$(dialog --stdout --title "$title" --inputbox "Enter an alias to turn Bluetooth off:" 0 0)
		printf "alias $alias=\'systemctl stop bluetooth.service\'\n\n" >> .bashrc
	fi

	return $?
}

# Configure custom scripts
function installScripts () {
	dialog --title "Installing Scripts" --infobox "Copying user scripts to $homedir/.local/bin/" 0 0
	cp $homedir/Documents/git/Archrice/.local/bin/* $homedir/.local/bin/ 2>>$logfile 1>&2

	dialog --title "Installing Scripts" --infobox "Copying system scripts to /usr/local/bin/" 0 0
	cp $homedir/Documents/git/Archrice/dotfiles/system_scripts/* /usr/local/bin/ 2>>$logfile 1>&2

	return $?
}

# Copy configuration files
function copyConfigs() {

	folders=(dunst gsimplecal picom ranger)
	for folder in "${folders[@]}"; do
		dialog --title "Installing Configuration Files" --infobox "Installing $folder" 0 0
		cp -r $homedir/Documents/git/Archrice/dotfiles/$folder/ $homedir/.config/$folder/ 2>>$logfile 1>&2
	done

	files=(.newsboat/ .xinitrc .xprofile)
	for file in ${files[@]}; do
		dialog --title "Installing Configuration Files" --infobox "Installing $file" 0 0
		cp -r $homedir/Documents/git/Archrice/dotfiles/$file $homedir/$file 2>>$logfile 1>&2
	done

	# Copy X11 configuration to /etc/X11/xorg.conf.d
	cp $homedir/Documents/git/Archrice/dotfiles/xorg.conf.d/10-monitor.conf /etc/X11/xorg.conf.d/ 2>>$logfile 1>&2
	cp $homedir/Documents/git/Archrice/dotfiles/xorg.conf.d/40-libinput.conf /etc/X11/xorg.conf.d/ 2>>$logfile 1>&2

	# If Intel iGPU exists, copy Intel iGPU config to /etc/X11/xorg.conf.d
	lspci | grep Intel\ Corporation\ HD\ Graphics 2>$logfile 1>&2
	if [ $? == 0 ]; then cp $homedir/Documents/git/Archrice/dotfiles/xorg.conf.d/30-intel.conf /etc/X11/xorg.conf.d/ 2>>$logfile 1>&2; fi

	# Copy pixmaps to /usr/share/pixmaps
	cp $homedir/Documents/git/Archrice/dotfiles/pixmaps/* /usr/share/pixmaps/ 2>>$logfile 1>&2

	# Download mpv notification script rom emilazy
	wget https://raw.githubusercontent.com/emilazy/mpv-notify-send/master/notify-send.lua -P $homedir/.config/mpv/scripts/ 2>>$logfile 1>&2

	return $?
}

# Recursively set ownership of users' home directory
function configureOwnership() {
	cd /home/ && chown -R $username:$username $homedir/ 2>>$logfile 1>&2 && return $?
}

# Customize Vim text editor
function configureVim () {
	title="Vim Configuration" && isAUR="False" && isGIT="False" && MAKE="False"
	cd $homedir/
	vimdir=""
	dialog --title $title --yes-label "Neovim" --no-label "Vim" --yesno "Which editor to install?" 0 0
	choice=$?
	if [ $choice == 0 ]; then # Choice == neovim
		vimdir=$homedir/.config/nvim/
		printf "\n\nexport EDITOR=nvim" >> $homedir/.bashrc
		nvim=(neovim python-neovim) && Install "$title" "$isAUR" "$isGIT" "$MAKE" "${nvim[@]}"
		dialog --title "$title" --yesno "Do you want to alias nvim as vim?" 0 0
		if [ $? == 0 ]; then printf "\n\nalias vim=\'nvim\'" >> $homedir/.bashrc; fi
	elif [ $choice == 1 ]; then # Choice == vim
		vimdir=$homedir/.vim/
		Install "$title" "$isAUR" "$isGIT" "$MAKE" "vim"
	fi

	# Install Pathogen plugin manager
	dialog --title "$title" --infobox "Installing Vim plugin manager" 0 0
	mkdir -p $vimdir/autoload/ $vimdir/bundle/ && curl -LSso $vimdir/autoload/pathogen.vim https://tpo.pe/pathogen.vim

	cd $vimdir/bundle/ && isGIT="True" && Install "$title" "$isAUR" "$isGIT" "$MAKE" ${vim_plugins[@]}

	# Create a directory in $vimdir to store color themes
	mkdir $vimdir/colors/ && cd $vimdir/colors/

	# Install solarized color theme variations for Vim
	for theme in ${themes_solarized[@]}; do
		wget https://raw.githubusercontent.com/lifepillar/vim-solarized8/master/colors/$theme.vim 2>>$logfile 1>&2
	done

	# Install gruvbox color theme variations for Vim
	for theme in ${themes_gruvbox[@]}; do
		wget https://raw.githubusercontent.com/lifepillar/vim-gruvbox8/master/colors/$theme.vim 2>>$logfile 1>&2
	done

	# Copy .vimrc config file from dotfiles
	dialog --title "$title" --infobox "Copying configuration to the user $username home directory" 0 0
	if [ $choice == 0 ]; then
		cp /home/$username/Documents/git/Archrice/dotfiles/.vimrc $vimdir/init.vim 2>>$logfile 1>&2
	elif [ $choice == 1 ]; then
		cp /home/$username/Documents/git/Archrice/dotfiles/.vimrc $homedir/.vimrc 2>>$logfile 1>&2
	fi

	return $?
}

function bashPowerline () {
	cd $homedir/Documents/git/
	git clone https://github.com/chris-marsh/pureline.git
	cp pureline/configs/powerline_full_256col.conf $homedir/.pureline.conf
	echo "source $homedir/Documents/git/pureline/ $homedir/.pureline.conf"
	return $?
}

#  --------------
# | Installation |
#  --------------

# Install necessary utilities
function installDependencies () {
	for dependency in ${dependencies[@]}; do
		until echo "Installing package $dependency" && installPackage $dependency; do
		   	dependencyError $dependency || break
		done
	done

	return $?
}

# Synchronize repositories and update existing packages
function updateSystem () {
	title="System Update" && isAUR="False" && isGIT="False" && MAKE="False"
	Install "$title" "$isAUR" "$isGIT" "$MAKE" "archlinux-keyring"
	dialog --title "$title" --infobox "Synchronizing and updating packages" 0 0
	until pacman --noconfirm -Syyu 2>>$logfile 1>&2; do updateError || break; done

	return $?
}

# Install a package using pacman
function installPackage () {
	pacman --noconfirm --needed -S $1 2>>$logfile 1>&2 && return $?
}

# Install a package from AUR
function installAURPackage() {
	yay --noconfirm --needed -S $1 2>>$logfile 1>&2 && return $?
}

# Install a package using pacman
function InstallAUR () {
	title="Installing AUR Package" && isAUR="True" && isGIT="False" && MAKE="False"
	dialog --title "$title" --infobox "Installing packages from AUR" 0 0 && sleep 1
	Install "$title" "$isAUR" "$isGIT" "$MAKE" "${aur_packages[@]}"

	return $?
}

# Source: https://askubuntu.com/questions/674333/how-to-pass-an-array-as-function-argument
# This function takes 5 arguments:
# $title - title of a dialog window
# $isAUR - isAUR flag, "True" is passed if a package from AUR needs to be installed
# $isGIT - isGIT flag, "True" is passed if a package from git repo needs to be installed
# $MAKE - MAKE flag, "True" is passed if a package needs to be installed using make
# ${arr[@]} - array of packages to install with this function
function Install() {
	# Grab first arguments and shift the remaining ones to the left
	local title="$1" && local isAUR="$2" && local isGIT="$3" && local MAKE="$4" && shift 4
	local arr=("$@") && local len=${#arr[@]} # Grab elements of an array and get it's length

	if [[ "$isAUR" == "False" && "$isGIT" == "False" && "$MAKE" == "False" ]]; then
		for i in "${arr[@]}"; do
			until dialog --title "$title" --infobox "Installing $i" 0 0 && installPackage $i; do
				installError $i || break
			done
		done
	fi
	if [[ "$isAUR" == "True" && "$isGIT" == "False" && "$MAKE" == "False" ]]; then
		for i in "${arr[@]}"; do
			until dialog --title "$title" --infobox "Installing $i" 0 0 && installAURPackage $i; do
				installError $i || break
			done
		done
	fi
	if [[ "$isAUR" == "False" && "$isGIT" == "True" && "$MAKE" == "False" ]]; then
		if [ "${arr[0]}" == "preservim/nerdtree" ]; then
			for i in "${arr[@]}"; do
				until dialog --title "$title" --infobox "Cloning $i" 0 0 && \
					git clone --quiet https://github.com/$i.git 2>>$logfile 1>&2; do
					gitError || break
				done
			done
		elif [ ${arr[0]} == "yay" ]; then
			until dialog --title "$title" --infobox "Cloning ${arr[0]}" 0 0 && \
				git clone --quiet https://aur.archlinux.org/yay.git 2>>$logfile 1>&2; do
				gitError || break
			done
		else
			for i in "${arr[@]}"; do
				until dialog --title "$title" --infobox "Cloning $i" 0 0 && \
					git clone --quiet https://github.com/KostasEreksonas/$i.git 2>>$logfile 1>&2; do
					gitError || break
				done
			done
		fi
	fi
	if [[ "$isAUR" == "False" && "$isGIT" == "False" && "$MAKE" == "True" ]]; then
		for i in "${arr[@]}"; do
			dialog --title "$title" --infobox "Installing $i" 0 0
			cd $i/ && make 2>>$logfile 1>&2 && make clean install 2>>$logfile 1>&2 && cd ..
		done
	fi

	return $?
}

# Install video card drivers
function installDrivers () {
	title="Video Driver Installation" && isAUR="False" && isGIT="False" && MAKE="False"

	dialog --title "$title" --yesno "Do you want to install Intel GPU drivers?" 0 0
	if [ $? == 0 ]; then Install "$title" "$isAUR" "$isGIT" "$MAKE" "${intel_igpu_drivers[@]}"; fi

	dialog --title "$title" --yesno "Do you want to install AMD GPU drivers?" 0 0
	if [ $? == 0 ]; then Install "$title" "$isAUR" "$isGIT" "$MAKE" "xf86-video-amdgpu"; fi

	dialog --title "$title" --yesno "Do you want to install Nvidia GPU drivers?" 0 0
	if [ $? == 0 ]; then
		dialog --title "$title" --yes-label "Proprietary" --no-label "Open Source" --yesno "Would you like to install proprietary or open source Nvidia GPU drivers?" 0 0
		if [ $? == 0 ]; then
			Install "$title" "$isAUR" "$isGIT" "$MAKE" "${nvidia_dgpu_drivers_proprietary[@]}"
		else
			Install "$title" "$isAUR" "$isGIT" "$MAKE" "${nvidia_dgpu_drivers_open_source[@]}"
		fi
	fi

	return $?
}

# Install system applications
function installApplications () {
	title="Installing Base Packages" && isAUR="False" && isGIT="False" && MAKE="False"

	dialog --title "$title" --infobox "Installing base packages" 0 0 && sleep 2
	Install "$title" "$isAUR" "$isGIT" "$MAKE" "${applications[@]}"

	usermod -aG vboxusers $username		# Add user to vboxusers group

	dialog --title "$title" --yesno "Do you want to install virtualbox-guest-utils (necessary if you want to run X sessions within Arch Linux guest in Virtualbox)?" 0 0
	if [ $? == 0 ]; then Install "$title" "$isAUR" "$isGIT" "$MAKE" "virtualbox-guest-utils"; fi

	return $?
}

function installAURHelper() {
	title="Installing AUR Helper" && isAUR="False" && isGIT="True" && MAKE="False"

	cd $homedir/Documents/aur/ && Install "$title" "$isAUR" "$isGIT" "$MAKE" "yay"

	chown -R $username:$username $homedir/Documents/aur/yay
	dialog --title "$title" --infobox "Installing yay AUR helper" 0 0
	cd $homedir/Documents/aur/yay/
	until sudo -u $username makepkg --noconfirm -si 2>>$logfile 1>&2; do installError yay || break; done
	dialog --title "$title" --infobox "AUR helper installed" 0 0 && sleep 1

	return $?
}

# Install Wine compatibility layer
function installWine () {
	title="Installing Wine" && isAUR="False" && isGIT="False" && MAKE="False"

	dialog --title "$title" --yesno "Do You want to install Wine?" 0 0
	if [ $? == 0 ]; then
		Install "$title" "$isAUR" "$isGIT" "$MAKE" "${wine_main[@]}"
		dialog --title "$title" --yesno "Do You want to install optional 64-bit dependencies for Wine?" 0 0
		if [ $? == 0 ]; then Install "$title" "$isAUR" "$isGIT" "$MAKE" "${wine_opt_depts[@]}"; fi
		dialog --title "$title" --yesno "Do You want to install optional 32-bit dependencies for Wine?" 0 0
		if [ $? == 0 ]; then Install "$title" "$isAUR" "$isGIT" "$MAKE" "${wine_opt_depts_32bit[@]}"; fi
	fi

	return $?
}

# Downloads and installs dwm and other suckless utilities
function installWM () {
	title="Installing Window Manager" && isAUR="False" && isGIT="True" && MAKE="False"

	dialog --title "$title" --infobox "Install suckless window manager and it's utilities" 0 0 && sleep 2
	cd $homedir/Documents/git/ 2>>$logfile 1>&2

	# Clone suckless utilities
	Install "$title" "$isAUR" "$isGIT" "$MAKE" "${suckless_utilities[@]}"

	# Install suckless utilities
	isGIT="False" && MAKE="True" && Install "$title" "$isAUR" "$isGIT" "$MAKE" "${suckless_utilities[@]}"

	return $?
}

# Install additional software to extend window manager functionality
function extendWM () {
	title="Install WM Tools" && isAUR="False" && isGIT="False" && MAKE="False"

	dialog --title "$title" --infobox "Installing additional packages for window manager" 0 0 && sleep 2
	Install "$title" "$isAUR" "$isGIT" "$MAKE" "${wm_tools[@]}"

	return $?
}

# Install system fonts
function installFonts () {
	title="Font Configuration" && isAUR="False" && isGIT="False" && MAKE="False"

	dialog --title "$title" --infobox "Installing all necessary fonts" 0 0 && sleep 2
	cd $homedir/.local/share/fonts
	dialog --title "$title" --infobox "Downloading Hack Nerd font" 0 0
	wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Hack.zip 2>>$logfile 1>&2
	dialog --title "$title" --infobox "Extracting Hack Nerd font" 0 0
	7z x Hack.zip 2>>$logfile 1>&2 && rm Hack.zip

	Install "$title" "$isAUR" "$isGIT" "$MAKE" "${fonts[@]}"	# Install some more fonts with pacman

	return $?
}

function installVirtualization() {
	title="Virtualization Software Installation" && isAUR="False" && isGIT="False" && MAKE="False"

	dialog --title "$title" --yesno "Do you want to install software for virtualization?" 0 0
	if [ $? == 0 ]; then
		dialog --title "$title" --yes-label "Virtualbox" --no-label "QEMU" --yesno "Which software do you want to install?" 0 0
		if [ $? == 0 ]; then
			Install "$title" "$isAUR" "$isGIT" "$MAKE" "${vbox_utils[@]}"
			isAUR="True" && Install "$title" "$isAUR" "$isGIT" "$MAKE" "virtualbox-ext-oracle"
		fi
		if [ $? == 1 ]; then
			Install "$title" "$isAUR" "$isGIT" "$MAKE" "${qemu[@]}"
			usermod -aG libvirt $username # Add user to libvirt group
		fi
	fi

	return $?
}

function installHacking() {
	title="Installing Hacking Apps" && isAUR="False" && isGIT="False" && MAKE="False"
	dialog --title "$title" --yesno "Do you want to install apps for hacking?" 0 0
	if [ $? == 0 ]; then Install "$title" "$isAUR" "$isGIT" "$MAKE" "${hack_apps[@]}"; fi
}

#  --------
# | Errors |
#  --------

# Display this error when the script fails to install package
function dependencyError () {
	sleep 2
	printf "Failed to install package $1. Error message: $(grep $1 $logfile | tail -1). Do you want to retry downloading package $1?\nChoice (Yes/No): "
	read choice
	if [ $choice == "Yes" ]; then
		printf "Retrying to install $1 in 5 seconds\n" && sleep 5 && return 0
	else
		printf "Failed to install script dependecy $1. Installation aborting.\n" && exit 1
	fi
}

function updateError() {
	error=$(grep failed\ to\ synchronize $logfile | tail -1)
	if [ "$error" == "error: failed to synchronize all databases (invalid url for server)" ]; then
		dialog --title "System Update Error" --yesno "Failed to update existing packages. Error: $error. Do you want to retry updating system?" 0 0
		if [ $? == 0 ]; then
			dialog --title "System Update" --infobox "Retrying system update in 5 seconds" 0 0 && sleep 5
			return 0
		else
			dialog --title "System Update Error" --msgbox "System not updated" 0 0
			return 1
		fi
	fi
}

# Display this message when a package fails to install via pacman
function installError () {
	sleep 1 && title="Package Installation Error"
	error=$(grep $1 $logfile | tail -1)
	dialog --title "$title" --yesno "Could not install $1. Error message: $error. Do you want to retry the installation process? (Warning: if you choose No, some packages will not be installed)" 0 0
	if [ $? == 0 ]; then
		dialog --title "$title" --infobox "Retrying to install $1 in 5 seconds" 0 0 && sleep 5 && return 0
	else
		dialog --title "$title" --msgbox "Package $1 not installed" 0 0 && return 1
	fi
}

# Display this message when there is an error when creating user
function userError() {
	title="User Creation Error"
	dialog --title "$title" --yesno "Passwords for $username do not match. Do you want to try again?" 0 0
	if [ $? == 0 ]; then
		return 0
	else
		dialog --title "$title" --msgbox "Password for $username was not created" 0 0 && return 1
	fi
}

# Display this message when a package fails to install via make
function gitError () {
	title="Error Cloning Git Repository"
	error=$(grep "Could not resolve host: github.com" $logfile)
	if [ $? == 0 ]; then
		dialog --title "$title" --yesno "Failed to clone $1. Error message: $error Do you want to retry?" 0 0
		choice=$?
		if [ $choice == 0 ]; then
			dialog --title "$title" --infobox "Retrying to clone $1 in 5 seconds" 0 0
			return $choice
		else
			dialog --title "$title" --msgbox "Failed to clone $1. Some features will not be installed" 0 0
			return $choice
		fi
	fi

	return $?
}

#  -------
# | Other |
#  -------
title="Arch Linux Auto Configuration Script"
msg="Welcome to Arch Linux configuration script. Purpose of this script is to expand a base Arch Linux install and configure a dwm window manager environment with most of the software necessary for daily usage installed. Press OK to start the configuration process"
function welcomeMsg () {
	dialog --title $title --msgbox $msg 0 0 && return $?
}

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

	return $?
}

# Creates directories within home directory of the new user
function createDirectories() {
	dialog --title "Directory Creation" --infobox "Creating necessary directories" 0 0 && sleep 2
	cd $homedir/
	for directory in ${directories[@]}; do
		mkdir -p $directory
	done
	return $?
}

function exitMsg () {
	dialog --title "Arch Auto Configuration Script" --infobox "The system is now installed. It will be cleaned up and rebooted in 10 seconds (Note: If you have multiple displays and want to extend them on startup, run extendDisplays command after starting your X session)" 0 0 && sleep 10
	rm -r /root/* && rm $logfile && sleep 2 && reboot && return 1
}

#  --------------
# | Main program |
#  --------------

while [ $? == 0 ]; do
	installDependencies
	welcomeMsg
	createUser
	createDirectories
	configurePacman
	updateSystem
	installDrivers
	installApplications
	installWine
	installWM
	extendWM
	installFonts
	configurePass
	cloneDotfiles
	configureBashrc
	installScripts
	configureVim
	bashPowerline
	copyConfigs
	configureOwnership
	installAURHelper
	installVirtualization
	installHacking
	exitMsg
done
