#!/usr/bin/env bash

runTask() {
    installPackage git
    if [ -d ~/dotfiles ]; then
       git -C "$HOME/dotfiles" pull
    else
       git clone https://github.com/ReArmedHalo/dotfiles.git "$HOME/dotfiles"
        if [ $? = 0 ]; then
            ln -sf ~/dotfile/.zshrc ~/.zshrc
        fi
    fi
}