#!/bin/bash

##############################################################################
# setup script for OpenSUSE Tumbleweed                                       #
# 
# TODO: divide into automated setup and optional parts
# TODO: figure out whether gnome extensions can be installed via cli
# TODO: read up on bash conditionals, add arguments to start at default, post-install or any of the optional stages
##############################################################################

set -euo pipefail

printf "\nStage  0 - set up personal folder structure ------------------------------------\n"
mkdir -p ~/dev/personal
mkdir -p ~/dev/other
mkdir -p ~/bin

printf "\nStage  1 - initial update ------------------------------------------------------\n"
sudo zypper dup --no-confirm

printf "\nStage  2 - install standard programs from distro repos -------------------------\n"
sudo zypper install -t pattern devel_basis devel_C_C++ devel_python3 --no-confirm
sudo zypper install htop git tmux zsh neovim curl wget --no-confirm

printf "\nStage  3 - install vscode ------------------------------------------------------\n"
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo zypper addrepo https://packages.microsoft.com/yumrepos/vscode vscode
sudo zypper refresh
sudo zypper install code

printf "\nStage  4 - install oh my zsh and plugins ---------------------------------------\n"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

printf "\nStage  5 - install rust and associated programs --------------------------------\n"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup update stable
cargo install bottom
cargo install bat

printf "\nStage  6 - install alacritty ---------------------------------------------------\n"
zypper install cmake freetype-devel fontconfig-devel libxcb-devel libxkbcommon-devel
git clone https://github.com/alacritty/alacritty.git ~/dev/other/
cd ~/dev/other/alacritty
cargo build --release --features=wayland --features=x11
sudo tic -xe alacritty,alacritty-direct extra/alacritty.info
sudo cp target/release/alacritty /usr/local/bin # or anywhere else in $PATH
sudo cp extra/logo/alacritty-simple.svg /usr/share/pixmaps/Alacritty.svg
sudo desktop-file-install extra/linux/Alacritty.desktop
sudo update-desktop-database

printf "\nStage  7 - install vivaldi -----------------------------------------------------\n"
sudo zypper ar -f https://repo.vivaldi.com/stable/rpm/x86_64/
sudo rpm --import https://repo.vivaldi.com/stable/linux_signing_key.pub
sudo zypper install vivaldi-stable

printf "\nStage  8 - install sdkman ------------------------------------------------------\n"
curl -s "https://get.sdkman.io" | bash

printf "\nStage  9 - install snap --------------------------------------------------------\n"
sudo zypper addrepo --refresh https://download.opensuse.org/repositories/system:/snappy/openSUSE_Tumbleweed snappy
sudo zypper --gpg-auto-import-keys refresh
sudo zypper dup --from snappy
sudo zypper install snapd
sudo systemctl enable --now snapd
sudo systemctl enable --now snapd.apparmor
# need to reboot before installing snap apps

printf "\nStage 10 - set preferred dark and light wallpapers -----------------------------\n"
mkdir -p /home/michael/Pictures/wallpaper
gsettings set org.gnome.desktop.background picture-uri-dark file:////home/michael/Pictures/wallpaper/dark.jpg
gsettings set org.gnome.desktop.background picture-uri file:////home/michael/Pictures/wallpaper/light.jpg

printf "\nStage 11 - create ssh key for github -------------------------------------------\n"
ssh-keygen -t ed25519 -C "wagner.mchl@googlemail.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
# after this, copy contents of ~/.ssh/id_ed25519.pub to github > new ssh key

printf "\nStage 12 - configure firewall to lat GSConnect work ----------------------------\n"
sudo firewall-cmd --permanent --new-service=GSConnect
sudo firewall-cmd --permanent --service=GSConnect --set-description="KDE Connect implementation for GNOME"
sudo firewall-cmd --permanent --service=GSConnect --set-short="GSConnect"
sudo firewall-cmd --permanent --service=GSConnect --add-port=1716/tcp
sudo firewall-cmd --permanent --service=GSConnect --add-port=1716/udp
sudo firewall-cmd --permanent --service=GSConnect --add-port=1739-1764/tcp
sudo firewall-cmd --permanent --service=GSConnect --add-port=1739-1764/udp
sudo firewall-cmd --permanent --zone=public --add-service=GSConnect
sudo firewall-cmd --reload

printf "\nInitial setup is done. REBOOT and add ssh key to github to continue ------------\n"

printf "\nStage 13 - download dotfiles and copy to home ----------------------------------\n"
git clone git@github.com:Micutio/dotfiles.git ~/dev/personal
cp -r ~/dev/personal/dotfiles/general/. ~ 

printf "\nStage 14 -  download gsettings monitor and add to autostart --------------------\n"
touch ~/.config/autostart/gsettings-monitor.desktop
cat <<EOF >> ~/.config/autostart/gsettings-monitor.desktop
[Desktop Entry]
Name=gsettings-monitor
GenericName=gsettings-monitor
Comment=Automatic switching between dark and light alacritty themes
Exec=/home/michael/bin/gsettings-monitor
Terminal=false
Type=Application
X-GNOME-Autostart-enabled=true
EOF

printf "\nOptional 1 - install snap nVidia drivers ---------------------------------------\n"
sudo zypper addrepo --refresh https://download.nvidia.com/opensuse/tumbleweed NVIDIA
sudo zypper search -s x11-video-nvidiaG0* nvidia-video-G06*
sudo zypper install nvidia-video-G06 --no-confirm
sudo zypper install nvidia-gl-G06 --no-confirm
printf "\n           - DONE, better reboot now -------------------------------------------\n"

printf "\nOptional 2 - install snap apps -------------------------------------------------\n"
snap install intellij-idea-community --classic

# optional 2: install auto rgb-keyboard-light setter
