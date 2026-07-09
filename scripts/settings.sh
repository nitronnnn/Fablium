#!/usr/bin/env bash
# ─────────────────────────────────────────────
#  settings.sh — открыть/закрыть панель настроек (eww)
#  Использование: settings.sh [toggle|open|close|debug]
# ─────────────────────────────────────────────
set -uo pipefail

CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
EWW_DIR="$CONFIG/eww"
LOG="/tmp/eww-settings.log"
ACTION="${1:-toggle}"

eww_cmd() { eww -c "$EWW_DIR" "$@"; }

fail() {
    echo "[settings.sh] $1" | tee -a "$LOG" >&2
    notify-send "Настройки" "$1 (лог: $LOG)" -i dialog-error 2>/dev/null || true
    exit 1
}

# 1) eww вообще установлен?
if ! command -v eww >/dev/null 2>&1; then
    fail "eww не установлен. Поставь: yay -S eww  (или paru -S eww)"
fi

# 2) Демон запущен? Если нет — стартуем и проверяем, что конфиг грузится.
if ! eww_cmd ping >/dev/null 2>&1; then
    echo "[settings.sh] $(date) запуск демона eww" >> "$LOG"
    # Запускаем демон и ЛОВИМ ошибки конфига (yuck/scss) в лог.
    eww_cmd daemon >>"$LOG" 2>&1 || true
    sleep 0.5
    if ! eww_cmd ping >/dev/null 2>&1; then
        fail "Демон eww не поднялся — вероятно ошибка в конфиге. Смотри $LOG"
    fi
fi

is_open() {
    [[ "$(eww_cmd get settings_open 2>/dev/null || echo false)" == "true" ]]
}

open_panel() {
    # eww open сам поднимет окно; ошибки пишем в лог, не прячем.
    if ! eww_cmd open settings >>"$LOG" 2>&1; then
        # окно уже открыто — это не ошибка
        eww_cmd list-windows 2>/dev/null | grep -q '\*settings' || \
            fail "Не удалось открыть окно settings. Смотри $LOG"
    fi
    sleep 0.03
    eww_cmd update settings_open=true
}

close_panel() {
    eww_cmd update settings_open=false
    sleep 0.34   # ждём анимацию revealer перед закрытием окна
    eww_cmd close settings >>"$LOG" 2>&1 || true
}

case "$ACTION" in
    open)  open_panel ;;
    close) close_panel ;;
    toggle)
        if is_open; then close_panel; else open_panel; fi
        ;;
    debug)
        echo "eww:      $(command -v eww || echo 'НЕ НАЙДЕН')"
        echo "config:   $EWW_DIR"
        echo "--- eww reload (ошибки конфига) ---"
        eww_cmd reload 2>&1 || true
        echo "--- windows ---"
        eww_cmd list-windows 2>&1 || true
        echo "--- лог ---"
        tail -n 20 "$LOG" 2>/dev/null || echo "(лог пуст)"
        ;;
    *) echo "Использование: $0 [toggle|open|close|debug]" >&2; exit 1 ;;
esac
