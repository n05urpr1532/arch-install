#!/usr/bin/env bash

install_openbox() {
  local user_name=$1

  # TODO obkey obkey-git lxhotkey-gtk3 ?
  exec_in_container /usr/bin/su -c 'paru -S --noconfirm --needed openbox obconf lxhotkey-gtk3 oblogout-py3-git nitrogen picom rofi numlockx network-manager-applet' - "${user_name}"
  exec_in_container /usr/bin/su -c 'paru -S --noconfirm --needed xfce4-panel xfconf xfce-polkit xfce4-clipman-plugin xfce4-datetime-plugin xfce4-diskperf-plugin xfce4-fsguard-plugin xfce4-netload-plugin xfce4-notifyd xfce4-power-manager xfce4-pulseaudio-plugin xfce4-screensaver xfce4-sensors-plugin xfce4-settings xfce4-systemload-plugin xfce4-taskmanager xfce4-verve-plugin xfce4-whiskermenu-plugin xfce4-xkb-plugin pavucontrol' - "${user_name}"
  #exec_in_container /usr/bin/su -c 'paru -S --noconfirm --needed lxappearance-gtk3 lxrandr-gtk3 lxpanel-gtk3 lxpanel-multiload-ng-plugin-gtk3 lxhotkey-gtk3 lxtask-gtk3' - "${user_name}"
  exec_in_container /usr/bin/su -c 'paru -S --noconfirm --needed obmenu-generator perl-gtk3 perl-file-desktopentry xdg-desktop-portal-gtk' - "${user_name}"
}

configure_openbox() {
  local user_name=$1

  exec_in_container /usr/bin/su -c 'mkdir -p ~/.config/openbox' - "${user_name}"

  exec_in_container /usr/bin/su -c 'obmenu-generator -p -i' - "${user_name}"

  exec_in_container /usr/bin/su -c 'cp /etc/xdg/picom.conf ~/.config/picom.conf' - "${user_name}"

  cat << 'EOF' > "/mnt/home/${user_name}/.config/openbox/autostart"
picom -b --config ~/.config/picom.conf

nitrogen --restore

xfce4-panel &
/usr/lib/xfce4/notifyd/xfce4-notifyd &
xfce4-power-manager &
xfsettingsd --daemon

numlockx &

nm-applet &
EOF

  exec_in_container /usr/bin/chown "${user_name}:${user_name}" "/home/${user_name}/.config/openbox/autostart"
}
