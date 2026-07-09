#!/usr/bin/env bash
# ─────────────────────────────────────────────
#  style-menu.sh — меню выбора стиля через rofi
#  Хоткей: SUPER+S
# ─────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
CURRENT="$(cat "$CONFIG/hypr/.current-style" 2>/dev/null || echo glass)"

OPTIONS="  Стекло (glass) — блюр и полупрозрачность
  Минимализм (minimal) — плоско и быстро
  Неон (neon) — свечение и градиенты"

CHOICE="$(echo "$OPTIONS" | rofi -dmenu -p "Стиль [$CURRENT]" -i -no-custom)" || exit 0
[[ -z "$CHOICE" ]] && exit 0

case "$CHOICE" in
    *glass*)   exec "$SCRIPT_DIR/style.sh" glass ;;
    *minimal*) exec "$SCRIPT_DIR/style.sh" minimal ;;
    *neon*)    exec "$SCRIPT_DIR/style.sh" neon ;;
esac
