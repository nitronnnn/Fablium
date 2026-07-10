#!/usr/bin/env bash
# ─────────────────────────────────────────────
#  font.sh — сменить шрифт во всех компонентах
#  Использование: font.sh "JetBrainsMono Nerd Font"
#  Генерирует подключаемые файлы для Waybar, Kitty,
#  Rofi, Dunst и eww, затем перезагружает их.
# ─────────────────────────────────────────────
set -euo pipefail

FONT="${1:-JetBrainsMono Nerd Font}"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
STATE_FILE="$CONFIG/hypr/.current-font"

mkdir -p "$CONFIG/waybar" "$CONFIG/kitty" "$CONFIG/rofi" \
         "$CONFIG/dunst/dunstrc.d" "$CONFIG/eww"

# ── Waybar ───────────────────────────────────
cat > "$CONFIG/waybar/font.css" <<EOF
/* Сгенерировано font.sh */
* { font-family: "$FONT", monospace; }
EOF

# ── Kitty ────────────────────────────────────
cat > "$CONFIG/kitty/font.conf" <<EOF
# Сгенерировано font.sh
font_family $FONT
EOF

# ── Rofi ─────────────────────────────────────
cat > "$CONFIG/rofi/font.rasi" <<EOF
/* Сгенерировано font.sh */
configuration { font: "$FONT 12"; }
EOF

# ── Dunst ────────────────────────────────────
cat > "$CONFIG/dunst/dunstrc.d/60-font.conf" <<EOF
# Сгенерировано font.sh
[global]
    font = $FONT 11
EOF

# ── eww ──────────────────────────────────────
cat > "$CONFIG/eww/font.scss" <<EOF
// Сгенерировано font.sh
\$font: "$FONT";
EOF

echo "$FONT" > "$STATE_FILE"

# Fablium Shell обновляет font.family реактивно и остаётся открытым.
# Kitty использует новый шрифт в следующих окнах; никаких reload/notify-send.
printf '{"ok":true,"font":"%s"}\n' "$FONT"
