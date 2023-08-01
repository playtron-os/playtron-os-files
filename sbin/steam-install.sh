#!/bin/bash

# Install dependencies for Steam itself.
# "binutils" and "xz" are specifically only needed to extract the Debian package.
# The only missing dependency is "steam-devices" from RPMFusion.
sudo rpm-ostree install --apply-live -y binutils glibc.i686 gtk2 libdbusmenu-gtk3 libdrm.i686 libglvnd-glx.i686 libnsl libnsl.i686 libpng12 libvdpau xz zenity
wget 'https://cdn.cloudflare.steamstatic.com/client/installer/steam.deb'
ar xv steam.deb
rm -f -v debinay-binary control.tar.gz
mkdir "${HOME}/steam_install/"
tar -x -v -f data.tar.xz --directory="${HOME}/steam_install/"
rm -f -v steam.deb control.tar.gz
# Run Steam.
# This will actually fail because the package "libsnl.i686" requires a reboot to be loaded up
# and it does not work as a live applied update.
#/var/home/playtron/steam_install/usr/bin/steam
