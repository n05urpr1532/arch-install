#!/usr/bin/env bash

# Safe Bash parameters
set -euo pipefail

source ../common/functions.sh

root_device_parameter=$1

check_root_device_parameter "${root_device_parameter}"

unmount_root "${root_device_parameter}"
