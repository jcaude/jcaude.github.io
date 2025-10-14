#!/usr/bin/env bash

red="$(printf '\e[1;91m')"
green="$(printf '\e[1;92m')"
bold="$(printf '\e[1m')"
norm="$(printf '\e[0m')"
err="$(printf '\e[1m\e[1;91mERROR: ')"

OK() {
  echo -e "${green}OK${norm}"
}

echo -e "${bold}[ Deploy InstallerTGCC on your computer ]${norm}"

echo -n "- create local bin directory "
mkdir -p ${HOME}/bin
OK

echo -n "- create local installation in ~/.tgcc "
mkdir -p ${HOME}/.tgcc
cd ${HOME}/.tgcc
OK

echo  "- clone repository.."
git clone git@github.com:neurospin-brainomics/InstallerTGCC.git

echo -n "- link InstallerTGCC files in the bin directory "
ln -sf ~/.tgcc/InstallerTGCC/docker/scripts/push-* ~/bin
ln -sf ~/.tgcc/InstallerTGCC/sync/scripts/sync-* ~/bin
OK

echo ""
echo -e "${bold}NOTE: ~/bin must be in your PATH variable${norm}"


