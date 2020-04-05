#!/usr/bin/env bash

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../functions.sh"

installBrew() {
    if [ $OS_NAME = 'macOS' ]; then
        if [ ! -d "/usr/local/Homebrew/bin/brew" ]; then
            CI=1
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
        fi
    else
        if [ ! -d "/home/linuxbrew" ]; then
            CI=1
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
            echo 'eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)' >> ~/.zshenv
            echo 'eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)' >> ~/.bashrc
            eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv) # Add to the current shell
        fi
    fi
    unset CI
}