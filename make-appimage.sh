#!/bin/sh

set -eu

ARCH=$(uname -m)
#VERSION=$(pacman -Q spaghettikart | awk '{print $2; exit}') # example command to get version of application here
export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.bg.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=/usr/share/pixmaps/SpaghettiKart.png
export DESKTOP=/usr/share/applications/SpaghettiKart.desktop
export DEPLOY_OPENGL=1

# Deploy dependencies
quick-sharun /usr/bin/Spaghettify
mv /usr/bin/spaghetti.o2r /usr/bin/config.yml /usr/bin/meta /usr/bin/yamls ./AppDir/shared/bin/
echo 'SHARUN_WORKING_DIR=${SHARUN_DIR}' >> ./AppDir/.env

# Additional changes can be done in between here

# Turn AppDir into AppImage
quick-sharun --make-appimage
