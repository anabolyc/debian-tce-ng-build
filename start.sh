#!/bin/bash

cd /live-default

lb config --linux-packages "linux-image linux-headers" --archive-areas "main contrib"
echo "virtualbox-guest-dkms virtualbox-guest-x11" >> ./config/package-lists/my.list.chroot
echo "task-gnome-desktop" > ./config/package-lists/desktop.list.chroot
lb build

