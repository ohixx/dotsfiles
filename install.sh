#!/bin/bash

echo "=== Ohixx Dotfiles Installer ==="

echo "[1/7] Обновление системы / Updating the system"
sudo pacman -Syu --noconfirm

echo "[2/7] Установка yay / Installing yay"
sudo pacman -S --needed --noconfirm git base-devel
git clone https://aur.archlinux.org/yay.git /tmp/yay
cd /tmp/yay
makepkg -si --noconfirm
cd ~

echo "[3/7] Установка NVIDIA драйвера / Installing NVIDIA driver"
sudo pacman -Rns --noconfirm vulkan-nouveau xf86-video-nouveau 2>/dev/null
sudo pacman -S --noconfirm linux-headers
yay -S --noconfirm nvidia-580xx-dkms nvidia-580xx-utils lib32-nvidia-580xx-utils

echo "[4/7] Установка HyprYou / Installing Hypryou"
yay -S --noconfirm hypryou hypryou-utils hypryou-greeter

echo "[5/7] Установка программ / Installing programs"
sudo pacman -S --noconfirm \
    thunar \
    discord \
    telegram-desktop \
    easyeffects \
    obs-studio \
    steam \
    firefox \
    kitty \
    btop \
    fastfetch

echo "[6/7] Установка AUR программ / Installing AUR programs"
yay -S --noconfirm \
    portproton \
    zapret-discord-youtube

echo "[7/7] Настройка сервисов / Configuring services"
sudo systemctl enable greetd
sudo systemctl enable zapret_discord_youtube.service

echo ""
echo "Установка завершена | Download complete"
echo "Please: sudo reboot"
