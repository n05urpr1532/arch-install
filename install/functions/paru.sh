#!/usr/bin/env bash

install_paru() {
  local user_name=$1

  arch-chroot /mnt su -c 'cd /tmp && git clone https://aur.archlinux.org/paru-bin.git && cd paru-bin && makepkg -sic --noconfirm && cd /tmp && rm -rf paru-bin' - "${user_name}"
  arch-chroot /mnt su -c 'paru -Syyu --noconfirm' - "${user_name}"

  # pacman and paru utilities
  # TODO To fix
  # informant causes error when ran with pacman. Waiting for informant update from current version 0.4.4-1.
  #arch-chroot /mnt su -c 'paru -S --noconfirm --needed informant wat-git' - "${user_name}"
  arch-chroot /mnt su -c 'paru -S --noconfirm --needed wat-git' - "${user_name}"
}

clean_paru() {
  arch-chroot /mnt paru -Sc --noconfirm
}
