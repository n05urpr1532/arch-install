#!/usr/bin/env bash

#
# Sensors config
#
configure_sensors () {
  echo "i2c-dev" > /mnt/etc/modules-load.d/i2c-dev.conf
  arch-chroot /mnt modprobe i2c-dev
  arch-chroot /mnt sensors-detect --auto
}
