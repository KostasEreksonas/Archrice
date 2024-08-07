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
	rm -r /root/Archrice/ && return 1
}

#  --------
# | Errors |
#  --------

function installError() {
	title="Error Installing Package"
	dialog --title "$title" --yesno "Could not install $1. Retry?" 0 0
	if [ $? == 0 ]; then
		dialog --title "$title" --infobox "Retrying to install $1 in 5 seconds." 0 0 && sleep 5 && return 0
	else
		dialog --title "$title" --msgbox "Package $1 not installed" 0 0 && return 1
	fi
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
	done < /root/Archrice/directories.txt
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

# Configure pass utility to store passwords
function configurePass () {
	logfile=/var/log/archrice.log
	title="Configuring Pass"
	dialog --title "$title" --msgbox "Now you will be prompted to create a GPG keypair." 0 0
	# Change terminal ownership to $username to get the passphrase for GPG key, as sugessted here:
	# https://github.com/MISP/MISP/issues/3702#issuecomment-443371431
	chown -R $username:$username /dev/tty1
	runuser -u $username -- gpg --full-gen-key && sleep 5
	email=$(grep @ $logfile | tail -1 | cut -d " " -f 25 | tr -d "<>")
	dialog --title "$title" --infobox "Initializing password store for $email" 0 0 && sleep 2
	runuser -u $username -- pass init $email
	chown -R root:root /dev/tty1
	rm $logfile
}

# Configure system scripts
function configureScripts() {
	cp /root/Archrice/.local/bin/* $homedir/.local/bin/
	cp /root/Archrice/dotfiles/system_scripts/* /usr/local/bin/
}

function cloneDotfiles() {
	cd /root/Archrice/dotfiles/
	cp .xinitrc .xprofile .bashrc $homedir/
	cp -r .newsboat/ $homedir/
	cp pixmaps/* /usr/share/pixmaps/
	cp xorg.conf.d/* /etc/X11/xorg.conf.d/
	dotfiles=(dunst gsimplecal mutt picom ranger)
	for file in ${dotfiles[@]}; do
		cp -r $file $homedir/.config/
	done
}

function configureNeovim() {
	mkdir $homedir/.config/nvim/
	cp /root/Archrice/dotfiles/init.vim $homedir/.config/nvim/
	cd $homedir/.config/nvim/
	mkdir autoload/ bundle/ colors/
	curl -LSso autoload/pathogen.vim https://tpo.pe/pathogen.vim
	cd bundle/
	vim_plugins=(preservim/nerdtree \
		vim-airline/vim-airline \
		vim-airline/vim-airline-themes \
		altercation/vim-colors-solarized \
		tmsvg/pear-tree)
	for plugin in ${vim_plugins[@]}; do
		git clone https://github.com/$plugin.git
	done
	cd ../colors/
	themes_solarized=(solarized8 solarized8_flat solarized8_high solarized8_low)
	for theme in ${themes_solarized[@]}; do
		wget https://raw.githubusercontent.com/lifepillar/vim-solarized8/master/colors/$theme.vim
	done
	themes_gruvbox=(gruvbox8 gruvbox8_hard gruvbox8_soft)
	for theme in ${themes_gruvbox[@]}; do
		wget https://raw.githubusercontent.com/lifepillar/vim-gruvbox8/master/colors/$theme.vim
	done
}

# Recursively set ownership of users' home directory
function configureOwnership() {
	cd /home/ && chown -R $username:$username $homedir/
}

function configureVM() {
	cd /var/lib/libvirt/images/
	title="Local File Download"
	ip=$(dialog --stdout --title "$title" --inputbox "Enter IP address to download from" 0 0)
	port=$(dialog --stdout --title "$title" --inputbox "Enter port for downloading files" 0 0)
	while [ $? == 0 ]; do
		file=$(dialog --stdout --title "$title" --inputbox "Enter the name of a file you want to download" 0 0)
		wget -nc http://$ip:$port/$file
		dialog --title "$title" --yesno "Download another file?" 0 0
		if [ $? != 0 ]; then break; fi
	done
}

function installPureline() {
	cd $homedir/Documents/git/
	git clone https://github.com/chris-marsh/pureline.git
	mkdir $homedir/pureline/
	cd pureline/
	cp -r pureline segments/ $homedir/pureline/
	cp configs/powerline_full_256col.conf $homedir/.pureline.conf
}

#  --------------
# | Installation |
#  --------------

function installDependencies() {
	echo "Installing dependencies"
	pacman --no-confirm --needed -S - < /root/Archrice/package_lists/dependencies.txt
}

function updateSystem() {
	pacman -Syyu
}

function install() {
	pacman --noconfirm --needed -S $1
}

function installPackages() {
	readarray -t packages < package_lists/pacman_packages.txt
	for package in ${packages[@]}; do
		until dialog --title "Installing packages" --infobox "Installing $package" 0 0 && install $package; do
			installError $package || break
		done
	done
}

function installYAY() {
	title="Installing AUR Helper" && isAUR="False" && isGIT="True" && MAKE="False"
	cd $homedir/Documents/aur/ && git clone https://aur.archlinux.org/yay.git
	chown -R $username:$username $homedir/Documents/aur/yay
	dialog --title "$title" --infobox "Installing yay AUR helper" 0 0
	cd $homedir/Documents/aur/yay/
	sudo -u $username makepkg --noconfirm -si
	dialog --title "$title" --infobox "AUR helper installed" 0 0 && sleep 1
}

function installAURPackages() {
	yay --noconfirm --needed -S - < /root/Archrice/package_lists/aur_packages.txt
}

function installKernel() {
	dialog --title "Kernel Install" --infobox "Installing linux-tkg kernel " 0 0 && sleep 1
	cd $homedir/Documents/git/
	git clone https://github.com/Frogging-Family/linux-tkg.git
	cd linux-tkg/
	./install.sh install
}

function installSD() {
	dialog --title "Stable Diffusion Install" --infobox "Installing Automatic1111 UI for Stable Diffusion" 0 0 && sleep 1
	chown -R $username:$username /usr/local/games/
	cd /usr/local/games/
	git clone https://github.com/KostasEreksonas/stable-diffusion-webui.git
}

function installLlama() {
	curl -fsSL https://ollama.com/install.sh | sh
}

#  -------------
# | Main Script |
#  -------------

while [ $? == 0 ]; do
	installDependencies
	welcomeMsg
	createUser
	createDirectories
	configurePacman
	updateSystem
	installPackages
	installYAY
	installAURPackages
	installKernel
	installSD
	installLlama
	installPureline
	configureVM
	installFonts
	configurePass
	configureScripts
	cloneDotfiles
	configureNeovim
	configureOwnership
	exitMsg
done
