#!/usr/bin/env bash
# Rofi power menu — ~/.config/rofi/power-menu.sh

if [[ -z "$1" ]]; then
    echo -e "󰐥 Выключить\n󰜉 Перезагрузить\n󰤄 Сон\n󰍃 Выйти\n󰌾 Заблокировать"
else
    case "$1" in
        *"Выключить") systemctl poweroff ;;
        *"Перезагрузить") systemctl reboot ;;
        *"Сон") systemctl suspend ;;
        *"Выйти") hyprctl dispatch exit ;;
        *"Заблокировать") hyprlock & ;;
    esac
fi
