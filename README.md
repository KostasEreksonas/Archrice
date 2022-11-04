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
curl -LJO https://raw.githubusercontent.com/KostasEreksonas/Archrice/main/archrice.sh
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

* [extendDisplays](.local/bin/extendDisplays) - a script to extend multi-displays and make it permanent.
* [openmutt](.local/bin/openmutt) - a script to open mutt with a dwm shortcut.
* [openranger](.local/bin/openranger) - a script to open ranger with a dwm shortcut.
* [openvim](.local/bin/openvim) - a script to open vim with a dwm shortcut.
* [sb-battery](.local/bin/sb-battery) - display battery status and charge level.
* [sb-brightness](.local/bin/sb-brightness) - display screen brightness percentage.
* [sb-clock](.local/bin/sb-clock) - show current date and time.
* [sb-cpu_freq](.local/bin/sb-cpu_freq) - show current CPU frequency.
* [sb-cpu_temp](.local/bin/sb-cpu_temp) - show current CPU temperature.
* [sb-cpu_usage](.local/bin/sb-cpu_usage) - show current CPU usage.
* [sb-kernel](.local/bin/sb-kernel) - show current kernel version.
* [sb-memory](.local/bin/sb-memory) - show memory usage.
* [sb-network](.local/bin/sb-network) - show SSID and IP address of last connected wireless network.
* [sb-shutdown](.local/bin/sb-shutdown) - open a terminal with a locker script terminal-based menu with power options.
* [sb-volume](.local/bin/sb-volume) - show volume level.

## Aliases

During the installation of archrice script the user is prompted to create aliases for Wireless and Bluetooth network connections.

## Vim

Archrice script installs either Vim or Neovim terminal based text editor and `Pathogen` plugin manager with some plugins.

* [Nerd Tree](https://github.com/preservim/nerdtree) - file system explorer for Vim.
* [Pear Tree](https://github.com/tmsvg/pear-tree) - auto-pair plugin for Vim.
* [Vim Airline](https://github.com/vim-airline/vim-airline) - status/tabline for Vim.
* [Vim Airline Themes](https://github.com/vim-airline/vim-airline-themes) - collection of color themes for airline statusline.
* [Vim Solarized Theme](https://github.com/lifepillar/vim-solarized8) - solarized themes collection for Vim.
* [Vim Gruvbox Theme](https://github.com/lifepillar/vim-gruvbox8) - gruvbox themes collection for Vim.
* [Vim Fugitive](https://github.com/tpope/vim-fugitive) - Git plugin for Vim.
* [You Complete Me](https://github.com/ycm-core/YouCompleteMe) - code completion engine for Vim.

## Hacking applications

Recently I added some software I use for hacking and cybersecurity analysis. The list includes ***Nmap***, ***Wireshark*** and ***Radare2*** software and might be expandend later on.

## Other Software
Other software installed with archrice script include:
* `Firefox` - web browser
* `Mpv` - media player
* `Virtualbox / QEMU` - a hypervisor for x86 virtualization
* [Optional Installation] `Wine` - compatibility layer for Windows applications
