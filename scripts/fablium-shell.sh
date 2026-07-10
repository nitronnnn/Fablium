#!/usr/bin/env bash
# Единая точка запуска и IPC Fablium Shell с безопасным Waybar fallback.
set -u
CONFIG_NAME="fablium"
LOG_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/fablium"
LOG="$LOG_DIR/shell.log"
mkdir -p "$LOG_DIR"

start_shell() {
    # Перегенерируем активный стиль при каждом старте. Это автоматически
    # исправляет старые style.conf с невалидным `windows ..., fade`.
    local style_file="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/.current-style"
    local style="glass"
    [[ -r "$style_file" ]] && read -r style < "$style_file"
    case "$style" in glass|minimal|neon) ;; *) style="glass" ;; esac
    "${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts/style.sh" "$style" >>"$LOG" 2>&1 || true

    if ! command -v quickshell >/dev/null 2>&1; then
        command -v waybar >/dev/null && pgrep -x waybar >/dev/null || waybar >>"$LOG" 2>&1 &
        printf 'Fablium: quickshell не установлен, запущен Waybar fallback\n' >> "$LOG"
        return 1
    fi
    pkill -x waybar 2>/dev/null || true
    quickshell -c "$CONFIG_NAME" >>"$LOG" 2>&1 &
}

ipc() {
    if ! quickshell ipc call fablium "$@" >>"$LOG" 2>&1; then
        start_shell
        sleep 1
        quickshell ipc call fablium "$@" >>"$LOG" 2>&1
    fi
}

case "${1:-start}" in
    start) start_shell ;;
    restart) quickshell kill -c "$CONFIG_NAME" 2>/dev/null || pkill -x quickshell 2>/dev/null || true; sleep 0.2; start_shell ;;
    stop) quickshell kill -c "$CONFIG_NAME" 2>/dev/null || pkill -x quickshell 2>/dev/null || true ;;
    toggle) ipc toggle "${2:-settings}" ;;
    close) ipc close ;;
    toast) ipc toast "${2:-Готово}" ;;
    rollback) pkill -x quickshell 2>/dev/null || true; waybar >>"$LOG" 2>&1 & ;;
    *) echo "Использование: $0 start|restart|stop|toggle <menu>|close|toast <text>|rollback" >&2; exit 2 ;;
esac
