#!/usr/bin/env bash

# One-liner
# git clone https://github.com/ReArmedHalo/myenv.git ~/myenv && /bin/bash ~/myenv/main.sh -u -a

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/functions.sh"

doTask() {
    printf "${tty_reset}"
    printf "${tty_blue}=========================\n"
    printf "${tty_white}Running task: $1\n"
    printf "${tty_blue}=========================\n"
    . "$DIR/tasks/$1.sh"
    TASK_RETURN=runTask
    printf "${tty_blue}=========================\n"
    printf "${tty_white}Task complete: $1\n"
    printf "Returned: $TASK_RETURN\n"
    printf "${tty_blue}=========================\n"
    printf "${tty_reset}\n"
}

header() {
    printf "${tty_blue}"
    printf "====================================\n"
    printf "||   ${tty_white}MyEnv Configuration Script${tty_blue}   ||\n"
    printf "||      ${tty_white}By: Dustin Schreiber${tty_blue}      ||\n"
    printf "|| ${tty_white}https://github.com/ReArmedHalo${tty_blue} ||\n"
    printf "====================================\n"
    printf "${tty_reset}\n"
}

systemStateDetection() {
    # OS
    detectOS

    # Brew
    BREW_PATH="$(command -v brew)"

    # PHP
    PHP_PATH="$(command -v php)"
    if [ -n PHP_PATH ]; then PHP_VERSION="$(${PHP_PATH} -r 'echo PHP_VERSION;')"; fi

    # NGINX
    NGINX_DETECTED="$(command -v nginx)"

    # MariaDB
    MARIADB_PATH="$(command -v mysqld)"
}

systemState() {
    systemStateDetection
    printf "${tty_blue}${tty_bold}OS: ${tty_reset}${tty_white}$OS_PRETTY\n"
    if [ -n "$BREW_PATH" ]; then checkbox "Brew Installed" 1; else checkbox "Brew Not Installed"; fi
    if [ -n "$PHP_PATH" ]; then checkbox "PHP Installed - $PHP_VERSION" 1; else checkbox "PHP Not Installed"; fi
    if [ -n "$NGINX_DETECTED" ]; then checkbox "NGINX Installed" 1; else checkbox "NGINX Not Installed"; fi
    if [ -n "$MARIADB_PATH" ]; then checkbox "MariaDB Installed" 1; else checkbox "MariaDB Not Installed"; fi
}

menuPrompt() {
    while true; do
        printf "${tty_reset}\n"
        printf "${tty_blue}==============================\n"
        printf "${tty_white}What do you want to do?"
        printf "\n"
        printf "${tty_bold}${tty_blue} A) Run all tasks\n"
        printf "${tty_bold}${tty_blue} D) Clone dot files from GitHub\n"
        printf "${tty_bold}${tty_blue} L) Install and configure packages necessary for Laravel development\n"
        printf "${tty_bold}${tty_blue} S) Install SSH and GPG keys from BitWarden\n"
        printf "${tty_bold}${tty_blue} V) Install OpenVPN Server and configure client profile\n"
        printf "${tty_bold}${tty_blue} Z) Install ZSH and Oh-My-Zsh\n"
        printf "${tty_reset}\n"
        printf "${tty_white}Select an option: ${tty_bold}${tty_green}"
        read selection
        printf "${tty_reset}"
        case "$selection" in
            a|A)
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

# Download SSH keys from BitWarden
ARG_SSH=0 # --ssh -s

# Install OpenVPN Server and configure client profile (### NOT DONE)
ARG_VPN=0 # --vpn -v

# Install ZSH and Oh-My-Zsh
ARG_ZSH=0 # --zsh -z

while [ $# -gt 0 ]; do
    case "$1" in
        --unattended|-u)
            ARG_UNATTENDED=1
            ;;
        --all|-a)
            ARG_DOTFILES=1
            ARG_LARAVEL=1
            ARG_SSH=1
            ARG_VPN=1
            ARG_ZSH=1
            ;;
        --dotfiles|-d)
            ARG_DOTFILES=1
            ;;
        --laravel|-l)
            ARG_LARAVEL=1
            ;;
        --ssh|-s)
            ARG_SSH=1
            ;;
        --vpn|-v)
            ARG_VPN=1
            ;;
        --zsh|-z)
            ARG_ZSH=1
            ;;
        *)
            printf "${tty_red}"
            printf "***************************\n"
            printf "Error: Invalid argument: $1\n"
            printf "***************************\n"
            printf "${tty_reset}"
            exit 1
        esac
    shift
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
    if [ "$ARG_SSH" = "1" ]; then
        if [ -n "$ARG_BW_SERVER" ]; then
            doTask ssh
        else
            printf "${tty_red}BW_SERVER variable not defined. Required for unattended operations with the 'ssh' task.\n"
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