#!/usr/bin/env bash
# ─────────────────────────────────────────────
#  theme.sh — генератор палитры из одного цвета
#  Использование: theme.sh "#7aa2f7"
#  Генерирует цвета для: Hyprland, Waybar, Rofi, Kitty, Dunst
# ─────────────────────────────────────────────
set -euo pipefail

ACCENT="${1:-}"
if [[ -z "$ACCENT" ]]; then
    echo "Использование: $0 '#RRGGBB'" >&2
    exit 1
fi

ACCENT="${ACCENT#\#}"
if ! [[ "$ACCENT" =~ ^[0-9a-fA-F]{6}$ ]]; then
    echo "Ошибка: цвет должен быть в формате #RRGGBB" >&2
    exit 1
fi

CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
STATE_FILE="$CONFIG/hypr/.current-theme"

# ── Утилиты работы с цветом ──────────────────
hex_to_rgb() { # $1=hex -> "r g b"
    printf "%d %d %d" "0x${1:0:2}" "0x${1:2:2}" "0x${1:4:2}"
}

rgb_to_hex() { # $1=r $2=g $3=b
    printf "%02x%02x%02x" "$1" "$2" "$3"
}

clamp() {
    local v=$1
    (( v < 0 )) && v=0
    (( v > 255 )) && v=255
    echo "$v"
}

mix() { # смешать цвет $1 с цветом $2 в пропорции $3 (0-100, % второго)
    read -r r1 g1 b1 <<< "$(hex_to_rgb "$1")"
    read -r r2 g2 b2 <<< "$(hex_to_rgb "$2")"
    local p=$3
    local r=$(( (r1 * (100 - p) + r2 * p) / 100 ))
    local g=$(( (g1 * (100 - p) + g2 * p) / 100 ))
    local b=$(( (b1 * (100 - p) + b2 * p) / 100 ))
    rgb_to_hex "$(clamp $r)" "$(clamp $g)" "$(clamp $b)"
}

rotate_hue() { # грубый сдвиг оттенка: r->g->b->r
    read -r r g b <<< "$(hex_to_rgb "$1")"
    rgb_to_hex "$b" "$r" "$g"
}

# ── Палитра ──────────────────────────────────
BLACK="000000"; WHITE="ffffff"

BG=$(mix "$ACCENT" "$BLACK" 92)         # почти чёрный фон с оттенком акцента
SURFACE0=$(mix "$ACCENT" "$BLACK" 86)
SURFACE1=$(mix "$ACCENT" "$BLACK" 78)
SURFACE2=$(mix "$ACCENT" "$BLACK" 68)
FG=$(mix "$ACCENT" "$WHITE" 88)         # почти белый текст с оттенком акцента
MUTED=$(mix "$ACCENT" "$WHITE" 45)
ACCENT2=$(rotate_hue "$ACCENT")         # второй акцент для градиентов
ACCENT_DIM=$(mix "$ACCENT" "$BLACK" 40)
RED="f38ba8"; GREEN="a6e3a1"; YELLOW="f9e2af"

mkdir -p "$CONFIG/hypr" "$CONFIG/waybar" "$CONFIG/rofi" "$CONFIG/kitty" "$CONFIG/dunst/dunstrc.d" "$CONFIG/eww"

# ── Hyprland ─────────────────────────────────
cat > "$CONFIG/hypr/colors.conf" <<EOF
# Сгенерировано theme.sh — не редактировать вручную
\$accent    = rgba(${ACCENT}ee)
\$accent2   = rgba(${ACCENT2}ee)
\$surface1  = rgba(${SURFACE1}aa)
\$bg        = rgba(${BG}ff)
\$fg        = rgba(${FG}ff)
EOF

# ── Waybar ───────────────────────────────────
cat > "$CONFIG/waybar/colors.css" <<EOF
/* Сгенерировано theme.sh */
@define-color bg #${BG};
@define-color surface0 #${SURFACE0};
@define-color surface1 #${SURFACE1};
@define-color surface2 #${SURFACE2};
@define-color fg #${FG};
@define-color muted #${MUTED};
@define-color accent #${ACCENT};
@define-color accent2 #${ACCENT2};
@define-color red #${RED};
@define-color green #${GREEN};
@define-color yellow #${YELLOW};
EOF

# ── Rofi ─────────────────────────────────────
cat > "$CONFIG/rofi/colors.rasi" <<EOF
/* Сгенерировано theme.sh */
* {
    bg:             #${BG};
    bg-trans:       #${BG}cc;
    surface0:       #${SURFACE0};
    surface0-trans: #${SURFACE0}99;
    surface1:       #${SURFACE1};
    fg:             #${FG};
    muted:          #${MUTED};
    accent:         #${ACCENT};
    accent2:        #${ACCENT2};
}
EOF

# ── Kitty ────────────────────────────────────
cat > "$CONFIG/kitty/colors.conf" <<EOF
# Сгенерировано theme.sh
foreground #${FG}
background #${BG}
cursor     #${ACCENT}
selection_background #${SURFACE2}
selection_foreground #${FG}

active_border_color   #${ACCENT}
inactive_border_color #${SURFACE1}

active_tab_background   #${ACCENT}
active_tab_foreground   #${BG}
inactive_tab_background #${SURFACE0}
inactive_tab_foreground #${MUTED}

color0  #${SURFACE0}
color8  #${SURFACE2}
color1  #${RED}
color9  #${RED}
color2  #${GREEN}
color10 #${GREEN}
color3  #${YELLOW}
color11 #${YELLOW}
color4  #${ACCENT}
color12 #${ACCENT}
color5  #${ACCENT2}
color13 #${ACCENT2}
color6  #$(mix "$ACCENT" "$WHITE" 30)
color14 #$(mix "$ACCENT" "$WHITE" 30)
color7  #${FG}
color15 #${WHITE}
EOF

# ── Dunst ────────────────────────────────────
cat > "$CONFIG/dunst/dunstrc.d/99-colors.conf" <<EOF
# Сгенерировано theme.sh
[global]
    frame_color = "#${ACCENT}"

[urgency_low]
    background = "#${BG}"
    foreground = "#${MUTED}"

[urgency_normal]
    background = "#${BG}"
    foreground = "#${FG}"

[urgency_critical]
    background = "#${BG}"
    foreground = "#${RED}"
    frame_color = "#${RED}"
EOF

# ── eww (панель настроек) ────────────────────
cat > "$CONFIG/eww/colors.scss" <<EOF
// Сгенерировано theme.sh
\$bg:       #${BG};
\$surface0: #${SURFACE0};
\$surface1: #${SURFACE1};
\$surface2: #${SURFACE2};
\$fg:       #${FG};
\$muted:    #${MUTED};
\$accent:   #${ACCENT};
\$accent2:  #${ACCENT2};
\$red:      #${RED};
\$green:    #${GREEN};
\$yellow:   #${YELLOW};
EOF

echo "$ACCENT" > "$STATE_FILE"

# Hyprland и Kitty применяются без перезапуска Fablium Shell.
command -v hyprctl >/dev/null && hyprctl reload >/dev/null 2>&1 || true
command -v kitty >/dev/null && kitty @ --to unix:/tmp/kitty set-colors -a "$CONFIG/kitty/colors.conf" 2>/dev/null || true

# Машиночитаемый ответ для Quickshell (никаких notify-send).
printf '{"ok":true,"accent":"#%s"}\n' "$ACCENT"
