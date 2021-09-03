#!/usr/bin/env bash
# shellcheck disable=SC2086

install_paru() {
  local user_name=$1

  arch-chroot /mnt su -c 'cd /tmp && git clone https://aur.archlinux.org/paru.git && cd paru && makepkg -si --noconfirm && cd /tmp && rm -rf paru' - ${user_name}
  arch-chroot /mnt su -c 'paru -Syyu --noconfirm' - ${user_name}
}

clean_paru () {
  arch-chroot /mnt paru -Sc --noconfirm
}
