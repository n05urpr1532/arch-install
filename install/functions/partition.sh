#!/usr/bin/env bash

#
# Partitioning
#
create_partitions() {
  local root_device_parameter=$1
  local root_partition_size=$2

  # Create 2 partitions:
  # * ESP - 256M, type "EFI System"
  # * ARCH-B-ROOT - The rest, type "Linux filesystem" (by default)

  local parted_config
  # Creates a new disk label, of type GPT
  parted_config="mklabel gpt"
  # Creates a new partition named "ESP" of type FAT32 of size 256MiB
  parted_config="${parted_config} mkpart ESP fat32 1MiB 257MiB"
  # Creates a new partition named "ARCH-B-ROOT" of type BTRFS of the remaining ${root_partition_size} size of the disk
  parted_config="${parted_config} mkpart ARCH-B-ROOT btrfs 257MiB ${root_partition_size}"
  # Change the flag ESP to "on" on partition 1 (ESP)
  parted_config="${parted_config} set 1 esp on"
  parted --align optimal --script "${root_device_parameter}" -- "${parted_config}"

  mkfs.fat -v -F 32 -n "ESP" "${root_device_parameter}1"
  mkfs.btrfs --checksum "xxhash" --data "single" --metadata "dup" --label "ARCH-B-ROOT" --features "no-holes" --runtime-features "quota,free-space-tree" --force "${root_device_parameter}2"

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
