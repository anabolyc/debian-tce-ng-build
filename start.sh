#!/bin/bash

cd /live-default && find . -delete

# >> recepie for building stock debian

#lb config --linux-packages "linux-image linux-headers" --archive-areas "main contrib"
#echo "virtualbox-guest-dkms virtualbox-guest-x11" >> ./config/package-lists/my.list.chroot
#echo "task-gnome-desktop" > ./config/package-lists/desktop.list.chroot
#lb build

# <<

. /live-build-scripts/1-config-build.sh && \
mkdir -p ./patch/package-lists && \
echo "virtualbox-guest-dkms virtualbox-guest-x11" >> ./patch/package-lists/vbox.list.chroot && \
. /live-build-scripts/2-perform-build.sh

