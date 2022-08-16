# Archrice

Archrice is a shell script for installing a window manager based graphical environment with most necessary software on a base Arch Linux install.

Table of Contents
=================
* [Installation](#Installation)
* [Features](#Features)
	* [Window Manager](#Window-Manager)
	* [System Scripts](#System-Scripts)
	* [Statusbar](#Statusbar)
	* [Aliases](#Aliases)
	* [Vim](#Vim)
	* [Other Software](#Other-Software)

# Installation

Download the archrice shell script from this repo with `curl`, make the script executable and run it.

```
curl -LJO https://raw.githubusercontent.com/KostasEreksonas/archrice/main/archrice.sh
chmod +x archrice.sh
./archrice.sh
```

# Features

Main system features that are installed by archrice script are presented below.

## Window Manager

For a graphical environment, Archrice script installs a suckless dynamic window manager and it's supplementary utilities. For more information about installed utilities and their configurations (i.e. applied patches and keybinds), click on the name of the utility.

* [dwm](https://github.com/KostasEreksonas/dwm-kostas) - custom build of dynamic window manager.
* [dwmblocks](https://github.com/KostasEreksonas/dwmblocks-kostas) - modular status bar for dwm.
* [st](https://github.com/KostasEreksonas/st-kostas) - custom build of suckless simple terminal.
* [slock](https://github.com/KostasEreksonas/slock-kostas) - custom build of screen locker utility.
* [dmenu](https://github.com/KostasEreksonas/dmenu-kostas) - custom build of suckless menu utility.

## System Scripts

For my custom build of dwm, I made a few scripts to enhance it's functionality.

* [locker](system_scripts/locker) -	terminal based menu with power management options.
![Locker script](/images/locker_script.png)
* [screenshot](system_scripts/screenshot) - a simple script for taking a screenshot of an active window.
* [screenshot clipboard](system_scripts/screenshot_clipboard) - a script to choose a part of the screen and save it to clipboard. 
* [paste clipboard](system_scripts/paste_clipboard) - paste the clipboard contents to an image file at ~/Photos/Screenshots.
* [piper](system_scripts/piper) - a script I got from [a paste in arza[.]us](http://arza.us/paste/piper) and is used to open links from dmenu with predefined software.

## Statusbar

For dwmblocks statusbar I made several scripts that are used for system monitoring.

* [sb-battery](statusbar/sb-battery) - display battery status and charge level.
* [sb-brightness](statusbar/sb-brightness) - display screen brightness percentage.
* [sb-clock](statusbar/sb-clock) - show current date and time.
* [sb-cpu_freq](statusbar/sb-cpu_freq) - show current CPU frequency.
* [sb-cpu_temp](statusbar/sb-cpu_temp) - show current CPU temperature.
* [sb-cpu_usage](statusbar/sb-cpu_usage) - show current CPU usage.
* [sb-kernel](statusbar/sb-kernel) - show current kernel version.
* [sb-memory](statusbar/sb-memory) - show memory usage.
* [sb-network](statusbar/sb-network) - show SSID and IP address of last connected wireless network.
* [sb-shutdown](statusbar/sb-shutdown) - open a terminal with a locker script terminal-based menu with power options.
* [sb-volume](statusbar/sb-volume) - show volume level.

## Aliases

Some useful bash aliases are in a `.bashrc` file. During setup the user is prompted to choose whether to keep and configure or to delete aliases.

* `blthon` - enable bluetooth service.
* `blthoff` - disable bluetooth service.
* `connect_wifi` - connect to a wifi network.
* `connect_hotspot` - connect to a hotspot network.
* `list_networks` - list available wireless networks.
* Aliases for games installed with Wine.

## Vim

Archrice script installs Vim terminal based text editor and `Pathogen` plugin manager with some plugins.

* `Nerd Tree` - file system explorer for Vim.
* `Pear Tree` - auto-pair plugin for Vim.
* `Vim Airline` - status/tabline for Vim.
* `Vim Solarized` - solarized color theme for Vim.
* `You Complete Me` - code completion engine for Vim.

## Other Software
Other software installed with archrice script include:
* `firefox` - web browser
* `mpv` - media player
* [Optional Installation] `wine` - compatibility layer for Windows applications.
