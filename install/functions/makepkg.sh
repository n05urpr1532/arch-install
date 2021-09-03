#!/usr/bin/env bash

#
# Makepkg config
#
configure_makepkg () {
  sed -i "s@'ftp::/usr/bin/curl .*'@'ftp::/usr/bin/aria2c --conf-path=/root/.config/aria2/aria2-makepkg.conf --dir=/ --out %o %u'@" /etc/makepkg.conf
  sed -i "s@'http::/usr/bin/curl .*'@'http::/usr/bin/aria2c --conf-path=/root/.config/aria2/aria2-makepkg.conf --dir=/ --out %o %u'@" /etc/makepkg.conf
  sed -i "s@'https::/usr/bin/curl .*'@'https::/usr/bin/aria2c --conf-path=/root/.config/aria2/aria2-makepkg.conf --dir=/ --out %o %u'@" /etc/makepkg.conf
  sed -i "s/^CFLAGS=\"-march=x86-64 -mtune=generic -O2/CFLAGS=\"-march=native -O2/" /mnt/etc/makepkg.conf
  sed -i "s/^#RUSTFLAGS=\"-C opt-level=2\"/RUSTFLAGS=\"-C opt-level=3 -C target-cpu=native\"/" /mnt/etc/makepkg.conf
  sed -i "s/^#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j$(nproc)\"/" /mnt/etc/makepkg.conf
  sed -i "s@^#BUILDDIR=/tmp/makepkg@BUILDDIR=/tmp/makepkg@" /mnt/etc/makepkg.conf
}
