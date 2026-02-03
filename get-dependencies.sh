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
#patch -Np1 -i "../spaghettikart-cmake-flags.patch"
cmake . \
    -Bbuild \
    -GNinja \
    -DNON_PORTABLE=On \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_C_FLAGS="-Wno-incompatible-pointer-types -Wno-int-conversion -Wno-changes-meaning"
cmake --build build --config Release
cmake --build build --config Release --target GenerateO2R
cmake --install build

#install -dm755 /usr/bin/
#install -Dm755 "Spaghettify" /usr/bin/
# Create Directories
#  install -dm755 "${pkgdir}/${SHIP_PREFIX}" "${pkgdir}/usr/bin/"
  # Main executable & assets to /opt
#  cp -r build/yamls build/meta "${pkgdir}/${SHIP_PREFIX}"
#  install -m755 build/Spaghettify "${pkgdir}/${SHIP_PREFIX}"
#  install -m644 -t "${pkgdir}/${SHIP_PREFIX}" \
#        build/config.yml \
#        build/spaghetti.o2r \
#        "${srcdir}/SDL_GameControllerDB/gamecontrollerdb.txt"
  # Link executable to /usr/bin, add to desktop entry & icons
#  ln -s "${SHIP_PREFIX}/Spaghettify" "${pkgdir}/usr/bin/Spaghettify"
#  install -Dm644 "${srcdir}/spaghettikart.desktop" -t "${pkgdir}/usr/share/applications"
#  install -Dm644 icon.png "${pkgdir}/usr/share/pixmaps/spaghettikart.png"
  # Licenses (HarbourMasters libraries are MIT, game engine + port source code is nonfree)
#  install -Dm644 "libultraship/LICENSE" "${pkgdir}/usr/share/licenses/spaghettikart/libultraship-LICENSE"
#  install -Dm644 "torch/LICENSE" "${pkgdir}/usr/share/licenses/spaghettikart/torch-LICENSE"
