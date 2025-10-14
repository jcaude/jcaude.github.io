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

# echo -n "- create local '~/bin' directory "
# mkdir -p ${HOME}/bin
# OK

# echo -n "- create local installation folder '~/.tgcc' "
# mkdir -p ${HOME}/.tgcc
# cd ${HOME}/.tgcc
# OK

# echo  "- clone repository.."
# git clone git@github.com:neurospin-brainomics/InstallerTGCC.git

# echo -n "- link InstallerTGCC files in the bin directory "
# ln -sf ~/.tgcc/InstallerTGCC/docker/scripts/push-* ~/bin
# ln -sf ~/.tgcc/InstallerTGCC/sync/scripts/sync-* ~/bin
# OK

# echo ""
# echo -e "${bold}NOTE: ~/bin must be in your PATH variable${norm}"

# -- part 2 : deploy on TGCC

echo ""
echo -e "${bold}[ Deploy InstallerTGCC on TGCC ]${norm}"

read -p "> Enter your TGCC ssh configuration profile (or ENTER if you haven't configure SSH profiles): " TGCC_PROFILE
if [[ -z "${TGCC_PROFILE}" ]]; then
  echo -e "${red}Abort remote installation${norm}"
  exit 0
fi

echo -n "- create TGCC '~/bin' folder '~/.tgcc' "
TGCC_CMD="bash -l -c \"mkdir -p ~/bin\""
ssh -q $TGCC_PROFILE -t $TGCC_CMD
if [ $? -eq 0 ]; then
  OK
else
  echo -e "\n${err}Fail to create TGCC folder .. abort${norm}"
  exit 10
fi

echo -n "- create TGCC installation folder '~/.tgcc' "
TGCC_CMD="bash -l -c \"mkdir -p ~/.tgcc\""
ssh -q $TGCC_PROFILE -t $TGCC_CMD
if [ $? -eq 0 ]; then
  OK
else
  echo -e "\n${err}Fail to create installation folder on TGCC.. abort${norm}"
  exit 10
fi

echo "- synchronise InstallerTGCC repository "
$HOME/bin/sync-tgcc.sh -s $HOME/.tgcc/ -d ~/.tgcc/
if [ $? -ne 0 ]; then
  echo -e "\n${err}Synchronisastion fail .. abort${norm}"
  exit 10
fi

echo -n "- link scripts in ~/bin on TGCC "
TGCC_CMD="bash -l -c \"ln -sf ~/.tgcc/InstallerTGCC/docker/scripts/docker-import.sh ~/bin\""
ssh -q $TGCC_PROFILE -t $TGCC_CMD
if [ $? -ne 0 ]; then
  echo -e "\n${err}Fail to link docker import script.. abort${norm}"
fi

echo -e "\n${green}InstallerTGCC setup complete${norm}"
