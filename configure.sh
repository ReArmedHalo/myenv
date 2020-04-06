#!/bin/bash

# Install updates and other packages
apt update
apt upgrade -y
apt install -y build-essential

apt install -y software-properties-common
add-apt-repository ppa:ondrej/php
apt update

# Install brew bottles
brew install gcc
brew install nginx

# Install Laravel Installer
/usr/local/bin/composer global require laravel/installer
