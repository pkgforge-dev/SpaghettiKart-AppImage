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
export CFLAGS="${CFLAGS/-Werror=format-security/}"
export CXXFLAGS="${CXXFLAGS/-Werror=format-security/}"
cmake . \
    -Bbuild \
    -GNinja \
    -DNON_PORTABLE=On \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -Wno
cmake --build build --config Release $NINJAFLAGS
cmake --build build --config Release --target GenerateO2R
cmake --install build
