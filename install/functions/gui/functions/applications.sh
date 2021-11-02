#!/usr/bin/env bash

install_apps() {
  local user_name=$1

  exec_in_container /usr/bin/su -c 'paru -S --noconfirm --needed srandrd mesa-demos grub-customizer hwinfo' - "${user_name}"
  exec_in_container /usr/bin/su -c 'paru -S --noconfirm --needed pcmanfm-gtk3 xarchiver gvfs gvfs-google gvfs-nfs gvfs-smb' - "${user_name}"
  exec_in_container /usr/bin/su -c 'paru -S --noconfirm --needed alacritty xterm galculator geany geany-plugins geany-themes firefox firefox-i18n-fr snapper-gui cpupower-gui psensor' - "${user_name}"
}

configure_geany() {
  mkdir -p /mnt/usr/share/geany
  cp -p "$(get_file 'geany' 'geany.conf')" /mnt/usr/share/geany/geany.conf
}
