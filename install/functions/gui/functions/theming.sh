#!/usr/bin/env bash

install_themes() {
  local user_name=$1

  # TODO suru-plus-aspromauros materia-gtk-theme(not for openbox) ?
  exec_in_container /usr/bin/su -c 'paru -S --noconfirm --needed archlinux-xdg-menu archlinux-wallpaper bunsen-themes sardi-icons ocs-url' - "${user_name}"
}

configure_gtk_themes() {
  cat << 'EOF' > /mnt/etc/gtk-2.0/gtkrc
[Settings]
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

include "/usr/share/themes/Bunsen-Blackish-Remix/gtk-2.0/apps/xfce-panel.rc"
EOF

  cat << 'EOF' > /mnt/etc/gtk-3.0/settings.ini
[Settings]
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
gtk-application-prefer-dark-theme=true
EOF
}
