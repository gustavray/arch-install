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

# Root/Linux partition
echo "Enter the /dev path of root partiton/Linux filesystem: "
read partition
mkfs.ext4 $partition

echo "Enter the /dev path of boot partition: "
read bootpartition
mkfs.xfs $bootpartition

# Boot partition
echo "Enter the /dev path of EFI partition: "
read efipartition
mkfs.fat -F32 $efipartition

echo "Enter the /dev path of swap partition: "
read swappartition
mkswap $swappartition


# Mount root partition to /mnt
mount $partition /mnt
mount $bootpartition /mnt/boot
mount $efipartition /mnt/efi
# Pacstrap the needed packages
pacstrap /mnt base base-devel linux-zen linux-firmware
# Generate an /etc/fstab and append it to /mnt/etc/fstab
genfstab -U /mnt > /mnt/etc/fstab
####################################################################################
# Chrooting
arch-chroot /mnt
####################################################################################
# Install Intel Microcode
read -p "Intel CPU? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    # Install Intel microcode
    pacman -S --noconfirm intel-ucode dhcpcd iwd
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
hwclock -lw

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

# Change root password
passwd
# Create user account
echo "Enter name of sudo user: "
read $user
useradd -mG sudo,wheel,audio,video $user
# Set user password
passwd $user
# Configure sudo
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
echo "%sudo ALL=(ALL) ALL" >> /etc/sudoers

# GRUB
pacman --noconfirm -S grub efibootmgr

lsblk
#echo "Enter EFI partition: "
#read efipartition
grub-install --target=x86_64-efi --efi-dir=/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Enable dhcpcd.service
systemctl enable dhcpcd.service
systemctl enable iwd.service

pacman -S --noconfirm vim neofetch htop xorg xorg-xinit firefox xclip libreoffice-fresh pipewire pipewire-alsa pipewire-pulse pavucontrol plasma plasma-wayland-session 

systemctl enable sddm.service
systemctl enable NetworkManager.service

# Updating pacman.conf to include multilib
rm -rf /etc/pacman.conf
mkdir /.pac
gitclone https://github.com/gustavray/pacconf ./.pac
cp -r ./.pac/pacman.conf /etc/

# Update after enabling multilib and other pacman.conf options
pacman -Syu

#Install Pamac
git clone https://aur.archlinux.org/pamac-aur.git
cd pamac-aur
makepkg -si
cd

# Update after enabling multilib and other pacman.conf options
pacman -Syu

#clean files
rm -r .pac
rm -r pamac-aur

read -p "Install Nvidia drivers? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    # Install NVIDIA drivers
    pacman -S --noconfirm --needed nvidia nvidia-utils lib32-nvidia-utils nvidia-settings vulkan-icd-loader lib32-vulkan-icd-loader
fi

# Install a few multilib programs
pacman -S --noconfirm lib32-pipewire discord steam ttf-liberation

#optional multilibs
read -p "Would you like to install optional multilib programs? This includes VS Code, calibre and other programs " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    # Install optional multilib programs
    pacman -S --noconfirm code calibre lutris notepadqq minecraft-launcher obs-studio krita
fi

#Install pikaur
git clone https://aur.archlinux.org/pikaur.git
cd pikaur
makepkg -fsri

printf '\033c'
echo "Installation Complete! Rebooting: (Press return): "
read $aaa

systemctl reboot
