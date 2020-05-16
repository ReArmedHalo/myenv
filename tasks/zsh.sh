#!/usr/bin/env bash

runTask() {
    if [ ! "$OS_NAME" = "macOS" ]; then
        installPackage zsh
    fi
    
    $(which sh) -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    printf '%sTime to set the default shell to ZSH!%s\n' "$tty_boldtty_green" "$tty_reset$tty_white"
    chsh -s $(grep '^/.*/zsh$' /etc/shells | tail -1)
    printf '%s' "$tty_reset"
    if [ -d ~/dotfiles ]; then
        rm -f ~/.zshrc
        ln -s ~/dotfiles/.zshrc ~/.zshrc
    fi
}