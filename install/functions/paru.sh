#!/usr/bin/env bash

install_paru() {
  local user_name=$1

  arch-chroot /mnt su -c 'cd /tmp && git clone https://aur.archlinux.org/paru.git && cd paru && makepkg -si --noconfirm && cd /tmp && rm -rf paru' - "${user_name}"
  arch-chroot /mnt su -c 'paru -Syyu --noconfirm' - "${user_name}"

  arch-chroot /mnt su -c 'paru -S --noconfirm --needed informant' - "${user_name}"
}

clean_paru () {
  arch-chroot /mnt paru -Sc --noconfirm
}
