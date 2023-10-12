# Archrice

1. Install dependencies from `dependencies.txt`:
2. Create user `kostas`.
    2.1. `useradd - m kostas`
3. Add user `kostas` to groups `wheel, audio, video, optical, storage`.
    3.1. `usermod -aG wheel,audio,video,optical,storage kostas`
4. Create directories:
    4.1. ./local/bin/
    4.2. ./local/share/fonts/
    4.3. Desktop/
    4.4. Documents/git/
    4.5. Documents/aur/
    4.6. Downloads/
    4.7. Music/
    4.8. Pictures/Screenshots/
    4.9. Videos/OBS/
    4.10. `mkdir -p Desktop/ Documents/git/ Documents/aur/ Downloads/ Music/ Pictures/Screenshots/ Videos/OBS/`
5. Install system packages from `./package_lists/pacman_packages.txt`
6. Clone and install suckless utilities from git:
    6.1. dwm-kostas
    6.2. dwmblocks-kostas
    6.3. dmenu-kostas
    6.4. st-kostas
    6.5. slock-kostas
7. Git clone and install yay.
8. Install aur packages from `./package_lists/aur_packages.txt`
9. Download and unpack Hack Nerd Fonts to `./local/share/fonts/`
10. Copy statusbar scripts from `./local/bin` to `~/.local/bin/`
11. Copy system scripts to `/usr/local/bin`
12. Copy xorg.conf.d to `/etc/X11/`
13. Copy dotfiles to `~/.config` (create dir if not existing)
14. Configure nvim:
    14.1. Install pathogen to `~/.config/nvim`
    14.2. Git clone plugins to `bunlde` folder
    14.3. Create folder `colors`
    14.4. Git clone colorschemes to `colors` folder
15. Configure `pass`
16. Copy `neomutt` config to `~/.config/mutt/`
    16.1. Update email addresses in config files
    16.2. Move `.msmtprc` and `.mbsyncrc` to `~/`
17. Configure bash pureline.
18. Configure `.bashrc`:
    18.1. Add aliases for `list_neworks`, `connect_wifi` and `connect_hotspot` commands
    18.2. Add `~/local/bin/` to `$PATH`
19. Use `dialog` for displaying configuration options.
20. Configure `pacman.conf`
21. Clone Automatic1111
