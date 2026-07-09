#!/usr/bin/env bash
# ─────────────────────────────────────────────
#  settings.sh — открыть/закрыть панель настроек (eww)
#  Использование: settings.sh [toggle|open|close]
# ─────────────────────────────────────────────
set -euo pipefail

CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
EWW_DIR="$CONFIG/eww"
EWW="eww -c $EWW_DIR"
ACTION="${1:-toggle}"

# Демон eww должен быть запущен
if ! $EWW ping >/dev/null 2>&1; then
    $EWW daemon >/dev/null 2>&1 || true
    sleep 0.3
fi

is_open() {
    [[ "$($EWW get settings_open 2>/dev/null || echo false)" == "true" ]]
}

open_panel() {
    $EWW open settings >/dev/null 2>&1 || true
    # маленькая задержка, чтобы окно успело смапиться до анимации revealer
    sleep 0.02
    $EWW update settings_open=true
}

close_panel() {
    $EWW update settings_open=false
    sleep 0.34   # ждём анимацию revealer перед закрытием окна
    $EWW close settings >/dev/null 2>&1 || true
}

case "$ACTION" in
    open)  open_panel ;;
    close) close_panel ;;
    toggle)
        if is_open; then close_panel; else open_panel; fi
        ;;
    *) echo "Использование: $0 [toggle|open|close]" >&2; exit 1 ;;
esac
