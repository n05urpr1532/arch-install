#!/usr/bin/env bash

#
# Snapper config
#
install_and_configure_snapper() {
  local root_device_parameter=$1
  local user_name=$2
  local mount_options

  local qgroup_root='1/1'
  local qgroup_home='1/2'

  mount_options=$(get_mount_options)

  umount /mnt/.snapshots \
    && umount /mnt/home/.snapshots \
    && rm -r /mnt/.snapshots /mnt/home/.snapshots \
    && arch-chroot /mnt pacman -Sy --noconfirm --needed snapper \
    && arch-chroot /mnt groupadd "btrfs-users" \
    && arch-chroot /mnt usermod -a -G "btrfs-users" "${user_name}" \
    && arch-chroot /mnt snapper --no-dbus -c root create-config / \
    && arch-chroot /mnt snapper --no-dbus -c home create-config /home \
    && arch-chroot /mnt btrfs sub delete /.snapshots /home/.snapshots \
    && mkdir -p /mnt/{.snapshots,home/.snapshots} \
    && mount -o "${mount_options},subvol=@.snapshots/root" "${root_device_parameter}2" /mnt/.snapshots \
    && mount -o "${mount_options},subvol=@.snapshots/home" "${root_device_parameter}2" /mnt/home/.snapshots \
    && arch-chroot /mnt chmod 750 /.snapshots /home/.snapshots \
    && arch-chroot /mnt chown ":btrfs-users" /.snapshots /home/.snapshots \
    && arch-chroot /mnt btrfs qgroup create "${qgroup_root}" /.btrfs-root \
    && arch-chroot /mnt btrfs qgroup create "${qgroup_home}" /.btrfs-root

  # root config
  sed -i "s@^QGROUP=\"\"@QGROUP=\"${qgroup_root}\"@" /mnt/etc/snapper/configs/root
  sed -i 's/^ALLOW_GROUPS=""/ALLOW_GROUPS="btrfs-users"/' /mnt/etc/snapper/configs/root
  sed -i 's/^NUMBER_LIMIT="50"/NUMBER_LIMIT="3-10"/' /mnt/etc/snapper/configs/root
  sed -i 's/^NUMBER_LIMIT_IMPORTANT="10"/NUMBER_LIMIT_IMPORTANT="5-10"/' /mnt/etc/snapper/configs/root
  sed -i 's/^NUMBER_MIN_AGE="1800"/NUMBER_MIN_AGE="86400"/' /mnt/etc/snapper/configs/root
  sed -i 's/^TIMELINE_LIMIT_HOURLY="10"/TIMELINE_LIMIT_HOURLY="3"/' /mnt/etc/snapper/configs/root
  sed -i 's/^TIMELINE_LIMIT_DAILY="10"/TIMELINE_LIMIT_DAILY="7"/' /mnt/etc/snapper/configs/root
  sed -i 's/^TIMELINE_LIMIT_WEEKLY="10"/TIMELINE_LIMIT_WEEKLY="4"/' /mnt/etc/snapper/configs/root
  sed -i 's/^TIMELINE_LIMIT_MONTHLY="10"/TIMELINE_LIMIT_MONTHLY="3"/' /mnt/etc/snapper/configs/root
  sed -i 's/^TIMELINE_LIMIT_YEARLY="10"/TIMELINE_LIMIT_YEARLY="0"/' /mnt/etc/snapper/configs/root

  # home config
  sed -i "s@^QGROUP=\"\"@QGROUP=\"${qgroup_home}\"@" /mnt/etc/snapper/configs/home
  sed -i 's/^ALLOW_GROUPS=""/ALLOW_GROUPS="btrfs-users"/' /mnt/etc/snapper/configs/home
  sed -i 's/^NUMBER_LIMIT="50"/NUMBER_LIMIT="5-10"/' /mnt/etc/snapper/configs/home
  sed -i 's/^NUMBER_LIMIT_IMPORTANT="10"/NUMBER_LIMIT_IMPORTANT="5-10"/' /mnt/etc/snapper/configs/home
  sed -i 's/^NUMBER_MIN_AGE="1800"/NUMBER_MIN_AGE="86400"/' /mnt/etc/snapper/configs/home
  sed -i 's/^TIMELINE_LIMIT_HOURLY="10"/TIMELINE_LIMIT_HOURLY="6"/' /mnt/etc/snapper/configs/home
  sed -i 's/^TIMELINE_LIMIT_DAILY="10"/TIMELINE_LIMIT_DAILY="7"/' /mnt/etc/snapper/configs/home
  sed -i 's/^TIMELINE_LIMIT_WEEKLY="10"/TIMELINE_LIMIT_WEEKLY="4"/' /mnt/etc/snapper/configs/home
  sed -i 's/^TIMELINE_LIMIT_MONTHLY="10"/TIMELINE_LIMIT_MONTHLY="3"/' /mnt/etc/snapper/configs/home
  sed -i 's/^TIMELINE_LIMIT_YEARLY="10"/TIMELINE_LIMIT_YEARLY="0"/' /mnt/etc/snapper/configs/home

  # Enable Snapper timers
  arch-chroot /mnt systemctl enable snapper-timeline.timer snapper-cleanup.timer
}

install_and_configure_snap_pac_and_snapper_rollback() {
  local user_name=$1

  arch-chroot /mnt pacman -Sy --noconfirm --needed snap-pac \
    && arch-chroot /mnt gpg --auto-key-import --recv-keys EB4F9E5A60D32232BB52150C12C87A28FEAC6B20 \
    && arch-chroot /mnt su -c 'paru -S --noconfirm --needed snap-pac-grub' - "${user_name}" \
    && arch-chroot /mnt su -c 'paru -S --noconfirm --needed snapper-rollback' - "${user_name}"

  # snap-pac config
  cat << 'EOF' >> /mnt/etc/snap-pac.ini

[DEFAULT]
## Uncomment to add "important=yes" to userdata for snapshots referring to these packages
## Default is []
important_packages = ["linux", "linux-lts", "linux-zen"]

## Uncomment to add "important=yes" to userdata for snapshots that were created with the following commands
## Default is []
important_commands = ["pacman -Syu", "pacman -Syyu", "paru -Syu", "paru -Syyu"]
EOF

  # snapper-rollback config
  sed -i 's%^subvol_snapshots = @snapshots%subvol_snapshots = @.snapshots/root%' /mnt/etc/snapper-rollback.conf
  sed -i 's%^mountpoint = /btrfsroot%mountpoint = /.btrfs-root%' /mnt/etc/snapper-rollback.conf
}

clean_snapper() {
  local max_snapshot_num
  max_snapshot_num=$(arch-chroot /mnt snapper --no-dbus list | tail -n 1 | cut -d' ' -f 1)

  arch-chroot /mnt snapper --no-dbus delete "1-${max_snapshot_num}"

  arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
}
