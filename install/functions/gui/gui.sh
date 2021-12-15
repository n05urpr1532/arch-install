#!/usr/bin/env bash

# Safe Bash parameters
set -euo pipefail

install_gui() {
  local user_name=$1
  local install_gui_type=$2

  case ${install_gui_type} in

    openbox | kde | plasma) ;;

    *)
      echo "!!! Error !!!"
      echo ""
      echo "Unknown GUI environment '${install_gui_type}'"
      echo ""
      exit 1
      exit1
      ;;

  esac

  pushd "$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)" 1>/dev/null || exit 1

  # Functions
  source ./functions/applications.sh
  source ./functions/audio.sh
  source ./functions/gnome-keyring.sh
  source ./functions/lightdm.sh
  source ./functions/theming.sh
  source ./functions/xorg.sh

  case ${install_gui_type} in
    openbox)
      source ./functions/openbox.sh
      ;;
    kde | plasma)
      source ./functions/kde-plasma.sh
      ;;
  esac

  popd 1>/dev/null || exit 1

  # XOrg
  install_xorg "${user_name}"
  configure_xorg

  # LightDM
  install_lightdm "${user_name}"

  # Gnome Keyring
  install_gnome_keyring "${user_name}"
  configure_gnome_keyring "${user_name}"

  # Audio
  install_audio "${user_name}"

  # Theming
  install_themes "${user_name}"
  configure_gtk_themes

  # Applications
  install_apps "${user_name}"
  configure_apps

  case ${install_gui_type} in
    openbox)
      install_openbox "${user_name}"
      configure_openbox "${user_name}"
      configure_xfce_theme
      ;;
    kde | plasma)
      install_plasma "${user_name}"
      ;;
  esac
}
