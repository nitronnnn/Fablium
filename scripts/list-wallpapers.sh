#!/usr/bin/env bash
# ─────────────────────────────────────────────
#  list-wallpapers.sh — JSON-массив путей к обоям
#  для eww. Сканирует ~/Pictures/wallpapers.
# ─────────────────────────────────────────────
set -euo pipefail

DIR="${WALLPAPER_DIR:-$HOME/Pictures/wallpapers}"

if [[ ! -d "$DIR" ]]; then
    echo "[]"
    exit 0
fi

first=1
printf '['
while IFS= read -r -d '' f; do
    [[ $first -eq 1 ]] && first=0 || printf ','
    # экранируем обратные слэши и кавычки для валидного JSON
    esc=${f//\\/\\\\}
    esc=${esc//\"/\\\"}
    printf '"%s"' "$esc"
done < <(find "$DIR" -maxdepth 1 -type f \
        \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) \
        -print0 2>/dev/null | sort -z)
printf ']'
