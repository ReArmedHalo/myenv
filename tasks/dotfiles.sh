#!/usr/bin/env bash

runTask() {
    installPackage git
    if [ -d ~/dotfiles ]; then
        git -C "~/dotfiles" pull
    else
        git clone https://github.com/ReArmedHalo/dotfiles.git "~/dotfiles"
        if [ $? = 0 ]; then
            ln -sf "~/dotfile/.zshrc" "~/.zshrc"
        fi
        chown $MYSELF: -R "~/dotfiles"
        chown $MYSELF: "~/.zshrc"
    fi
}