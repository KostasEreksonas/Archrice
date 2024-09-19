# Archrice

Install Arch Linux and use the archrice configuration script to install programs and load configs.

Table of Contents
=================
* [Installation](#Installation)

# Installation

1. Download Arch iso from https://archlinux.org/download/ .

2. Write Arch iso to usb drive:
    - `dd if=<arch-iso> of=/dev/<usb-device> bs=4M status=progress conv=fdatasync`

3. Reboot into Arch live usb.

4. Get name if network interface:
    - `ip a`

5. Connect to the internet:
    - `iwctl station <network-interface> connect <SSID>`

6. Get name of the disk to install Arch to:
    - `lsblk`

7. Partition the disk:
    - `fdisk /dev/<disk-to-partition>`

8. Partitions to create:
    - /dev/<disk-to-partition>1 - Boot partition, size: 500M
    - /dev/<disk-to-partition>2 - Swap partition, size: 8G
    - /dev/<disk-to-partition>3 - Home partiiton, size: rest of the drive

9. Create filesystems:
    - `mkfs.ext4 -T small /dev/<disk-to-install>1`
    - `mkswap /dev/<disk-to-install>2`
    - `swapon /dev/<disk-to-install>2`
    - `mkfs.ext4 /dev/<disk-to-install>3`

10. Mount filesystems:
    - `mount /dev/<disk-to-install>3 /mnt`
    - `mkdir /mnt/boot`
    - `mount /dev/<disk-to-install>1 /mnt/boot`

11. Install base system:
    - `pacstrap -K /mnt base base-devel linux linux-firmware vim texinfo man-db man-pages`

12. Generate fstab:
    - `gensftab -U /mnt >> /mnt/etc/fstab`

13. Chroot into the new environment:
    - `arch-chroot /mnt`

14. Set timezone:
    - `ln -sf /usr/share/zoneinfo/Region/City /etc/localtime`
    - `hwclock --systohc`

15. Set localization:
    - Run `vim /etc/locale.gen` and uncomment locale: en_US.UTF-8 UTF-8
    - `locale-gen`
    - `echo "LANG=en_US.UTF-8" | tee -a /etc/locale.conf`

16. Set hostname:
    - `echo "Arch" | tee -a /etc/hostname`

17. Set root password:
    - `passwd`

18. Enable sudo for other users:
    - `visudo`
    - Uncomment line: `# %wheel ALL=(ALL:ALL) ALL`

19. Install and configure bootloader and network manager:
    - `pacman -S grub networkmanager`
    - `grub-install --target=i386-pc /dev/<drive-to-install>`
    - `grub-mkconfig -o /boot/grub/grub.cfg`
    - `systemctl enable NetworkManager.service`

20. Exit chrooted environment:
    - `exit`

21. Unmount partitions:
    - `umount -R /mnt`

22. Reboot:
    - `reboot`

23. Login to the new install and start wifi network:
    - `nmcli device wifi connect <SSID> password <password>`

24. Download configuration script:
    - `curl -LJO https://raw.githubusercontent.com/KostasEreksonas/Archrice/main/archrice`

25. Make the configuration script executable:
    - `chmod +x archrice`

26. Run the configuration script:
    - `./archrice`
