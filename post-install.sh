#!/usr/bin/env bash

pacman -Syu --noconfirm

pacman -S --noconfirm reflector rsync
reflector -l 200 --sort rate --save /etc/pacman.d/mirrorlist

pacman -S --noconfirm git base-devel

# install yay
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

# enable x11 forwarding
sed -i '/^#X11Forwarding/c\X11Forwarding yes' /etc/ssh/sshd_config
systemctl restart sshd

# install xorg
pacman -S --noconfirm xorg xorg-xinit xorg-xauth

# install fonts
pacman -S --noconfirm \
    fontconfig \
    ttf-dejavu \
    ttf-liberation \
    noto-fonts \
    noto-fonts-cjk \
    noto-fonts-emoji

# disable embedded bitmap for all fonts, enable sub-pixel RGB rendering, and enable the LCD filter
# which is designed to reduce colour fringing when subpixel rendering is used.
ln -s /etc/fonts/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.d
ln -s /etc/fonts/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d
ln -s /etc/fonts/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d

# configure fonts
mkdir -p .config/fontconfig
cat << EOF > ./config/fontconfig/fonts.conf
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>

    <!-- general settings -->
    <match target="font">
        <edit name="autohint" mode="assign"><bool>false</bool></edit>
        <edit name="antialias" mode="assign"><bool>true</bool></edit>
        <edit name="hinting" mode="assign"><bool>true</bool></edit>
        <edit name="hintstyle" mode="assign"><const>hintslight</const></edit>
        <edit name="lcdfilter" mode="assign"><const>lcddefault</const></edit>
    </match>

    <match target="pattern">
        <test qual="any" name="family"><string>serif</string></test>
        <edit name="family" mode="prepend" binding="strong"><string>DejaVu Serif</string></edit>
    </match>

    <match target="pattern">
        <test qual="any" name="family"><string>sans-serif</string></test>
        <edit name="family" mode="prepend" binding="strong"><string>DejaVu Sans</string></edit>
    </match>

    <match target="pattern">
        <test qual="any" name="family"><string>monospace</string></test>
        <edit name="family" mode="prepend" binding="strong"><string>DejaVu Sans Mono</string></edit>
    </match>
</fontconfig>
EOF

# install dwm
git clone https://git.suckless.org/dwm
cd dwm
make clean install

# install st
git clone https://git.suckless.org/st
cd st
make clean install

# install ranger file manager
pacman -S ranger

# install user dirs
pacman -S xdg-user-dirs
# edit .config/user-dirs.dirs and change to lowercase
cat << EOF > user-dirs.dirs
XDG_DESKTOP_DIR="$HOME/desktop"
XDG_DOWNLOAD_DIR="$HOME/downloads"
XDG_TEMPLATES_DIR="$HOME/templates"
XDG_PUBLICSHARE_DIR="$HOME/public"
XDG_DOCUMENTS_DIR="$HOME/documents"
XDG_MUSIC_DIR="$HOME/music"
XDG_PICTURES_DIR="$HOME/pictures"
XDG_VIDEOS_DIR="$HOME/videos"
EOF
