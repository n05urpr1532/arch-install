#!/usr/bin/env bash

install_vfio() {
  local user_name=$1

  # TODO QEMU + KVM + Virtmanager install
  #exec_in_container /usr/bin/su -c 'paru -S --noconfirm --needed ' - "${user_name}"
  #arch-chroot /mnt usermod -a -G "kvm,libvirt" "${user_name}"
}

#
# VFIO + Intel GVT-g config
#
configure_vfio() {
  cp -p "$(get_file 'vfio' 'iommu-groups-ls')" /mnt/usr/local/bin/iommu-groups-ls

  # Set IOMMU and VFIO
  sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 intel_iommu=on iommu=pt"/' /mnt/etc/default/grub

  # TODO Or directly in /mnt/etc/modules ?
  cat << 'EOF' > /mnt/etc/modules-load.d/00-vfio-gvt-d-modules.conf

# IOMMU/VFIO
vfio
vfio_iommu_type1
vfio_pci
vfio_virqfd

# Intel GVT-g
kvmgt
vfio_mdev
EOF

  # Enabling Intel GVT-g
  echo "options kvm ignore_msrs=1 report_ignored_msrs=0" > /mnt/etc/modprobe.d/nvidia-vfio-kvm.conf

  # Try to retrieve PCI ids for Nvidia card
  local ids
  ids="$(_configure_vfio_retrieve_pci_ids_list)" || true

  if [ -n "${ids}" ]; then

    cat << EOF > /mnt/etc/modprobe.d/nvidia-vfio-pci.conf
options vfio-pci ids=${ids} disable_vga=1
softdep nouveau pre: vfio-pci
EOF

    echo "options kvm ignore_msrs=1 report_ignored_msrs=0" > /mnt/etc/modprobe.d/nvidia-vfio-kvm.conf

    echo "options kvm-intel nested=1" > /mnt/etc/modprobe.d/nvidia-vfio-kvm-intel.conf

    echo "options vfio-iommu-type1" > /mnt/etc/modprobe.d/nvidia-vfio-iommu.conf

    # Blacklist NVidia kernel modules
    cat << 'EOF' > /mnt/etc/modprobe.d/nvidia-blacklist.conf
blacklist nouveau
options nouveau modeset=0
blacklist nvidia
options nvidia modeset=0
EOF

  fi

  arch-chroot /mnt mkinitcpio -P
}

_configure_vfio_retrieve_pci_ids_list() {
  local iommu_groups
  iommu_groups=$(arch-chroot /mnt /usr/local/bin/iommu-groups-ls)

  echo "${iommu_groups}" | grep -i 'nvidia' | sed -r 's/^.*(10de:[a-z0-9]+).*$/\1/' | tr -s '\r\n' ',' | sed -r 's/^(.+),+/\1/'
}
