#!/usr/bin/env bash

install_plasma() {
  local user_name=$1

  exec_in_container /usr/bin/su -c 'paru -S --noconfirm --needed plasma-desktop drkonqi xdg-desktop-portal-kde' - "${user_name}"
  exec_in_container /usr/bin/su -c 'paru -S --noconfirm --needed kde-gtk-config kdeplasma-addons khotkeys kscreen kwrited' - "${user_name}"
  exec_in_container /usr/bin/su -c 'paru -S --noconfirm --needed plasma-browser-integration plasma-disks plasma-firewall plasma-nm plasma-pa plasma-systemmonitor plasma-workspace-wallpapers' - "${user_name}"
  exec_in_container /usr/bin/su -c 'paru -S --noconfirm --needed partitionmanager ksystemlog kcalc print-manager kdeconnect kdenetwork-filesharing kio-extras kio-gdrive zeroconf-ioslave' - "${user_name}"
}

configure_plasma() {
  local user_name=$1

  cat << 'EOF' > /mnt/etc/xdg/kdesurc
[super-user-command]
super-user-command=sudo
EOF

  # TODO Is this needed ?
  #  mkdir -p "/home/${user_name}/.config"
  #  cp /mnt/etc/xdg/kdesurc "/home/${user_name}/.config/kdesurc"
  #  exec_in_container /usr/bin/chown "${user_name}:${user_name}" "/home/${user_name}/.config/kdesurc"
}
