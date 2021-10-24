#!/usr/bin/env bash

get_file () {
  local directory=$1
  local filename=$2

  # ${script_dir} is defined in install.sh
  # shellcheck disable=SC2154
  echo "${script_dir}/files/${directory}/${filename}"
}

get_directory () {
  local directory=$1

  # ${script_dir} is defined in install.sh
  # shellcheck disable=SC2154
  echo "${script_dir}/files/${directory}"
}
