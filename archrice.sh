#!/bin/sh

# Custom script for automatic Arch Linux configuration after base install
# Created by: Kostas Ereksonas
# License: GPLv3

#  -----------
# | Variables |
#  -----------

homedir=
username=
logfile=/var/log/archrice.log

# Directories for the new user
directories=(.local/share/fonts/ \
		bin/ \
		Desktop/ \
		Documents/aur/ \
		Documents/git/ \
		Documents/Phone/ \
		Downloads/ \
		Music/ \
		Photos/Screenshots/ \
		Videos/OBS/ \
		Wine/)

# Dependencies for this script
dependencies=(dialog \
		git \
		wget \
		p7zip)

# Intel integrated GPU drivers
intel_igpu_drivers=(vulkan-intel \
		xf86-video-intel)

# Proprietary Nvidia GPU drivers
nvidia_dgpu_drivers_proprietary=(nvidia \
		nvidia-prime \
		nvidia-utils \
		lib32-nvidia-utils)

# Open Source Nvidia GPU drivers
nvidia_dgpu_drivers_open_source=(xf86-video-nouveau)

# Custom suckless dwm window manager and it's utilities
suckless_utilities=(dwm-kostas \
		dwmblocks-kostas \
		dmenu-kostas \
		st-kostas \
		slock-kostas)

# Tools to extend functionality of dwm window manager
wm_tools=(feh \
		xclip \
		iw \
		maim \
		xdotool \
		picom \
		udisks2 \
		udiskie \
		numlockx \
		dunst \
		ranger \
		ueberzug \
		zathura \
		zathura-pdf-poppler \
		ffmpegthumbnailer \
		lynx \
		perl-image-exiftool \
		odt2txt \
		ntfs-3g \
		bash-completion)

# Other applications and drivers
applications=(xorg-server \
		xorg-xinit \
		mesa \
		vim \
		openssh \
		newsboat \
		pass \
		passff-host \
		neofetch \
		htop \
		nvtop \
		cmatrix \
		firefox \
		gimp \
		mpv \
		alsa-utils \
		pulseaudio-alsa \
		pamixer \
		pavucontrol \
		sysstat \
		acpilight \
		libreoffice-fresh \
		android-file-transfer \
		android-udev \
		discord)

aur_packages=(virtualbox-ext-oracle \
		xurls \
		vim-youcompleteme-git)

fonts=(noto-fonts \
	noto-fonts-emoji \
	adobe-source-han-sans-kr-fonts \
	adobe-source-han-sans-cn-fonts \
	adobe-source-han-sans-tw-fonts \
	adobe-source-han-sans-jp-fonts)

# Plugins for Vim text editor
vim_plugins=(preservim/nerdtree \
		vim-airline/vim-airline \
		altercation/vim-colors-solarized \
		tmsvg/pear-tree)

# Main Wine utilities
wine_main=(wine \
		wine-mono \
		wine-gecko)

# Optional dependencies for Wine
wine_opt_depts=(giflib \
		libpng \
		libldap \
		gnutls \
		mpg123 \
		openal \
		v4l-utils \
		libpulse \
		alsa-plugins \
		alsa-lib \
		libjpeg-turbo \
		libxcomposite \
		libxinerama \
		opencl-icd-loader \
		libxslt \
		gst-plugins-base-libs \
		vkd3d \
		sdl2 \
		libgphoto2 \
		sane \
		gsm \
		cups \
		samba \
		dosbox)

wine_opt_depts_32bit=(lib32-giflib \
		lib32-libldap \
		lib32-libpng \
		lib32-gnutls \
		lib32-mpg123 \
		lib32-openal \
		lib32-v4l-utils \
		lib32-libpulse \
		lib32-alsa-plugins \
		lib32-alsa-lib \
		lib32-libjpeg-turbo \
		lib32-libxcomposite \
		lib32-libxinerama \
		lib32-opencl-icd-loader \
		lib32-libxslt \
		lib32-gst-plugins-base-libs \
		lib32-vkd3d \
		lib32-sdl2)

#  ---------------
# | Configuration |
#  ---------------

# Editing pacman configuration file
function configurePacman () {
	dialog --title "Configuring Pacman" --infobox "Updating Pacman configuration file" 0 0
	sleep 2

	cd /etc/
	sed -i '33s/#//' pacman.conf; sed -i '37s/#//' pacman.conf; sed -i '93s/#//' pacman.conf; sed -i '94s/#//' pacman.conf

	return $?
}

# Configure pass utility to store passwords
function configurePass () {
	dialog --title "Pass Configuration" --msgbox "Now you will be prompted to create a GPG key. When the GPG key is created, a password store will be initialized with a provided E-mail address." 0 0
	gpg --full-gen-key 2>>$logfile 1>&2
	email=$(grep @ $logfile | cut -d " " -f 25 | tr -d "<>")
	dialog --title "Pass Configuration" --infobox "Initializing password store for $email" 0 0
	sleep 1
	pass init $email

	return $?
}

# Clone dotfiles repository
function cloneDotfiles () {
	tempfile=/tmp/archtemp.txt
	cd $homedir/Documents/git/
	dialog --title "Configuring Bashrc" --infobox "Cloning archrice repository" 0 0
	until git clone --quiet https://github.com/KostasEreksonas/Archrice.git 2>>$tempfile; do
		gitError Archrice || break
	done

	rm -f $tempfile
	return $?
}

# Configure bashrc file
function configureBashrc () {
	cd $homedir/
	cp $homedir/Documents/git/Archrice/dotfiles/.bashrc $homedir/.bashrc

	dialog --title "Configuring Bashrc" --infobox "Appending a custom script directory at $homedir/bin/ to PATH" 0 0
	sleep 2
	sed -i "13s/username/$username/" .bashrc

	# Create an alias for connecting to Wi-Fi network and add it's password to password store
	dialog --title "Configuring Bashrc" --yesno "Do you want to keep 'connect_wifi' alias to connect to Wi-Fi? " 0 0
	if [ $? == 0 ]; then
		wifi_ssid=$(dialog --stdout --title "Configuring Bashrc" --inputbox "Enter SSID of your Wi-Fi" 0 0)
		# https://stackoverflow.com/questions/148451/how-to-use-sed-to-replace-only-the-first-occurrence-in-a-file
		sed -i "0,/SSID/s//$wifi_ssid/" .bashrc

		dialog --title "Configuring Bashrc" --msgbox "Now You will be prompted to enter a password for your Wi-Fi network" 0 0
		mkdir -p /root/.password-store/wifi/
		pass add $wifi_ssid
		mv /root/.password-store/$wifi_ssid.gpg /root/.password-store/wifi/wifi.gpg
	else
		sed -i '/connect_wifi/d'
	fi

	# Create an alias for connecting to Wi-Fi network and add it's password to password store
	dialog --title "Configuring Bashrc" --yesno "Do you want to keep 'connect_hotspot' alias to connect to hotspot? " 0 0
	if [ $? == 0 ]; then
		hotspot_ssid=$(dialog --stdout --title "Configuring Bashrc" --inputbox "Enter SSID of your hotspot" 0 0)
		sed -i "s/SSID/$hotspot_ssid/" .bashrc

		dialog --title "Configuring Bashrc" --msgbox "Now You will be prompted to enter a password for Your hotspot network" 0 0
		pass add $hotspot_ssid
		mv /root/.password-store/$hotspot_ssid.gpg /root/.password-store/wifi/hotspot.gpg
	else
		sed -i '/connect_hotspot/d'
	fi

	# Move password store to the users' home directory
	mv /root/.password-store/ $homedir/.password-store

	dialog --title "Configuring Bashrc" --yesno "Do you want to keep aliases to toggle bluetooth on and off?" 0 0
	if [ $? == 1 ]; then
		sed -i '/blth/d' .bashrc
	fi

	dialog --title "Configuring Bashrc" --yesno "Do you want to keep aliases for games installed with Wine?" 0 0
	if [ $? == 1 ]; then
		sed -i '/Wine/d' .bashrc
	fi

	return $?
}

# Configure custom scripts
function installScripts () {
	dialog --title "Installing Scripts" --infobox "Copying statusbar scripts to $homedir/bin/" 0 0
	cp $homedir/Documents/git/Archrice/statusbar/* $homedir/bin/

	scripts=(locker screenshot screenshot_clipboard paste_clipboard piper)
	len=${#scripts[@]}

	for (( i=0; i<$len; i++ )); do
	dialog --title "Installing Scripts" --infobox "Copying ${scripts[$i]} script to /usr/local/bin" 0 0
		cp $homedir/Documents/git/Archrice/system_scripts/${scripts[$i]} /usr/local/bin/
	done

	return $?
}

# Copy configuration files
function copyConfigs() {

	folders=(dunst gsimplecal picom ranger)
	len=${#folders[@]}
	for (( i=0; i<$len; i++ )); do
		dialog --title "Installing Configuration Files" --infobox "Installing ${folders[$i]}" 0 0
		cp -r $homedir/Documents/Archrice/dotfiles/${folders[$i]}/ $homedir/.config/${folders[$i]}/
	done

	files=(.newsboat/ .xinitrc .xprofile)
	len=${files[@]}
	for (( i=0; i<$len; i++ )); do
		dialog --title "Installing Configuration Files" --infobox "Installing ${files[$i]}"
		cp -r $homedir/Documents/git/Archrice/dotfiles/${files[$i]} $homedir/${files[$i]}
	done

	# Copy X11 configuration to /etc/X11/xorg.conf.d
	cp $homedir/Documents/git/Archrice/dotfiles//xorg.conf.d/10-monitor.conf /etc/X11/xorg.conf.d/
	cp $homedir/Documents/git/Archrice/dotfiles/xorg.conf.d/40-libinput.conf /etc/X11/xorg.conf.d/

	# If Nvidia drivers are installed, copy Nvidia config to /etc/X11/xorg.conf.d
	pacman -Qi nvidia 2>>$logfile 1>&2
	if [ $? == 0 ]; then cp $homedir/Documents/git/Archrice/xorg.conf.d/20-nvidia.conf /etc/X11/xorg.conf.d/; fi

	# If Intel iGPU exists, copy Intel iGPU config to /etc/X11/xorg.conf.d
	lspci | grep Intel\ Corporation\ HD\ Graphics 2>$logfile 1>&2
	if [ $? == 0 ]; then cp $homedir/Documents/git/Archrice/xorg.conf.d/20-intel.conf /etc/X11/xorg.conf.d/; fi

	# Copy pixmaps to /usr/share/pixmaps
	cp $homedir/Documents/git/Archrice/dotfiles/pixmaps/* /usr/share/pixmaps/

	return $?
}

# Configure ownership of users' home directory
function configureOwnership() {
	cd /home/
	chown -R $username:$username $homedir/
}

# Customize Vim text editor
function configureVim () {
	tempfile=/tmp/archtemp.txt
	cd $homedir/
	# Install Pathogen plugin manager
	dialog --title "Vim Configuration" --infobox "Installing Vim plugin manager" 0 0
	mkdir -p .vim/autoload .vim/bundle && curl -LSso .vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

	# Go into plugin directory
	cd .vim/bundle/

	# Download Vim plugins
	len=${#vim_plugins[@]}
	for (( i=0; i<$len; i++ )); do
		until dialog --title "Vim Configuration" --infobox "Installing ${vim_plugins[$i]} plugin" 0 0 && git clone --quiet https://github.com/${vim_plugins[$i]}.git 2>>$tempfile 1>&2; do
			gitError ${vim_plugins[$i]} || break
		done
	done

	# Copy .vimrc config file from dotfiles
	dialog --title "Vim Configuration" --infobox "Copying configuration to the user $username home directory" 0 0
	cp /home/$username/Documents/git/Archrice/dotfiles/.vimrc $homedir/.vimrc

	rm -f $tempfile
	return $?
}

#  --------------
# | Installation |
#  --------------

# Install necessary utilities
function installDependencies () {
	len=${#dependencies[@]}
	for (( i=0; i<$len; i++ )); do
		until echo "Installing package ${dependencies[$i]}" && installPackage ${dependencies[$i]}; do
		   	dependencyError ${dependencies[$i]} || break
		done
	done

	return $?
}

# Synchronize repositories and update existing packages
function updateSystem () {
	dialog --title "System Update" --infobox "Updating Arch Linux keyring" 0 0
	until installPackage archlinux-keyring 2>>$logfile 1>&2; do
		installError archlinux-keyring || break
	done
	dialog --title "System Update" --infobox "Synchronizing and updating packages" 0 0
	until pacman --noconfirm -Syyu 2>>$logfile 1>&2; do
		updateError || break
	done

	return $?
}

# Install a package using pacman
function installPackage () {
	pacman --noconfirm --needed -S $1 2>>$logfile 1>&2

	return $?
}

# Install a package using pacman
function installAURPackages () {
	dialog --title "Installing AUR Packages" --infobox "Installing packages from AUR" 0 0
	sleep 1
	len=${#aur_packages[@]}
	for (( i=0; i<$len; i++ )); do
		until dialog --title "Installing AUR Packages" --infobox "Installing ${aur_packages[$i]}" 0 0 && yay --noconfirm --needed -S ${aur_packages[$i]} 2>>$logfile 1>&2; do
			installError ${aur_packages[$i]} || break
		done
	done

	return $?
}

# Install video card drivers
function installDrivers () {
	dialog --title "Video Driver Installation" --yesno "Do you want to install Intel GPU drivers?" 0 0
	if [ $? == 0 ]; then
		len=${#intel_igpu_drivers[@]}
		for (( i=0; i<$len; i++ )); do
			until dialog --title "Video Driver Installation" --infobox "Now installing ${intel_igpu_drivers[$i]}" 0 0 && installPackage ${intel_igpu_drivers[$i]}; do
				installError ${intel_igpu_drivers[$i]} || break
			done
		done
	fi
	dialog --title "Video Driver Installation" --yesno "Do you want to install Nvidia GPU drivers?" 0 0
	if [ $? == 0 ]; then
		dialog --title "Video Driver Installation" --yes-label "Proprietary" --no-label "Open Source" --yesno "Would you like to install proprietary or open source Nvidia GPU drivers?" 0 0
		if [ $? == 0 ]; then
			len=${#nvidia_dgpu_drivers_proprietary[@]}
			for (( i=0; i<$len; i++ )); do
				until dialog --title "Nvidia Proprietary Driver Installation" --infobox "Now installing ${nvidia_dgpu_drivers_proprietary[$i]}" 0 0 && installPackage ${nvidia_dgpu_drivers_proprietary[$i]}; do
					installError ${nvidia_dgpu_drivers_proprietary[$i]} || break
				done
			done
		else
			len=${#nvidia_dgpu_drivers_open_source[@]}
			for (( i=0; i<$len; i++ )); do
				until dialog --title "Nvidia Open Source Driver Installation" --infobox "Now installing ${nvidia_dgpu_drivers_open_source[$i]}" 0 0 && installPackage ${nvidia_dgpu_drivers_open_source[$i]}; do
					installError ${nvidia_dgpu_drivers_open_source[$i]} || break
				done
			done
		fi
	fi

	return $?
}

# Install system applications
function installApplications () {
	dialog --title "Installing Packages" --infobox "Installing base packages" 0 0
	sleep 2
	len=${#applications[@]}
	for (( i=0; i<$len; i++ )); do
		until dialog --title "Installing Packages" --infobox "Now installing ${applications[$i]}" 0 0 && installPackage ${applications[$i]}; do
			installError ${applications[$i]} || break
		done
	done

	dialog --title "Installing Packages" --yesno "Do you want to install virtualbox-guest-utils (necessary if you want to run X sessions within Arch Linux guest in Virtualbox)?" 0 0
	if [ $? == 0 ]; then
		until installPackage virtualbox-guest-utils; do
			installError virtualbox-guest-utils || break
		done
	fi

	return $?
}

function installAURHelper() {
	tempfile=/tmp/archtemp.txt
	cd $homedir/Documents/aur/
	until dialog --title "Installing AUR Helper" --infobox "Downloading yay AUR helper" 0 0 && git clone --quiet https://aur.archlinux.org/yay.git 2>>$tempfile; do
		gitError yay || break
	done

	chown -R $username:$username $homedir/Documents/aur/yay
	dialog --title "Installing AUR Helper" --infobox "Installing yay AUR helper" 0 0
	cd $homedir/Documents/aur/yay/
	until sudo -u $username makepkg --noconfirm -si 2>>$logfile 1>&2; do
		installError yay || break
	done
	dialog --title "Installing AUR Helper" --infobox "AUR helper installed" 0 0
	sleep 1

	rm -f $tempfile
	return $?
}

# Install Wine compatibility layer
function installWine () {
	dialog --title "Installing Wine" --yesno "Do You want to install Wine?" 0 0
	if [ $? == 0 ]; then
		len=${#wine_main[@]}
		for (( i=0; i<$len; i++ )); do
			until dialog --title "Wine" --infobox "Now installing ${wine_main[$i]}" 0 0 && installPackage ${wine_main[$i]}; do
				installError ${wine_main[$i]} || break
			done
		done
		dialog --title "Installing Wine" --yesno "Do You want to install optional 64-bit dependencies for Wine?" 0 0
		if [ $? == 0 ]; then
			len=${#wine_opt_depts[@]}
			for (( i=0; i<$len; i++ )); do
				until dialog --title "Wine" --infobox "Now installing ${wine_opt_depts[$i]}" 0 0 && installPackage ${wine_opt_depts[$i]}; do
					installError ${wine_opt_depts[$i]} || break
				done
			done
		fi
		dialog --title "Installing Wine" --yesno "Do You want to install optional 32-bit dependencies for Wine?" 0 0
		if [ $? == 0 ]; then
			len=${#wine_opt_depts_32bit[@]}
			for (( i=0; i<$len; i++ )); do
				until dialog --title "Wine" --infobox "Now installing ${wine_opt_depts_32bit[$i]}" 0 0 && installPackage ${wine_opt_depts_32bit[$i]}; do
					installError ${wine_opt_depts_32bit[$i]} || break
				done
			done
		fi
	fi

	return $?
}

# Downloads and installs dwm and other suckless utilities
function installWM () {
	dialog --title "Installing Window Manager" --infobox "Install suckless window manager and it's utilities" 0 0
	sleep 2
	tempfile=/tmp/archtemp.txt
	cd $homedir/Documents/git/ 2>>$logfile 1>&2
	# Install suckless utilities
	len=${#suckless_utilities[@]}
	for (( i=0; i<$len; i++ )); do
		until dialog --title "Installing Window Manager" --infobox "Cloning ${suckless_utilities[$i]}" 0 0 && git clone --quiet https://github.com/KostasEreksonas/${suckless_utilities[$i]}.git 2>>$tempfile; do
			gitError || break
		done
	done

	for (( j=0; j<$len; j++ )); do
		dialog --title "Installing Window Manager" --infobox "Installing ${suckless_utilities[$i]}" 0 0
		cd ${suckless_utilities[$i]}/
		make 2>>$logfile 1>&2
		make clean install 2>>$logfile 1>&2
		cd ..
	done

	rm -f $tempfile
	return $?
}

# Install additional software to extend window manager functionality
function extendWM () {
	dialog --title "Install Additional WM Tools" --infobox "Installing additional packages for window manager" 0 0
	sleep 2
	len=${#wm_tools[@]}
	for (( i=0; i<$len; i++ )); do
		until dialog --title "Install Additional WM Tools" --infobox "Installing ${wm_tools[$i]}" 0 0 && installPackage ${wm_tools[$i]}; do
			installError ${wm_tools[$i]} || break
		done
	done

	return $?
}

# Install system fonts
function installFonts () {
	dialog --title "Font Configuration" --infobox "Installing all necessary fonts" 0 0
	sleep 2
	cd $homedir/.local/share/fonts
	dialog --title "Font Configuration" --infobox "Downloading Hack Nerd font" 0 0
	wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Hack.zip 2>>$logfile 1>&2
	dialog --title "Font Configuration" --infobox "Extracting Hack Nerd font" 0 0
	7z x Hack.zip 2>>$logfile 1>&2
	rm Hack.zip

	# Install some more fonts with pacman
	len=${#fonts[@]}
	for (( i=0; i<$len; i++ )); do
		until dialog --title "Font Configuration" --infobox "Installing ${fonts[$i]}" 0 0 && installPackage ${fonts[$i]}; do
			installError ${fonts[$i]} || break
		done
	done

	return $?
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
		printf "Retrying to install $1 in 5 seconds\n"
		sleep 5
		return 0
	else
		printf "Failed to install script dependecy $1. Installation aborting.\n"
		exit 1
	fi
}

function updateError() {
	error=$(grep failed\ to\ synchronize $logfile | tail -1)
	if [ "$error" == "error: failed to synchronize all databases (invalid url for server)" ]; then
		dialog --title "System Update Error" --yesno "Failed to update existing packages. Error: $error. Do you want to retry updating system?" 0 0
		if [ $? == 0 ]; then
			dialog --title "System Update" --infobox "Retrying system update in 5 seconds" 0 0
			sleep 5
			return 0
		else
			dialog --title "System Update Error" --msgbox "System not updated" 0 0
			return 1
		fi
	fi
}

# Display this message when a package fails to install via pacman
function installError () {
	sleep 1
	error=$(grep $1 $logfile | tail -1)
	dialog --title "Package Installation Error" --yesno "Could not install $1. Error message: $error. Do you want to retry the installation process? (Warning: if you choose No, some packages will not be installed)" 0 0
	if [ $? == 0 ]; then
		dialog --title "Package Installation Error" --infobox "Retrying to install $1 in 5 seconds" 0 0
		sleep 5
		return 0
	else
		dialog --title "Package Installation Error" --msgbox "Package $1 not installed" 0 0
		return 1
	fi
}

# Display this message when there is an error when creating user
function userError() {
	# Empty username error
	if [ $username == "" ]; then
		dialog --title "User Creation Error" --msgbox "Username cannot be empty. Please try again." 0 0
		return 0
	fi

	# Password creation error
	dialog --title "User Creation Error" --yesno "Passwords for $username do not match. Do you want to try again?" 0 0
	if [ $? == 0 ]; then
		return 0
	else
		dialog --title "User Creation Error" --msgbox "Password for $username was not created." 0 0
		return 1
	fi
}

# Display this message when a package fails to install via make
function gitError () {
	error=$(grep "Could not resolve host: github.com" $tempfile)
	if [ $? == 0 ]; then
		dialog --title "Error Cloning Git Repository" \
			--yesno "Failed to clone repository $1. Error message: $error Do you want to retry?" 0 0
		choice=$?
		if [ $choice == 0 ]; then
			dialog --title "Error Cloning Git Repository" \
				--infobox "Retrying to download $1 in 5 seconds" 0 0
			cat $tempfile >> $logfile
			> $tempfile
			sleep 5
			return $choice
		else
			dialog --title "Error Cloning Git Repository" \
			--msgbox "Failed to clone repository $1. Some features will not be installed" 0 0
			cat $tempfile >> $logfile
			> $tempfile
			return $choice
		fi
	fi

}

#  -------
# | Other |
#  -------

function welcomeMsg () {
	dialog --title "Arch Linux Auto Configuration Script" --msgbox "Welcome to Arch Linux configuration script. This script is created to expand a base Arch Linux system and configure a dwm window manager environment with most of the software necessary for daily usage installed. Press OK to start the configuration process." 0 0

	return $?
}

# Create and configure a new system user
function createUser() {
	# Pick an username
	while [ "$username" == "" ]; do
		name=$(dialog --stdout --title "User Creation" --inputbox "User Name:" 0 0)
		homedir=/home/$name
		username=$name
		if [ "$username" == "" ]; then
			userError || dialog --title "User Creation Error" --msgbox "Failed to create user. Installation aborting" 0 0 && exit 1
		fi
		useradd -m $name
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
			storage storage on | sed 's/ /,/g')
	usermod -aG $groups $name

	# Create a password for new user
	while [ $password != $passcheck ]; do
		password=$(dialog --stdout --title "User Creation" --passwordbox "Enter password for user $name:" 0 0)
		passcheck=$(dialog --stdout --title "User Creation" --passwordbox "Re-enter password for user $name:" 0 0)
		if [ $password != $passcheck ]; then
			unset passcheck
			userError $name || break
		else
			unset passcheck
			echo "$name:$password" | chpasswd
		fi
	done

	return $?
}

# Creates directories within home directory of the new user
function createDirectories () {
	dialog --title "Directory Creation" --infobox "Creating necessary directories" 0 0
	sleep 2

	cd $homedir/
	len=${#directories[@]}
	for (( i=0; i<$len; i++ )); do
		mkdir -p ${directories[$i]}
	done

	return $?
}

function exitMsg () {
	dialog --title "Arch Auto Configuration Script" --infobox "The system is now installed and will be rebooted in 5 seconds." 0 0
	sleep 5
	reboot

	return 1
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
	copyConfigs
	configureOwnership
	installAURHelper
	installAURPackages
	exitMsg
done
