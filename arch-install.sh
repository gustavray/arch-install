#!/bin/bash

# ARCH INSTALL

# https://github.com/fr000gs/arch-install
#
# Be sure to run as root.

#part1
clear

echo "Welcome to Haruki's Arch installer."

# Change ParallelDownloads from "5" to "10"
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
# Update archlinux-keyring to avoid unnecessary errors
pacman --noconfirm -Sy archlinux-keyring
# Load US keyboard layout
#loadkeys us (reserved as I don't use a US keyboard) 
# Fix date and time
timedatectl set-ntp true
timedatectl set-local-rtc 1

# Select drive to partition
lsblk
echo "Enter the drive you wish to partition: "
read drive
cfdisk $drive

# Select partitions to format

# Boot partition
lsblk
echo "Enter the /dev path of EFI partition: "
read efipartition
mkfs.fat -F32 $efipartition

# Root/Linux partition
lsblk
echo "Enter the /dev path of root partiton/Linux filesystem: "
read partition
mkfs.btrfs $partition

# Mount root partition to /mnt
lsblk
mount $partition /mnt

# Pacstrap the needed packages
pacstrap /mnt base base-devel linux-zen linux-firmware vim nano
# Generate an /etc/fstab and append it to /mnt/etc/fstab
genfstab -U /mnt >> /mnt/etc/fstab
# Create new sh file for arch-chroot
sed '1,/^#part2$/d' `basename $0` > /mnt/arch-install2.sh
#mv /home/arch-install2.sh /mnt
chmod +x /mnt/arch-install2.sh
arch-chroot /mnt ./arch-install2.sh
exit

#part2

# Update Pacman 
pacman -Syu

clear

# Install Intel/AMD Microcode
read -p "Intel CPU? (y/N) " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    # Install Intel microcode
    pacman -S --noconfirm intel-ucode dhcpcd iwd
else
    # Install AMD microcode
    pacman -S --noconfirm amd-ucode dhcpcd iwd linux-zen-headers
fi

# Change ParallelDownloads from 5 to 15
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf

# Set timezone
echo "Enter timezone (format Continent/City): "
read $timezone
timedatectl set-timezone $timezone
ln -sf /usr/share/zoneinfo/$timezone /etc/localtime
# Sync hardware clock with Arch Linux
hwclock --systohc

# Set locale
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
# Generate locale
locale-gen
# Set locale.conf
echo "LANG=en_US.UTF-8" > /etc/locale.conf
# Set hostname
echo "Hostname: "
read hostname
echo $hostname > /etc/hostname

# Configure /etc/hosts
echo "127.0.0.1		localhost" >> /etc/hosts
echo "::1		localhost" >> /etc/hosts
echo "127.0.1.1		$hostname.localdomain	$hostname >> /etc/hosts"

# Install sudo
pacman -S --noconfirm sudo

# Change root password
echo "Set root password: "
passwd
# Create user account
echo "Enter desired username(lowercase letters only: "
read user
useradd -m $user
# Set user passwordwheel,audio,video,storage 
passwd $user
usermod -aG wheel,audio,video,storage $user
# Configure sudo
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

# GRUB
pacman -S --noconfirm grub efibootmgr os-prober
lsblk
echo "Enter EFI partition again: "
read efipartition
mkdir /boot/efi
mount $efipartition /boot/efi
grub-install --target=x86_64-efi --bootloader-id=ArchLinux --efi-directory=/boot/efi
sudo os-prober
grub-mkconfig -o /boot/grub/grub.cfg

# Install git for cloning config file
pacman -S --noconfirm git
rm -rf /etc/pacman.conf
mkdir /.pacm
git clone https://github.com/gustavray/pacconf ./.pac
git clone https://github.com/gustavray/pacconf /etc/
cp ./.pac/pacman.conf /etc/

# Update after enabling multilib and other pacman.conf options
pacman -Syu

pacman -S --noconfirm vim neofetch xorg xorg-server xorg-xinit firefox git pipewire pipewire-alsa pipewire-pulse pavucontrol git dmenu vlc ttf-cascadia-code picom 


# DE installation 
# GNOME
# read -p "Install GNOME? y/n " -n 1 -r
#echo    # (optional) move to a new line
#if [[ $REPLY =~ ^[Yy]$ ]]
#then
#    # Install Gnome and dependancies
#    pacman -S --noconfirm gnome
#    systemctl enable gdm.service
#fi
# KDE Plasma
read -p "Install KDE? y/n " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    # Install Gnome and dependancies
    pacman -S --noconfirm  kde-applications plasma plasma-wayland-session sddm
    systemctl enable sddm.service
fi

# Enable essential services
systemctl enable dhcpcd.service
systemctl enable iwd.service
systemctl enable NetworkManager.service

#part3

################################################################################################
# Reserved for future wallpapers
# Wallpapers
# git clone https://github.com/CalvinKev/wallpapers.git /home/$username/Pictures/wallpapers
# rm -rf /home/$user/Pictures/wallpapers/.git
# rm -rf /home/$user/Pictures/wallpapers/LICENSE
# rm -rf /home/$user/Pictures/wallpapers/README.md
################################################################################################

# Nvidia Driver installation 
read -p "Install Nvidia drivers? y/n " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    # Install NVIDIA drivers
    pacman -S --noconfirm --needed nvidia-dkms #nvidia-utils nvidia-settings vulkan-icd-loader 
fi

# Install a few multilib programs
echo "Would you like to install Discord, Steam and fonts? [y/n] "
read answer1
if [[ $answer1 = y ]] ; then
    pacman -S --noconfirm lib32-pipewire discord steam ttf-liberation
fi

#optional multilibs
read -p "Would you like to install optional multilib programs? This includes VS Code, Calibre, OBS Studio, Lutris, and other programs: (y/n) " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    # Install optional multilib programs
    pacman -S --noconfirm code calibre lutris notepadqq obs-studio krita grub-customizer
fi

read -p "Install Libre Office? "
echo # to move a line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    # Install LIbreOffice
    pacman -S --noconfirm libreoffice-fresh
fi

clear
echo "Installation Complete! Rebooting: (Press return) and enter "systemctl reboot" or "reboot now" on the next screen: "
read $aaa

sleep 2s
#clear
exit
