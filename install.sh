#!/usr/bin/env bash
# ─────────────────────────────────────────────
#  install.sh — установка дотфайлов
#  Использование: ./install.sh
# ─────────────────────────────────────────────
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

# ── Пакеты ───────────────────────────────────
PACMAN_PKGS=(
    hyprland hyprlock hypridle hyprpicker
    waybar kitty swww
    grim slurp wl-clipboard cliphist curl
    brightnessctl playerctl pavucontrol
    network-manager-applet blueman polkit-kde-agent
    ttf-jetbrains-mono-nerd ttf-firacode-nerd
    ttf-iosevka-nerd ttf-hack-nerd ttf-cascadia-code-nerd
    yazi
)

# Quickshell в Arch/AUR (нужен yay или paru, если пакет не в репозитории)
AUR_PKGS=(
    quickshell
)

install_packages() {
    echo "==> Установка пакетов через pacman..."
    sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}"

    local helper=""
    command -v yay  >/dev/null && helper="yay"
    command -v paru >/dev/null && helper="paru"
    if [[ -n "$helper" ]]; then
        echo "==> Установка AUR-пакетов через $helper..."
        "$helper" -S --needed --noconfirm "${AUR_PKGS[@]}"
    else
        echo "!! AUR-хелпер (yay/paru) не найден."
        echo "   Fablium Shell требует Quickshell — установи вручную:"
        echo "     yay -S quickshell"
        echo "   До установки будет автоматически запускаться Waybar fallback."
    fi
}

# ── Симлинки ─────────────────────────────────
link() {
    local src="$1" dst="$2"
    if [[ -e "$dst" && ! -L "$dst" ]]; then
        mkdir -p "$BACKUP"
        echo "  бэкап: $dst -> $BACKUP/"
        mv "$dst" "$BACKUP/"
    fi
    mkdir -p "$(dirname "$dst")"
    ln -sfn "$src" "$dst"
    echo "  линк:  $dst -> $src"
}

install_configs() {
    echo "==> Создание симлинков..."
    link "$DOTFILES/hypr"    "$CONFIG/hypr"
    link "$DOTFILES/waybar"  "$CONFIG/waybar"
    link "$DOTFILES/rofi"    "$CONFIG/rofi"
    link "$DOTFILES/kitty"   "$CONFIG/kitty"
    # Legacy-конфиги оставляем для rollback, но больше не запускаем.
    link "$DOTFILES/dunst"   "$CONFIG/dunst"
    link "$DOTFILES/eww"     "$CONFIG/eww"
    link "$DOTFILES/quickshell/fablium" "$CONFIG/quickshell/fablium"
    link "$DOTFILES/scripts" "$CONFIG/hypr/scripts" 2>/dev/null || true

    chmod +x "$DOTFILES/scripts/"*.sh "$DOTFILES/rofi/power-menu.sh"

    # Папка обоев для панели настроек
    mkdir -p "$HOME/Pictures/wallpapers"
}

apply_default_theme() {
    echo "==> Генерация темы по умолчанию (#7aa2f7)..."
    "$DOTFILES/scripts/theme.sh" "#7aa2f7" || true
    echo "==> Применение стиля по умолчанию (glass)..."
    "$DOTFILES/scripts/style.sh" glass || true
    echo "==> Применение шрифта по умолчанию..."
    "$DOTFILES/scripts/font.sh" "JetBrainsMono Nerd Font" || true
}

# ── Запуск ───────────────────────────────────
echo "Дотфайлы Arch Linux + Hyprland"
echo "Директория: $DOTFILES"
echo

if command -v pacman >/dev/null; then
    read -rp "Установить пакеты? [Y/n] " ans
    [[ "${ans,,}" != "n" ]] && install_packages
else
    echo "!! pacman не найден — пропускаю установку пакетов"
fi

install_configs
apply_default_theme

echo
echo "Готово! Перелогинься в Hyprland или запусти:"
echo "  ~/.config/hypr/scripts/fablium-shell.sh restart"
echo "  SUPER+D        — launcher"
echo "  SUPER+T        — настройки"
echo "  SUPER+C / N    — control center / уведомления"
echo "  SUPER+SHIFT+V  — история буфера"
echo "  SUPER+SHIFT+P  — питание"
echo
echo "Диагностика: ~/.config/hypr/scripts/fablium-doctor.sh"
