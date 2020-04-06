#!/usr/bin/env bash

runTask() {
    installPackage zsh
    
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended"
    chsh -s $(which zsh)
}