#!/bin/bash

clear

# Update system clock
timedatectl set-ntp true

# Show Installed Devices
lsblk

# Choose Drive to Install Arch
echo -n "Enter drive you wish to install Arch on. Add /dev/ before device Example: /dev/sda"
read -r BLOCK_DEVICE

disk=$BLOCK_DEVICE
boot=${disk}1
root=${disk}2
swap=${disk}3
home=${disk}4

# Create Disk Partitions
parted -s $disk mklabel msdos
parted -sa optimal $disk mkpart primary fat32
parted -sa optimal $disk mkpart primary ext4
parted -sa optimal $disk mkpart primary linix-swap
parted -sa optimal $disk mkpart primary ext4
parted -s $disk set 1 esp on

# Format Partitions
mkfs.fat -F32 $boot
mkfs.ext4 -F $root
mkfs.ext4 -F $home
mkswap -f $swap

# Mount partitions
mount $root /mnt
swapon $swap

# Install Base System
pacstrap -K /mnt base base-devel linux linux-headers linux-firmware git vim nano networkmanager grub

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

grub-install --target=i386-pc $disk

