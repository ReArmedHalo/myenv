#!/usr/bin/env bash

runTask() {
    installPackage git
    if [ -d ~/dotfiles ]; then
        su $MYSELF -c "git -C '$HOME/dotfiles' pull"
    else
        su $MYSELF -c "git clone https://github.com/ReArmedHalo/dotfiles.git '$HOME/dotfiles'"
        if [ $? = 0 ]; then
            su $MYSELF -c "ln -sf '$HOME/dotfile/.zshrc' '$HOME/.zshrc'"
        fi
    fi
}