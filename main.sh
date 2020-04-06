#!/usr/bin/env bash

# One-liner, change bwserver argument
# git clone https://github.com/ReArmedHalo/myenv.git ~/myenv && /bin/bash ~/myenv/main.sh --bwserver SERVER

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi

MYSELF=$(logname)

# String formatter
if [[ -t 1 ]]; then
  tty_escape() { printf "\033[%sm" "$1"; }
else
  tty_escape() { :; }
fi

tty_bold="$(tty_escape 1)"

tty_blue="$(tty_escape 34)"
tty_red="$(tty_escape 31)"
tty_green="$(tty_escape 32)"
tty_white="$(tty_escape 97)"
tty_reset="$(tty_escape 0)"

ttyReset() {
    printf '%s\n' "$tty_reset"
    exit $?
}

trap 'ttyReset' SIGINT

checkbox() {
    if [ -n "$2" ]
    then
        printf '%s[X]%s %s %s\n' "$tty_blue" "$tty_reset$tty_green" "$1" "$tty_reset"
    else
        printf '%s[ ]%s %s %s\n' "$tty_blue" "$tty_reset$tty_red" "$1" "$tty_reset"
    fi
}

isPackageInstalled() {
    case "$OS_NAME" in
        "centos")
            # Does this need sudo?
            if yum list installed "$1" >/dev/null 2>&1; then
                return 0
            fi
            ;;
        "ubuntu")
            if dpkg --get-selections | grep -q "^$1[[:space:]]*install$" >/dev/null 2>&1; then
                return 0
            fi
            ;;
    esac
    return 1
}

installPackages() { # Skips checking if already installed
    case "$OS_NAME" in
        "centos")
            return "$(sudo yum install -y "$1")"
            ;;
        "ubuntu")
            return "$(sudo apt-get install -y "$1")"
            ;;
    esac
}

installPackage() {
    if ! isPackageInstalled "$1"; then
        case "$OS_NAME" in
            "centos")
                return "$(sudo yum install -y "$1")"
                ;;
            "ubuntu")
                return "$(sudo apt-get install -y "$1")"
                ;;
        esac
    fi
}

detectOS() {
    if [ -e /etc/os-release ]; then
        source "/etc/os-release"
        if [ "$ID" = "ubuntu" ] || [ "$ID" = "centos" ]; then
            OS_NAME="${ID}"
            OS_PRETTY="${PRETTY_NAME}"
        else
            printf "%sUnsupported OS.%s" "$tty_red" "$tty_reset"
            return 1
        fi
    elif [ $(uname) = "Darwin" ]; then
        OS_NAME="macOS"
        OS_PRETTY="macOS $(sw_vers -productVersion)"
    else
        printf "%sFailed to detect OS! /etc/os-release not found and uname is not Darwin.%s" "$tty_red" "$tty_reset"
        return 1
    fi
}

installBrew() {
    if [ $OS_NAME = 'macOS' ]; then
        if [ ! -d "/usr/local/Homebrew/bin/brew" ]; then
            export CI=1
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
        fi
    else
        if [ ! -d "/home/linuxbrew" ]; then
            installPackage curl
            export CI=1
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
            echo 'eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)' >> ~/".zshenv"
            echo 'eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)' >> ~/".bashrc"
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" # Add to the current shell
        else
            # Let's make sure Brew is in the path
            if [ ! -n "$BREW_PATH" ]; then
                eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" # Add to the current shell
            fi
        fi
    fi
    unset CI
}

installBitWarden() {
    if [ ! -e "$(command -v bw)" ]; then
        installBrew
        brew install bitwarden-cli
    fi
}

bwUnlock() {
    if [ -z "$BW_SERVER" ]; then
        printf "%sBitWarden server not provided.\n" "$tty_red"
        printf "Set the variable and try again:\n"
        printf "myenv.sh --bwserver=https://%s\n" "$tty_reset"
        exit 1
    fi
    bw login --check 2>&1
    if [ $? ]; then
        bw config server "$BW_SERVER"
        printf "%sPlease login to %sBitWarden%s: %s\n" "$tty_bold$tty_blue" "$tty_white" "$tty_green" "$BW_SERVER$tty_reset"
        export BW_SESSION=$(bw login --raw)
    else
        printf "%sPlease unlock BitWarden%s\n" "$tty_bold$tty_blue" "$tty_reset"
        export BW_SESSION=$(bw unlock --raw)
    fi
}

allowFirewallService() {
    case $OS_NAME in
        "ubuntu")
            sudo ufw allow $1
            break
            ;;
        "centos")
            sudo firewall-cmd --permanent --add-service=$1
            break
            ;;
        *)
            break
            ;;
    esac
}

doTask() {
    printf '%s' "$tty_reset"
    printf '%s=========================\n' "$tty_blue"
    printf '%sRunning task: %s\n' "$tty_white" "$1"
    printf '%s=========================\n' "$tty_blue"
    printf '%s' "$tty_reset$tty_white"
    . "$DIR/tasks/$1.sh"
    runTask
    printf '%s=========================\n' "$tty_blue"
    printf '%sTask complete: %s\n' "$tty_white" "$1"
    printf '%s=========================\n' "$tty_blue"
    printf '%s\n' "$tty_reset"
}

header() {
    printf "${tty_blue}"
    printf "==========================================\n"
    printf "||      ${tty_white}MyEnv Configuration Script${tty_blue}      ||\n"
    printf "|| ${tty_white}https://github.com/ReArmedHalo/myenv${tty_blue} ||\n"
    printf "==========================================\n"
    printf "${tty_reset}\n"
}

systemStateDetection() {
    # OS
    detectOS

    # BitWarden
    BW_PATH="$(command -v bw)"
    
    # Brew
    BREW_PATH="$(command -v brew)"

    # Composer
    COMPOSER_PATH="$(command -v composer)"

    # Git
    GIT_PATH="$(command -v git)"

    # MariaDB
    MARIADB_PATH="$(command -v mysqld)"

    # NGINX
    NGINX_DETECTED="$(command -v nginx)"

    # PHP
    PHP_PATH="$(command -v php)"
    if [ -n "$PHP_PATH" ]; then PHP_VERSION="$(${PHP_PATH} -r 'echo PHP_VERSION;')"; fi

    # ZSH
    ZSH_PATH="$(command -v zsh)"
}

systemState() {
    systemStateDetection
    printf "%sOS: %s\n" "$tty_blue$tty_bold" "$tty_reset$tty_white$OS_PRETTY"
    if [ -n "$BW_SERVER" ]; then printf '%sBitWarden Server:%s %s\n' "$tty_blue$tty_bold" "$tty_reset$tty_white" "$BW_SERVER"; fi
    if [ -n "$ARG_PHP_VER" ]; then printf '%sPHP Version:%s %s\n' "$tty_blue$tty_bold" "$tty_reset$tty_white" "$ARG_PHP_VER"; fi
    if [ -n "$BW_PATH" ]; then checkbox "BitWarden Installed" 1; else checkbox "BitWarden Not Installed"; fi
    if [ -n "$BREW_PATH" ]; then checkbox "Brew Installed" 1; else checkbox "Brew Not Installed"; fi
    if [ -n "$COMPOSER_PATH" ]; then checkbox "Composer Installed" 1; else checkbox "Composer Not Installed"; fi
    if [ -n "$GIT_PATH" ]; then checkbox "Git Installed" 1; else checkbox "Git Not Installed"; fi
    if [ -n "$MARIADB_PATH" ]; then checkbox "MariaDB Installed" 1; else checkbox "MariaDB Not Installed"; fi
    if [ -n "$NGINX_DETECTED" ]; then checkbox "NGINX Installed" 1; else checkbox "NGINX Not Installed"; fi
    if [ -n "$PHP_PATH" ]; then checkbox "PHP Installed - $PHP_VERSION" 1; else checkbox "PHP Not Installed"; fi
    if [ -n "$ZSH_PATH" ]; then checkbox "ZSH Installed" 1; else checkbox "ZSH Not Installed"; fi
}

menuPrompt() {
    while true; do
        printf '\n' "$tty_reset"
        printf '%s==============================\n' "$tty_blue"
        printf '%sWhat do you want to do?\n' "$tty_white"
        printf '%sA) Run all tasks\n' "$tty_bold$tty_blue"
        printf '%sD) Clone dot files from GitHub\n' "$tty_bold$tty_blue"
        printf '%sL) Install and configure packages necessary for Laravel development\n' "$tty_bold$tty_blue"
        printf '%sP) Install support packages only (Brew, Composer and ZSH are not installed)\n' "$tty_bold$tty_blue"
        printf '%sS) Install SSH and GPG keys from BitWarden\n' "$tty_bold$tty_blue"
        printf '%sV) Install OpenVPN Server and configure client profile\n' "$tty_bold$tty_blue"
        printf '%sZ) Install ZSH and Oh-My-Zsh\n' "$tty_bold$tty_blue"
        printf '%s\n' "$tty_reset"
        printf '%sSelect an option:%s ' "$tty_white" "$tty_bold$tty_green"
        read selection
        printf '%s' "$tty_reset"
        case "$selection" in
            a|A)
                doTask packages
                doTask dotfiles
                doTask laravel
                doTask ssh
                doTask vpn
                doTask zsh
                break
                ;;
            d|D)
                doTask dotfiles
                break
                ;;
            l|L)
                doTask laravel
                break
                ;;
            p|P)
                doTask packages
                break
                ;;
            s|S)
                doTask ssh
                break
                ;;
            v|V)
                doTask vpn
                break
                ;;
            z|Z)
                doTask zsh
                break
                ;;
            *)
                printf "${tty_bold}${tty_red}Invalid selection\n"
                ;;
        esac
    done
}

# Argument processing
# Don't prompt for input, requires additional arguments
ARG_UNATTENDED=0 # --unattended -u

# Clone dot files from GitHub
ARG_DOTFILES=0 # --dotfiles -d

# Install and configure Laravel development env (### NOT DONE)
ARG_LARAVEL=0 # --laravel -l

# Install support packages only
ARG_PACKAGES=0 # --packages -p

# Download SSH keys from BitWarden
ARG_SSH=0 # --ssh -s

# Install OpenVPN Server and configure client profile (### NOT DONE)
ARG_VPN=0 # --vpn -v

# Install ZSH and Oh-My-Zsh
ARG_ZSH=0 # --zsh -z

## PHP Version to install
ARG_PHP_VER="7.4"

while [[ $# -gt 0 ]]
do
key="$1";

case $key in
    --bwserver)
        BW_SERVER="$2"
        shift
        shift
        ;;
    --unattended|-u)
        ARG_UNATTENDED=1
        shift
        ;;
    --all|-a)
        ARG_DOTFILES=1
        ARG_LARAVEL=1
        ARG_SSH=1
        ARG_VPN=1
        ARG_ZSH=1
        shift
        ;;
    --dotfiles|-d)
        ARG_DOTFILES=1
        shift
        ;;
    --laravel|-l)
        ARG_LARAVEL=1
        shift
        ;;
    --packages|-p)
        ARG_PACKAGES=1
        shift
        ;;
    --ssh|-s)
        ARG_SSH=1
        shift
        ;;
    --vpn|-v)
        ARG_VPN=1
        shift
        ;;
    --zsh|-z)
        ARG_ZSH=1
        shift
        ;;
    --php-version|-pv)
        ARG_PHP_VER="$2"
        shift
        shift
        ;;
    *)
        printf "%s" "$tty_red"
        printf "***************************\n"
        printf "Error: Invalid argument: %s\n" "$1"
        printf "***************************\n"
        printf "%s" "$tty_reset"
        exit 1
    ;;
esac
done

header
systemState

if [ "$ARG_UNATTENDED" = "0" ]; then
    menuPrompt
    else
    # unattended calls
    if [ "$ARG_DOTFILES" = "1" ]; then
        doTask dotfiles
    fi
    if [ "$ARG_LARAVEL" = "1" ]; then
        doTask laravel
    fi
    if [ "$ARG_PACKAGES" = "1" ]; then
        dotask packages
    fi
    if [ "$ARG_SSH" = "1" ]; then
        if [ -n "$ARG_BW_SERVER" ]; then
            doTask ssh
        else
            printf "${tty_red}BW_SERVER variable not defined. Required for operations with the 'ssh' task.\n"
            printf "Set the variable and try again:\n"
            printf "BW_SERVER=https://\n"
            exit 1
        fi
    fi
    if [ "$ARG_VPN" = "1" ]; then
        doTask vpn
    fi
    if [ "$ARG_ZSH" = "1" ]; then
        doTask zsh
    fi
fi