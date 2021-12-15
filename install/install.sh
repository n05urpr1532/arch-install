#!/usr/bin/env bash

# Safe Bash parameters
set -euo pipefail

DESTINATION_DEVICE_TMP_FILE="/tmp/DESTINATION_DEVICE"
INSTALL_LOG_FILE_NAME="arch-install_$(date '+%Y-%m-%d_%H%M%S').log"
INSTALL_LOG_FILE_PATH="/tmp/${INSTALL_LOG_FILE_NAME}"

install_main() {
  # Current script directory
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

  pushd "${script_dir}" 1> /dev/null

  # Common functions
  source ../common/functions.sh
  source ./functions/config-prompt.sh
  source ./functions/get-files.sh

  # Specific functions
  source ./functions/aria2.sh
  source ./functions/btrfsmaintenance.sh
  source ./functions/fish-config.sh
  source ./functions/grub.sh
  source ./functions/gui/gui.sh
  source ./functions/locale.sh
  source ./functions/makepkg.sh
  source ./functions/network.sh
  source ./functions/pacman.sh
  source ./functions/partition.sh
  source ./functions/paru.sh
  source ./functions/reflector.sh
  source ./functions/sensors.sh
  source ./functions/snapper.sh
  source ./functions/vfio/vfio.sh
  source ./functions/vm-guest/vm-guest.sh

  # Global configuration
  DESTINATION_DEVICE=
  ROOT_PARTITION_SIZE=
  HOSTNAME=
  ROOT_PASSWORD=
  USERNAME=
  USER_PASSWORD=
  INSTALL_GUI=
  INSTALL_GUI_TYPE=
  SET_VFIO=
  IS_VM_GUEST=
  configure_install
  confirm_install

  printf "%s" "${DESTINATION_DEVICE}" > "${DESTINATION_DEVICE_TMP_FILE}"

  #
  # Arch installer environment initialization
  #
  loadkeys fr
  timedatectl set-ntp true
  reflector --threads "$(nproc)" --country France --protocol https --sort rate --age 12 --number 20 --save /etc/pacman.d/mirrorlist
  sed -i 's/#Color/Color/' /etc/pacman.conf
  sed -Ei 's/^#ParallelDownloads.+$/ParallelDownloads = 10\nILoveCandy/' /etc/pacman.conf
  pacman-key --init
  pacman-key --populate archlinux

  #
  # Partitioning
  #
  create_partitions "${DESTINATION_DEVICE}" "${ROOT_PARTITION_SIZE}"
  mount_root "${DESTINATION_DEVICE}"
  configure_swap

  #
  # Boostrapping
  #
  pacstrap /mnt base base-devel linux linux-headers linux-lts linux-lts-headers linux-firmware intel-ucode \
    grub os-prober dosfstools efibootmgr mtools ntfs-3g hdparm nvme-cli sdparm smartmontools usbutils usb_modeswitch lm_sensors i2c-tools lshw powertop liquidctl \
    btrfs-progs grub-btrfs compsize \
    archlinux-keyring lsb-release acpid linux-tools dmidecode logrotate pacman-contrib \
    man-db man-pages texinfo \
    arj unarj bzip2 gzip lhasa p7zip tar unrar zip unzip xz zstd \
    awesome-terminal-fonts vim neovim nano bat lsd bash-completion fish pkgfile mlocate htop lsof strace tmux neofetch jq ripgrep \
    aria2 reflector networkmanager git git-lfs rsync wget openssh net-tools ethtool gnu-netcat ntp

  #
  # Generate fstab
  #
  genfstab -U /mnt > /mnt/etc/fstab

  #
  # Sensors config
  #
  if [ "${IS_VM_GUEST}" != "1" ]; then
    configure_sensors
  fi

  #
  # Reflector config
  #
  configure_reflector

  #
  # Enable various services
  #
  arch-chroot /mnt systemctl enable acpid.service smartd.service logrotate.timer

  #
  # Enable weekly TRIM
  #
  arch-chroot /mnt systemctl enable fstrim.timer

  #
  # Locale related config
  #
  configure_locale

  #
  # Network related config
  #
  configure_network "${HOSTNAME}"

  #
  # Swappiness config
  #
  echo "vm.swappiness=10" > /mnt/etc/sysctl.d/99-swappiness.conf

  #
  # Aria2 config
  #
  configure_aria2

  #
  # Pacman config
  #
  configure_pacman

  #
  # Initramfs Config
  #
  sed -i "s@^BINARIES=()@BINARIES=(/usr/bin/btrfs)@" /mnt/etc/mkinitcpio.conf
  HOOKS="base udev keyboard keymap autodetect modconf block filesystems fsck grub-btrfs-overlayfs"
  sed -i "s/^HOOKS=(.*)/HOOKS=($HOOKS)/" /mnt/etc/mkinitcpio.conf
  arch-chroot /mnt mkinitcpio -P

  #
  # grub-btrfs config
  #
  sed -i 's/^GRUB_BTRFS_IGNORE_SPECIFIC_PATH=("@")/GRUB_BTRFS_IGNORE_SPECIFIC_PATH=("@" "@home" "@var_swap")/' /mnt/etc/default/grub-btrfs/config

  #
  # GRUB config
  #
  configure_grub_theme "${IS_VM_GUEST}"
  configure_grub

  #
  # mlocate config
  #
  sed -i 's/^PRUNENAMES = "\(.*\)"/PRUNENAMES = "(\1 .snapshots)"/' /mnt/etc/updatedb.conf
  sed -i 's/^PRUNEPATHS = "\(.*\)"/PRUNEPATHS = "(\1 \/.btrfs-root)"/' /mnt/etc/updatedb.conf
  arch-chroot /mnt updatedb

  #
  # Fish shell config
  #
  configure_fish

  #
  # Setting root password
  #
  printf "%s\n%s" "${ROOT_PASSWORD}" "${ROOT_PASSWORD}" | arch-chroot /mnt passwd

  #
  # Setting root user shell
  #
  arch-chroot /mnt pkgfile --update
  arch-chroot /mnt chsh -s /usr/bin/fish root

  #
  # User config
  #
  arch-chroot /mnt useradd -m -G "users,wheel,storage,optical" -s /usr/bin/fish "${USERNAME}"
  printf "%s\n%s" "${USER_PASSWORD}" "${USER_PASSWORD}" | arch-chroot /mnt passwd "${USERNAME}"

  #
  # nvim as default editor, bat as default pager
  #
  cat << 'EOF' >> /mnt/etc/environment
EDITOR=nvim
VISUAL=nvim
PAGER=bat
EOF

  #
  # Makepkg config
  #
  configure_makepkg

  #
  # Setting temporarily wheel as sudoer without password
  #
  sed -i 's/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /mnt/etc/sudoers
  echo 'Defaults env_keep += "SNAP_PAC_SKIP"' > /mnt/etc/sudoers.d/preserve_snap_pac_skip

  #
  # Paru config
  #
  install_paru "${USERNAME}"

  #
  # NTP config
  #
  arch-chroot /mnt su -c 'paru -S --noconfirm --needed networkmanager-dispatcher-ntpd' - "${USERNAME}"

  #
  # btrfsmaintenance config
  #
  install_and_configure_btrfsmaintenance "${USERNAME}"

  #
  # Snapper config
  #
  install_and_configure_snapper "${DESTINATION_DEVICE}" "${USERNAME}"

  #
  # btrfs-du install
  #
  arch-chroot /mnt su -c 'paru -S --noconfirm --needed btrfs-du' - "${USERNAME}"

  #
  # Patch grub to make vmlinuz-linux the first entry (and not vmlinuz-linux-lts)
  #
  configure_grub_linux_as_default "${USERNAME}"

  #
  # Start boostraped system in container
  #
  init_container

  #
  # Configure locale in container
  #
  configure_locale_in_container

  #
  # Graphical installation (optional)
  #
  if [ "${INSTALL_GUI}" = "1" ]; then

    #
    # Configure fish prompt for user
    #
    configure_fish_prompt "${USERNAME}"

    install_gui "${USERNAME}" "${INSTALL_GUI_TYPE}"

  fi

  #
  # Virtual machine guest config
  #
  if [ "${IS_VM_GUEST}" = "1" ]; then
    configure_as_vm_guest "${USERNAME}" "${INSTALL_GUI}"
  fi

  #
  # snap-pac, snap-pac-grub and snapper-rollback config
  #
  install_and_configure_snap_pac_and_snapper_rollback "${USERNAME}"

  #
  # VFIO setup
  #
  if [ "${SET_VFIO}" = "1" ]; then
    configure_vfio
  fi

  #
  # Cleanup pacman and paru
  #
  clean_pacman
  clean_paru

  #
  # Clean snapper
  #
  clean_snapper

  #
  # List enabled systemd units
  #
  if [ "${INSTALL_GUI}" = "1" ]; then
    exec_in_container /usr/bin/systemctl list-unit-files --state enabled
  else
    arch-chroot /mnt systemctl list-unit-files --state enabled
  fi

  #
  # Setting wheel as sudoer with password
  #
  sed -i 's/^%wheel ALL=(ALL) NOPASSWD: ALL/# %wheel ALL=(ALL) NOPASSWD: ALL/' /mnt/etc/sudoers
  sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /mnt/etc/sudoers

  #
  # Stop boostraped system in container
  #
  stop_container
  sleep 5

  #
  # Cleanup
  #
  unmount_root "${DESTINATION_DEVICE}"

  popd 1> /dev/null

  # TODO Configure Super key
  # xfce4-popup-whiskermenu
}

install_copy_log_file() {
  local destination_device
  destination_device=$(cat "${DESTINATION_DEVICE_TMP_FILE}")

  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

  pushd "${script_dir}" 1> /dev/null

  # Common functions
  source ../common/functions.sh

  #
  # Remount the destination drive
  #
  echo "Remouting ${destination_device}..."
  mount_root "${destination_device}"

  #
  # Copy log file to destination
  #
  echo "Copying install log file to ${destination_device}..."
  mkdir -p "/mnt/root/os-install-log"
  cp "${INSTALL_LOG_FILE_PATH}" "/mnt/root/os-install-log/${INSTALL_LOG_FILE_NAME}"

  #
  # Cleanup
  #
  echo "Unmounting ${destination_device}..."
  unmount_root "${destination_device}"

  popd 1> /dev/null
}

(install_main) |& tee -a "${INSTALL_LOG_FILE_PATH}"

install_copy_log_file
