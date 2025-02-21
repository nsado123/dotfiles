#!/bin/bash
#---------------------------------------
# color codes
ROSEWATER="\e[38;2;245;224;220m"
FLAMINGO="\e[38;2;242;205;205m"
RED="\e[38;2;243;139;168m"
MAROON="\e[38;2;235;160;172m"
GREEN="\e[38;2;166;227;161m"
NC="\e[0m"
#---------------------------------------
TIMER=5
echo -e "${MAROON}Rebooting System in $TIMER seconds..."
for ((i=TIMER; i>0; i--)); do 
    echo -ne "Rebooting in $i seconds...\r"
    sleep 1
done 

echo -e "\nRebooting Now!"
systemctl reboot