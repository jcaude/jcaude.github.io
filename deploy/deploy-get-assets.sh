#!/usr/bin/env bash

## TTY Constants
red="$(printf '\e[0;91m')"
bred="$(printf '\e[1;91m')"
green="$(printf '\e[0;92m')"
bgreen="$(printf '\e[1;92m')"
bold="$(printf '\e[1m')"
norm="$(printf '\e[0m')"
err="$(printf '\e[1m\e[1;91mERROR: ')"

# retrieve latest assets ids
TOKEN=`cat ~/.config/deploy-token`

function OK() {
    echo -e "${green}OK${norm}"
}

function Error() {
    [ $# -eq 2 ] && echo -e "$2"
    echo -e "${bred}ERROR: ${red}$1${norm}"
}

function asset_list() {
    curl -s -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer $TOKEN" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        https://api.github.com/repos/neurospin-brainomics/Deploy/releases/latest
}

function asset_download() {
    url=$1
    output="$DOWNLOAD_DIR/$2"

    curl -L -H "Accept: application/octet-stream" \
        -H "Authorization: Bearer $TOKEN" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        $url \
        -o $output

    chmod +x $output
}

function GetAssets() {
    ASSETS_LIST=`asset_list | jq -r '.assets | .[] | [ .url,  .name ] | @csv' `

    while IFS=',' read -r url bin; do
        echo "Download $bin"
        url=$(echo "$url" | sed 's/"//g')
        bin=$(echo "$bin" | sed 's/"//g')
        asset_download $url $bin
    done <<< "$ASSETS_LIST"
}

function Usage() {
    echo -e "${bold}Usage:${norm} $(basename $0) -d download_dir -r release_tag"
}

# check args
if [ $# -eq 0 ]; then
    Usage
    exit 1
fi

# parse command line
while getopts "d:r:" opt; do
    case "$opt" in
    d)  DOWNLOAD_DIR=$OPTARG
        ;;
    r)  RELEASE_TAG=$OPTARG
        ;;
    esac
done

# check args
if [ ! "$DOWNLOAD_DIR" ]; then
    Error "Missing mandatory 'download_dir' argument"
    echo ""
    Usage
    exit 1
fi

if [ ! "$RELEASE_TAG" ]; then
    Error "Missing mandatory 'release_tag' argument"
    echo ""
    Usage
    exit 1
fi

echo "${green}Download release ${bgreen}$RELEASE_TAG${green} to ${bgreen}$DOWNLOAD_DIR${norm}"
echo ""

# create directory if not exeists
if [ ! -d $DOWNLOAD_DIR ]; then
    echo -n "${bold}> create download directory${norm} "
    mkdir -p $DOWNLOAD_DIR
    OK
fi

echo "${bold}> download assets${norm} "
GetAssets
echo -n "${bold}> download assets${norm} "
OK

echo "$RELEASE_TAG" > "$DOWNLOAD_DIR/TAG"

