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
PACMAN_PACKAGES=("neovim" "btop" "git" "curl")
AUR_PACKAGES=("visual-studio-code-bin" "waytrogen")  
SYSTEM_SERVICES=("swayosd-libinput-backend.service")  # do not put sddm here as it will start it and take over
USER_SERVICES=("hyprpolkitagent")
#---------------------------------------
# autologin setup
sddm_autologin() {
sudo mkdir -p /etc/sddm.conf.d
sudo tee /etc/sddm.conf.d/autologin.conf > /dev/null <<EOF
[Autologin]
User=nsado
Session=hyprland-uwsm
EOF
}
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
sudo systemctl enable --now "${SYSTEM_SERVICES[@]}" && echo -e "${SUCCESS} System services enabled & started" || echo -e "${FAIL} System services failed to enable/start"
# enable user services
echo -e "${MAROON} Enabling User Services...${NC}\n"
systemctl --user enable --now "${SYSTEM_SERVICES[@]}" && echo -e "${SUCCESS} User services enabled & started" || echo -e "${FAIL} User services failed to enable/start"
# sddm autologin setup
if command -v sddm &> /dev/null; then
    echo -ne "${MAROON}Detected Sddm Installed...Setup Autologin? (Y/n):${NC}"
    read -r response
    case "$response" in 
        [Nn]* )
            echo -e "${FLAMINGO}Skipping Autologin"
            ;;
        * )
            echo -e "${ROSEWATER}Setting up autologin..."
            sudo systemctl enable sddm
            sddm_autologin
            ;;
    esac
fi
# end
echo "${LAVENDER}System Setup Finished...${NC}\n"