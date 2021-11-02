#!/usr/bin/env bash

configure_grub () {
  arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot/ESP --bootloader-id=ArchLinux --recheck
  arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
}

configure_grub_theme () {
  mkdir -p /mnt/boot/grub/themes
  cp -pr "$(get_directory 'grub-themes/Xenlism-Arch')" /mnt/boot/grub/themes/

  sed -i 's@GRUB_GFXMODE=auto@GRUB_GFXMODE=3840x2160,2560x1440,1920x1200,1920x1080@' /mnt/etc/default/grub
  sed -i 's@#GRUB_THEME="/path/to/gfxtheme"@GRUB_THEME="/boot/grub/themes/Xenlism-Arch/theme.txt"@' /mnt/etc/default/grub
}
