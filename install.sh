#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

START_TIME=$SECONDS

check_internet() {
    echo -e "${BLUE}Проверка интернета...${NC}"
    if ! ping -c 1 google.com &>/dev/null; then
        echo -e "${RED}Нет интернета! Выход.${NC}"
        exit 1
    fi
    echo -e "${GREEN}Интернет есть!${NC}"
}

check_root() {
    if [ "$EUID" -eq 0 ]; then
        echo -e "${RED}Не запускай от root!${NC}"
        exit 1
    fi
}

detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo $ID
    fi
}

detect_pm() {
    if command -v pacman &>/dev/null; then echo "pacman"
    elif command -v dnf &>/dev/null; then echo "dnf"
    elif command -v apt &>/dev/null; then echo "apt"
    elif command -v zypper &>/dev/null; then echo "zypper"
    else echo "unknown"
    fi
}

check_root
check_internet

DISTRO=$(detect_distro)
PM=$(detect_pm)
LOG_FILE=~/ohixx_install.log

echo -e "${BLUE}=== Ohixx Dotfiles Installer ===${NC}"
echo -e "${GREEN}Дистрибутив: $DISTRO${NC}"
echo -e "${GREEN}Пакетный менеджер: $PM${NC}"
echo -e "${GREEN}Лог: $LOG_FILE${NC}"

echo ""
echo -e "${YELLOW}Выберите окружение:${NC}"
echo "1) HyprYou (Hyprland) [Arch only]"
echo "2) GNOME"
echo "3) KDE Plasma"
echo "4) Только программы (без DE)"
read -p "Ваш выбор [1-4]: " DE_CHOICE

echo ""
echo -e "${YELLOW}Выберите GPU:${NC}"
echo "1) NVIDIA Pascal (GTX 1000)"
echo "2) NVIDIA новее Pascal"
echo "3) AMD"
echo "4) Intel"
echo "5) Без GPU драйверов"
read -p "Ваш выбор [1-5]: " GPU_CHOICE

echo ""
echo -e "${YELLOW}Выберите браузер:${NC}"
echo "1) Firefox"
echo "2) Floorp"
echo "3) Zen Browser"
echo "4) Brave"
echo "5) Chromium"
echo "6) Thorium"
echo "7) LibreWolf"
echo "8) Vivaldi"
echo "9) Google Chrome"
echo "10) Без браузера"
read -p "Ваш выбор [1-10]: " BROWSER_CHOICE

echo ""
echo -e "${YELLOW}Выберите терминал:${NC}"
echo "1) Kitty"
echo "2) Alacritty"
echo "3) Konsole"
echo "4) Foot"
echo "5) WezTerm"
read -p "Ваш выбор [1-5]: " TERM_CHOICE

echo ""
echo -e "${YELLOW}Выберите оболочку:${NC}"
echo "1) Fish"
echo "2) Zsh"
echo "3) Bash (оставить стандартный)"
read -p "Ваш выбор [1-3]: " SHELL_CHOICE

echo ""
echo -e "${YELLOW}Вы Руzzкий? (нужен zapret для YouTube/Discord?)${NC}"
read -p "[y/n]: " ZAPRET_CHOICE

echo ""
echo -e "${YELLOW}Установить Flatpak + Flathub?${NC}"
read -p "[y/n]: " FLATPAK_CHOICE

echo ""
echo -e "${YELLOW}Установить Sober (Roblox)?${NC}"
read -p "[y/n]: " SOBER_CHOICE

echo -e "\n${BLUE}[1/10] Обновление системы${NC}" | tee -a $LOG_FILE
case $PM in
    pacman) sudo pacman -Syu --noconfirm 2>&1 | tee -a $LOG_FILE ;;
    dnf)    sudo dnf update -y 2>&1 | tee -a $LOG_FILE ;;
    apt)    sudo apt update && sudo apt upgrade -y 2>&1 | tee -a $LOG_FILE ;;
    zypper) sudo zypper update -y 2>&1 | tee -a $LOG_FILE ;;
esac

if [ "$PM" = "pacman" ]; then
    echo -e "\n${BLUE}[2/10] Установка yay${NC}" | tee -a $LOG_FILE
    if ! command -v yay &>/dev/null; then
        sudo pacman -S --needed --noconfirm git base-devel 2>&1 | tee -a $LOG_FILE
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        cd /tmp/yay
        makepkg -si --noconfirm 2>&1 | tee -a $LOG_FILE
        cd ~
        rm -rf /tmp/yay
    else
        echo -e "${GREEN}yay уже установлен${NC}"
    fi
fi

echo -e "\n${BLUE}[3/10] Установка GPU драйверов${NC}" | tee -a $LOG_FILE
case $GPU_CHOICE in
    1)
        case $PM in
            pacman)
                sudo pacman -Rns --noconfirm vulkan-nouveau xf86-video-nouveau 2>/dev/null
                sudo pacman -S --noconfirm linux-headers 2>&1 | tee -a $LOG_FILE
                yay -S --noconfirm nvidia-580xx-dkms nvidia-580xx-utils lib32-nvidia-580xx-utils 2>&1 | tee -a $LOG_FILE
                ;;
            dnf)
                sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda 2>&1 | tee -a $LOG_FILE
                ;;
            apt)
                sudo apt install -y nvidia-driver 2>&1 | tee -a $LOG_FILE
                ;;
        esac
        ;;
    2)
        case $PM in
            pacman)
                sudo pacman -Rns --noconfirm vulkan-nouveau xf86-video-nouveau 2>/dev/null
                sudo pacman -S --noconfirm nvidia-dkms nvidia-utils lib32-nvidia-utils linux-headers 2>&1 | tee -a $LOG_FILE
                ;;
            dnf)
                sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda 2>&1 | tee -a $LOG_FILE
                ;;
            apt)
                sudo apt install -y nvidia-driver 2>&1 | tee -a $LOG_FILE
                ;;
        esac
        ;;
    3)
        case $PM in
            pacman) sudo pacman -S --noconfirm mesa lib32-mesa vulkan-radeon 2>&1 | tee -a $LOG_FILE ;;
            dnf)    sudo dnf install -y mesa-dri-drivers mesa-vulkan-drivers 2>&1 | tee -a $LOG_FILE ;;
            apt)    sudo apt install -y mesa-vulkan-drivers 2>&1 | tee -a $LOG_FILE ;;
        esac
        ;;
    4)
        case $PM in
            pacman) sudo pacman -S --noconfirm mesa lib32-mesa vulkan-intel 2>&1 | tee -a $LOG_FILE ;;
            dnf)    sudo dnf install -y mesa-dri-drivers 2>&1 | tee -a $LOG_FILE ;;
            apt)    sudo apt install -y mesa-vulkan-drivers 2>&1 | tee -a $LOG_FILE ;;
        esac
        ;;
    5) echo -e "${YELLOW}Пропуск GPU драйверов${NC}" ;;
esac

echo -e "\n${BLUE}[4/10] Установка окружения${NC}" | tee -a $LOG_FILE
case $DE_CHOICE in
    1)
        if [ "$PM" != "pacman" ]; then
            echo -e "${RED}HyprYou только на Arch!${NC}"
        else
            yay -S --noconfirm hypryou hypryou-utils hypryou-greeter 2>&1 | tee -a $LOG_FILE
            sudo systemctl enable greetd
        fi
        ;;
    2)
        case $PM in
            pacman)
                sudo pacman -S --noconfirm gnome gnome-tweaks 2>&1 | tee -a $LOG_FILE
                sudo systemctl enable gdm
                ;;
            dnf)
                sudo dnf groupinstall -y "GNOME Desktop Environment" 2>&1 | tee -a $LOG_FILE
                sudo systemctl enable gdm
                ;;
            apt)
                sudo apt install -y gnome-shell gnome-tweaks gdm3 2>&1 | tee -a $LOG_FILE
                sudo systemctl enable gdm3
                ;;
        esac
        ;;
    3)
        case $PM in
            pacman)
                sudo pacman -S --noconfirm plasma sddm 2>&1 | tee -a $LOG_FILE
                sudo systemctl enable sddm
                ;;
            dnf)
                sudo dnf groupinstall -y "KDE Plasma Workspaces" 2>&1 | tee -a $LOG_FILE
                sudo systemctl enable sddm
                ;;
            apt)
                sudo apt install -y kde-plasma-desktop sddm 2>&1 | tee -a $LOG_FILE
                sudo systemctl enable sddm
                ;;
        esac
        ;;
    4) echo -e "${YELLOW}Пропуск DE${NC}" ;;
esac

echo -e "\n${BLUE}[5/10] Установка браузера${NC}" | tee -a $LOG_FILE
case $BROWSER_CHOICE in
    1)
        case $PM in
            pacman) sudo pacman -S --noconfirm firefox 2>&1 | tee -a $LOG_FILE ;;
            dnf)    sudo dnf install -y firefox 2>&1 | tee -a $LOG_FILE ;;
            apt)    sudo apt install -y firefox 2>&1 | tee -a $LOG_FILE ;;
        esac
        ;;
    2)
        if [ "$PM" = "pacman" ]; then
            yay -S --noconfirm floorp-bin 2>&1 | tee -a $LOG_FILE
        else
            echo -e "${YELLOW}Floorp доступен только через AUR или flatpak${NC}"
            flatpak install -y flathub one.ablaze.floorp 2>&1 | tee -a $LOG_FILE
        fi
        ;;
    3)
        if [ "$PM" = "pacman" ]; then
            yay -S --noconfirm zen-browser-bin 2>&1 | tee -a $LOG_FILE
        else
            flatpak install -y flathub app.zen_browser.zen 2>&1 | tee -a $LOG_FILE
        fi
        ;;
    4)
        case $PM in
            pacman) sudo pacman -S --noconfirm brave-browser 2>&1 | tee -a $LOG_FILE ;;
            dnf)
                sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
                sudo dnf install -y brave-browser 2>&1 | tee -a $LOG_FILE
                ;;
            apt)
                curl -fsSL https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg | sudo gpg --dearmor -o /usr/share/keyrings/brave-browser-archive-keyring.gpg
                echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-stable.list
                sudo apt update && sudo apt install -y brave-browser 2>&1 | tee -a $LOG_FILE
                ;;
        esac
        ;;
    5)
        case $PM in
            pacman) sudo pacman -S --noconfirm chromium 2>&1 | tee -a $LOG_FILE ;;
            dnf)    sudo dnf install -y chromium 2>&1 | tee -a $LOG_FILE ;;
            apt)    sudo apt install -y chromium 2>&1 | tee -a $LOG_FILE ;;
        esac
        ;;
    6)
        if [ "$PM" = "pacman" ]; then
            yay -S --noconfirm thorium-browser-bin 2>&1 | tee -a $LOG_FILE
        else
            echo -e "${YELLOW}Thorium только через AUR${NC}"
        fi
        ;;
    7)
        if [ "$PM" = "pacman" ]; then
            yay -S --noconfirm librewolf-bin 2>&1 | tee -a $LOG_FILE
        else
            flatpak install -y flathub io.gitlab.librewolf-community 2>&1 | tee -a $LOG_FILE
        fi
        ;;
    8)
        if [ "$PM" = "pacman" ]; then
            yay -S --noconfirm vivaldi 2>&1 | tee -a $LOG_FILE
        else
            flatpak install -y flathub com.vivaldi.Vivaldi 2>&1 | tee -a $LOG_FILE
        fi
        ;;
    9)
        if [ "$PM" = "pacman" ]; then
            yay -S --noconfirm google-chrome 2>&1 | tee -a $LOG_FILE
        elif [ "$PM" = "dnf" ]; then
            sudo dnf config-manager --add-repo https://dl.google.com/linux/chrome/rpm/stable/x86_64
            sudo dnf install -y google-chrome-stable 2>&1 | tee -a $LOG_FILE
        elif [ "$PM" = "apt" ]; then
            wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
            echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
            sudo apt update && sudo apt install -y google-chrome-stable 2>&1 | tee -a $LOG_FILE
        fi
        ;;
    10) echo -e "${YELLOW}Пропуск браузера${NC}" ;;
esac

echo -e "\n${BLUE}[6/10] Установка терминала${NC}" | tee -a $LOG_FILE
case $TERM_CHOICE in
    1)
        case $PM in
            pacman) sudo pacman -S --noconfirm kitty 2>&1 | tee -a $LOG_FILE ;;
            dnf)    sudo dnf install -y kitty 2>&1 | tee -a $LOG_FILE ;;
            apt)    sudo apt install -y kitty 2>&1 | tee -a $LOG_FILE ;;
        esac
        ;;
    2)
        case $PM in
            pacman) sudo pacman -S --noconfirm alacritty 2>&1 | tee -a $LOG_FILE ;;
            dnf)    sudo dnf install -y alacritty 2>&1 | tee -a $LOG_FILE ;;
            apt)    sudo apt install -y alacritty 2>&1 | tee -a $LOG_FILE ;;
        esac
        ;;
    3)
        case $PM in
            pacman) sudo pacman -S --noconfirm konsole 2>&1 | tee -a $LOG_FILE ;;
            dnf)    sudo dnf install -y konsole5 2>&1 | tee -a $LOG_FILE ;;
            apt)    sudo apt install -y konsole 2>&1 | tee -a $LOG_FILE ;;
        esac
        ;;
    4)
        case $PM in
            pacman) sudo pacman -S --noconfirm foot 2>&1 | tee -a $LOG_FILE ;;
            dnf)    sudo dnf install -y foot 2>&1 | tee -a $LOG_FILE ;;
            apt)    sudo apt install -y foot 2>&1 | tee -a $LOG_FILE ;;
        esac
        ;;
    5)
        if [ "$PM" = "pacman" ]; then
            yay -S --noconfirm wezterm 2>&1 | tee -a $LOG_FILE
        else
            flatpak install -y flathub org.wezfurlong.wezterm 2>&1 | tee -a $LOG_FILE
        fi
        ;;
esac

echo -e "\n${BLUE}[7/10] Установка оболочки${NC}" | tee -a $LOG_FILE
case $SHELL_CHOICE in
    1)
        case $PM in
            pacman) sudo pacman -S --noconfirm fish 2>&1 | tee -a $LOG_FILE ;;
            dnf)    sudo dnf install -y fish 2>&1 | tee -a $LOG_FILE ;;
            apt)    sudo apt install -y fish 2>&1 | tee -a $LOG_FILE ;;
        esac
        chsh -s $(which fish)
        echo -e "${GREEN}Fish установлен и выбран по умолчанию${NC}"
        ;;
    2)
        case $PM in
            pacman) sudo pacman -S --noconfirm zsh 2>&1 | tee -a $LOG_FILE ;;
            dnf)    sudo dnf install -y zsh 2>&1 | tee -a $LOG_FILE ;;
            apt)    sudo apt install -y zsh 2>&1 | tee -a $LOG_FILE ;;
        esac
        chsh -s $(which zsh)
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        echo -e "${GREEN}Zsh + Oh My Zsh установлены${NC}"
        ;;
    3) echo -e "${YELLOW}Оставляем Bash${NC}" ;;
esac

echo -e "\n${BLUE}[8/10] Установка шрифтов${NC}" | tee -a $LOG_FILE
case $PM in
    pacman)
        sudo pacman -S --noconfirm \
            ttf-jetbrains-mono-nerd \
            ttf-firacode-nerd \
            ttf-hack-nerd \
            ttf-noto-nerd \
            ttf-roboto \
            ttf-liberation \
            noto-fonts \
            noto-fonts-cjk \
            noto-fonts-emoji \
            noto-fonts-extra \
            ttf-dejavu \
            ttf-opensans \
            adobe-source-code-pro-fonts \
            adobe-source-sans-fonts \
            adobe-source-serif-fonts \
            ttf-font-awesome \
            ttf-material-design-icons-git 2>&1 | tee -a $LOG_FILE
        yay -S --noconfirm \
            ttf-ms-fonts \
            ttf-google-fonts-git 2>&1 | tee -a $LOG_FILE
        ;;
    dnf)
        sudo dnf install -y \
            jetbrains-mono-fonts \
            fira-code-fonts \
            google-roboto-fonts \
            liberation-fonts \
            google-noto-fonts-common \
            google-noto-emoji-fonts \
            google-noto-sans-cjk-fonts \
            dejavu-fonts-all \
            adobe-source-code-pro-fonts \
            adobe-source-sans-pro-fonts \
            fontawesome-fonts 2>&1 | tee -a $LOG_FILE
        ;;
    apt)
        sudo apt install -y \
            fonts-jetbrains-mono \
            fonts-firacode \
            fonts-roboto \
            fonts-liberation \
            fonts-noto \
            fonts-noto-color-emoji \
            fonts-noto-cjk \
            fonts-dejavu \
            fonts-font-awesome \
            adobe-source-code-pro 2>&1 | tee -a $LOG_FILE
        ;;
esac
fc-cache -fv 2>&1 | tee -a $LOG_FILE

echo -e "\n${BLUE}[9/10] Установка основных программ${NC}" | tee -a $LOG_FILE
case $PM in
    pacman)
        sudo pacman -S --noconfirm \
            thunar \
            discord \
            telegram-desktop \
            easyeffects \
            obs-studio \
            steam \
            btop \
            fastfetch \
            git \
            wget \
            curl \
            unzip \
            p7zip \
            wine \
            pinta \
            gimp 2>&1 | tee -a $LOG_FILE
        yay -S --noconfirm portproton 2>&1 | tee -a $LOG_FILE
        ;;
    dnf)
        sudo dnf install -y \
            https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
            https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
        sudo dnf install -y \
            thunar \
            discord \
            telegram-desktop \
            easyeffects \
            obs-studio \
            steam \
            btop \
            fastfetch \
            git \
            wget \
            curl \
            unzip \
            p7zip \
            wine \
            pinta \
            gimp 2>&1 | tee -a $LOG_FILE
        ;;
    apt)
        sudo apt install -y \
            thunar \
            discord \
            telegram-desktop \
            easyeffects \
            obs-studio \
            steam \
            btop \
            fastfetch \
            git \
            wget \
            curl \
            unzip \
            p7zip-full \
            wine \
            pinta \
            gimp 2>&1 | tee -a $LOG_FILE
        ;;
esac

if [ "$FLATPAK_CHOICE" = "y" ] || [ "$FLATPAK_CHOICE" = "Y" ]; then
    echo -e "${CYAN}Установка Flatpak...${NC}" | tee -a $LOG_FILE
    case $PM in
        pacman) sudo pacman -S --noconfirm flatpak 2>&1 | tee -a $LOG_FILE ;;
        dnf)    sudo dnf install -y flatpak 2>&1 | tee -a $LOG_FILE ;;
        apt)    sudo apt install -y flatpak 2>&1 | tee -a $LOG_FILE ;;
    esac
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    echo -e "${GREEN}Flatpak + Flathub установлены${NC}"
fi

if [ "$SOBER_CHOICE" = "y" ] || [ "$SOBER_CHOICE" = "Y" ]; then
    echo -e "${CYAN}Установка Sober (Roblox)...${NC}" | tee -a $LOG_FILE
    if ! command -v flatpak &>/dev/null; then
        case $PM in
            pacman) sudo pacman -S --noconfirm flatpak 2>&1 | tee -a $LOG_FILE ;;
            dnf)    sudo dnf install -y flatpak 2>&1 | tee -a $LOG_FILE ;;
            apt)    sudo apt install -y flatpak 2>&1 | tee -a $LOG_FILE ;;
        esac
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    fi
    flatpak install -y flathub com.sober.Sober 2>&1 | tee -a $LOG_FILE
    echo -e "${GREEN}Sober установлен!${NC}"
fi

echo -e "\n${BLUE}[10/10] Zapret${NC}" | tee -a $LOG_FILE
echo -e "${YELLOW}Вы Руzzкий? (нужен zapret для YouTube/Discord?)${NC}"
read -p "[y/n]: " ZAPRET_CHOICE

if [ "$ZAPRET_CHOICE" = "y" ] || [ "$ZAPRET_CHOICE" = "Y" ]; then
    echo -e "${GREEN}Ставим запрет...${NC}" | tee -a $LOG_FILE
    git clone https://github.com/Sergeydigl3/zapret-discord-youtube-linux.git ~/zapret
    cd ~/zapret
    ./service.sh download-deps --default 2>&1 | tee -a $LOG_FILE
    ./service.sh service install 2>&1 | tee -a $LOG_FILE
    cd ~
    echo -e "${GREEN}Zapret установлен!${NC}"
else
    echo -e "${YELLOW}Пропуск Zapret${NC}"
fi

ELAPSED=$((SECONDS - START_TIME))

echo ""
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}=== Установка завершена! ===${NC}"
echo -e "${GREEN}================================${NC}"
echo -e "${CYAN}Время установки: ${ELAPSED} секунд${NC}"
echo -e "${CYAN}Лог сохранён: $LOG_FILE${NC}"
echo ""
echo -e "${YELLOW}Что установлено:${NC}"
[ "$DE_CHOICE" = "1" ] && echo -e "  ${GREEN}✓${NC} HyprYou"
[ "$DE_CHOICE" = "2" ] && echo -e "  ${GREEN}✓${NC} GNOME"
[ "$DE_CHOICE" = "3" ] && echo -e "  ${GREEN}✓${NC} KDE Plasma"
[ "$SHELL_CHOICE" = "1" ] && echo -e "  ${GREEN}✓${NC} Fish"
[ "$SHELL_CHOICE" = "2" ] && echo -e "  ${GREEN}✓${NC} Zsh + Oh My Zsh"
[ "$FLATPAK_CHOICE" = "y" ] || [ "$FLATPAK_CHOICE" = "Y" ] && echo -e "  ${GREEN}✓${NC} Flatpak + Flathub"
[ "$SOBER_CHOICE" = "y" ] || [ "$SOBER_CHOICE" = "Y" ] && echo -e "  ${GREEN}✓${NC} Sober (Roblox)"
[ "$ZAPRET_CHOICE" = "y" ] || [ "$ZAPRET_CHOICE" = "Y" ] && echo -e "  ${GREEN}✓${NC} Zapret"
echo -e "  ${GREEN}✓${NC} Шрифты + эмодзи"
echo -e "  ${GREEN}✓${NC} Основные программы"
echo ""
echo -e "${RED}Перезагрузите систему: sudo reboot${NC}"
