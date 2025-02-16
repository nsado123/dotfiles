#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Helper function for printing status messages
function print_status() {
    echo -e "${GREEN}$1${NC}"
}

# Helper function to check if a command is installed
function is_installed() {
    command -v "$1" &>/dev/null
}

# Step 1: Check if the system is Arch-based
print_status "Checking if the system is Arch-based..."
if [ ! -f /etc/arch-release ] ; then
    exit 1
fi
print_status "System confirmed as Arch-based."

# Step 2: Check if an AUR helper is installed (yay or paru)
aur_helper=""
if command -v paru &> /dev/null; then
    aur_helper="paru"
elif command -v yay &> /dev/null; then
    aur_helper="yay"
else
    echo "No AUR helper found."
    echo "Choose an AUR helper to install:"
    select aur_helper_choice in "paru" "yay"; do
        case $aur_helper_choice in
            paru) 
                echo "Installing paru..."
                sudo pacman -Sy --needed paru
                aur_helper="paru"
                break
                ;;
            yay)
                echo "Installing yay..."
                sudo pacman -Sy --needed yay
                aur_helper="yay"
                break
                ;;
            *) 
                echo "Invalid choice, please select 1 or 2."
                ;;
        esac
    done
fi

print_status "Using AUR helper: $aur_helper"

# Step 3: Install packages from pacman-pkg.lst
if [ -f pacman-pkg.lst ]; then
    echo "Installing packages from pacman-pkg.lst..."
    sudo pacman -Syu --needed $(< pacman-pkg.lst)
else
    echo -e "${RED}Error: pacman-pkg.lst is missing. Please create the file to continue.${NC}"
    exit 1
fi

# Step 4: Check if rustup is installed, if not install rustup
if command -v rustup &>/dev/null; then
    print_status "rustup found. Setting default toolchain to stable..."
    rustup default stable
else
    print_status "rustup not found. Installing rustup..."
    sudo pacman -S --needed rustup --noconfirm
    rustup default stable
fi

# Step 5: Ensure Rust is installed
if ! command -v rustc &>/dev/null; then
    print_status "Rust not found. Installing Rust..."
    sudo pacman -S --needed rust --noconfirm
else
    print_status "Rust is already installed."
fi

# Step 6: Install packages from aur-pkg.lst using the selected AUR helper
if [ -f aur-pkg.lst ]; then
    echo "Installing AUR packages from aur-pkg.lst..."
    $aur_helper -S --noconfirm --needed $(< aur-pkg.lst)
else
    echo -e "${YELLOW}Warning: aur-pkg.lst not found! Skipping AUR package installation.${NC}"
fi

# Step 7: Ask for Flatpak installation
read -p "Do you want to install Flatpak? (y/n): " install_flatpak
if [[ "$install_flatpak" =~ ^[Yy]$ ]]; then
    if ! is_installed "flatpak"; then
        echo "Installing Flatpak..."
        sudo pacman -Sy --needed flatpak
    else
        echo "Flatpak is already installed."
    fi

    # Step 8: Install Flatpak packages from flatpak-pkg.lst
    if [ -f flatpak-pkg.lst ]; then
        echo "Installing Flatpak packages from flatpak-pkg.lst..."
        xargs -a flatpak-pkg.lst -I{} flatpak install -y {}
    else
        echo -e "${YELLOW}Warning: flatpak-pkg.lst not found! Skipping Flatpak package installation.${NC}"
    fi
else
    echo "Flatpak installation skipped."
fi

# Step 9: Enable and start system services from system.lst
if [ -f system.lst ]; then
    echo "Enabling and starting system services..."
    while read -r service; do
        if systemctl list-unit-files | grep -q "^$service"; then
            sudo systemctl enable --now "$service"
        else
            echo -e "${RED}Warning: Service '$service' not found.${NC}"
        fi
    done < system.lst
else
    echo -e "${YELLOW}Warning: system.lst not found! Skipping system services setup.${NC}"
fi

# Step 10: Enable and start user services from user.lst
if [ -f user.lst ]; then
    echo "Enabling and starting user services..."
    while read -r service; do
        systemctl --user enable --now "$service"
    done < user.lst
else
    echo -e "${YELLOW}Warning: user.lst not found! Skipping user services setup.${NC}"
fi

# Step 11: Autologin Configuration
target_dir="/etc/systemd/system/getty@tty1.service.d"
target_file="$target_dir/autologin.conf"

sudo mkdir -p "$target_dir"

sudo tee "$target_file" > /dev/null <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty -o '-p -f -- \\u' --noclear --autologin nsado %I $TERM
EOF

sudo systemctl daemon-reload
echo "Autologin configuration set up successfully."

# Step 12: Reboot Prompt
read -p "Do you want to reboot now? (y/n): " reboot_now
if [[ "$reboot_now" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Installation complete. Rebooting the system...${NC}"
    sudo reboot
else
    echo "Reboot skipped."
fi
