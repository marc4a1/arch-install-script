#!/bin/bash

# Install Grub
grub-install --target=i386-pc /dev/sda;
grub-mkconfig -o /boot/grub/grub.cfg;

echo root:1234 | chpasswd;
