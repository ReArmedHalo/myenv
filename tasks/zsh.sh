#!/usr/bin/env bash

runTask() {
    installPackage zsh
    
    su $MYSELF -c "sh -c '$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended'"
    su $MYSELF -c "chsh -s $(which zsh)"
}