#!/usr/bin/env bash
# ─────────────────────────────────────────────
#  theme-picker.sh — выбор цвета из спектра пипеткой
#  Хоткей: SUPER+SHIFT+T
#  Кликни в любую точку экрана (например, на обои
#  или открытую картинку со спектром) — тема
#  сгенерируется из этого цвета.
# ─────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v hyprpicker >/dev/null; then
    notify-send "Ошибка" "Установи hyprpicker: pacman -S hyprpicker" 2>/dev/null || true
    exit 1
fi

COLOR="$(hyprpicker --format=hex --no-fancy)" || exit 0
[[ -z "$COLOR" ]] && exit 0

exec "$SCRIPT_DIR/theme.sh" "$COLOR"
