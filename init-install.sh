#!/usr/bin/env bash

# Safe Bash parameters
set -euo pipefail

BRANCH="${1:-}"

pushd "${HOME}"

timedatectl set-ntp true
reflector --threads "$(nproc)" --country France --protocol https --sort rate --age 12 --number 20 --save /etc/pacman.d/mirrorlist
sed -i 's/#Color/Color/' /etc/pacman.conf
sed -Ei 's/^#ParallelDownloads.+$/ParallelDownloads = 10\nILoveCandy/' /etc/pacman.conf
pacman-key --init
pacman-key --populate archlinux

pacman -Sy --noconfirm git

if [ -n "${BRANCH}" ]; then
  git clone https://github.com/n05urpr1532/arch-install -b "${BRANCH}"
else
  git clone https://github.com/n05urpr1532/arch-install
fi

cd arch-install

clear && time ./install/install.sh

popd
