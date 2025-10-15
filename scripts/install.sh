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


INSTALL_PATH="${HOME}/.tgcc"
TGCC_BRANCH="main"

OPTSTRING=":p:b:"
hile getopts ${OPTSTRING} opt; do
  case "$opt" in
  p) INSTALL_PATH=$OPTARG
      ;;
  b) TGCC_BRANCH=$OPTARG
      ;;
  *) Error "Unknown Arguments.. exit"
      exit 1
      ;;
  esac
done

echo -e "${bold}[ Deploy InstallerTGCC on your computer ]${norm}"

echo -n "- create local '~/bin' directory "
mkdir -p ${HOME}/bin
OK

echo -n "- create local installation folder '${INSTALL_PATH}' "
mkdir -p ${INSTALL_PATH}
cd ${INSTALL_PATH}
OK

echo  "- clone repository.."
git clone -b $TGCC_BRANCH git@github.com:neurospin-brainomics/InstallerTGCC.git

echo -n "- link InstallerTGCC files in the bin directory "
ln -sf "${INSTALL_PATH}/InstallerTGCC/docker/scripts/push-*" "${HOME}/bin"
ln -sf "${INSTALL_PATH}/InstallerTGCC/sync/scripts/sync-*" "${HOME}/bin"
OK

echo ""
echo -e "${bold}NOTE: ~/bin must be in your PATH variable${norm}"

# -- part 2 : deploy on TGCC

echo ""
echo -e "${bold}[ Deploy InstallerTGCC on TGCC ]${norm}"

read -p "> Enter your TGCC ssh configuration profile (or ENTER if you haven't configure SSH profiles): " TGCC_SSH_CONFIG
if [[ -z "${TGCC_SSH_CONFIG}" ]]; then
  Error "Abort remote installation"
  exit 0
fi

echo -n "- create TGCC '~/bin' folder "
TGCC_CMD="bash -c \"mkdir -p ~/bin\""
ssh -q $TGCC_SSH_CONFIG -t $TGCC_CMD
if [ $? -eq 0 ]; then
  OK
else
  Error "Fail to create TGCC '~/bin' folder (rc=$?).. abort" "\n"
  exit 10
fi

echo -n "- create TGCC installation folder '${TGCC_INSTALL}' "
TGCC_CMD="bash -c \"mkdir -p $TGCC_INSTALL\""
ssh -q $TGCC_SSH_CONFIG -t $TGCC_CMD
if [ $? -eq 0 ]; then
  OK
else
  Error "Fail to create installation folder on TGCC (rc=$?).. abort" "\n"
  exit 10
fi

echo "- synchronise InstallerTGCC repository"
echo ""
$HOME/bin/sync-tgcc.sh -s "$HOME/.tgcc/InstallerTGCC" -d "${TGCC_INSTALL}" -z
if [ $? -ne 0 ]; then
  Error "Synchronisastion fail .. abort" "\n"
  exit 10
fi

echo -n "- link scripts in ~/bin on TGCC "
TGCC_CMD="bash -c \"ln -sf $TGCC_INSTALL/InstallerTGCC/docker/scripts/docker-import.sh ~/bin\""
ssh -q $TGCC_SSH_CONFIG -t $TGCC_CMD
if [ $? -eq 0 ]; then
  OK
else
  Error "Fail to link docker import script.. abort${norm}" "\n"
fi

echo -e "\n${green}[ --- InstallerTGCC setup complete --- ]${norm}"
