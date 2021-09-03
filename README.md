# Arch Linux installation and rescue scripts

## Installation

Install Arch Linux on BTRFS.

Check configuration in script `./install/install.sh`, then run :
```shell script
./install/install.sh <disk device path>
```

## Rescue

Allow to mount the Arch Linux BTRFS installation in /mnt.

Run this command to mount :
```shell script
./rescue/rescue-mount.sh <disk device path>
```

Run this command to unmount :
```shell script
./rescue/rescue-unmount.sh <disk device path>
```
