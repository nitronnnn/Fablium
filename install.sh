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
    waybar rofi-wayland kitty dunst swww
    grim slurp wl-clipboard cliphist
    brightnessctl playerctl pavucontrol
    network-manager-applet polkit-kde-agent
    ttf-jetbrains-mono-nerd ttf-firacode-nerd
    ttf-iosevka-nerd ttf-hack-nerd ttf-cascadia-code-nerd
    yazi
)

# Пакеты из AUR (нужен yay или paru)
AUR_PKGS=(
    eww
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
        echo "   Панель настроек требует eww — установи вручную:"
        echo "     yay -S eww"
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
    link "$DOTFILES/dunst"   "$CONFIG/dunst"
    link "$DOTFILES/eww"     "$CONFIG/eww"
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
echo "Готово! Перелогинься в Hyprland."
echo "  SUPER+T        — панель настроек (тема / стиль / обои / шрифт)"
echo "  SUPER+SHIFT+T  — пипетка: выбери цвет из спектра на экране"
echo "  Клик по 󰒓 в Waybar — открыть/закрыть панель настроек"
echo
echo "Положи картинки в ~/Pictures/wallpapers, чтобы выбирать обои в панели."
