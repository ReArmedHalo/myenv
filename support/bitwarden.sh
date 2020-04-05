#!/usr/bin/env bash

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../functions.sh"

installBitWarden() {
    . "$DIR/brew.sh"
    installBrew
    if [ ! -e $(command -v bw) ]; then
        brew install bitwarden-cli
    fi
}

bwUnlock() {
    if [ -z $BW_SESSION ]; then
        bw config server $BW_SERVER
        export BW_SESSION=$(bw login --raw)
    else
        export BW_SESSION=$(bw unlock --raw)
    fi
}