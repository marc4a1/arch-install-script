#!/bin/bash

clear

source config.conf

touch config.conf

# Update System Clock
timedatectl set-ntp true

# Show Installed Devices
lsblk

# Choose Drive to Install Arch
echo -n "Enter drive you wish to install Arch on. (i.e /dev/sda) "
read -r BLOCK_DEVICE

echo disk=$BLOCK_DEVICE >> config.conf

disk=$BLOCK_DEVICE
swap=${disk}1
root=${disk}2

# Remove Previous mnt and swap
swapoff $swap
umount -R /mnt

# Create Disk Partitions
set -xe
parted -s $disk mklabel msdos
parted -sa optimal $disk mkpart primary linux-swap 0% 2G
parted -sa optimal $disk mkpart primary ext4 2G 100%
parted -s $disk set 1 boot on

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
cp arch-chroot.sh config.conf /mnt

arch-chroot /mnt ./arch-chroot.sh

# Unmount and Reboot
umount -R /mnt
reboot
