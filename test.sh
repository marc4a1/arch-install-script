#!/bin/bash

clear

sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf

# Update System Clock
timedatectl set-ntp true

# Show Installed Devices
lsblk

# Choose Drive to Install Arch
echo -n "Enter drive you wish to install Arch on. (i.e /dev/sda) "
read -r BLOCK_DEVICE

disk=/dev/$BLOCK_DEVICE
boot=${disk}1
root=${disk}2

# Umount mnt for clean install
umount -R /mnt

# Create Disk Partitions
set -xe
parted -s $disk mklabel gpt
parted -sa optimal $disk mkpart primary fat32 0% 1024M
parted -sa optimal $disk mkpart primary ext4 1024M 100%
parted -s $disk set 1 esp on

# Format Partitions
mkfs.fat -F32 $boot
mkfs.ext4 -F $root

# Mount Partitions
mount $root /mnt
mkdir -p /mnt/boot/efi
mount $boot /mnt/boot/efi

# Install Base System
pacstrap -K /mnt base base-devel linux linux-firmware vim

# Generate Fstab
genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt

# Parallel Downloads
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf

# Enter Host and User Details.
echo -n "Enter Timezone (i.e. America/Los_Angeles): "
read timezone

echo -n "Enter Hostname: "
read hostname

echo -n "Enter Username: "
read username

echo -n "Enter Password: "
read password

# Set Timezone
ln -sf /usr/share/zoneinfo/$timezone /etc/localtime
hwclock --systohc

# Set Locale
sed -i 's/^#en_US.UTF-8/en_US.UTF-8/g' /etc/locale.gen
locale-gen

touch /etc/locale.conf
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

# Configure Host
echo "$hostname" >> /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1.      localhost" >> /etc/hosts
echo "127.0.1.1 $hostname.localdomain $hostname" >> /etc/hosts

# Install EFI Bootloader
pacman -Sy
pacman -S --noconfirm --needed grub efibootmgr
grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi
mkdir /boot/grub
grub-mkconfig -o /boot/grub/grub.cfg

# Install Packages
pacman -Sy
pacman -S --noconfirm networkmanager sudo

# Enable System
systemctl enable NetworkManager
# systemctl enable fstrim.timer

# Default User
useradd -m $username
echo $username:$password | chpasswd
usermod -aG wheel,audio,video,storage $username

sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/g' /etc/sudoers

# Unmount and Reboot
#umount -R /mnt
#echo "Remove install media. System will reboot in 10 seconds."
#sleep 10
#reboot