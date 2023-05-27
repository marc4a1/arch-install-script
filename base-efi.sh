#!/bin/bash

clear

rm config.conf
touch config.conf

sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf

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
chmod +x arch-chroot-uefi.sh
cp arch-chroot-uefi.sh config.conf /mnt

arch-chroot /mnt ./arch-chroot-uefi.sh

# Unmount and Reboot
umount -R /mnt
echo "Remove install media. System will reboot in 10 seconds."
sleep 10
reboot
