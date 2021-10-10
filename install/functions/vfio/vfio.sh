#!/usr/bin/env bash

#
# VFIO config
#
configure_vfio() {
  # Set IOMMU and VFIO
  sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 intel_iommu=on iommu=pt"/' /mnt/etc/default/grub

  cat << 'EOF' >> /mnt/etc/modules

# IOMMU/VFIO
vfio
vfio_iommu_type1
vfio_pci
vfio_virqfd
EOF

  echo "options vfio-pci ids=10de:1381,10de:0fbc disable_vga=1" > /mnt/etc/modprobe.d/nvidia-vfio-pci.conf
  echo "options kvm ignore_msrs=1" > /mnt/etc/modprobe.d/nvidia-vfio-kvm.conf

  # Blacklist NVidia kernel modules
  printf "blacklist nouveau\nblacklist nvidia\n" > /mnt/etc/modprobe.d/nvidia-blacklist.conf

  arch-chroot /mnt mkinitcpio -P
}
