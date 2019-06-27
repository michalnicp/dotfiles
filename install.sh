#!/bin/bash

set -euo pipefail

if [ "${1:-}" = "--debug" ] || [ "${1:-}" = "-d" ]; then
    set -x
fi

# colors
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
nc='\033[0m'

if [[ $EUID -eq 0 ]]; then
    printf "${red}Please run as normal user.${nc}" >&2
    # echo "This script must be run with sudo" 1>&2
    exit 1
fi

# ask for sudo password, see sudo(8)
sudo -v
# while true; do sleep 1m; sudo -nv; done &

# update mirrorlist
# curl https://www.archlinux.org/mirrorlist/?country=CA&country=US&protocol=https&use_mirror_status=on

# use reflector to rank the fastest mirrors
sudo pacman -S --noconfirm reflector

sudo reflector --protocol http --latest 30 --number 20 --sort rate --save /etc/pacman.d/mirrorlist

# full system upgrade
sudo pacman -Syu --noconfirm

packages=(
    base-devel
    git
    openssh
    bash-completion

    xorg xorg-xinit
    xdg-user-dirs

    # fonts
    fontconfig ttf-dejavu ttf-liberation noto-fonts noto-fonts-cjk noto-fonts-emoji

    # window manager
    bspwm sxhkd

    # image viewer
    feh

    # editor
    neovim

    # terminal emulator
    alacritty

    # file manager
    ranger

    # browser
    firefox
)

# install packages
sudo pacman -S --noconfirm ${packages[*]}

# install yay
cd /tmp
rm -rf yay
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm

# install aur packages
aur_packages=(
    lemonbar-git
)

yay -Syu
yay -S --noconfirm ${aur_packages[*]}

# reflector
sudo bash -c "cat > /etc/systemd/system/reflector.service << EOF
[Unit]
Description=Pacman mirrorlist update
Requires=network-online.target
After=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/bin/reflector --protocol http --latest 30 --number 20 --sort rate --save /etc/pacman.d/mirrorlist

[Install]
RequiredBy=multi-user.target
EOF"
sudo systemctl daemon-reload
sudo systemctl enable reflector

# sshd service
sudo sed -i '/^#X11Forwarding/c\X11Forwarding yes' /etc/ssh/sshd_config
sudo systemctl enable sshd
sudo systemctl start sshd

# disable embedded bitmap for all fonts, enable sub-pixel RGB rendering, and enable the LCD filter
# which is designed to reduce colour fringing when subpixel rendering is used.
mkdir -p ~/.config/fontconfig/conf.d
ln -sf /etc/fonts/conf.avail/70-no-bitmaps.conf ~/.config/fontconfig/conf.d/70-no-bitmaps.conf
ln -sf /etc/fonts/conf.avail/10-sub-pixel-rgb.conf ~/.config/fontconfig/conf.d/10-sub-pixel-rgb.conf
ln -sf /etc/fonts/conf.avail/11-lcdfilter-default.conf ~/.config/fontconfig/conf.d/11-lcdfilter-default.conf

mkdir -p ~/.config/fontconfig
ln -s ~/dotfiles/.config/fontconfig/fonts.conf ~/.config/fontconfig/fonts.conf

# dotfiles
cd ~
git clone https://github.com/michalnicp/dotfiles.git

# bash
ln -s ~/dotfiles/.bashrc ~/.bashrc
ln -s ~/dotfiles/.bash_profile ~/.bash_profile

# bin
ln -s ~/dotfiles/bin ~/bin

# xinit
ln -s ~/dotfiles/.xinitrc ~/.xinitrc

# neovim
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

mkdir -p ~/.config/nvim
ln -sf ~/dotfiles/.config/nvim/init.vim ~/.config/nvim/init.vim

# install vim plugins for the first time
nvim -u <(sed -n '/^call plug#begin/,/^call plug#end/p' ~/.config/nvim/init.vim) +PlugInstall +qall

# alacritty
mkdir -p ~/.config/alacritty
ln -sf ~/dotfiles/.config/alacritty/alacritty.yml ~/.config/alacritty/alacritty.yml

# git
git config --global core.excludesfile '~/.gitignore_global'
ln -sf ~/dotfiles/.gitignore_global ~/.gitignore_global

# bspwm
mkdir -p ~/.config/sxhkd
ln -sf ~/dotfiles/.config/sxhkd/sxhkdrc ~/.config/sxhkd/sxhkdrc

mkdir -p ~/.config/bspwm
ln -sf ~/dotfiles/.config/bspwm/bspwmrc ~/.config/bspwm/bspwmrc

# mkdir -p ~/.config
ln -sf ~/dotfiles/.config/user-dirs.dirs ~/.config/user-dirs.dirs
sudo xdg-user-dirs-update
