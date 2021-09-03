#!/usr/bin/env bash

#
# Aria2 config
#
configure_aria2 () {
  mkdir -p /mnt/etc/skel/.config/aria2

  cat << 'EOF' > /mnt/etc/skel/.config/aria2/aria2.conf
#
# Aria2 default configuration
#

# User agent
user-agent=Wget

# Error handling
timeout=30
connect-timeout=30
max-tries=3
retry-wait=5
max-file-not-found=3

# Downloading
split=5
max-connection-per-server=5
min-split-size=1M
max-concurrent-downloads=10

# Console
console-log-level=warn
enable-color=true
human-readable=true
EOF

  mkdir -p /mnt/root/.config/aria2

  cp /mnt/etc/skel/.config/aria2/aria2.conf /mnt/root/.config/aria2/aria2.conf

  cat << 'EOF' > /mnt/root/.config/aria2/aria2-makepkg.conf
# Aria2 Makepkg configuration

# User agent
user-agent=Wget

# Error handling
timeout=30
connect-timeout=30
max-tries=3
retry-wait=5
max-file-not-found=3

# Downloading
split=5
max-connection-per-server=5
min-split-size=1M
max-concurrent-downloads=10
check-integrity=true
file-allocation=none
remote-time=true
conditional-get=true
no-netrc=true

# Resuming
continue=true
allow-overwrite=true
always-resume=false
auto-file-renaming=false

# Console
console-log-level=warn
summary-interval=0
#download-result=hide

# logging
#log-level=notice
#log=/var/log/aria2-makepkg.log
EOF
}
