#!/usr/bin/env bash

red="$(printf '\e[1;91m')"
green="$(printf '\e[1;92m')"
bold="$(printf '\e[1m')"
norm="$(printf '\e[0m')"
err="$(printf '\e[1m\e[1;91mERROR: ')"

OK() {
    echo -e "${green}OK${norm}"
}

Error() {
    [ $# -eq 2 ] && echo -e "$2"
    echo -e "${bred}ERROR: ${red}$1${norm}"
}

echo -e "${bold}[ Install DEPLOY on your computer ]${norm}"

if [ ! -d "${HOME}/bin" ]; then
    echo -n "- create local '~/bin' directory "
    mkdir -p ${HOME}/bin
    OK
fi

if [ ! -d "${HOME}/.config/deploy" ]; then
    echo -n "- create local configuration folder '${HOME}/.config/deploy' "
    mkdir -p ${HOME}/.config/deploy
    OK
fi

# get os/arch
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"
echo "- detected OS=${OS} ARCH=${ARCH}"

# download assets

# auto-configure

