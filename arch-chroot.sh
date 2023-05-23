#!/bin/bash

# Enter Host and User Details.

echo -n "Enter Timezone (i.e. America/Los_Angeles): "
read TIMEZONE

echo -n "Enter Hostname: "
read HOSTNAME

echo -n "Enter Username: "
read USERNAME

echo -n "Enter Password: "
read PASSWORD

timezone=$TIMEZONE
hostname=$HOSTNAME
username=$USERNAME
password=$PASSWORD

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

# Install Grub Bootloader
pacman -S grub
grub-install --target=i386-pc $disk
grub-mkconfig -o /boot/grub/grub.cfg

# Install EFI Bootloader
# pacman -S grub efibootmgr dosfstools mtools gptfdisk fatresize
# grub-install --target=x86_64-efi --bootloader-id=grub_uefi --efi-directory=/boot/efi --recheck
# grub-mkconfig -o /boot/grub/grub.cfg

# Enable System
systemctl enable NetworkManager
systemctl enable fstrim.timer

# Default User
useradd -m $username
echo $username:$password | chpasswd
