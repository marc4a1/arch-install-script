#!/bin/bash

source config.conf

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
sed -i 's/^#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
locale-gen

touch /etc/locale.conf
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

# Configure Host
echo "$hostname" >> /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1.      localhost" >> /etc/hosts
echo "127.0.1.1 $hostname.localdomain $hostname" >> /etc/hosts

# Install Grub Bootloader
pacman -Sy
pacman -S --noconfirm grub
grub-install --target=i386-pc $disk
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

sed -i 's/^#%wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/g' /etc/sudoers

rm arch-chroot.sh config.conf
