#!/usr/bin/env bash

# Safe Bash parameters
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

pushd "${script_dir}" 1>/dev/null

source ../common/functions.sh

root_device_parameter=$1

check_root_device_parameter "${root_device_parameter}"

unmount_root "${root_device_parameter}"

popd 1>/dev/null
