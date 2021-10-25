# Arch Linux installation and rescue scripts

## Installation

Install Arch Linux on BTRFS.

Run :
```shell script
./install/install.sh
```

Or with `curl`:
```shell script
curl -s https://raw.githubusercontent.com/n05urpr1532/arch-install/main/init-install.sh | bash
```

For develop branch:
```shell script
curl -s https://raw.githubusercontent.com/n05urpr1532/arch-install/develop/init-install.sh | bash -s -- 'develop'
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
