#!/bin/bash

clear

# Update System Clock
timedatectl set-ntp true

# Show Installed Devices
lsblk

# Choose Drive to Install Arch
echo -n "Enter drive you wish to install Arch on. (i.e /dev/sda) "
read -r BLOCK_DEVICE

disk=$BLOCK_DEVICE
swap=${disk}1
root=${disk}2

# Remove Previous mnt and swap
swapoff $swap
umount -R /mnt

# Create Disk Partitions
set -xe
parted -s $disk mklabel gpt
parted -sa optimal $disk mkpart primary fat32
parted -sa optimal $disk mkpart primary linux-swap
parted -sa optimal $disk mkpart primary ext4
parted -s $disk set 1 esp on

# Format Partitions
mkswap -f $swap
mkfs.ext4 -F $root

# Mount Partitions
mount $root /mnt
swapon $swap

# Install Base System
pacstrap -K /mnt base base-devel linux linux-firmware nano vim

# Generate Fstab
genfstab -U /mnt >> /mnt/etc/fstab

# To Chroot To Root User
chmod +x arch-chroot.sh
cp arch-chroot.sh /mnt

arch-chroot /mnt ./arch-chroot.sh

# Unmount and Reboot
umount -R /mnt
reboot
