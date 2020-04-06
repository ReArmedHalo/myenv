#!/usr/bin/env bash

runTask() {
    installPackage git
    if [ -d ~/dotfiles ]; then
        su $MYSELF -c "git -C '~/dotfiles' pull"
    else
        su $MYSELF -c "git clone https://github.com/ReArmedHalo/dotfiles.git '~/dotfiles'"
        if [ $? = 0 ]; then
            su $MYSELF -c "ln -sf '~/dotfile/.zshrc' '~/.zshrc'"
        fi
    fi
}