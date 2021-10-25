#!/usr/bin/env bash

install_themes() {
  local user_name=$1

  # Bunsen-Blackish-JPV comes from Bunsen-Blackish-Remix, from the "bunsen-themes" package
  exec_in_container /usr/bin/su -c 'paru -S --noconfirm --needed archlinux-xdg-menu archlinux-wallpaper sardi-icons ocs-url' - "${user_name}"

  cp -pr "$(get_directory 'themes/Bunsen-Blackish-JPV')" /mnt/usr/share/themes/
}

configure_gtk_themes() {
  mkdir -p /mnt/etc/gtk-2.0
  cat << 'EOF' > /mnt/etc/gtk-2.0/gtkrc
gtk-theme-name="Bunsen-Blackish-JPV"
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

  mkdir -p /mnt/etc/gtk-3.0
  cat << 'EOF' > /mnt/etc/gtk-3.0/settings.ini
[Settings]
gtk-theme-name="Bunsen-Blackish-JPV"
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
gtk-theme='Bunsen-Blackish-JPV'
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
    sed -i 's@<property name="ThemeName" type="string" value="Adwaita"/>@<property name="ThemeName" type="string" value="Bunsen-Blackish-JPV"/>@' /mnt/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml
    sed -i 's@<property name="IconThemeName" type="string" value="Adwaita"/>@<property name="IconThemeName" type="string" value="Sardi-Ghost-Flexible-Colora"/>@' /mnt/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml
  fi
}
