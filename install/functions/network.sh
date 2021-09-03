#!/usr/bin/env bash

#
# Network related config
#
configure_network() {
  local host_name=$1

  echo "${host_name}" > /mnt/etc/hostname

  echo -e "127.0.0.1\t localhost\n::1\t localhost\n127.0.1.1\t ${host_name}" > /mnt/etc/hosts

  arch-chroot /mnt systemctl enable NetworkManager
}
