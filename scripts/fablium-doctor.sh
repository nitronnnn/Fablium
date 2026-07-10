#!/usr/bin/env bash
# Быстрая диагностика Fablium Shell без изменения системы.
set -u
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
errors=0; warnings=0
ok() { printf '[ OK ] %s\n' "$1"; }
warn() { printf '[WARN] %s\n' "$1"; warnings=$((warnings + 1)); }
fail() { printf '[FAIL] %s\n' "$1"; errors=$((errors + 1)); }

printf 'Fablium Doctor\n===============\n'
for cmd in hyprland hyprctl quickshell swww wl-paste cliphist wpctl brightnessctl playerctl; do
    command -v "$cmd" >/dev/null 2>&1 && ok "$cmd найден" || { [[ "$cmd" == quickshell || "$cmd" == hyprland ]] && fail "$cmd не установлен" || warn "$cmd не установлен — соответствующий модуль недоступен"; }
done

[[ -e "$CONFIG/quickshell/fablium/shell.qml" ]] && ok "Quickshell config найден" || fail "$CONFIG/quickshell/fablium/shell.qml отсутствует"
[[ -x "$CONFIG/hypr/scripts/fablium-shell.sh" ]] && ok "shell controller исполняемый" || fail "fablium-shell.sh отсутствует или не исполняемый"
[[ -d "$HOME/Pictures/wallpapers" ]] && ok "папка обоев существует" || warn "нет ~/Pictures/wallpapers"

if command -v hyprctl >/dev/null 2>&1; then
    version="$(hyprctl version 2>/dev/null | head -1)"
    printf '[INFO] %s\n' "${version:-версия Hyprland неизвестна}"
    config_errors="$(hyprctl configerrors 2>/dev/null || true)"
    [[ -z "$config_errors" || "$config_errors" == "no errors" ]] && ok "Hyprland config без ошибок" || { fail "Hyprland configerrors:"; printf '%s\n' "$config_errors"; }
fi

if command -v quickshell >/dev/null 2>&1; then
    if quickshell ipc call fablium toast "Диагностика завершена" >/dev/null 2>&1; then
        ok "Fablium IPC отвечает"
    else
        warn "Fablium Shell не запущен; лог: ${XDG_STATE_HOME:-$HOME/.local/state}/fablium/shell.log"
    fi
fi

for font in "JetBrainsMono Nerd Font" "FiraCode Nerd Font" "Iosevka Nerd Font" "Hack Nerd Font" "CaskaydiaCove Nerd Font"; do
    fc-match "$font" 2>/dev/null | grep -qiE 'Nerd|JetBrains|Fira|Iosevka|Hack|Caskaydia' && ok "шрифт: $font" || warn "шрифт не найден: $font"
done

printf '\nИтог: %d ошибок, %d предупреждений.\n' "$errors" "$warnings"
(( errors == 0 ))
