#!/bin/bash

source user.cfg

# Enter Host and User Details.
read TIMEZONE
read HOSTNAME
read USERNAME
read PASSWORD

TIMEZONE=$timezone
HOSTNAME=$hostname
USERNAME=$username
PASSWORD=$password

# Set Timezone
ln -sf /usr/share/zoneinfo/$timezone /etc/localtime
hwclock --systohc

# Set Locale
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen

touch /etc/locale.conf
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

# Configure Host

echo "$hostname" >> /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1.      localhost" >> /etc/hosts
echo "127.0.1.1 $hostname.localdomain $hostname" >> /etc/hosts

# Install Grub Bootloader
grub-install --target=i386-pc $disk
grub-mkconfig -o /boot/grub/grub.cfg

# Enable System
systemctl enable NetworkManager
systemctl enable fstrim.timer

# Default User
useradd -m $username
echo $username:$password | chpasswd
