#!/usr/bin/env bash
# ─────────────────────────────────────────────
#  theme-menu.sh — меню выбора темы через rofi
#  Хоткей: SUPER+T
#  Пресеты + ввод своего hex + пипетка спектра
# ─────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

declare -A PRESETS=(
    ["Синий (Tokyo)"]="#7aa2f7"
    ["Лавандовый (Catppuccin)"]="#b4befe"
    ["Зелёный (Gruvbox)"]="#b8bb26"
    ["Голубой (Nord)"]="#88c0d0"
    ["Розовый (Dracula)"]="#ff79c6"
    ["Оранжевый"]="#fab387"
    ["Красный"]="#f38ba8"
    ["Бирюзовый"]="#94e2d5"
)

OPTIONS="Пипетка (выбрать из спектра)\nВвести свой hex"
for name in "${!PRESETS[@]}"; do
    OPTIONS+="\n$name  ${PRESETS[$name]}"
done

CHOICE="$(echo -e "$OPTIONS" | rofi -dmenu -p "Тема" -i)" || exit 0
[[ -z "$CHOICE" ]] && exit 0

case "$CHOICE" in
    "Пипетка"*)
        exec "$SCRIPT_DIR/theme-picker.sh"
        ;;
    "Ввести свой hex")
        HEX="$(rofi -dmenu -p "Hex цвет (#RRGGBB)")" || exit 0
        [[ -z "$HEX" ]] && exit 0
        exec "$SCRIPT_DIR/theme.sh" "$HEX"
        ;;
    *)
        # достаём hex из конца строки
        HEX="$(echo "$CHOICE" | grep -oE '#[0-9a-fA-F]{6}$')" || exit 0
        exec "$SCRIPT_DIR/theme.sh" "$HEX"
        ;;
esac
