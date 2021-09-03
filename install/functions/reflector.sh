#!/usr/bin/env bash

#
# Reflector config
#
configure_reflector () {
  cat << EOF > /mnt/etc/xdg/reflector/reflector.conf
# Reflector configuration file for the systemd service.
#
# Empty lines and lines beginning with "#" are ignored.  All other lines should
# contain valid reflector command-line arguments. The lines are parsed with
# Python's shlex modules so standard shell syntax should work. All arguments are
# collected into a single argument list.
#
# See "reflector --help" for details.

# Threads to number of cpus threads
--threads $(nproc)

# Set the output path where the mirrorlist will be saved (--save).
--save /etc/pacman.d/mirrorlist

# Select the transfer protocol (--protocol).
--protocol https

# Select the country (--country).
--country France

# Sort the mirrors by download rate (--sort).
--sort rate

# Only return mirrors that have synchronized in the last 12 hours
--age 12

# Limit to 20 servers
--number 20
EOF

  arch-chroot /mnt systemctl start reflector.service
}
