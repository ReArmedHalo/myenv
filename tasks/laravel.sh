#!/usr/bin/env bash

runTask() {
    # Install PHP
    PHPV="$ARG_PHP_VER"

    case $OS_NAME in
        "macOS")
            brew install php@$PHPV
            break
            ;;
        "ubuntu")
            installPackage "wget software-properties-common libnss3-tool"
            sudo add-apt-repository ppa:ondrej/php
            sudo apt-get update
            #PHPV=$(brew info php --json | jq -r '.[0].aliases[0]')
            sudo apt-get install -y php$PHPV-cli php$PHPV-curl php$PHPV-mbstring php$PHPV-mcrypt php$PHPV-xml php$PHPV-zip
            break
            ;;
        "centos")

            break
            ;;
    esac

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
        echo 'export PATH=$PATH:$HOME/.config/composer/vendor/bin/' >> ~/.bashrc
        echo 'export PATH=$PATH:$HOME/.config/composer/vendor/bin/' >> ~/.zshenv
    fi
    export PATH="$PATH:$HOME/.config/composer/vendor/bin/"
    composer global require cpriego/valet-linux
    valet install
}