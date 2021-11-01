#!/usr/bin/env bash

# shellcheck disable=SC2034
configure_install() {
  config_prompt_title "Destination disk"
  DESTINATION_DEVICE=$(config_prompt_disk)
  check_not_empty "${DESTINATION_DEVICE}"
  check_root_device_parameter "${DESTINATION_DEVICE}"

  config_prompt_title "Root partition size"
  ROOT_PARTITION_SIZE=$(config_prompt_root_part_size)
  check_not_empty "${ROOT_PARTITION_SIZE}"

  config_prompt_title "Hostname"
  HOSTNAME=$(config_prompt_hostname)
  check_not_empty "${HOSTNAME}"

  config_prompt_title "Root password"
  ROOT_PASSWORD=$(config_prompt_root_password)
  check_not_empty "${ROOT_PASSWORD}"

  config_prompt_title "Username"
  USERNAME=$(config_prompt_username)
  check_not_empty "${USERNAME}"

  config_prompt_title "Username password"
  USER_PASSWORD=$(config_prompt_username_password)
  check_not_empty "${USER_PASSWORD}"

  config_prompt_title "Install GUI"
  local is_install_gui
  is_install_gui=$(config_prompt_install_gui)
  check_yes_or_no "${is_install_gui}"
  INSTALL_GUI=0
  INSTALL_GUI_TYPE=
  if [ "${is_install_gui}" = "y" ]; then
    config_prompt_title "GUI type"
    INSTALL_GUI=1
    INSTALL_GUI_TYPE=$(config_prompt_gui_type)
    case ${INSTALL_GUI_TYPE} in
      openbox | kde | plasma) ;;

      *)
        echo "!!! Error !!!"
        echo ""
        echo "Invalid GUI type ${INSTALL_GUI_TYPE} !"
        echo ""
        exit 1
        ;;
    esac
  fi

  config_prompt_title "Setting VFIO"
  local is_set_vfio
  is_set_vfio=$(config_prompt_vfio)
  check_yes_or_no "${is_set_vfio}"
  SET_VFIO=0
  if [ "${is_set_vfio}" = "y" ]; then
    SET_VFIO=1
  fi

  config_prompt_title "VM Guest"
  local is_vm_guest
  is_vm_guest=$(config_prompt_vm_guest)
  check_yes_or_no "${is_vm_guest}"
  IS_VM_GUEST=0
  if [ "${is_vm_guest}" = "y" ]; then
    IS_VM_GUEST=1
  fi
}

confirm_install() {
  config_prompt_title "Confirm installation parameters"

  echo "Installation will be performed with the following parameters :"
  echo ""
  echo "DESTINATION_DEVICE=${DESTINATION_DEVICE}"
  echo ""
  echo "ROOT_PARTITION_SIZE=${ROOT_PARTITION_SIZE}"
  echo ""
  echo "HOSTNAME=${HOSTNAME}"
  echo ""
  echo "ROOT_PASSWORD=${ROOT_PASSWORD}"
  echo ""
  echo "USERNAME=${USERNAME}"
  echo "USER_PASSWORD=${USER_PASSWORD}"
  echo ""
  echo "INSTALL_GUI=${INSTALL_GUI}"
  echo "INSTALL_GUI_TYPE=${INSTALL_GUI_TYPE}"
  echo ""
  echo "SET_VFIO=${SET_VFIO}"
  echo ""
  echo "IS_VM_GUEST=${IS_VM_GUEST}"
  echo ""

  echo "*********************************************"
  echo "!!! WARNING !!!"
  echo "*********************************************"
  echo ""
  echo "!!! Device ${DESTINATION_DEVICE} will be permantly erased !!!"
  echo ""
  lsblk "${DESTINATION_DEVICE}"
  echo ""
  echo "*********************************************"
  echo ""

  local response

  read -r -p "Run installation ? (y/n):  " -e -i 'n' response

  if [ "${response}" != "y" ]; then
    echo ""
    echo "!!! Installation aborted !!!"
    echo ""
    exit 1
  fi
}

config_prompt_title() {
  local title=$1

  echo ""
  echo "---------------------------------------------"
  echo "--- $title"
  echo "---------------------------------------------"
}

config_prompt_disk() {
  local response

  read -r -p "Where to install: " -e -i '/dev/vda' response

  check_not_empty "${response}"

  echo "${response}"
}

config_prompt_root_part_size() {
  local response

  read -r -p "Root partition size: " -e -i '50%' response

  check_not_empty "${response}"

  echo "${response}"
}

config_prompt_hostname() {
  local response

  read -r -p "Hostname: " -e -i 'archlinux' response

  echo "${response}"
}

config_prompt_root_password() {
  local response

  read -r -p "Root password:  " -e -i 'root' response

  echo "${response}"
}

config_prompt_username() {
  local response

  read -r -p "Username: " -e -i 'jpv' response

  echo "${response}"
}

config_prompt_username_password() {
  local response

  read -r -p "Username password:  " -e -i 'jpv' response

  echo "${response}"
}

config_prompt_install_gui() {
  local response

  read -r -p "Install GUI (y/n):  " -e -i 'y' response

  echo "${response}"
}

config_prompt_gui_type() {
  local response

  read -r -p "GUI type (openbox/kde/plasma):  " -e -i 'openbox' response

  echo "${response}"
}

config_prompt_vfio() {
  local response

  read -r -p "Setting VFIO ? (y/n): " -e -i 'n' response

  echo "${response}"
}

config_prompt_vm_guest() {
  local response

  read -r -p "Is a VM guest ? (y/n):  " -e -i 'n' response

  echo "${response}"
}
