#!/usr/bin/env bash

install_paru() {
  local user_name=$1

  # TODO Remove when paru-bin is validated
  #arch-chroot /mnt su -c 'cd /tmp && git clone https://aur.archlinux.org/paru.git && cd paru && makepkg -sic --noconfirm && cd /tmp && rm -rf paru' - "${user_name}"
  arch-chroot /mnt su -c 'cd /tmp && git clone https://aur.archlinux.org/paru-bin.git && cd paru-bin && makepkg -sic --noconfirm && cd /tmp && rm -rf paru-bin' - "${user_name}"
  arch-chroot /mnt su -c 'paru -Syyu --noconfirm' - "${user_name}"

  # informant causes error when ran with pacman. Waiting for informant update from current version 0.4.4-1.
  # arch-chroot /mnt su -c 'paru -S --noconfirm --needed informant' - "${user_name}"
}

clean_paru() {
  arch-chroot /mnt paru -Sc --noconfirm
}
