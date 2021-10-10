#!/usr/bin/env bash

install_gnome_keyring() {
  local user_name=$1

  exec_in_container /usr/bin/su -c 'paru -S --noconfirm --needed gnome-keyring libsecret seahorse' - "${user_name}"
}

configure_gnome_keyring() {
  local user_name=$1

  cat << 'EOF' > /mnt/etc/X11/xinit/xinitrc.d/99-gnome-keyring.sh
#!/bin/bash

eval $(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh,gpg)
export SSH_AUTH_SOCK
EOF
  chmod +x /mnt/etc/X11/xinit/xinitrc.d/99-gnome-keyring.sh

  cat << 'EOF' > /mnt/etc/pam.d/login
#%PAM-1.0

auth       required     pam_securetty.so
auth       requisite    pam_nologin.so
auth       include      system-local-login
auth       optional     pam_gnome_keyring.so
account    include      system-local-login
session    include      system-local-login
session    optional     pam_gnome_keyring.so auto_start
EOF

  mkdir -p "/mnt/home/${user_name}/.config/autostart"
  cp /mnt/etc/xdg/autostart/{gnome-keyring-secrets.desktop,gnome-keyring-ssh.desktop} "/mnt/home/${user_name}/.config/autostart/"
  sed -i '/^OnlyShowIn.*$/d' "/mnt/home/${user_name}/.config/autostart/gnome-keyring-secrets.desktop"
  sed -i '/^OnlyShowIn.*$/d' "/mnt/home/${user_name}/.config/autostart/gnome-keyring-ssh.desktop"
  exec_in_container /usr/bin/chown "${user_name}:${user_name}" "/home/${user_name}/.config/autostart"

  mkdir -p /mnt/etc/fish/conf.d
  cat << 'EOF' > /mnt/etc/fish/conf.d/gnome-keyring-ssh-agent.fish
if test -n "$DESKTOP_SESSION"
  set -x (gnome-keyring-daemon --start | string split "=")
end
EOF
}
