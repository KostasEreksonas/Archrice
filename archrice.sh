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
		.config/ \
		.local/bin/ \
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
		p7zip \
		networkmanager)

# Intel integrated GPU drivers
intel_igpu_drivers=(vulkan-intel \
		xf86-video-intel)

# Proprietary Nvidia GPU drivers
nvidia_dgpu_drivers_proprietary=(nvidia \
		nvidia-prime \
		nvidia-utils \
		nvidia-settings \
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
		bmon \
		xclip \
		maim \
		xdotool \
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
		yt-dlp \
		youtube-dl \
		bash-completion \
		intel-undervolt)

# Other applications and drivers
applications=(xorg-server \
		xorg-xinit \
		mesa \
		mesa-utils \
		vulkan-tools \
		openssh \
		newsboat \
		pass \
		passff-host \
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
		transmission-gtk \
		python-pip \
		darktable \
		discord)

aur_packages=(xurls \
		vim-youcompleteme-git \
		picom-jonaburg-git \
		fastfetch-git)

fonts=(noto-fonts \
	noto-fonts-emoji \
	adobe-source-han-sans-kr-fonts \
	adobe-source-han-sans-cn-fonts \
	adobe-source-han-sans-tw-fonts \
	adobe-source-han-sans-jp-fonts)

# Plugins for Vim text editor
vim_plugins=(preservim/nerdtree \
		vim-airline/vim-airline \
		vim-airline/vim-airline-themes \
		altercation/vim-colors-solarized \
		tmsvg/pear-tree \
		tpope/vim-fugitive)

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
	dialog --title "Pass Configuration" --msgbox "Now you will be prompted to create a GPG keypair." 0 0
	# Change terminal ownership to $username to get the passphrase for GPG key, as sugessted here:
	# https://github.com/MISP/MISP/issues/3702#issuecomment-443371431
	chown -R $username:$username /dev/tty1
	runuser -u $username -- gpg --full-gen-key 2>>$logfile 1>&2
	sleep 5
	email=$(grep @ $logfile | tail -1 | cut -d " " -f 25 | tr -d "<>")
	dialog --title "Pass Configuration" --infobox "Initializing password store for $email" 0 0
	sleep 2
	runuser -u $username -- pass init $email 2>>$logfile
	chown -R root:root /dev/tty1

	return $?
}

# Clone dotfiles repository
function cloneDotfiles () {
	tempfile=/tmp/archtemp.txt
	cd $homedir/Documents/git/
	dialog --title "Configuring Bashrc" --infobox "Cloning Archrice repository" 0 0
	until git clone --quiet https://github.com/KostasEreksonas/Archrice.git 2>>$tempfile; do
		gitError Archrice || break
	done

	rm -f $tempfile

	return $?
}

# Configure bashrc file
function configureBashrc () {
	alias=""
	SSID=""
	cd $homedir/
	cp $homedir/Documents/git/Archrice/dotfiles/.bashrc $homedir/.bashrc 2>>$logfile 1>&2

	dialog --title "Configuring Bashrc" --infobox "Appending a custom script directory at $homedir/bin/ to PATH" 0 0
	sleep 2
	sed -i "13s/username/$username/" .bashrc 2>>$logfile 1>&2

	# Create an alias for connecting to Wi-Fi network and add it's password to password store
	dialog --title "Configuring Bashrc" --yesno "Do you want to add an alias command for connecting to Wireless (hotspot) network? " 0 0
	if [ $? == 0 ]; then
		printf "\n\n#  -------\n# | Wi-Fi |\n#  -------" >> .bashrc
		mkdir -p $homedir/.password-store/wifi/
		chown -R $username:$username $homedir/.password-store/wifi/
		while [ $? == 0 ]; do
			unset alias
			unset SSID
			alias=$(dialog --stdout --title "Configuring Bashrc" --inputbox "Enter name of an alias:" 0 0)
			SSID=$(dialog --stdout --title "Configuring Bashrc" --inputbox "Enter SSID of your Wireless network:" 0 0)
			dialog --title "Configuring Bashrc" --msgbox "Now You will be prompted to enter a password for $SSID" 0 0
			chown -R $username:$username /dev/tty1 && runuser -u $username -- pass add $SSID && chown -R root:root /dev/tty1
			mv $homedir/.password-store/$SSID.gpg $homedir/.password-store/wifi/$SSID.gpg
			dialog --title "Configuring Bashrc" --infobox "Creating an alias for connecting to $SSID with $alias" 0 0
			sleep 1
			printf "\n\nalias $alias=\'nmcli device wifi connect $SSID password \`pass wifi/$SSID\`\'" >> .bashrc
			dialog --title "Configuring Bashrc" --yesno "Do you want to add an alias for another Wireless network?" 0 0
			if [ $? != 0 ]; then
				break
			fi
		done
	fi

	dialog --title "Configuring Bashrc" --yesno "Do you want to add alias to list all available Wireless networks?" 0 0
	if [ $? == 0 ]; then
		unset alias
		alias=$(dialog --stdout --title "Configuring Bashrc" --inputbox "Enter name of an alias:" 0 0)
		printf "\n\nalias $alias=\'nmcli device wifi list\'" >> .bashrc
	fi

	dialog --title "Configuring Bashrc" --yesno "Do you want to add alias to turn Bluetooth on/off?" 0 0
	if [ $? == 0 ]; then
		# Install bluetooth utils
		bluetooth=(bluez bluez-utils)
		for i in ${bluetooth[@]}; do
			until dialog --title "Installing Bluetooth" --infobox "Installing $i" && installPackage $i; do
				installError $i || break
			done
		done

		# Add a Bluetooth banner
		printf "\n\n#  -----------\n# | Bluetooth |\n#  -----------"
		# Alias to turn bluetooth on
		unset alias
		alias=$(dialog --stdout --title "Configuring Bashrc" --inputbox "Enter an alias to turn Bluetooth on:" 0 0)
		printf "alias $alias=\'systemctl start bluetooth.service\'\n\n" >> .bashrc

		# Alias to turn bluetooth off
		unset alias
		alias=$(dialog --stdout --title "Configuring Bashrc" --inputbox "Enter an alias to turn Bluetooth off:" 0 0)
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
	for i in "${folders[@]}"; do
		dialog --title "Installing Configuration Files" --infobox "Installing $i" 0 0
		cp -r $homedir/Documents/git/Archrice/dotfiles/$i/ $homedir/.config/$i/ 2>>$logfile 1>&2
	done

	files=(.newsboat/ .xinitrc .xprofile)
	for i in ${files[@]}; do
		dialog --title "Installing Configuration Files" --infobox "Installing $i" 0 0
		cp -r $homedir/Documents/git/Archrice/dotfiles/$i $homedir/$i 2>>$logfile 1>&2
	done

	# Copy X11 configuration to /etc/X11/xorg.conf.d
	cp $homedir/Documents/git/Archrice/dotfiles/xorg.conf.d/10-monitor.conf /etc/X11/xorg.conf.d/ 2>>$logfile 1>&2
	cp $homedir/Documents/git/Archrice/dotfiles/xorg.conf.d/40-libinput.conf /etc/X11/xorg.conf.d/ 2>>$logfile 1>&2

	# If Nvidia drivers are installed, copy Nvidia config to /etc/X11/xorg.conf.d
	pacman -Qi nvidia 2>>$logfile 1>&2
	if [ $? == 0 ]; then cp $homedir/Documents/git/Archrice/dotfiles/xorg.conf.d/20-nvidia.conf /etc/X11/xorg.conf.d/ 2>>$logfile 1>&2; fi

	# If Intel iGPU exists, copy Intel iGPU config to /etc/X11/xorg.conf.d
	lspci | grep Intel\ Corporation\ HD\ Graphics 2>$logfile 1>&2
	if [ $? == 0 ]; then cp $homedir/Documents/git/Archrice/dotfiles/xorg.conf.d/30-intel.conf /etc/X11/xorg.conf.d/ 2>>$logfile 1>&2; fi

	# Copy pixmaps to /usr/share/pixmaps
	cp $homedir/Documents/git/Archrice/dotfiles/pixmaps/* /usr/share/pixmaps/ 2>>$logfile 1>&2

	# Download mpv notification script rom emilazy
	wget https://raw.githubuserconttent.com/emilazy/mpv-notify-send/master/notify-send.lua -P $homedir/.config/mpv/scripts/

	return $?
}

# Configure ownership of users' home directory
function configureOwnership() {
	cd /home/
	chown -R $username:$username $homedir/ 2>>$logfile 1>&2

	return $?
}

# Customize Vim text editor
function configureVim () {
	tempfile=/tmp/archtemp.txt
	vimdir=""
	dialog --title "Vim Configuration" --yes-label "Neovim" --no-label "Vim" --yesno "Would you like to install Vim or Neovim?" 0 0
	choice=$?
	if [ $choice == 0 ]; then # Choice == neovim
		vimdir=$homedir/.config/nvim/
		printf "\n\nexport EDITOR=nvim" >> $homedir/.bashrc
		nvim=(neovim python-neovim)
		for i in ${nvim[@]}; do
			until dialog --title "Vim Configuration" --infobox "Installing $i" 0 0 && installPackage $i; do
				installError $i || break
			done
		done
		dialog --title "Vim Configuration" --yesno "Do you want to alias nvim as vim?" 0 0
		if [ $? == 0 ]; then
			printf "\n\nalias vim=\'nvim\'" >> $homedir/.bashrc
		fi
	elif [ $choice == 1 ]; then # Choice == vim
		vimdir=$homedir/.vim/
		until dialog --title "Vim Configuration" --infobox "Installing Vim" 0 0 && installPackage vim; do
			installError vim || break
		done
	fi

	# Install Pathogen plugin manager
	dialog --title "Vim Configuration" --infobox "Installing Vim plugin manager" 0 0
	mkdir -p $vimdir/autoload $vimdir/bundle && curl -LSso $vimdir/autoload/pathogen.vim https://tpo.pe/pathogen.vim

	# Go into plugin directory
	cd $vimdir/bundle/

	# Download Vim plugins
	for i in ${vim_plugins[@]}; do
		until dialog --title "Vim Configuration" --infobox "Installing $i plugin" 0 0 && git clone --quiet https://github.com/$i.git 2>>$tempfile 1>&2; do
			gitError $i || break
		done
	done

	# Download solarized8 color scheme by lifepillar from Github and put it to $vimdir/colors/
	wget https://raw.githubusercontent.com/lifepillar/vim-solarized8/master/colors/solarized8.vim -P $vimdir/colors/

	# Download gruvbox8 color scheme by lifepillar from Github and put it to $vimdir/colors/
	wget https://raw.githubusercontent.com/lifepillar/vim-gruvbox8/master/colors/gruvbox8.vim -P $vimdir/colors/

	# Download gruvbox8 hard color scheme by lifepillar from Github and put it to $vimdir/colors/
	wget https://raw.githubusercontent.com/lifepillar/vim-gruvbox8/master/colors/gruvbox8_hard.vim

	# Download gruvbox8 soft color scheme by lifepillar from Github and put it to $vimdir/colors/
	wget https://raw.githubusercontent.com/lifepillar/vim-gruvbox8/master/colors/gruvbox8_soft.vim

	# Copy .vimrc config file from dotfiles
	dialog --title "Vim Configuration" --infobox "Copying configuration to the user $username home directory" 0 0
	if [ $choice == 0 ]; then
		cp /home/$username/Documents/git/Archrice/dotfiles/.vimrc $vimdir/init.vim 2>>$logfile 1>&2
	elif [ $choice == 1 ]; then
		cp /home/$username/Documents/git/Archrice/dotfiles/.vimrc $homedir/.vimrc 2>>$logfile 1>&2
	fi

	rm -f $tempfile

	return $?
}

#  --------------
# | Installation |
#  --------------

# Install necessary utilities
function installDependencies () {
	for i in ${dependencies[@]}; do
		until echo "Installing package $i" && installPackage $i; do
		   	dependencyError $i || break
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

	for i in ${aur_packages[@]}; do
		until dialog --title "Installing AUR Packages" --infobox "Installing $i" 0 0 && yay --noconfirm --needed -S $i 2>>$logfile 1>&2; do
			installError $i || break
		done
	done

	return $?
}

# Install video card drivers
function installDrivers () {
	dialog --title "Video Driver Installation" --yesno "Do you want to install Intel GPU drivers?" 0 0
	if [ $? == 0 ]; then
		for i in ${intel_igpu_drivers[@]}; do
			until dialog --title "Video Driver Installation" --infobox "Now installing $i" 0 0 && installPackage $i; do
				installError $i || break
			done
		done
	fi

	dialog --title "Video Driver Installation" --yesno "Do you want to install AMD GPU drivers?" 0 0
	if [ $? == 0 ]; then
		until dialog --title "Video Driver Installation" --infobox "Now installing xf86-video-amdgpu" 0 0 && installPackage xf86-video-amdgpu; do
			installError xf86-video-amdgpu || break
		done
	fi

	dialog --title "Video Driver Installation" --yesno "Do you want to install Nvidia GPU drivers?" 0 0
	if [ $? == 0 ]; then
		dialog --title "Video Driver Installation" --yes-label "Proprietary" --no-label "Open Source" --yesno "Would you like to install proprietary or open source Nvidia GPU drivers?" 0 0
		if [ $? == 0 ]; then
			for i in ${nvidia_dgpu_drivers_proprietary[@]}; do
				until dialog --title "Nvidia Proprietary Driver Installation" --infobox "Now installing $i" 0 0 && installPackage $i; do
					installError $i || break
				done
			done
		else
			for i in ${nvidia_dgpu_drivers_open_source[@]}; do
				until dialog --title "Nvidia Open Source Driver Installation" --infobox "Now installing $i" 0 0 && installPackage $i; do
					installError $i || break
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
	for i in ${applications[@]}; do
		until dialog --title "Installing Packages" --infobox "Now installing $i" 0 0 && installPackage $i; do
			installError $i || break
		done
	done

	# Add user to vboxusers group
	usermod -aG vboxusers $username

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
		for i in ${wine_main[@]}; do
			until dialog --title "Wine" --infobox "Now installing $i" 0 0 && installPackage $i; do
				installError $i || break
			done
		done
		dialog --title "Installing Wine" --yesno "Do You want to install optional 64-bit dependencies for Wine?" 0 0
		if [ $? == 0 ]; then
			for i in ${wine_opt_depts[@]}; do
				until dialog --title "Wine" --infobox "Now installing $i" 0 0 && installPackage $i; do
					installError $i || break
				done
			done
		fi
		dialog --title "Installing Wine" --yesno "Do You want to install optional 32-bit dependencies for Wine?" 0 0
		if [ $? == 0 ]; then
			for i in ${wine_opt_depts_32bit[@]}; do
				until dialog --title "Wine" --infobox "Now installing $i" 0 0 && installPackage $i; do
					installError $i || break
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
	for i in ${suckless_utilities[@]}; do
		until dialog --title "Installing Window Manager" --infobox "Cloning $i" 0 0 && git clone --quiet https://github.com/KostasEreksonas/$i.git 2>>$tempfile 1>&2; do
			gitError || break
		done
	done

	for j in ${suckless_utilities[@]}; do
		dialog --title "Installing Window Manager" --infobox "Installing $j" 0 0
		cd $j/
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
	for i in ${wm_tools[@]}; do
		until dialog --title "Install Additional WM Tools" --infobox "Installing $i" 0 0 && installPackage $i; do
			installError $i || break
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
	for i in ${fonts[@]}; do
		until dialog --title "Font Configuration" --infobox "Installing $i" 0 0 && installPackage $i; do
			installError $i || break
		done
	done

	return $?
}

function installVirtualization() {
	dialog --title "Virtualization Software Installation" --yesno "Do you want to install software for virtualization?" 0 0
	if [ $? == 0 ]; then
		dialog --title "Virtualization Software Installation" --yes-label "Virtualbox" --no-label "QEMU" --yesno "Which software do you want to install?" 0 0
		if [ $? == 0 ]; then
			vbox=(virtualbox-host-modules-arch \
					virtualbox-guest-iso \
					virtualbox)
			for i in ${vbox[@]}; do
				until dialog --title "Virtualization Software Installation" --infobox "Installing $i" 0 0 && installPackage $i; do
					installError $i || break
				done
			done
			until dialog --title "Virtualization Software Installation" --infobox "Installing virtualbox-ext-oracle" 0 0 && yay --noconfirm --needed -S virtualbox-ext-oracle 2>>$logfile 1>&2; do
				installError virtualbox-ext-oracle || break
			done
		fi
		if [ $? == 1 ]; then
			qemu = (virt-manager \
					qemu-desktop \
					libvirt \
					edk2-ovmf \
					dnsmasq \
					iptables-nft)
			for i in ${qemu[@]}; do
				until dialog --title "Virtualization Software Installation" --infobox "Installing $i" 0 0 && installPackage $i; do
					installError $i || break
				done
			done
			usermod -aG libvirt $username
		fi
	fi

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
	# Password creation error
	dialog --title "User Creation Error" --yesno "Passwords for $username do not match. Do you want to try again?" 0 0
	if [ $? == 0 ]; then
		return 0
	else
		dialog --title "User Creation Error" --msgbox "Password for $username was not created" 0 0
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
	dialog --title "Arch Linux Auto Configuration Script" --msgbox "Welcome to Arch Linux configuration script. Purpose of this script is to expand a base Arch Linux install and configure a dwm window manager environment with most of the software necessary for daily usage installed. Press OK to start the configuration process" 0 0

	return $?
}

# Create and configure a new system user
function createUser() {
	# Pick an username (cannot be empty)
	while [ -z $name ]; do
		name=$(dialog --stdout --title "User Creation" --inputbox "User Name:" 0 0)
		if [ -z $name ]; then
			dialog --title "User Creation" --msgbox "Username cannot be empty. Try again" 0 0
		else
			homedir=/home/$name
			username=$name
			useradd -m $name
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
			storage storage on | sed 's/ /,/g')
	usermod -aG $groups $name

	# Create a password for new user
	while [ $password != $passcheck ]; do
		password=$(dialog --stdout --title "User Creation" --passwordbox "Enter password for user $name:" 0 0)
		passcheck=$(dialog --stdout --title "User Creation" --passwordbox "Re-enter password for user $name:" 0 0)
		if [ $password != $passcheck ]; then
			unset $passcheck
			userError $name || break
		else
			unset $passcheck
			echo "$name:$password" | chpasswd
		fi
	done

	return $?
}

# Creates directories within home directory of the new user
function createDirectories() {
	dialog --title "Directory Creation" --infobox "Creating necessary directories" 0 0
	sleep 2

	cd $homedir/
	for i in ${directories[@]}; do
		mkdir -p $i
	done

	return $?
}

function exitMsg () {
	dialog --title "Arch Auto Configuration Script" --infobox "The system is now installed. It will be cleaned up and rebooted in 10 seconds (Note: If you have multiple displays and want to extend them on startup, run "extendDisplays" command after starting your X session)" 0 0
	sleep 10
	rm -r /root/*
	rm $logfile
	sleep 2
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
	installVirtualization
	installAURPackages
	exitMsg
done
