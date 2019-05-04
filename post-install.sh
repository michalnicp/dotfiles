#!/usr/bin/env bash

set -euo pipefail

# colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ $EUID -eq 0 ]]; then
    echo "Please run as normal user." >&2
    exit 1
fi

# ask for password
sudo -v || exit $?
while true; do sleep 1m; sudo -nv; done &

# get latest mirrorlist
# tmpfile=$(mktemp --suffix=_mirrorlist)
# curl -o $tmpfile https://www.archlinux.org/mirrorlist/?country=CA&country=US&protocol=https&use_mirror_status=on
# mv /etc/pacman.d/mirrorlist{,.orig}
# mv $tmpfile /etc/pacman.d/mirrorlist

# install reflector
sudo pacman -S --noconfirm --needed reflector

sudo bash -c "cat > /etc/systemd/system/reflector.service << EOF
[Unit]
Description=Pacman mirrorlist update
Requires=network-online.target
After=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/bin/reflector --protocol https --latest 30 --number 20 --sort rate --save /etc/pacman.d/mirrorlist

[Install]
RequiredBy=multi-user.target
EOF"
sudo systemctl daemon-reload
sudo systemctl enable reflector.service

sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bkp."$(date +%Y%m%d%H%M%S)"
sudo reflector --protocol https --latest 30 --number 20 --sort rate --save /etc/pacman.d/mirrorlist

# full system upgrade
sudo pacman -Syyu --noconfirm

# install yay
sudo pacman -S --noconfirm --needed base-devel git

git -C /tmp/yay pull || git clone https://aur.archlinux.org/yay.git /tmp/yay
(cd /tmp/yay && makepkg -si --noconfirm)

# install ssh
sudo pacman -S --noconfirm --needed openssh

sudo sed -i '/^#X11Forwarding/c\X11Forwarding yes' /etc/ssh/sshd_config

sudo systemctl enable sshd
sudo systemctl start sshd

# install xorg
sudo pacman -S --noconfirm --needed xorg xorg-xinit
ln -sf "${DIR}/.xinitrc" "${HOME}/.xinitrc"

# install fonts
sudo pacman -S --noconfirm --needed \
    fontconfig \
    ttf-dejavu \
    ttf-liberation \
    noto-fonts \
    noto-fonts-cjk \
    noto-fonts-emoji

# disable embedded bitmap for all fonts, enable sub-pixel RGB rendering, and enable the LCD filter
# which is designed to reduce colour fringing when subpixel rendering is used.
mkdir -p "${HOME}/.config/fontconfig/conf.d"
ln -sf /etc/fonts/conf.avail/70-no-bitmaps.conf "${HOME}/.config/fontconfig/conf.d/70-no-bitmaps.conf"
ln -sf /etc/fonts/conf.avail/10-sub-pixel-rgb.conf "${HOME}/.config/fontconfig/conf.d/10-sub-pixel-rgb.conf"
ln -sf /etc/fonts/conf.avail/11-lcdfilter-default.conf "${HOME}/.config/fontconfig/conf.d/11-lcdfilter-default.conf"

mkdir -p "${HOME}/.config/fontconfig"
ln -sf "${DIR}.config/fontconfig/fonts.conf" "${HOME}/.config/fontconfig/fonts.conf"

# install xdg
sudo pacman -S --noconfirm --needed xdg-user-dirs

mkdir -p "${HOME}/.config"
ln -sf "${DIR}/.config/user-dirs.dirs" "${HOME}/.config/user-dirs.dirs"
xdg-user-dirs-update

# install bspwm (window manager)
sudo pacman -S --noconfirm --needed bspwm
mkdir -p "${HOME}/.config/bspwm"
ln -sf "${DIR}/.config/bspwm/bspwmrc" "${HOME}/.config/bspwm/bspwmrc"

# install sxhkd (hotkey deamon)
sudo pacman -S --noconfirm --needed sxhkd
mkdir -p "${HOME}/.config/sxhkd"
ln -sf "${DIR}/.config/sxhkd/sxhkdrc" "${HOME}/.config/sxhkd/sxhkdrc"

# create symlinks
ln -sf "${DIR}/.bashrc" "${HOME}/.bashrc"
ln -sf "${DIR}/.bash_profile" "${HOME}/.bash_profile"

# install git
git config --global core.excludesfile '~/.gitignore_global'
ln -sf "${DIR}/.gitignore_global" "${HOME}/.gitignore_global"

# install neovim
sudo pacman -S --noconfirm --needed neovim

curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

mkdir -p ~/.config/nvim
ln -sf "${DIR}/.config/nvim/init.vim" "${HOME}/.config/nvim/init.vim"
nvim -u <(sed -n '/^call plug#begin/,/^call plug#end/p' .config/nvim/init.vim) +PlugInstall +qall

# install alacritty (terminal emulator)
sudo pacman -S --noconfirm alacritty

mkdir -p "${HOME}/.config/alacritty"
ln -sf "${DIR}/.config/alacritty/alacritty.yml" "${HOME}/.config/alacritty/alacritty.yml"

# install ranger (file manager)
sudo pacman -S --noconfirm ranger

# install web browsers
sudo pacman -S --noconfirm chromium firefox
