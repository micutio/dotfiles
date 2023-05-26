#!/bin/bash

##############################################################################
# setup script for OpenSUSE Tumbleweed                                       #
# 
# TODO: divide into automated setup and optional parts
# TODO: figure out whether gnome extensions can be installed via cli
##############################################################################

set -euo pipefail

# stage 0: set up folder structure
mkdir -p ~/dev/personal
mkdir -p ~/dev/other
mkdir -p ~/bin

# stage 1: initial install of all required programs
sudo zypper dup -y
sudo zypper install -t pattern devel_basis devel_C_C++ devel_python3
sudo zypper install htop git tmux zsh neovim curl wget
# 1.1: install oh my zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# 1.2: install omz extensions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# stage 3: install rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup update stable

# stage 4: install alacritty
zypper install cmake freetype-devel fontconfig-devel libxcb-devel libxkbcommon-devel
git clone https://github.com/alacritty/alacritty.git ~/dev/other/
cd ~/dev/other/alacritty
cargo build --release --features=wayland --features=x11
sudo tic -xe alacritty,alacritty-direct extra/alacritty.info
sudo cp target/release/alacritty /usr/local/bin # or anywhere else in $PATH
sudo cp extra/logo/alacritty-simple.svg /usr/share/pixmaps/Alacritty.svg
sudo desktop-file-install extra/linux/Alacritty.desktop
sudo update-desktop-database

# stage 5: install vivaldi
sudo zypper ar -f https://repo.vivaldi.com/stable/rpm/x86_64/
sudo rpm --import https://repo.vivaldi.com/stable/linux_signing_key.pub
sudo zypper install vivaldi-stable

# stage 6: install sdkman
curl -s "https://get.sdkman.io" | bash

# stage 7: configure firewall to let GSConnect work
# TODO: install gnome extensions

# stage 8: install snap for intellij and vscode

# stage 9: install and update golang

# stage 2: download and copy dotfiles from github
# 2.1 create ssh key
ssh-keygen -t ed25519 -C "wagner.mchl@googlemail.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
# after this, copy contents of ~/.ssh/id_ed25519.pub to github > new ssh key
# 2.2 clone dot files

# 2.3 copy dot files to home

# stage 10: set preferred dark/light wallpaper
mkdir -p /home/michael/Pictures/wallpaper

# stage 11: install gsettings-monitor for automated alacritty theme switch

# optional 1: install nvidia-drivers

# optional 2: install auto rgb-keyboard-light setter
