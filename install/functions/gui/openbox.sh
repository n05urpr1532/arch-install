#!/usr/bin/env bash
# shellcheck disable=SC2086

install_openbox () {
  local user_name=$1

  arch-chroot /mnt su -c 'paru -S --noconfirm --needed xorg xorg-apps libxkbcommon-x11 xdg-utils xf86-input-evdev xf86-input-libinput xf86-input-void xf86-video-dummy xf86-video-fbdev xf86-video-intel' - ${user_name}
  arch-chroot /mnt su -c 'paru -S --noconfirm --needed srandrd libva libva-mesa-driver intel-media-driver mesa-demos noto-fonts grub-customizer hwinfo' - ${user_name}
  # TODO Replace Alsa/PulseAudio with PipeWire
  #arch-chroot /mnt su -c 'paru -S --noconfirm --needed alsa-firmware alsa-lib alsa-oss alsa-plugins alsa-utils pulseaudio pulseaudio-alsa' - ${user_name}
  arch-chroot /mnt su -c 'paru -S --noconfirm --needed pipewire pipewire-docs pipewire-alsa pipewire-pulse pipewire-jack pipewire-jack-dropin' - ${user_name}
  arch-chroot /mnt su -c 'paru -S --noconfirm --needed lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings numlockx accountsservice gnome-keyring libsecret seahorse' - ${user_name}
  # TODO obkey obkey-git lxhotkey-gtk3 ?
  arch-chroot /mnt su -c 'paru -S --noconfirm --needed openbox obconf lxhotkey-gtk3 oblogout-py3-git nitrogen picom rofi network-manager-applet' - ${user_name}
  arch-chroot /mnt su -c 'paru -S --noconfirm --needed xfce4-panel xfconf xfce-polkit xfce4-clipman-plugin xfce4-datetime-plugin xfce4-diskperf-plugin xfce4-fsguard-plugin xfce4-netload-plugin xfce4-notifyd xfce4-power-manager xfce4-pulseaudio-plugin xfce4-screensaver xfce4-sensors-plugin xfce4-settings xfce4-systemload-plugin xfce4-taskmanager xfce4-verve-plugin xfce4-whiskermenu-plugin xfce4-xkb-plugin pavucontrol' - ${user_name}
  #arch-chroot /mnt su -c 'paru -S --noconfirm --needed lxappearance-gtk3 lxrandr-gtk3 lxpanel-gtk3 lxpanel-multiload-ng-plugin-gtk3 lxhotkey-gtk3 lxtask-gtk3' - ${user_name}
  arch-chroot /mnt su -c 'paru -S --noconfirm --needed obmenu-generator perl-gtk3 perl-file-desktopentry' - ${user_name}
  arch-chroot /mnt su -c 'paru -S --noconfirm --needed pcmanfm-gtk3 xarchiver gvfs gvfs-google gvfs-nfs gvfs-smb' - ${user_name}
  arch-chroot /mnt su -c 'paru -S --noconfirm --needed alacritty xterm geany geany-plugins geany-themes firefox firefox-i18n-fr snapper-gui cpupower-gui' - ${user_name}
  # TODO suru-plus-aspromauros materia-gtk-theme(not for openbox) ?
  arch-chroot /mnt su -c 'paru -S --noconfirm --needed archlinux-xdg-menu archlinux-wallpaper bunsen-themes sardi-icons ocs-url' - ${user_name}

  arch-chroot /mnt systemctl enable lightdm.service

  arch-chroot /mnt systemctl enable accounts-daemon.service
}

configure_xorg () {
  arch-chroot /mnt localectl set-x11-keymap fr pc105

  cat << 'EOF' > /mnt/etc/X11/xinit/xinitrc.d/99-keymap.sh
#!/bin/bash

setxkbmap fr
EOF
  chmod +x /mnt/etc/X11/xinit/xinitrc.d/99-keymap.sh

  cat << 'EOF' > /mnt/etc/X11/xinit/xinitrc.d/99-gnome-keyring.sh
#!/bin/bash

eval $(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh,gpg)
export SSH_AUTH_SOCK
EOF
  chmod +x /mnt/etc/X11/xinit/xinitrc.d/99-gnome-keyring.sh

  cat << 'EOF' >> /mnt/etc/environment
XDG_CONFIG_DIRS=/etc/xdg
XDG_DATA_DIRS=/usr/local/share:/usr/share
EOF
}

configure_openbox () {
  local user_name=$1

  arch-chroot /mnt su -c 'mkdir -p ~/.config/openbox' - ${user_name}

  arch-chroot /mnt su -c 'obmenu-generator -p' - ${user_name}

  arch-chroot /mnt su -c 'cp /etc/xdg/picom.conf ~/.config/picom.conf' - ${user_name}

  cat << 'EOF' > /mnt/home/${user_name}/.config/openbox/autostart
picom -b --config ~/.config/picom.conf

nitrogen --restore

xfce4-panel &
/usr/lib/xfce4/notifyd/xfce4-notifyd &
xfce4-power-manager &
xfsettingsd --daemon

numlockx &

nm-applet &
EOF

  arch-chroot /mnt chown ${user_name}:${user_name} /home/${user_name}/.config/openbox/autostart
}

configure_gtk () {
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
