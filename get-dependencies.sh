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
echo "Building SpaghettiKart..."
echo "---------------------------------------------------------------"
REPO="https://github.com/HarbourMasters/SpaghettiKart"
GRON="https://raw.githubusercontent.com/xonixx/gron.awk/refs/heads/main/gron.awk"
# Determine to build nightly or stable
if [ "${DEVEL_RELEASE-}" = 1 ]; then
    echo "Making nightly build of SpaghettiKart..."
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
else
    echo "Making stable build of SpaghettiKart..."
	wget "$GRON" -O ./gron.awk
	chmod +x ./gron.awk
	VERSION=$(wget https://api.github.com/repos/HarbourMasters/SpaghettiKart/tags -O - | \
		./gron.awk | grep -v "nJoy" | awk -F'=|"' '/name/ {print $3}' | \
		sort -V -r | head -1)
	git clone --branch "$VERSION" --single-branch --recursive --depth 1 "$REPO" ./SpaghettiKart
    echo "$VERSION" > ~/version
    
    cd ./SpaghettiKart
    patch -Np1 -i "../spaghettikart-non-portable-fix.patch"
	cd libultraship
  	patch -Np1 -i "./lus-save-file-path.patch"
  	cd ../torch
  	patch -Np1 -i "./torch-src-dest-paths.patch"
	cd ..
    cmake . \
        -Bbuild \
        -GNinja \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DNON_PORTABLE=On
    
    cmake --build build --config Release
    cmake --build build --config Release --target GenerateO2R

    mkdir -p /usr/bin
    mv -v build/Spaghettify /usr/bin
    ln -s "usr/share/spaghettikart/Spaghettify" "/usr/bin/Spaghettify"
    mv -v build/config.yml build/spaghetti.o2r /usr/bin
    cp -r build/yamls build/meta /usr/bin
    sed -i 's/^Icon=icon$/Icon=SpaghettiKart/' SpaghettiKart.desktop
    cp -v "SpaghettiKart.desktop" "/usr/share/applications"
    cp -v icon.png "/usr/share/pixmaps/SpaghettiKart.png"
fi
