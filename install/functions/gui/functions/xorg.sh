#!/usr/bin/env bash

install_xorg() {
  local user_name=$1

  exec_in_container /usr/bin/su -c 'paru -S --noconfirm --needed xorg xorg-apps libxkbcommon-x11 xdg-utils xf86-input-evdev xf86-input-libinput xf86-input-void xf86-video-dummy xf86-video-fbdev xf86-video-intel vulkan-intel' - "${user_name}"
  exec_in_container /usr/bin/su -c 'paru -S --noconfirm --needed libva libva-mesa-driver intel-media-driver noto-fonts' - "${user_name}"
}

configure_xorg() {
  exec_in_container /usr/bin/localectl set-x11-keymap fr pc105

  #  cat << 'EOF' > /mnt/etc/X11/xinit/xinitrc.d/99-keymap.sh
  ##!/bin/bash
  #
  #setxkbmap fr
  #EOF
  #  chmod +x /mnt/etc/X11/xinit/xinitrc.d/99-keymap.sh

  cat << 'EOF' >> /mnt/etc/environment
XDG_CONFIG_DIRS=/etc/xdg
XDG_DATA_DIRS=/usr/local/share:/usr/share
EOF
}
