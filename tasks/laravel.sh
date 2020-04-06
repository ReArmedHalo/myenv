#!/usr/bin/env bash

runTask() {
    # Install PHP
    PHPV="$ARG_PHP_VER"

    case $OS_NAME in
        "macOS")
            brew install php@$PHPV
            ;;
        "ubuntu")
            installPackage "wget software-properties-common libnss3-tools xsel mariadb-server"
            sudo add-apt-repository -y ppa:ondrej/php
            sudo apt-get update
            #PHPV=$(brew info php --json | jq -r '.[0].aliases[0]')
            sudo apt-get install -y php$PHPV-cli php$PHPV-curl php$PHPV-mbstring php$PHPV-xml php$PHPV-zip
            ;;
        "centos")

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
        sudo mv composer.phar /usr/local/bin/composer
        echo 'export PATH=$PATH:$HOME/.config/composer/vendor/bin/' >> ~/.bashrc
        echo 'export PATH=$PATH:$HOME/.config/composer/vendor/bin/' >> ~/.zshenv
    fi
    export PATH="$PATH:$HOME/.config/composer/vendor/bin/"
    composer global require cpriego/valet-linux
    valet install
    mkdir "$HOME/code"
    valet park "$HOME/code"

    # DNSMasq configuration (depends on VPN interface)
    case $OS_NAME in
        "ubuntu")
            #echo 'listen-address=10.0.10.52' >> /etc/dnsmasq.d/options
            #echo 'listen-address=10.8.0.1' >> /etc/dnsmasq.d/options
            #echo 'address=/.test/10.0.10.52' > /etc/dnsmasq.d/valet
            #echo 'address=/.test/10.8.0.1' > /etc/dnsmasq.d/valet
            sudo systemctl restart dnsmasq
            ;;
        "centos")

            ;;
    esac

    mysql_secure_installation
}