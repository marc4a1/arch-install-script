#!/bin/bash

clear

# Update System Clock
timedatectl set-ntp true

# Show Installed Devices
lsblk

# Choose Drive to Install Arch
echo -n "Enter drive you wish to install Arch on."
read -r BLOCK_DEVICE

disk=$BLOCK_DEVICE
swap=${disk}1
root=${disk}2

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
pacstrap -K /mnt base linux linux-firmware grub

# Generate Fstab
genfstab -U /mnt >> /mnt/etc/fstab

cp ./*.sh /mnt/home

arch-chroot /mnt /home/./chroot.sh

umount -R /mnt
shutdown
