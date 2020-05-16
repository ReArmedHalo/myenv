#!/usr/bin/env bash

secureSSH() {
    sudo sed -i -e '/^PermitRootLogin/s/^.*$/PermitRootLogin no/' /etc/ssh/sshd_config
    sudo sed -i -e '/^PasswordAuthentication/s/^.*$/PasswordAuthentication no/' /etc/ssh/sshd_config
}

runTask() {
    if [ "$OS_NAME" = "centos" ]; then
        installPackage epel-release
    fi
    installPackage jq
    installBitWarden

    brew install mosh

    if [ ! "$OS_NAME" = "macOS" ]; then
        installPackage gpg
    else
        brew install gpg
    fi

    if [ ! -d "$HOME/.ssh" ]; then
        mkdir ~/.ssh
        chmod 700 ~/.ssh
    fi

    bwUnlock
    bw get item 650ab61d-adac-464d-b98a-ab92014ba2ec | jq -r '.notes' > ~/.ssh/id_rsa
    bw get item c95ce797-7661-4a9c-af0c-ab92015bb887 | jq -r '.notes' > ~/.ssh/id_rsa.pub
    chmod 600 ~/.ssh/id_rsa
    chmod 644 ~/.ssh/id_rsa.pub

    bw get attachment vnojbbfmdet6jdjtm5t71w712yehtyxp --itemid 86c45ebf-c911-436d-9909-ab940026f30c --output "$HOME/bw-private.gpg"

    bw lock

    gpg --import < "$HOME/bw-private.gpg"
    rm -f "$HOME/bw-private.gpg"

    installPackage git
    git config --global user.name "Dustin Schreiber"
    git config --global user.email "dustin@schreiber.us"

    git config --global user.signingkey 7EE17E53F4F57537
    git config --global commit.gpgsign true
    
    secureSSH
}