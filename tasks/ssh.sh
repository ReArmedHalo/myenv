#!/usr/bin/env bash

runTask() {
    installPackage jq
    installBitWarden

    if [ ! "$OS_NAME" = "macOS" ]; then
        installPackage gpg
    else
        brew install gpg
    fi

    if [ ! -d '~/.ssh' ]
    then mkdir ~/.ssh
        chmod 700 ~/.ssh
    fi

    bwUnlock
    bw get item 650ab61d-adac-464d-b98a-ab92014ba2ec | jq '.notes' > ~/.ssh/id_rsa
    bw get item c95ce797-7661-4a9c-af0c-ab92015bb887 | jq '.notes' > ~/.ssh/id_rsa.pub
    chmod 600 ~/.ssh/id_rsa
    chmod 644 ~/.ssh/id_rsa.pub

    bw get attachment vnojbbfmdet6jdjtm5t71w712yehtyxp --itemid 86c45ebf-c911-436d-9909-ab940026f30c --output "$HOME/bw-private.gpg"
    bw get attachment 003x1tubnony0twy5vnmqu6z4u8bw59o --itemid 86c45ebf-c911-436d-9909-ab940026f30c --output "$HOME/bw-public.gpg"
    
    bw lock

    gpg --import < "$HOME/bw-private.gpg"
    rm -f "$HOME/bw-private.gpg"

    installPackage git
    git config --global user.name "Dustin Schreiber"
    git config --global user.email "dustin@schreiber.us"

    git config --global user.signingkey 7EE17E53F4F57537
    git config --global commit.gpgsign true
}