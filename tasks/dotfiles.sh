#!/usr/bin/env bash

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../functions.sh"

runTask() {
    installPackage git
    git clone https://github.com/ReArmedHalo/dotfiles.git ~/dotfiles

    if [ $? = 0 ]; then
        ln -sf ~/dotfile/.zshrc ~/.zshrc
        
        return 0
    fi
    return $?
}