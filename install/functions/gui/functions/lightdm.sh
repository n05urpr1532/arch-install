#!/usr/bin/env bash

install_lightdm() {
  local user_name=$1

  exec_in_container /usr/bin/su -c 'paru -S --noconfirm --needed lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings accountsservice' - "${user_name}"

  exec_in_container /usr/bin/systemctl enable accounts-daemon.service
  exec_in_container /usr/bin/systemctl enable lightdm.service
}
