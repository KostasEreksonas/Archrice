#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
#PS1='[\u@\h \W]\$ '

export PATH=$PATH:/home/kostas/bin
export TERMINAL=st
#export PS1="\[$(tput bold)\]\[$(tput setaf 1)\][\[$(tput setaf 3)\]\u\[$(tput setaf 2)\]@\[$(tput setaf 4)\]\h \[$(tput setaf 5)\]\W\[$(tput setaf 1)\]]\[$(tput setaf 7)\]\\$ \[$(tput sgr0)\]"

RANGER_LOAD_DEFAULT_RC=FALSE

# Aliases

#  -------
# | Wi-Fi |
#  -------

# Connect to wifi
alias connect_wifi='nmcli device wifi connect SSID password `pass wifi/wifi`'

# Connect to hotspot
alias connect_hotspot='nmcli device wifi connect SSID password `pass wifi/hotspot`'

# List networks
alias list_networks='nmcli device wifi list'
