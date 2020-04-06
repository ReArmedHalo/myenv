#!/usr/bin/env bash

runTask() {
    installPackage zsh
    
    $(which sh) -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    printf '%sTime to set the default shell to ZSH!%s\n' "$tty_boldtty_green" "$tty_reset$tty_white"
    chsh -s $(which zsh)
    printf '%s' "$tty_reset"
}