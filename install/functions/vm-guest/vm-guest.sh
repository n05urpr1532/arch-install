#!/usr/bin/env bash
# shellcheck disable=SC2086

configure_as_vm_guest () {
  local user_name=$1
  local is_gui=$2

  if [ ${is_gui} == 1 ]; then
    exec_in_container /usr/bin/su -c 'paru -S --noconfirm --needed qemu-guest-agent open-vm-tools' - ${user_name}

    exec_in_container /usr/bin/systemctl enable qemu-guest-agent.service

    exec_in_container /usr/bin/su -c 'paru -S --noconfirm --needed xf86-input-vmmouse xf86-video-vmware virtualbox-guest-utils spice-vdagent' - ${user_name}
  else
    arch-chroot /mnt su -c 'paru -S --noconfirm --needed qemu-guest-agent open-vm-tools' - ${user_name}

    arch-chroot /mnt systemctl enable qemu-guest-agent.service

    arch-chroot /mnt su -c 'paru -S --noconfirm --needed virtualbox-guest-utils-nox' - ${user_name}
  fi

}
