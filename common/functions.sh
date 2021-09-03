#!/usr/bin/env bash

check_root_device_parameter () {
  local root_device_parameter=$1
  if [ -z "${root_device_parameter}" ]; then
    echo "!!! Error !!!"
    echo ""
    echo "Please specify a root device as a parameter (for example: /dev/sda)"
    echo ""
    exit 1
  fi
}

get_mount_options () {
  # TODO Add space_cache=v2 afterward
  printf "defaults,noatime,autodefrag,compress-force=zstd:2"
}

mount_root () {
  local root_device_parameter=$1
  local mount_options

  mount_options=$(get_mount_options)
  mount -o "${mount_options},subvol=@" "${root_device_parameter}2" /mnt
  mkdir -p /mnt/{.btrfs-root,boot/ESP,home,.snapshots,var/swap}
  mount "${root_device_parameter}1" /mnt/boot/ESP
  mount -o "${mount_options},subvolid=5" "${root_device_parameter}2" /mnt/.btrfs-root
  chmod 700 /mnt/.btrfs-root
  mount -o "${mount_options},subvol=@home" "${root_device_parameter}2" /mnt/home
  mount -o "${mount_options},subvol=@.snapshots/root" "${root_device_parameter}2" /mnt/.snapshots
  mkdir -p /mnt/home/.snapshots
  mount -o "${mount_options},subvol=@.snapshots/home" "${root_device_parameter}2" /mnt/home/.snapshots
  mount -o "${mount_options},subvol=@var_swap" "${root_device_parameter}2" /mnt/var/swap
}

unmount_root () {
  local root_device_parameter=$1

  swapoff /mnt/var/swap/swapfile || true
  umount -A "${root_device_parameter}1" || true
  umount -A "${root_device_parameter}2" || true
}

init_container () {
  systemd-nspawn -bD /mnt &
}

exec_in_container () {
  machinectl shell mnt "$@"
}

stop_container () {
  machinectl shell mnt /usr/bin/poweroff
  machinectl kill mnt || true
}
