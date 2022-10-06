### arch-install

## Welcome!

This is an Arch installation script made by CalvinKev, forked by fr000gs and then forked by me, to add a few options back like enabling multilib, and extra ones, such as AMD microcode option and a few optional programs. It will install KDE Plasma, Firefox, Discord, Steam, LibreOffice(fresh) and, optionally, nvidia drivers, VS Code, Calibre, Krita, Lutris, etc.

Credits to the aforementioned people.

Requirements:
You need to know how to read - Duh! 
A PC that can run Arch Linux
A live disc - You can download the ISO here: https://archlinux.org/download/
A thumb stick/flash drive, unless you're installing it on a virtual machine

Installation instructions:

1. Burn your Arch Linux Live ISO onto a USB using your preferred tool, i.e Rufus, Ventoy2Disk(for multiple ISOs in the same drive), command line, Fedora Live ISO creator (or whatever it's called), etc
2. Boot into Arch Linux Live ISO and when presented with the command line, enter: "curl -sL https://bit.ly/haruarch -o install.sh" and press Enter.
3. Choose your keyboard layout with loadkeys. For example "loadkeys us", "loadkeys br-abnt2" or fr, uk, de. For more layouts, visit https://wiki.archlinux.org/title/Linux_console/Keyboard_configuration#Listing_keymaps 
Press Enter and it should be downloaded. You may check by using "dir" if you'd like.
4. Now, we need permissions to execute the file. For that, enter: "chmod +x install.sh" and press Enter.
5. Enter sudo ./install.sh and wait until it prompts for a device.
6. Choose a device from the list and enter it as /dev/(name of the device you want Arch Linux installed on)
7. It'll take you to a screen where you may partition your disk. You can use arrows and Enter keys to choose options to delete, create, resize, etc. Make sure to create one 600-1024Mb partition at the top, and one partition where your files will be, including /home folder. The size of the latter depends on your preference, but I'd recommend at least 20Gb
8. Press Write when you're done, then Quit.
9. Follow the prompts now, with which partitions you'd like to set as efi/boot and /root. Remember to use /dev/(name of the chosen partition), as in /dev/sda1 or /dev/nvme0n1p1 (for SSD nVME devices)
10. Press Y to confirm.
11. At this point it'll start installing, with a few prompts later on. If you use an Intel CPU, press Y when asked. If you press N, it'll install the AMD variant. 
12. When asked for a hostname, enter it, as well as password for root, username(make sure to use LOWERCASE letters only, you can change the name shown in the login screen later, but this is the name that's going to be use in the folder structure and command line), and password for root user. Passwords will not echo, that is, they won't show that you're typing anything, so pay extra attention here.
13. A few more prompts with options for you to choose, and you'll also be asked for the EFI/boot partition again. Double check on the list of devices above it and enter it (i.e /dev/sda1)
14. Once you see the Installation complete prompt, you may press the enter key, you will leave arch-chroot mode and will be able to reboot with either "reboot now" or "systemctl reboot".
15. That's it! You should now be able to see the login screen of KDE Plasma with your username on it.

