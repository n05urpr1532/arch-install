#!/usr/bin/env bash

install_audio() {
  local user_name=$1

  # TODO Check if PipeWire is alright
  # Here, we replace Alsa/PulseAudio with PipeWire
  #exec_in_container /usr/bin/su -c 'paru -S --noconfirm --needed alsa-firmware alsa-lib alsa-oss alsa-plugins alsa-utils pulseaudio pulseaudio-alsa' - ${user_name}
  exec_in_container /usr/bin/su -c 'paru -S --noconfirm --needed pipewire pipewire-docs pipewire-alsa pipewire-pulse pipewire-jack pipewire-jack-dropin gst-plugin-pipewire' - "${user_name}"
}
