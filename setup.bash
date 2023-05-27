#!/bin/bash

##############################################################################
# setup script for OpenSUSE Tumbleweed                                       #
# 
# TODO: divide into automated setup and optional parts
# TODO: figure out whether gnome extensions can be installed via cli
# TODO: read up on bash conditionals, add arguments to start at default, post-install or any of the optional stages
##############################################################################

set -euo pipefail
set -o errexit
set -o nounset

# A help menu showing how to use the script and what the expected output is.
_usage() {
cat << EOF
  ${0} [optional arguments] [setup mode]

  Optional Arguments:
    -ss | --show-steps: show all individual steps of the setup script

  Setup Mode:
    -i | --initial-install (default): performs the initial setup steps after
                                      which a reboot is usually in order
    -p | --post-install             : performs setup steps which require the
                                      initial setup and reboot already done
    -s | --individual-step <step no>: performs an individual setup step from
                                      any of the above categories or optionals
EOF
}

SETUP_MODE=-1 # 0 = default, 1 = post_install, 2 = individual step

_validate_setup_mode() {
    if (( SETUP_MODE != -1 )); then
        printf "\nError: Only one setup mode possible at a time!"
        exit 1
    fi
}

main() {
    # true if initial setup, false if already done initial setup and rebooted
    local individual_step=0

    while [[ "${#}" -gt 0 ]]; do
        case "${1}" in
            -h|--help)
                _usage
                exit 0
                ;;
            -i|--initial-install)
                validate_setup_mode
                SETUP_MODE=0
                # TODO
                ;;
            -p|--post-install)
                validate_setup_mode
                SETUP_MODE=1
                # TODO
                ;;
            -s|--individual-step)
                validate_setup_mode
                SETUP_MODE=2
                individual_step="${2}"
                ;;
        esac
        
        if (( SETUP_MODE == -1 )) then
            SETUP_MODE=0
        fi

        printf "\nSetup mode: "
        if (( SETUP_MODE == 0 )) then
            printf "initial setup"
        fi
        if (( SETUP_MODE == 1 )) then
            printf "post-reboot setup"
        fi
        if (( SETUP_MODE == 2 )) then
            printf "individual step: %d", "${individual_step}"
        fi

    done

    local is_initial_setup=[ SETUP_MODE -eq 0] 
    local is_individual_step=[ SETUP_MODE -eq 2]
    if $is_initial_setup || $is_individual_step ; then
        printf "\nStage  0 - set up personal folder structure ------------------------------------\n"
        mkdir -p ~/dev/personal
        mkdir -p ~/dev/other
        mkdir -p ~/bin

        printf "\nStage  1 - initial update ------------------------------------------------------\n"
        sudo zypper dup --no-confirm

        printf "\nStage  2 - install standard programs from distro repos -------------------------\n"
        sudo zypper install --no-confirm -t pattern devel_basis devel_C_C++ devel_python3
        sudo zypper install --no-confirm htop git tmux zsh neovim curl wget

        printf "\nStage  3 - install vscode ------------------------------------------------------\n"
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
        sudo zypper addrepo https://packages.microsoft.com/yumrepos/vscode vscode
        sudo zypper refresh
        sudo zypper install code

        printf "\nStage  4 - install oh my zsh and plugins ---------------------------------------\n"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-syntax-highlighting

        printf "\nStage  5 - install rust and associated programs --------------------------------\n"
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
        rustup update stable
        cargo install bottom
        cargo install bat

        printf "\nStage  6 - install alacritty ---------------------------------------------------\n"
        sudo zypper install --no-confirm cmake freetype-devel fontconfig-devel libxcb-devel libxkbcommon-devel
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
        sudo zypper install --no-confirm vivaldi-stable

        printf "\nStage  8 - install sdkman ------------------------------------------------------\n"
        curl -s "https://get.sdkman.io" | bash

        printf "\nStage  9 - install snap --------------------------------------------------------\n"
        sudo zypper addrepo --refresh https://download.opensuse.org/repositories/system:/snappy/openSUSE_Tumbleweed snappy
        sudo zypper --gpg-auto-import-keys refresh
        sudo zypper dup --from snappy
        sudo zypper install --no-confirm snapd
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
    fi
    printf "\nInitial setup is done. REBOOT and add ssh key to github to continue ------------\n"

    if (( SETUP_MODE == 1 )) then
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
    fi

    printf "\nOptional 1 - install snap nVidia drivers ---------------------------------------\n"
    sudo zypper addrepo --refresh https://download.nvidia.com/opensuse/tumbleweed NVIDIA
    sudo zypper search -s x11-video-nvidiaG0* nvidia-video-G06*
    sudo zypper install nvidia-video-G06 --no-confirm
    sudo zypper install nvidia-gl-G06 --no-confirm
    printf "\n           - DONE, better reboot now -------------------------------------------\n"

    printf "\nOptional 2 - install snap apps -------------------------------------------------\n"
    snap install intellij-idea-community --classic

# optional 2: install auto rgb-keyboard-light setter
}
