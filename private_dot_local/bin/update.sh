#!/bin/bash 
#-------------------------
ICON=$(awk -F= '/^ID=/{print $2}' /etc/os-release)
SUMMARY=$(topgrade --dry-run --no-retry --skip-notify --only system | awk '/Summary ――/{flag=1; next} /Pacman/{flag=0} flag')
#-------------------------
if ! command -v topgrade &>/dev/null; then
  if [ ! -f /tmp/topgrade_check.txt ]; then
    action=$(notify-send "Topgrade not installed" "would you like to install it?" -i $ICON -e -t 5000 --action="download=Install Now" --action="Dismiss")
    case "$action" in 
      download)
        if ! command -v paru &> /dev/null; then
          kitty --title install-paru sh -c "echoo 'Paru not found; Installing...'; sudo pacman -S --noconfirm paru"
        fi  
        paru -S --noconfirm topgrade
        ;;
      *)
        touch /tmp/topgrade_check.txt && exit 1
      ;;
    esac
  fi
else
  if grep -qi "System Update: OK" <<< "$SUMMARY"; then
    echo "no updates available..." && exit 1 
  else 
    action=$(notify-send "Updates Available" "$SUMMARY" -i $ICON -t 7500 --action="update=Update Now" --action="Dismiss")
    case "$action" in 
      update)
        kitty --title systemupdate sh -c "echo 'Starting updates...'; topgrade --skip-notify --only system; notify-send 'System Update Complete' -i $ICON -e -t 3500"
        ;;
      *)
        exit 1 
        ;;
    esac
  fi 
fi
echo "Update Complete..."



