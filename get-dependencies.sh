#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
    cmake         \
    fmt           \
    libdecor      \
    libzip        \
    ninja         \
    nlohmann-json \
    sdl2          \
    sdl2_net      \
    spdlog        \
    tinyxml2

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

# Comment this out if you need an AUR package
make-aur-package zenity-rs-bin

# If the application needs to be manually built that has to be done down here
echo "Making stable build of SpaghettiKart..."
echo "---------------------------------------------------------------"
REPO="https://github.com/HarbourMasters/SpaghettiKart"
VERSION="$(git ls-remote --tags --sort="v:refname" "$REPO" | tail -n1 | sed 's/.*\///; s/\^{}//')"
git clone --branch "$VERSION" --single-branch --recursive --depth 1 "$REPO" ./SpaghettiKart
echo "$VERSION" > ~/version

mkdir -p ./AppDir/bin
cd ./SpaghettiKart
patch -Np1 -i "../spaghettikart-non-portable-fix.patch"
patch -d libultraship -Np1 -i "../../lus-save-file-path.patch"
patch -d torch -Np1 -i "../../torch-src-dest-paths.patch"
cmake . \
    -Bbuild \
    -GNinja \
    -DNON_PORTABLE=On
cmake --build build --config Release
cmake --build build --config Release --target GenerateO2R

mv -v build/yamls ../AppDir/bin
mv -v build/Spaghettify ../AppDir/bin
mv -v build/config.yml ../AppDir/bin
mv -v build/spaghetti.o2r ../AppDir/bin
wget -O ../AppDir/bin/gamecontrollerdb.txt https://raw.githubusercontent.com/mdqinc/SDL_GameControllerDB/master/gamecontrollerdb.txt
cp -rv icon.png /usr/share/pixmaps/spaghettikart.png
