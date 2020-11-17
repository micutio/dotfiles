#!/bin/sh

echo "installing programs from Solus repository\n"

sudo eopkg it \
	apache-maven dropbox git htop llvm-clang meld steam texlive tmux vim vivaldi-stable vscode zsh \
	-y

echo "installing programs from snap repository\n"

# TODO: Any way of circumventing manual password input?
snap install intellij-idea-community skype --classic
snap install spotify

echo "setting up vim plugin manager\n"

curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

echo "setting up oh-my-zsh and extensions\n"

sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" 

mv .zshrc.pre-oh-my-zsh .zshrc

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

echo "setting up sdkman\n"

curl -s "https://get.sdkman.io" | bash

echo "setting up rust\n"

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh


