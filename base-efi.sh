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
echo boot=${disk}1 >> config.conf

disk=$BLOCK_DEVICE
boot=${disk}1
swap=${disk}2
root=${disk}3

# Remove Previous mnt and swap
swapoff $swap
umount -R /mnt

# Create Disk Partitions
set -xe
parted -s $disk mklabel gpt
parted -sa optimal $disk mkpart primary fat32 0% 1024M
parted -sa optimal $disk mkpart primary linux-swap 1024M 2G
parted -sa optimal $disk mkpart primary ext4 2G 100%
parted -s $disk set 1 esp on

# Format Partitions
mkfs.fat -F32 $boot
mkswap -f $swap
mkfs.ext4 -F $root

# Mount Partitions
mount $root /mnt
swapon $swap
mount $boot /mnt/boot

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
