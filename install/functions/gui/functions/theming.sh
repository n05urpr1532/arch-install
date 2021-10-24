#!/usr/bin/env bash

install_themes() {
  local user_name=$1

  # TODO suru-plus-aspromauros materia-gtk-theme(not for openbox) ?
  exec_in_container /usr/bin/su -c 'paru -S --noconfirm --needed archlinux-xdg-menu archlinux-wallpaper bunsen-themes sardi-icons ocs-url' - "${user_name}"
}

configure_gtk_themes() {
  cat << 'EOF' > /mnt/etc/gtk-2.0/gtkrc
gtk-theme-name="Bunsen-Blackish-Remix"
gtk-icon-theme-name="Sardi-Ghost-Flexible-Colora"
gtk-font-name="Sans Regular 11"
gtk-monospace-font-name="Monospace Regular 11"
gtk-toolbar-style=GTK_TOOLBAR_ICONS
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle="hintslight"
gtk-xft-rgba="rgb"
EOF

  cat << 'EOF' > /mnt/etc/gtk-3.0/settings.ini
[Settings]
gtk-theme-name="Bunsen-Blackish-Remix"
gtk-icon-theme-name="Sardi-Ghost-Flexible-Colora"
gtk-font-name="Sans Regular 11"
gtk-toolbar-style=GTK_TOOLBAR_ICONS
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle="hintslight"
gtk-xft-rgba="rgb"
gtk-application-prefer-dark-theme=true
EOF

  mkdir -p /mnt/etc/dconf/db/local.d
  cat << 'EOF' > /mnt/etc/dconf/db/local.d/01-theme
[org/gnome/desktop/interface]
gtk-theme='Bunsen-Blackish-Remix'
icon-theme='Sardi-Ghost-Flexible-Colora'
EOF
  mkdir -p /mnt/etc/dconf/profile
  touch /mnt/etc/dconf/profile/user
  cat << 'EOF' > /mnt/etc/dconf/profile/user
user-db:user
system-db:local
EOF

  exec_in_container /usr/bin/dconf update
}

configure_xfce_theme () {
  if [ -f /mnt/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
    sed -i 's@<property name="ThemeName" type="string" value="Adwaita"/>@<property name="ThemeName" type="string" value="Bunsen-Blackish-Remix"/>@' /mnt/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml
    sed -i 's@<property name="IconThemeName" type="string" value="Adwaita"/>@<property name="IconThemeName" type="string" value="Sardi-Ghost-Flexible-Colora"/>@' /mnt/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml
  fi
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
