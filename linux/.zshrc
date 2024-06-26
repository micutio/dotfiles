# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
  export ZSH="/home/michael/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
# ZSH_THEME="bira"
ZSH_THEME="af-magic"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    git
    github
    mvn
    python
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias gitl='glola --date-order'

# connection to TUMCREATE machines
alias ctf='ssh michael@10.25.191.216'
alias ctc='ssh michaelw@10.25.191.228'

# inspect memory usage of directory content
alias memscan='du -h -s *'

#alias vim="stty stop '' -ixoff ; nvim"

touchoff() {
    gsettings set org.gnome.desktop.peripherals.touchpad send-events disabled
}

touchon() {
    gsettings set org.gnome.desktop.peripherals.touchpad send-events enabled
}

dark() {
  cp ~/.alacritty_dark.yml ~/.alacritty.yml
  # gsettings set com.solus-project.budgie-panel dark-theme true
  # gsettings set org.gnome.desktop.background picture-uri-dark file:////home/michael/Pictures/wallpaper/dark.jpg
  # gsettings set org.gnome.desktop.screensaver picture-uri file:////home/michael/Pictures/wallpaper/dark.jpg
  # gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
  # gsettings set org.gnome.desktop.wm.preferences theme "Adwaita-dark"
  # gsettings set org.gnome.shell.extensions.user-theme name "Adwaita-dark"
  # gsettings set org.gnome.desktop.interface icon-theme "Fluent-dark"
  # gsettings set org.gnome.desktop.interface color-scheme prefer-dark
}

light() {
  cp ~/.alacritty_light.yml ~/.alacritty.yml
  # gsettings set com.solus-project.budgie-panel dark-theme false
  # gsettings set org.gnome.desktop.background picture-uri file:////home/michael/Pictures/wallpaper/coast.jpg
  # gsettings set org.gnome.desktop.screensaver picture-uri file:////home/michael/Pictures/Wallpaper/coast.jpg
  # gsettings set org.gnome.desktop.interface gtk-theme "Adwaita"
  # gsettings set org.gnome.desktop.wm.preferences theme "Adwaita"
  # gsettings set org.gnome.shell.extensions.user-theme name "Adwaita"
  # gsettings set org.gnome.desktop.interface icon-theme "Fluent"
  # gsettings set org.gnome.desktop.interface color-scheme prefer-light
}

export PATH="$PATH:$HOME/.cargo/bin" # add cargo to PATH for all things rust
export PATH="$PATH:$HOME/.rvm/bin" # add RVM to PATH for scripting
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/.go/bin"

alias config='/usr/bin/git --git-dir=/home/michael/.cfg/ --work-tree=/home/michael'
alias clang-format-7='clang-format'

export JAVA_HOME="/home/michael/.sdkman/candidates/java/current"
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
export STEAM_RUNTIME_PREFER_HOST_LIBRARIES=0

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/home/michael/.sdkman"
[[ -s "/home/michael/.sdkman/bin/sdkman-init.sh" ]] && source "/home/michael/.sdkman/bin/sdkman-init.sh"


# GoLang
export GOROOT=/home/michael/.go
export PATH=$GOROOT/bin:$PATH
export GOPATH=/home/michael/.go
export PATH=$GOPATH/bin:$PATH
