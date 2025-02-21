#!/bin/bash
#---------------------------------------
# color codes
ROSEWATER="\e[38;2;245;224;220m"
FLAMINGO="\e[38;2;242;205;205m"
PINK="\e[38;2;245;194;231m"
MAUVE="\e[38;2;203;166;247m"
RED="\e[38;2;243;139;168m"
MAROON="\e[38;2;235;160;172m"
PEACH="\e[38;2;250;179;135m"
YELLOW="\e[38;2;249;226;175m"
GREEN="\e[38;2;166;227;161m"
TEAL="\e[38;2;148;226;213m"
BLUE="\e[38;2;137;180;250m"
LAVENDER="\e[38;2;180;190;254m"
NC="\e[0m"
#emoji codes
SUCCESS="${GREEN}\xE2\x9C\x94${NC}"
FAIL="${RED}\xE2\x9C\x96${NC}"
WARNING="${RED}\xF0\x9F\x9A\xA8${NC}"
#---------------------------------------
set -e  # exit on error
#---------------------------------------
# packages and services
USER_SERVICES=("hyprpolkitagent" "waybar")
SYSTEM_SERVICES=("swayosd-libinput-backend.service")  # do not put sddm here as it will start it and take over
AUR_PACKAGES=("topgrade" "visual-studio-code-bin" "waytrogen" "swayosd-git" "uwsm" "bibata-cursor-git" "all-repository-fonts" "spicetify-cli-git" "clipse-bin" "ddcutil" "kvantum-qt6-git" "kvantum-theme-catppuccin-git" "dracula-gtk-theme-git")  
PACMAN_PACKAGES=(
    # system utilities
    btop
    fastfetch
    fish
    starship
    zoxide
    rsync
    git
    nano
    jq
    parallel
    imagemagick
    libnotify
    pacman-contrib
    brightnessctl
    stow
    7zip
    fd
    fzf
    poppler
    age
    keychain
    openssh
    # Hyprland & Wayland Environment
    hyprland
    hypridle
    hyprpaper
    hyprlock
    swaync
    nwg-look
    nwg-displays
    waybar
    wlogout
    wl-clipboard
    slurp
    satty
    hyprpolkitagent
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    # Networking & Bluetooth
    networkmanager
    network-manager-applet
    blueman
    bluez
    bluez-utils
    nextcloud-client
    # File Management
    udiskie
    dolphin
    yazi
    ark
    # Theming & Appearance
    qt5ct
    qt6ct
    kvantum-qt5
    qt5-wayland
    qt6-wayland
    kde-cli-tools
    tela-circle-icon-theme-dracula
    gtk4
    gtk3
    gtk2
    # Pipewire & Audio
    pipewire
    pipewire-alsa
    pipewire-audio
    pipewire-jack
    pipewire-pulse
    gst-plugin-pipewire
    wireplumber
    pavucontrol
    pamixer
    # Applications
    kitty
    rofi-wayland
    spotify-launcher
    vivaldi
    vesktop
    obsidian
    sddm
    cmake
    neovim
    # KDE Integration
    kwallet
    kwallet-pam
    kio
    qt5-imageformats
    ffmpegthumbs
)    
#---------------------------------------
# no sudo run
if [[ $EUID -eq 0 ]]; then
    echo -e "${RED}${WARNING} Do not run this script as root${NC}"
    exit 1
fi
#---------------------------------------
# starting
echo -e "${LAVENDER}Setting System Up...${NC}\n"
# ensure system is up to data
echo -e "${MAROON}Updating System...${NC}\n"
sudo pacman -Syu --noconfirm --needed && echo -e "${SUCCESS} Pacman packages updated" || echo -e "${FAIL} Pacman update failed"
# install pacman packages
echo -e "${MAROON}Installing Packages...${NC}\n"
sudo pacman -S "${PACMAN_PACKAGES[@]}" && echo -e "${SUCCESS} Pacman packages installed" || echo -e "${FAIL} Pacman packages failed to install"
# install aur packages
echo -e "${MAROON}Installing Aur Packages...${NC}\n"
if command -v paru &> /dev/null; then
    paru -Syu "${AUR_PACKAGES[@]}" && echo -e "${SUCCESS} Aur packages installed" || echo -e "${FAIL} Aur packages failed to install"
else 
    echo -e "${WARNING}Paru not installed..."
fi
# enable system services
echo -e "${MAROON}Enabling System Services...${NC}\n"
sudo systemctl enable "${SYSTEM_SERVICES[@]}" && echo -e "${SUCCESS} System services enabled & started" || echo -e "${FAIL} System services failed to enable/start"
# enable user services
echo -e "${MAROON} Enabling User Services...${NC}\n"
systemctl --user enable "${USER_SERVICES[@]}" && echo -e "${SUCCESS} User services enabled & started" || echo -e "${FAIL} User services failed to enable/start"
