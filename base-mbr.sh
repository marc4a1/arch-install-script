#!/bin/bash

clear

# Update system clock
timedatectl set-ntp true

# Show installed devices
lsblk

# Choose drive to install Arch
echo -n "Enter drive you wish to install Arch on."
read -r BLOCK_DEVICE

disk=$BLOCK_DEVICE
swap=${disk}1
root=${disk}2

# Create disk partitions
parted -s $disk mklabel msdos
parted -sa optimal $disk mkpart primary linux-swap 0% 2G
parted -sa optimal $disk mkpart primary ext4 2G 100%

# Format partitions
mkswap -f $swap
mkfs.ext4 -F $root

# Mount partitions
mount $root /mnt
swapon $swap

# Install Base System
pacstrap -K /mnt base base-devel linux linux-headers linux-firmware git vim nano networkmanager grub

genfstab -U /mnt >> /mnt/etc/fstab
