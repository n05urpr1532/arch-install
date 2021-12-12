#!/usr/bin/env bash

check_root_device_parameter() {
  local root_device_parameter=$1
  if [ -z "${root_device_parameter}" ]; then
    echo "!!! Error !!!"
    echo ""
    echo "Please specify a root device as a parameter (for example: /dev/sda)"
    echo ""
    exit 1
  fi

  if ! lsblk "${root_device_parameter}" > /dev/null 2>&1; then
    echo "!!! Error !!!"
    echo ""
    echo "Invalid root device '${root_device_parameter}'"
    echo ""
    exit 1
  fi
}

check_not_empty() {
  local input=$1

  if [ -z "${input}" ]; then
    echo "!!! Error !!!"
    echo ""
    echo "This cannot be empty !"
    echo ""
    exit 1
  fi
}

check_yes_or_no() {
  local input=$1

  case ${input} in
    y | Y | n | N) ;;

    *)
      echo "!!! Error !!!"
      echo ""
      echo "This must be either y for yes or n for no !"
      echo ""
      exit 1
      ;;
  esac
}

get_mount_options() {
  printf "defaults,noatime,autodefrag,compress-force=zstd:2,space_cache=v2"
}

mount_root() {
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

unmount_root() {
  local root_device_parameter=$1

  swapoff /mnt/var/swap/swapfile || true
  umount -A "${root_device_parameter}1" || true
  umount -A "${root_device_parameter}2" || true
}

init_container() {
  sleep 5
  systemd-nspawn -bD /mnt < /dev/null &> /dev/null &
  sleep 10
}

exec_in_container() {
  machinectl shell mnt "$@"
}

stop_container() {
  ( (machinectl shell mnt /usr/bin/poweroff) && sleep 5) || machinectl kill mnt
}
