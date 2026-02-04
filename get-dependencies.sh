#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
    cmake         \
    fmt           \
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
    -DNON_PORTABLE=On \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_C_FLAGS="-Wno-incompatible-pointer-types -Wno-int-conversion -Wno-changes-meaning"
cmake --build build --config Release
cmake --build build --config Release --target GenerateO2R

install -dm755 /usr/bin/
install -m755 build/Spaghettify /usr/bin
install -m644 build/config.yml -t /usr/bin
install -m644 build/spaghetti.o2r -t /usr/bin
cp -r build/yamls build/meta /usr/bin
sed -i 's/^Icon=icon$/Icon=SpaghettiKart/' SpaghettiKart.desktop
install -Dm644 "SpaghettiKart.desktop" -t "/usr/share/applications"
install -Dm644 icon.png "/usr/share/pixmaps/SpaghettiKart.png"
# Licenses (HarbourMasters libraries are MIT, game engine + port source code is nonfree)
install -Dm644 "libultraship/LICENSE" "/usr/share/licenses/spaghettikart/libultraship-LICENSE"
install -Dm644 "torch/LICENSE" "/usr/share/licenses/spaghettikart/torch-LICENSE"
