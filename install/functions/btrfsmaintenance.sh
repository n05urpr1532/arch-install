#!/usr/bin/env bash

#
# btrfsmaintenance config
#
install_and_configure_btrfsmaintenance() {
  local user_name=$1

  arch-chroot /mnt su -c 'paru -S --noconfirm --needed btrfsmaintenance' - "${user_name}"

  sed -i 's@^BTRFS_LOG_OUTPUT="stdout"@BTRFS_LOG_OUTPUT="journal"@' /mnt/etc/default/btrfsmaintenance
  sed -i 's@^BTRFS_BALANCE_MOUNTPOINTS="/"@BTRFS_BALANCE_MOUNTPOINTS="/.btrfs-root"@' /mnt/etc/default/btrfsmaintenance
  sed -i 's@^BTRFS_BALANCE_DUSAGE="5 10"@BTRFS_BALANCE_DUSAGE="1 25"@' /mnt/etc/default/btrfsmaintenance
  sed -i 's@^BTRFS_BALANCE_MUSAGE="5"@BTRFS_BALANCE_MUSAGE="25"@' /mnt/etc/default/btrfsmaintenance
  sed -i 's@^BTRFS_SCRUB_MOUNTPOINTS="/"@BTRFS_SCRUB_MOUNTPOINTS="/.btrfs-root"@' /mnt/etc/default/btrfsmaintenance
  sed -i 's@^BTRFS_TRIM_PERIOD="none"@BTRFS_TRIM_PERIOD="weekly"@' /mnt/etc/default/btrfsmaintenance
  sed -i 's@^BTRFS_TRIM_MOUNTPOINTS="/"@BTRFS_TRIM_MOUNTPOINTS="/.btrfs-root"@' /mnt/etc/default/btrfsmaintenance

  arch-chroot /mnt systemctl restart btrfsmaintenance-refresh.service
}
