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
    tinyxml2      \
    zenity

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

# Comment this out if you need an AUR package
#make-aur-package

# If the application needs to be manually built that has to be done down here
echo "Making nightly build of SpaghettiKart..."
echo "---------------------------------------------------------------"
REPO="https://github.com/HarbourMasters/SpaghettiKart"
VERSION="$(git ls-remote "$REPO" HEAD | cut -c 1-9 | head -1)"
git clone --recursive --depth 1 "$REPO" ./SpaghettiKart
echo "$VERSION" > ~/version

cd ./SpaghettiKart
patch -Np1 -i "../spaghettikart-cmake-flags.patch"
cmake . \
    -Bbuild \
    -GNinja \
    -DCMAKE_INSTALL_PREFIX=/usr/share/spaghettikart \
    -DCMAKE_C_FLAGS="-Wno-incompatible-pointer-types -Wno-int-conversion -Wno-changes-meaning"
    #-DNON_PORTABLE=On \
cmake --build build --config Release
cmake --build build --config Release --target GenerateO2R

mkdir -p /usr/share/spaghettikart
mv -v build/Spaghettify /usr/share/spaghettikart
ln -s "usr/share/spaghettikart/Spaghettify" "/usr/bin/Spaghettify"
mv -v build/config.yml build/spaghetti.o2r /usr/share/spaghettikart
cp -r build/yamls build/meta /usr/share/spaghettikart
sed -i 's/^Icon=icon$/Icon=SpaghettiKart/' SpaghettiKart.desktop
cp -v "SpaghettiKart.desktop" "/usr/share/applications"
cp -v icon.png "/usr/share/pixmaps/SpaghettiKart.png"
