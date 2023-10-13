#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

#  ---------
# | Aliases |
#  ---------

alias connectWifi='nmcli device wifi connect <SSID> password `pass wifi/<SSID>`'
alias connectHotspot='nmcli device wifi connect <SSID> password `pass wifi/<SSID>`'
alias listNetworks="nmcli device wifi list"
alias startArch="virsh --connect qemu:///system start archlinux && virt-manager --connect qemu:///system --show-domain-console archlinux"
alias startWin10="virsh --connect qemu:///system start win10 && virt-manager --connect qemu:///system --show-domain-console win10"
alias startKali="virsh --connect qemu:///system start debian12 && virt-manager --connect qemu:///system --show-domain-console debian12"

#  ---------
# | Exports |
#  ---------

export PATH=$PATH:/home/kostas/.local/bin
export TERMINAL=st

#  ---------
# | Sources |
#  ---------

source ~/pureline/pureline ~/.pureline.conf

#  ------
# | Misc |
#  ------

RANGER_LOAD_DEFAULT_RC=FALSE
