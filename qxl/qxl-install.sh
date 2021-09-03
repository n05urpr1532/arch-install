#!/usr/bin/env bash

cp ./01-qxl-modules.conf /etc/X11/xorg.conf.d/

mkdir ~/build
cd ~/build || exit 1
git clone https://github.com/archlinux/svntogit-community.git --single-branch --branch "packages/xf86-video-qxl"
cd svntogit-community/repos/community-x86_64/ || exit 1
vim PKGBUILD
# Launch to install
#makepkg -rsic
