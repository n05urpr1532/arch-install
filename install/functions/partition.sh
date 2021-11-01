#!/usr/bin/env bash

#
# Partitioning
#
create_partitions() {
  local root_device_parameter=$1
  local root_partition_size=$2

  # Create 2 partitions:
  # * ESP - 256M, type "EFI System"
  # * BROOT - The rest, type "Linux filesystem" (by default)
  parted --align optimal -s "${root_device_parameter}" "mklabel gpt mkpart ESP fat32 1MiB 257MiB mkpart BROOT btrfs 257MiB ${root_partition_size} set 1 esp on"

  mkfs.fat -v -F 32 -n ESP "${root_device_parameter}1"
  mkfs.btrfs -L BROOT "${root_device_parameter}2" -f

  #
  # BTRFS layout config
  #
  mount "${root_device_parameter}2" /mnt

  btrfs sub create /mnt/@
  btrfs sub create /mnt/@home
  btrfs sub create /mnt/@.snapshots
  btrfs sub create /mnt/@.snapshots/root
  btrfs sub create /mnt/@.snapshots/home
  btrfs sub create /mnt/@var_swap

  umount /mnt
}

configure_swap() {
  #
  # Configure swap file directory
  #
  # No CoW and no compression
  chattr -R -c +m +C /mnt/var/swap

  #
  # Swap file on BTRFS
  #
  truncate -s 0 /mnt/var/swap/swapfile
  fallocate -l 8G /mnt/var/swap/swapfile
  chmod 700 /mnt/var/swap
  chmod 600 /mnt/var/swap/swapfile
  mkswap /mnt/var/swap/swapfile
  swapon /mnt/var/swap/swapfile
}
