#!/bin/bash

# ARCH INSTALL

# https://github.com/fr000gs/arch-install
#
# Be sure to run as root.

#part1
printf '\033c'

echo "Welcome to fr000gs Arch installer."

# Change ParallelDownloads from "5" to "10"
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
# Update archlinux-keyring to avoid unnecessary errors
pacman --noconfirm -Sy archlinux-keyring
# Load US keyboard layout
loadkeys us
# Fix date and time
timedatectl set-ntp true

# Select drive to partition
lsblk
echo "Enter the drive you wish to partition(root, bot, EFI and swap): "
read drive
cfdisk $drive

# Select partitions to format

# Boot partition
echo "Enter the /dev path of EFI partition: "
read efipartition
mkfs.fat -F32 $efipartition

# Root/Linux partition
echo "Enter the /dev path of root partiton/Linux filesystem: "
read partition
mkfs.ext4 $partition

# Mount root partition to /mnt
mount $efipartition /mnt/efi
mount $partition /mnt

# Pacstrap the needed packages
pacstrap /mnt base base-devel linux-zen linux-firmware vim nano
# Generate an /etc/fstab and append it to /mnt/etc/fstab
genfstab -U /mnt >> /mnt/etc/fstab
sed '1,/^#part2$/d' `basename $0` > /mnt/arch-install2.sh
#mv /home/arch-install2.sh /mnt
chmod +x /mnt/arch-install2.sh
arch-chroot /mnt ./arch-install2.sh

#part2

#updating
pacman -Syu

# Install Intel Microcode
read -p "Intel CPU? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    # Install Intel microcode
    pacman -S --noconfirm intel-ucode dhcpcd iwd
else
    # Install AMD microcode
    pacman -S --noconfirm amd-ucode dhcpcd iwd
fi

read -p "AMD CPU? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    # Install AMD microcode
    pacman -S --noconfirm amd-ucode dhcpcd iwd
fi

# Change ParallelDownloads from 5 to 15
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf

# Set timezone
echo "Enter timezone (format Continent/City): "
read $timezone
timedatectl set-timezone $timezone
ln -sf /usr/share/zoneinfo/$timezone /etc/localtime
# Sync hardware clock with Arch Linux

# Set locale
echo "pt_BR.UTF-8 UTF-8" >> /etc/locale.gen
# Generate locale
locale-gen
# Set locale.conf
echo "LANG=pt_BR.UTF-8" > /etc/locale.conf
# Set hostname
echo "Hostname: "
read hostname
echo $hostname > /etc/hostname

# Configure /etc/hosts
echo "127.0.0.1		localhost" >> /etc/hosts
echo "::1		localhost" >> /etc/hosts
echo "127.0.1.1		$hostname.localdomain	$hostname >> /etc/hosts"

#install sudo
pacman -S --noconfirm sudo

# Change root password
passwd
# Create user account
echo "Enter name of sudo user: "
read user
useradd -m $user
# Set user passwordwheel,audio,video,storage 
passwd $user
usermod -aG wheel,audio,video,storage $user

# Configure sudo
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
echo "%sudo ALL=(ALL) ALL" >> /etc/sudoers

# Updating pacman.conf to include multilib
pacman -S --noconfirm git
rm -rf /etc/pacman.conf
mkdir /.pacm
git clone https://github.com/gustavray/pacconf ./.pac
git clone https://github.com/gustavray/pacconf /etc/
cp ./.pac/pacman.conf /etc/

# Update after enabling multilib and other pacman.conf options
pacman -Syu

pacman -S --noconfirm vim neofetch htop xorg xorg-xinit firefox xclip pipewire pipewire-alsa pipewire-pulse pavucontrol plasma plasma-wayland-session 

# Enable dhcpcd.service
systemctl enable dhcpcd.service
systemctl enable iwd.service
systemctl enable sddm.service
systemctl enable NetworkManager.service

read -p "Install Nvidia drivers? y/n " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    # Install NVIDIA drivers
    pacman -S --noconfirm --needed nvidia nvidia-utils nvidia-settings vulkan-icd-loader 
fi

# Install a few multilib programs
#######pacman -S --noconfirm lib32-pipewire discord steam ttf-liberation

#optional multilibs
read -p "Would you like to install optional multilib programs? This includes VS Code, calibre and other programs " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    # Install optional multilib programs
    pacman -S --noconfirm code calibre lutris notepadqq minecraft-launcher obs-studio krita
fi

# GRUB
pacman -S --noconfirm grub efibootmgr os-prober
mkdir /boot/efi
mount $efipartition /boot/efi
grub-install --target=x86_64-efi --bootloader-id=ArchLinux --efi-directory=/boot/efi
sudo os-prober

grub-mkconfig -o /boot/grub/grub.cfg

#printf '\033c'
#echo "Installation Complete! Rebooting: (Press return): "
#read $aaa

#sleep 2s
#exit

#systemctl reboot
