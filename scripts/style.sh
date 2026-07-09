#!/usr/bin/env bash
# ─────────────────────────────────────────────
#  style.sh — переключатель визуального стиля
#  Использование: style.sh glass|minimal|neon
#  Меняет: Hyprland, Waybar, Rofi, Kitty, Dunst
# ─────────────────────────────────────────────
set -euo pipefail

STYLE="${1:-}"
case "$STYLE" in
    glass|minimal|neon) ;;
    *)
        echo "Использование: $0 glass|minimal|neon" >&2
        exit 1
        ;;
esac

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
DOTFILES="$(dirname "$SCRIPT_DIR")"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
STATE_FILE="$CONFIG/hypr/.current-style"

# ── Hyprland ─────────────────────────────────
cp "$DOTFILES/hypr/styles/$STYLE.conf" "$CONFIG/hypr/style.conf"

# ── Waybar ───────────────────────────────────
cp "$DOTFILES/waybar/modes/$STYLE.css" "$CONFIG/waybar/mode.css"

# ── Rofi ─────────────────────────────────────
cp "$DOTFILES/rofi/styles/$STYLE.rasi" "$CONFIG/rofi/style.rasi"

# ── Kitty ────────────────────────────────────
cp "$DOTFILES/kitty/styles/$STYLE.conf" "$CONFIG/kitty/style.conf"

# ── Dunst ────────────────────────────────────
mkdir -p "$CONFIG/dunst/dunstrc.d"
cp "$DOTFILES/dunst/styles/$STYLE.conf" "$CONFIG/dunst/dunstrc.d/50-style.conf"

echo "$STYLE" > "$STATE_FILE"

# ── Перезагрузка компонентов ─────────────────
command -v hyprctl >/dev/null && hyprctl reload >/dev/null 2>&1 || true
pkill -SIGUSR2 waybar 2>/dev/null || true
pkill dunst 2>/dev/null && { dunst & disown; } 2>/dev/null || true

# Живая смена прозрачности kitty
OPACITY="$(grep -oP '^background_opacity \K[0-9.]+' "$CONFIG/kitty/style.conf" || echo 1.0)"
command -v kitty >/dev/null && kitty @ --to unix:/tmp/kitty set-background-opacity -a "$OPACITY" 2>/dev/null || true

notify-send "Стиль применён" "Режим: $STYLE" -i preferences-desktop-theme 2>/dev/null || true
echo "Стиль применён: $STYLE"
