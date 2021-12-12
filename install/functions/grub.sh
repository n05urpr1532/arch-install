#!/usr/bin/env bash

configure_grub () {
  arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot/ESP --bootloader-id=ArchLinux --recheck
  arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
}

configure_grub_theme () {
  local is_vm_guest="${1}"

  mkdir -p /mnt/boot/grub/themes
  cp -pr "$(get_directory 'grub-themes/Xenlism-Arch')" /mnt/boot/grub/themes/

  sed -i 's@#GRUB_THEME="/path/to/gfxtheme"@GRUB_THEME="/boot/grub/themes/Xenlism-Arch/theme.txt"@' /mnt/etc/default/grub

  if [ "${is_vm_guest}" = "1" ]; then
    sed -i 's@GRUB_GFXMODE=auto@GRUB_GFXMODE=1920x1080@' /mnt/etc/default/grub
  fi
}

configure_grub_linux_as_default () {
  local user_name=$1

  # Patch grub to make vmlinuz-linux the first entry (and not vmlinuz-linux-lts)
  arch-chroot /mnt su -c 'paru -S --noconfirm --needed grub-linux-default-hook' - "${user_name}"

  arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
}
