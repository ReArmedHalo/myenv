#!/usr/bin/env bash

# String formatter
if [[ -t 1 ]]; then
  tty_escape() { printf "\033[%sm" "$1" }
else
  tty_escape() { : }
fi

tty_bold="$(tty_escape 1)"
tty_underline="$(tty_escape "4;39")"

tty_blue="$(tty_escape 34)"
tty_red="$(tty_escape 31)"
tty_green="$(tty_escape 32)"
tty_white="$(tty_escape 97)"
tty_reset="$(tty_escape 0)"

checkbox() {
    if [ -n "$2" ]
    then
        printf "${tty_blue}[X]${tty_reset}${tty_green} $1 ${tty_reset}\n"
    else
        printf "${tty_blue}[ ]${tty_reset}${tty_red} $1 ${tty_reset}\n"
    fi
}

isPackageInstalled() {
    case "$OS_NAME" in
        "centos")
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

installPackage() {
    if ! isPackageInstalled $1; then
        case "$OS_NAME" in
            "centos")
                return $(yum install -y $1)
                ;;
            "ubuntu")
                return $(apt install -y $1)
                ;;
        esac
    fi
}

detectOS() {
    if [ -e /etc/os-release ]; then
        source /etc/os-release
        if [ "$ID" = "ubuntu" ] || [ "$ID" = "centos" ]; then
            OS_NAME="${ID}"
            OS_PRETTY="${PRETTY_NAME}"
        else
            printf "${tty_red}Unsupported OS.${tty_reset}"
            return 1
        fi
    elif [ $(uname) = "Darwin" ]; then
        OS_NAME="macOS"
        OS_PRETTY="macOS $(sw_vers -productVersion)"
    else
        printf "${tty_red}Failed to detect OS! /etc/os-release not found and uname is not Darwin.${tty_reset}"
        return 1
    fi
}