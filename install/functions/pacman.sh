#!/usr/bin/env bash

#
# Pacman config
#
configure_pacman () {
  sed -i 's@\[options\]@[options]\nInclude = /etc/pacman.d/options@' /mnt/etc/pacman.conf

  cat << 'EOF' > /mnt/etc/pacman.d/options
Color
ParallelDownloads = 10
ILoveCandy
EOF

  arch-chroot /mnt pacman-key --init
  arch-chroot /mnt pacman-key --populate archlinux
}

clean_pacman () {
  arch-chroot /mnt bash -c 'pacman -Qtdq | pacman -Rns --noconfirm -'
}
