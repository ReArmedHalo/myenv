#!/bin/bash

# Target run line ex:
# git clone https://github.com/ReArmedHalo/myenv.git ~/myenv && /bin/bash ~/myenv/main.sh -u --all

# Sudo check
if [ "$EUID" -ne 0 ]
then
    echo 'Please run with sudo!'
    exit 1
fi

# Install updates and other packages
apt update
apt upgrade -y
apt install -y curl git build-essential zsh zip unzip jq

apt install -y software-properties-common
add-apt-repository ppa:ondrej/php
apt update

# Clone my dotfiles repository
git clone https://github.com/ReArmedHalo/dotfiles.git ~/dotfiles
ln -sf ~/dotfile/.zshrc ~/.zshrc

# Install Homebrew
CI=1
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
echo 'eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)' >> ~/.zshenv
eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv) # Add to the current shell

# Install brew bottles
brew install mosh
brew install gcc
brew install bitwarden-cli
brew install nginx
if [ -e $PHP_VERSION ] # Install selected version of PHP or latest
then
    brew install php@$PHP_VERSION
else
    brew install php
fi

# Install Oh-My-Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended"
chsh -s $(which zsh)

# Install Composer
EXPECTED_CHECKSUM="$(wget -q -O - https://composer.github.io/installer.sig)"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]
then
    >&2 echo 'ERROR: Invalid installer checksum'
    rm composer-setup.php
else
    php composer-setup.php --quiet
    rm composer-setup.php
    mv composer.phar /usr/local/bin/composer
    echo 'export PATH=$PATH:$HOME/.composer/vendor/bin/' >> ~/.zshenv
fi

# Install Laravel Installer
/usr/local/bin/composer global require laravel/installer

# BitWarden
if [ -e $BITWARDEN_SERVER ]
then
    bw config server $BITWARDEN_SERVER
    export BW_SESSION=$(bw login --raw)
    
    if [ ! -d '~/.ssh' ]
    then mkdir ~/.ssh
        chmod 700 ~/.ssh
    fi
    bw get item 650ab61d-adac-464d-b98a-ab92014ba2ec | jq '.notes' > ~/.ssh/id_rsa
    bw get item c95ce797-7661-4a9c-af0c-ab92015bb887 | jq '.notes' > ~/.ssh/id_rsa.pub
    chmod 600 ~/.ssh/id_rsa
    chmod 644 ~/.ssh/id_rsa.pub
    bw lock
fi

### FOR NOW, since we aren't using a cloud VM
ufw allow ssh
ufw allow mosh
ufw enable