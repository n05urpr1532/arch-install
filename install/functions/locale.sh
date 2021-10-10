#!/usr/bin/env bash

#
# Locale related config
#
configure_locale() {
  arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime

  arch-chroot /mnt hwclock --systohc

  sed -i "s/#en_US.UTF-8/en_US.UTF-8/" /mnt/etc/locale.gen
  sed -i "s/#fr_FR.UTF-8/fr_FR.UTF-8/" /mnt/etc/locale.gen
  arch-chroot /mnt locale-gen
  echo -e "LANG=fr_FR.UTF-8\nLC_MESSAGES=en_US.UTF-8\nLANGUAGE=en_US" > /mnt/etc/locale.conf

  echo "KEYMAP=fr" > /mnt/etc/vconsole.conf
}

configure_locale_in_container() {
  exec_in_container /usr/bin/timedatectl --no-ask-password set-timezone Europe/Paris
  exec_in_container /usr/bin/timedatectl --no-ask-password set-ntp true
}
