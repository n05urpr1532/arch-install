#!/usr/bin/env bash

install_openbox() {
  local user_name=$1

  # TODO obkey obkey-git lxhotkey-gtk3 ?
  exec_in_container /usr/bin/su -c 'paru -S --noconfirm --needed openbox obconf lxhotkey-gtk3 oblogout-py3-git nitrogen picom rofi numlockx network-manager-applet' - "${user_name}"
  exec_in_container /usr/bin/su -c 'paru -S --noconfirm --needed xfce4-panel xfconf xfce-polkit xfce4-clipman-plugin xfce4-datetime-plugin xfce4-diskperf-plugin xfce4-fsguard-plugin xfce4-netload-plugin xfce4-notifyd xfce4-power-manager xfce4-pulseaudio-plugin xfce4-screensaver xfce4-sensors-plugin xfce4-settings xfce4-systemload-plugin xfce4-taskmanager xfce4-verve-plugin xfce4-whiskermenu-plugin xfce4-xkb-plugin pavucontrol mugshot' - "${user_name}"
  #exec_in_container /usr/bin/su -c 'paru -S --noconfirm --needed lxappearance-gtk3 lxrandr-gtk3 lxpanel-gtk3 lxpanel-multiload-ng-plugin-gtk3 lxhotkey-gtk3 lxtask-gtk3' - "${user_name}"
  exec_in_container /usr/bin/su -c 'paru -S --noconfirm --needed obmenu-generator perl-gtk3 perl-file-desktopentry xdg-desktop-portal-gtk' - "${user_name}"
}

configure_openbox() {
  local user_name=$1

  exec_in_container /usr/bin/su -c 'mkdir -p ~/.config' - "${user_name}"

  _configure_openbox_openbox "${user_name}"

  _configure_openbox_oblogout

  _configure_openbox_xfce_terminal "${user_name}"

  _configure_xfce_settings

  _configure_openbox_nitrogen "${user_name}"

  _configure_openbox_rofi
}

_configure_openbox_openbox () {
  local user_name=$1

  cp -p "$(get_file 'openbox' 'rc.xml')" /mnt/etc/xdg/openbox/rc.xml
  cp -p "$(get_file 'openbox' 'autostart')" /mnt/etc/xdg/openbox/autostart

  mkdir -p /mnt/etc/xdg/obmenu-generator
  cp -p "$(get_file 'obmenu-generator' 'schema.pl')" /mnt/etc/xdg/obmenu-generator/schema.pl

  exec_in_container /usr/bin/su -c 'obmenu-generator -p -i' - "${user_name}"
}

_configure_openbox_oblogout () {
  cp -p "$(get_file 'oblogout' 'oblogout.conf')" /mnt/etc/oblogout.conf
}

_configure_openbox_xfce_terminal () {
  local user_name=$1

  sed -i 's/TerminalEmulator=xfce4-terminal/TerminalEmulator=Alacritty/' /mnt/etc/xdg/xfce4/helpers.rc

  cat << 'EOF' > /mnt/etc/xdg/xfce4/helpers.rc
#
# Default helpers.rc for Xfce's Preferred Applications
#
# Copyright (c) 2005-2006 Benedikt Meurer <benny@xfce.org>
#

WebBrowser=firefox
MailReader=thunderbird
TerminalEmulator=Alacritty
FileManager=pcmanfm
EOF

  cat << 'EOF' > /mnt/usr/share/xfce4/helpers/Alacritty.desktop
[Desktop Entry]
NoDisplay=true
Version=1.0
Icon=Alacritty
Type=X-XFCE-Helper
Name=Alacritty
Encoding=UTF-8
X-XFCE-Category=TerminalEmulator
X-XFCE-Commands=/usr/bin/alacritty
X-XFCE-CommandsWithParameter=/usr/bin/alacritty -e "%s"
EOF
}

_configure_xfce_settings () {
  if [ -f /mnt/etc/xdg/xfce4/panel/default.xml ]; then
    cp -p "$(get_file 'xfce/panel' 'customized.xml')" /mnt/etc/xdg/xfce4/panel/default.xml
  fi
  if [ -f /mnt/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml ]; then
    cp -p "$(get_file 'xfce/xfconf' 'xfce4-keyboard-shortcuts.xml')" /mnt/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml
  fi
  if [ -d /mnt/etc/xdg/xfce4 ]; then
    mkdir -p /mnt/etc/xdg/xfce4/whiskermenu
    cp -p "$(get_file 'xfce/whiskermenu' 'defaults.rc')" /mnt/etc/xdg/xfce4/whiskermenu/defaults.rc
  fi
}

_configure_openbox_nitrogen () {
  local user_name=$1

  mkdir -p /mnt/etc/skel/.config/nitrogen
  cat << 'EOF' > /mnt/etc/skel/.config/nitrogen/nitrogen.cfg
[geometry]
posx=0
posy=0
sizex=800
sizey=600

[nitrogen]
view=icon
recurse=true
sort=alpha
icon_caps=false
dirs=/usr/share/backgrounds/archlinux;

EOF
  cat << 'EOF' > /mnt/etc/skel/.config/nitrogen/bg-saved.cfg
[xin_-1]
file=/usr/share/backgrounds/archlinux/split.png
mode=5
bgcolor=#000000
EOF

  exec_in_container /usr/bin/su -c 'mkdir -p ~/.config/nitrogen' - "${user_name}"
  exec_in_container /usr/bin/su -c 'cp /etc/skel/.config/nitrogen/* ~/.config/nitrogen/' - "${user_name}"
  exec_in_container /usr/bin/chown -R "${user_name}:${user_name}" "/home/${user_name}/.config/nitrogen"
}

_configure_openbox_rofi () {
  mkdir -p /mnt/etc/xdg/rofi
  cp -p "$(get_file 'rofi' 'rofi.rasi')" /mnt/etc/xdg/rofi.rasi
}
