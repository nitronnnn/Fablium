#!/usr/bin/env bash
# ─────────────────────────────────────────────
#  wallpaper.sh — сменить обои с плавным переходом
#  Использование: wallpaper.sh /путь/к/обоям.png
#  swww (с анимацией) при наличии, иначе hyprpaper.
# ─────────────────────────────────────────────
set -euo pipefail

CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
STATE_FILE="$CONFIG/hypr/.current-wallpaper"
WALL_DIR="${WALLPAPER_DIR:-$HOME/Pictures/wallpapers}"

WALL="${1:-}"

# Режим восстановления при автозапуске: берём сохранённые обои,
# иначе первый файл из папки обоев.
if [[ "$WALL" == "--restore" ]]; then
    if [[ -f "$STATE_FILE" ]] && [[ -f "$(cat "$STATE_FILE")" ]]; then
        WALL="$(cat "$STATE_FILE")"
    else
        WALL="$(find "$WALL_DIR" -maxdepth 1 -type f \
            \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) \
            2>/dev/null | sort | head -n1)"
    fi
fi

if [[ -z "$WALL" || ! -f "$WALL" ]]; then
    echo "Использование: $0 /путь/к/обоям | --restore" >&2
    exit 0
fi

if command -v swww >/dev/null; then
    # запустить демон swww, если ещё не запущен
    if ! swww query >/dev/null 2>&1; then
        swww-daemon >/dev/null 2>&1 &
        sleep 0.4
    fi
    swww img "$WALL" \
        --transition-type grow \
        --transition-pos center \
        --transition-fps 60 \
        --transition-duration 1.1 >/dev/null 2>&1 || true
elif command -v hyprctl >/dev/null; then
    hyprctl hyprpaper preload "$WALL" >/dev/null 2>&1 || true
    hyprctl hyprpaper wallpaper ",$WALL" >/dev/null 2>&1 || true
fi

printf '%s\n' "$WALL" > "$STATE_FILE"
printf '{"ok":true,"wallpaper":"%s"}\n' "$WALL"
