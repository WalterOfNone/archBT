#!/bin/bash

cat << EOF
This script is used to install programs for after install
This is customized to my LG Gram 15Z90Q-P.AAC6U1 with an i5-1240p running Wayland
It does multiple unreviewed AUR installs so be aware

EOF

read -rp 'Enter git username: ' USERNAME
read -rp 'Enter git email: ' EMAIL
read -rp 'Enter git pubkey: ' PUBKEYID

# Prep sudo
sudo -l

# Update packages
paru

# Oh my bash install
echo '1' | paru oh-my-bash-git --skipreview
cat /usr/share/oh-my-bash/bashrc >> ~/.bashrc

# Install Firefox
sudo pacman -S firefox plasma-browser-integration --noconfirm
echo "export MOZ_ENABLE_WAYLAND=1" >> ~/.profile

# KDE Plasma Intel audio fix
sudo cp config/audiofix.conf /etc/modprobe.d/audiofix.conf

# Install display management
sudo pacman -S kscreen

# Install power management
sudo pacman -S powerdevil power-profiles-daemon powertop
# kinfocenter is not required but gives useful info especially about battery
sudo pacman -S kinfocenter

# Portal setup for dolphin in every file picker
sudo pacman -S xdg-desktop-portal xdg-desktop-portal-kde
echo "export GTK_USE_PORTAL=1" >> ~/.profile

# Install Obsidian
sudo pacman -S obsidian
echo "export OBSIDIAN_USE_WAYLAND=1" >> ~/.profile

# Chrony setup
sudo pacman -S chrony
sudo systemctl enable --now chronyd
sudo cp config/chrony.conf /etc/chrony.conf

# Bluetooth support
sudo pacman -S bluez bluez-utils bluedevil
sudo systemctl enable --now bluetooth

# Yubico authenticator install
echo '1' | paru yubico-authenticator-bin --skipreview
sudo pacman -S pcsclite
sudo systemctl enable --now pcscpd

# Discord install
sudo pacman -S discord noto-fonts-cjk noto-fonts-emoji ttf-symbola

# VS Code Install
sudo pacman -S ttf-firacode-nerd
echo '1' | paru visual-studio-code-bin --skipreview
cp config/code-flags.conf ~/.config/code-flags.conf
## Git config
git config --global user.name ${USERNAME}
git config --global user.email ${EMAIL}
## GPG support
cp secrets/.gnupg ~/.gnupg
gpg --list-keys --keyid-format=long
git config --global user.signingkey ${PUBKEYID}
git config --global commit.gpgsign true


# Bash history file unlimited support
echo 'export HISTSIZE="toInfinity"' >> ~/.bashrc
echo 'export HISTFILESIZE="andBeyond"' >> ~/.bashrc
echo ". ${HOME}/.bashrc" >> ~/.profile # Needed for TTY login

# VPN Setup
# Wireguard
nmcli connection import type wireguard file secrets/wg*
nmcli connection modify wg-home connect.autoconnect no
# OpenVPN
sudo pacman -S networkmanager-openvpn
nmcli connection import type openvpn file secrets/ovpn*

# Install screenshot
sudo pacman -S spectacle

# Install Spotify xWayland to have media support
sudo pacman -S spotify-launcher

# Install Steam (32-bit xwayland cause Steam is ancient dinosaur)
sudo pacman -S steam

# Install Slack
# Login Fix: https://stackoverflow.com/questions/70867064/signing-into-slack-desktop-not-working-on-4-23-0-64-bit-ubuntu
echo '1' | paru slack-electron
cp desktops/slack.desktop ~/.local/share/applications

# Install Teams (It somehow just works)
echo '1' | paru teams-for-linux-bin
cp desktops/teams-for-linux.desktop ~/.local/share/applications

# Node setup
echo '1' | paru volta-bin
volta setup
source ~/.bashrc
volta install node@latest
volta install node@lts
volta install npm
volta install pnpm
volta install yarn@1
volta insall yarn
volta install nodemon
volta install typescript

# Python setup
sudo pacman -S python-pip

# Java setup
sudo pacman -S jdk-openjdk jre-openjdk jre-openjdk-headless
echo '1' | paru eclipse-java
# Fix font aliasing in GTK apps (needs relogin)
sudo pacman -S xdg-desktop-portal-gtk
# To setup gpg signing go to preferences and lookup gpg and switch from bouncy castle to an external gpg executable /usr/bin/gpg

# Install [chaotic AUR](https://aur.chaotic.cx/)
sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
cat << EOF | sudo tee -a /etc/pacman.conf

[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist

EOF

# Install chromium with video accel for video decoding
sudo pacman -S libva-utils vdpauinfo
echo '1' | paru chromium-wayland-vaapi --skipreview
cp desktops/chrominum.desktop ~/.local/share/applications
# Intel only
echo "export VDPAU_DRIVER=va_gl" >> ~/.profile
echo "export LIBVA_DRIVER_NAME=iHD" >> ~/.profile
source ~/.profile

# libvirt install
# Win11 install guide: https://linustechtips.com/topic/1379063-windows-11-in-virt-manager/
sudo pacman -S virt-manager qemu-desktop dnsmasq iptables-nft swtpm
sudo usermod -aG libvirt $USER

sudo sed -i 's/#unix_sock_group/unix_sock_group/g' /etc/libvirt/libvirtd.conf
sudo sed -i 's/#unix_sock_rw/unix_sock_rw/g' /etc/libvirt/libvirtd.conf
sudo sed -i "s/#user = \"@QEMU_USER@\"/user = \"${USER}\"/g" /etc/libvirt/qemu.conf
sudo sed -i 's/#group = \"@QEMU_GROUP@\"/group = "libvirt"/g' /etc/libvirt/qemu.conf

echo 'In virt-manager you can remove the system QEMU connection and add a User Session QEMU connections'
