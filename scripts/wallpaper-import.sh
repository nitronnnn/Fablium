#!/usr/bin/env bash
# Импорт обоев из Wayland clipboard: image, локальный путь или https URL.
set -euo pipefail

DIR="${WALLPAPER_DIR:-$HOME/Pictures/wallpapers}"
MAX_BYTES=$((25 * 1024 * 1024))
mkdir -p "$DIR"

fail() { printf '{"ok":false,"error":"%s"}\n' "$1" >&2; exit 1; }
unique_path() { printf '%s/fablium-%(%Y%m%d-%H%M%S)T-%s.%s' "$DIR" -1 "$RANDOM" "$1"; }

# Сначала пробуем бинарное изображение. wl-paste --list-types безопаснее,
# чем гадать формат и не сохраняет произвольные данные как картинку.
types="$(wl-paste --list-types 2>/dev/null || true)"
for mime_ext in 'image/png png' 'image/jpeg jpg' 'image/webp webp'; do
    read -r mime ext <<< "$mime_ext"
    if grep -Fxq "$mime" <<< "$types"; then
        out="$(unique_path "$ext")"
        wl-paste --type "$mime" > "$out"
        [[ -s "$out" ]] || { rm -f "$out"; fail "Буфер изображения пуст"; }
        printf '{"ok":true,"path":"%s"}\n' "$out"
        exit 0
    fi
done

text="$(wl-paste --no-newline 2>/dev/null || true)"
[[ -n "$text" ]] || fail "В буфере нет изображения или пути"

if [[ "$text" == file://* ]]; then
    text="${text#file://}"
fi

if [[ -f "$text" ]]; then
    case "${text,,}" in *.png) ext=png;; *.jpg|*.jpeg) ext=jpg;; *.webp) ext=webp;; *) fail "Файл не является PNG/JPEG/WebP";; esac
    out="$(unique_path "$ext")"
    cp -- "$text" "$out"
    printf '{"ok":true,"path":"%s"}\n' "$out"
    exit 0
fi

if [[ "$text" =~ ^https:// ]]; then
    command -v curl >/dev/null || fail "Для URL нужен curl"
    tmp="$(mktemp)"; trap 'rm -f "$tmp"' EXIT
    headers="$(curl --fail --location --silent --show-error --max-time 20 --max-filesize "$MAX_BYTES" --proto '=https' --proto-redir '=https' -D - -o "$tmp" "$text")" || fail "Не удалось загрузить URL"
    mime="$(awk -F': *' 'tolower($1)=="content-type" {print tolower($2)}' <<< "$headers" | tail -1 | tr -d '\r' | cut -d';' -f1)"
    case "$mime" in image/png) ext=png;; image/jpeg) ext=jpg;; image/webp) ext=webp;; *) fail "URL вернул неподдерживаемый тип: $mime";; esac
    size="$(stat -c %s "$tmp")"; (( size <= MAX_BYTES )) || fail "Файл больше 25 МБ"
    out="$(unique_path "$ext")"; mv "$tmp" "$out"; trap - EXIT
    printf '{"ok":true,"path":"%s"}\n' "$out"
    exit 0
fi

fail "Буфер должен содержать изображение, локальный путь или HTTPS URL"
