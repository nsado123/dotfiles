#!/bin/bash
#-----------
# send notification
action=$(notify-send "System Setup Complete" "Reboot!" -u critical -a chezmoi -i /usr/share/icons/cachyos.svg --wait --action="reboot=Reboot Now" --action="Ignore")
# check if $action was triggered
case "$action" in 
    reboot)
        systemctl reboot
        ;;
    *)
        ;;
esac