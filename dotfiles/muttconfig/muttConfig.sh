#!/bin/sh

title="Configuring Neomutt"
dialog --title "$title" --yesno "Do you want to configure Neomutt?" 0 0

if [ $? == 0 ]; then
	#Configure Neomutt
fi
