#!/bin/bash
#---------------------------------------
# color codes
ROSEWATER="\e[38;2;245;224;220m"
FLAMINGO="\e[38;2;242;205;205m"
RED="\e[38;2;243;139;168m"
MAROON="\e[38;2;235;160;172m"
GREEN="\e[38;2;166;227;161m"
NC="\e[0m"
#emoji codes
SUCCESS="${GREEN}\xE2\x9C\x94${NC}"
FAIL="${RED}\xE2\x9C\x96${NC}"
#---------------------------------------
set -e  # exit on error
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
# sddm autologin setup
if command -v sddm &> /dev/null; then
    echo -ne "${MAROON}Detected Sddm Installed...Setup Autologin? (Y/n):${NC}"
    read -r response
    case "$response" in 
        [Nn]* )
            echo -e "${FLAMINGO}Skipping autologin"
            ;;
        * )
            echo -e "${ROSEWATER}Setting up autologin..."
            sudo systemctl enable sddm
            sddm_autologin && echo -e "${SUCCESS} Autologin set" || echo -e "${FAIL} Autologin failed!"
            ;;
    esac
fi
#---------------------------------------
# ddcutil permission
if command -v ddcui &> /dev/null; then
    echo -e "${MAROON}Detected Ddcui Installed...Setup Group Permissions? (Y/n):${NC}"
    read -r response
    case "$response" in 
        [Nn]* )
            echo -e "${FLAMINGO}Skipping group permissions setup"
            ;;
        * )
            echo -e "${ROSEWATER}Setting up group permsissions..."
            if ! getent group i2c &> /dev/null; then 
                sudo groupadd i2c
            fi 
            sudo usermod -aG i2c nsado
            echo 'KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"' | sudo tee /etc/udev/rules.d/45-ddcutil-i2c.rules
             sudo udevadm control --reload-rules && sudo udevadm trigger &> /dev/null && echo -e "${SUCCESS} Group permissions set" || echo -e "${FAIL} Failed to set group permissions!" 
    esac
fi
#---------------------------------------
# yazi setup
if command -v ya &> /dev/null; then
    ya pack -i -u
fi

systemctl daemon-reload