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
    -i | --initial-setup (default)  : performs the initial setup steps after
                                      which a reboot is usually in order
    -p | --post-reboot-setup        : performs setup steps which require the
                                      initial setup and reboot already done
    -o | --optional-setup           : performs optional setup steps
    -s | --individual-step <step no>: performs an individual setup step from
                                      any of the above categories or optionals
EOF
}

SETUP_MODE=-1 # 0 = default, 1 = post_install, 2 = individual step

_validate_setup_mode() {
    if (( SETUP_MODE != -1 )); then
        printf "\nError: Only one setup mode possible at a time!\n"
        exit 1
    fi
}

# Setup steps ################################################################

_setup_directories() {
    mkdir -p ~/dev/personal
    mkdir -p ~/dev/other
    mkdir -p ~/bin
}

_setup_initial_update() {
    sudo zypper dup --no-confirm
}

_setup_standard_programs() {
    sudo zypper install --no-confirm -t pattern devel_basis devel_C_C++ devel_python3
    sudo zypper install --no-confirm htop git tmux zsh neovim curl wget
}

_setup_vscode() {
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo zypper addrepo https://packages.microsoft.com/yumrepos/vscode vscode
    sudo zypper refresh
    sudo zypper install code
}

_setup_zsh() {
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-syntax-highlighting
}

_setup_rust() {
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    rustup update stable
    cargo install bottom
    cargo install bat
}

_setup_alacritty() {
    sudo zypper install --no-confirm cmake freetype-devel fontconfig-devel libxcb-devel libxkbcommon-devel
    git clone https://github.com/alacritty/alacritty.git ~/dev/other/
    cd ~/dev/other/alacritty
    cargo build --release --features=wayland --features=x11
    sudo tic -xe alacritty,alacritty-direct extra/alacritty.info
    sudo cp target/release/alacritty /usr/local/bin # or anywhere else in $PATH
    sudo cp extra/logo/alacritty-simple.svg /usr/share/pixmaps/Alacritty.svg
    sudo desktop-file-install extra/linux/Alacritty.desktop
    sudo update-desktop-database
}

_setup_vivaldi() {
    sudo zypper ar -f https://repo.vivaldi.com/stable/rpm/x86_64/
    sudo rpm --import https://repo.vivaldi.com/stable/linux_signing_key.pub
    sudo zypper install --no-confirm vivaldi-stable
}

_setup_sdkman() {
    curl -s "https://get.sdkman.io" | bash
}

_setup_snap() {
    sudo zypper addrepo --refresh https://download.opensuse.org/repositories/system:/snappy/openSUSE_Tumbleweed snappy
    sudo zypper --gpg-auto-import-keys refresh
    sudo zypper dup --from snappy
    sudo zypper install --no-confirm snapd
    sudo systemctl enable --now snapd
    sudo systemctl enable --now snapd.apparmor
    # need to reboot before installing snap apps
}

_setup_wallpapers() {
    mkdir -p /home/michael/Pictures/wallpaper
    gsettings set org.gnome.desktop.background picture-uri-dark file:////home/michael/Pictures/wallpaper/dark.jpg
    gsettings set org.gnome.desktop.background picture-uri file:////home/michael/Pictures/wallpaper/light.jpg
}

_setup_ssh_key() {
    ssh-keygen -t ed25519 -C "wagner.mchl@googlemail.com"
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519
    # after this, copy contents of ~/.ssh/id_ed25519.pub to github > new ssh key
}

_setup_firewall() {
    sudo firewall-cmd --permanent --new-service=GSConnect
    sudo firewall-cmd --permanent --service=GSConnect --set-description="KDE Connect implementation for GNOME"
    sudo firewall-cmd --permanent --service=GSConnect --set-short="GSConnect"
    sudo firewall-cmd --permanent --service=GSConnect --add-port=1716/tcp
    sudo firewall-cmd --permanent --service=GSConnect --add-port=1716/udp
    sudo firewall-cmd --permanent --service=GSConnect --add-port=1739-1764/tcp
    sudo firewall-cmd --permanent --service=GSConnect --add-port=1739-1764/udp
    sudo firewall-cmd --permanent --zone=public --add-service=GSConnect
    sudo firewall-cmd --reload
}

_post_setup_dotfiles() {
    git clone git@github.com:Micutio/dotfiles.git ~/dev/personal
    cp -r ~/dev/personal/dotfiles/general/. ~ 
}

_post_setup_gsettings_monitor() {
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
}

_opt_setup_nvidia_drivers() {
    sudo zypper addrepo --refresh https://download.nvidia.com/opensuse/tumbleweed NVIDIA
    sudo zypper search -s x11-video-nvidiaG0* nvidia-video-G06*
    sudo zypper install nvidia-video-G06 --no-confirm
    sudo zypper install nvidia-gl-G06 --no-confirm
}

_opt_setup_intellij() {
    snap install intellij-idea-community --classic
}

# TODO: optional: install auto rgb-keyboard-light setter
declare -a INITIAL_SETUP_DESCRIPTIONS
INITIAL_SETUP_DESCRIPTIONS[0]="set up directories" 
INITIAL_SETUP_DESCRIPTIONS[1]="initial update" 
INITIAL_SETUP_DESCRIPTIONS[2]="install standard programs" 
INITIAL_SETUP_DESCRIPTIONS[3]="install vscode" 
INITIAL_SETUP_DESCRIPTIONS[4]="install zsh and omz" 
INITIAL_SETUP_DESCRIPTIONS[5]="install rust" 
INITIAL_SETUP_DESCRIPTIONS[6]="install alacritty" 
INITIAL_SETUP_DESCRIPTIONS[7]="install sdkman" 
INITIAL_SETUP_DESCRIPTIONS[8]="install vivaldi" 
INITIAL_SETUP_DESCRIPTIONS[9]="set up dark and light wallpaper" 
INITIAL_SETUP_DESCRIPTIONS[10]="create ssh key" 
INITIAL_SETUP_DESCRIPTIONS[11]="set up firewall" 

declare -a INITIAL_SETUP_FUNCTIONS
INITIAL_SETUP_FUNCTIONS[0]="_setup_directories"
INITIAL_SETUP_FUNCTIONS[1]="_setup_initial_update"
INITIAL_SETUP_FUNCTIONS[2]="_setup_standard_programs"
INITIAL_SETUP_FUNCTIONS[3]="_setup_vscode"
INITIAL_SETUP_FUNCTIONS[4]="_setup_zsh"
INITIAL_SETUP_FUNCTIONS[5]="_setup_rust"
INITIAL_SETUP_FUNCTIONS[6]="_setup_alacritty"
INITIAL_SETUP_FUNCTIONS[7]="_setup_vivaldi"
INITIAL_SETUP_FUNCTIONS[8]="_setup_sdkman"
INITIAL_SETUP_FUNCTIONS[9]="_setup_wallpapers"
INITIAL_SETUP_FUNCTIONS[10]="_setup_ssh_key"
INITIAL_SETUP_FUNCTIONS[11]="_setup_firewall"

declare -a POST_SETUP_DESCRIPTIONS
POST_SETUP_DESCRIPTIONS[0]="download dotfiles"
POST_SETUP_DESCRIPTIONS[1]="setup gsettings-monitor"

declare -a POST_SETUP_FUNCTIONS
POST_SETUP_FUNCTIONS[0]="_post_setup_dotfiles"
POST_SETUP_FUNCTIONS[1]="_post_setup_gsettings_monitor"

declare -a OPT_SETUP_DESCRIPTIONS
OPT_SETUP_DESCRIPTIONS[0]="install nvidia drivers"
OPT_SETUP_DESCRIPTIONS[1]="install intellij"

declare -a OPT_SETUP_FUNCTIONS
OPT_SETUP_FUNCTIONS[0]="_opt_setup_nvidia_drivers"
OPT_SETUP_FUNCTIONS[1]="_opt_setup_intellij"

_show_steps() {
    printf "\ninitial setup steps:\n"
    for i in "${!INITIAL_SETUP_DESCRIPTIONS[@]}"; do
        printf "%i - %s\n" "$i" "${INITIAL_SETUP_DESCRIPTIONS["$i"]}"
    done
    
    printf "\npost-reboot setup steps:\n"
    for i in "${!POST_SETUP_DESCRIPTIONS[@]}"; do
        printf "%i - %s\n" "$i" "${POST_SETUP_DESCRIPTIONS["$i"]}"
    done
    
    printf "\noptional setup steps:\n"
    for i in "${!OPT_SETUP_DESCRIPTIONS[@]}"; do
        printf "%i - %s\n" "$i" "${OPT_SETUP_DESCRIPTIONS["$i"]}"
    done
}

main() {
    # true if initial setup, false if already done initial setup and rebooted
    local individual_step=-1

    while [[ "${#}" -gt 0 ]]; do
        # printf "\nreading argument: %s\n" "${1}"
        case "${1}" in
            -h|--help)
                _usage
                exit 0
                ;;
            -i|--initial-setup)
                _validate_setup_mode
                SETUP_MODE=0
                # TODO
                ;;
            -p|--post-reboot-setup)
                _validate_setup_mode
                SETUP_MODE=1
                # TODO
                ;;
            -o|--optional-setup)
                _validate_setup_mode
                SETUP_MODE=2
                ;;
            -s|--step)
                individual_step="${2}"
                shift # past argument
                ;;
            -ss|--show_steps)
                _show_steps
                exit 0
                ;;
            *)
                echo "Unknown option $1"
                exit 1
                ;;
        esac
        
        if (( SETUP_MODE == -1 )) then
            SETUP_MODE=0
        fi

        shift # to next argument
    done

    #local is_post_reboot_setup=[ SETUP_MODE -eq 1]
    #local is_optional_setup=[ SETUP_MODE -eq 2]
    #local is_individual_step=[ individual_step -ne -1]

    if [[ SETUP_MODE -eq 0 ]]; then
        if [[ individual_step -ne -1 ]]; then
            printf "[system setup] executing initial setup step %d - %s\n" "${individual_step}" "${INITIAL_SETUP_DESCRIPTIONS[$individual_step]}"
            ${INITIAL_SETUP_FUNCTIONS["$individual_step"]}
            printf "[system setup] executing initial setup step %d done\n" "${individual_step}"
        else
            for i in "${!INITIAL_SETUP_FUNCTIONS[@]}"; do 
            printf "[system setup] step %d - %s\n" "${individual_step}" "${INITIAL_SETUP_DESCRIPTIONS[$individual_step]}"
                ${INITIAL_SETUP_FUNCTIONS[i]}
            done
            printf "\n[system setup] Initial setup is done. REBOOT and add ssh key to github to continue\n\n"
        fi
    fi

    if [[ SETUP_MODE -eq 1 ]]; then
        if [[ individual_step -ne -1 ]]; then
            printf "[system setup] executing post-setup step %d\n" "${individual_step}"
            "${POST_SETUP_FUNCTIONS[$individual_step]}"
            printf "[system setup] executing post-setup step %d done\n" "${individual_step}"
        else
            for i in "${!POST_SETUP_FUNCTIONS[@]}"; do 
            printf "[system setup] step %d - %s\n" "${individual_step}" "${POST_SETUP_DESCRIPTIONS[$individual_step]}"
                ${POST_SETUP_FUNCTIONS[i]}
            done
            printf "\n[system setup] Post-setup is done\n\n"
        fi
    fi

    if [[ SETUP_MODE -eq 2 ]] ; then
        if [[ individual_step -ne -1 ]]; then
            printf "[system setup] executing optional setup step %d\n", "${individual_step}"
            "${OPT_SETUP_FUNCTIONS[$individual_step]}"
            printf "[system setup] executing optional setup step %d done\n" "${individual_step}"
        else
            for i in "${!OPT_SETUP_FUNCTIONS[@]}"; do 
            printf "[system setup] step %d - %s\n" "${individual_step}" "${OPT_SETUP_DESCRIPTIONS[$individual_step]}"
                ${OPT_SETUP_FUNCTIONS[i]}
            done
            printf "\n[system setup] Optional setup is done\n\n"
        fi
    fi

}

main "$@"
