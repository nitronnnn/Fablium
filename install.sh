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
    hyprland hyprpaper hyprlock hypridle hyprpicker
    waybar rofi-wayland kitty dunst
    grim slurp wl-clipboard cliphist
    brightnessctl playerctl pavucontrol
    network-manager-applet polkit-kde-agent
    ttf-jetbrains-mono-nerd
    yazi
)

install_packages() {
    echo "==> Установка пакетов через pacman..."
    sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}"
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
    link "$DOTFILES/scripts" "$CONFIG/hypr/scripts" 2>/dev/null || true

    chmod +x "$DOTFILES/scripts/"*.sh "$DOTFILES/rofi/power-menu.sh"
}

apply_default_theme() {
    echo "==> Генерация темы по умолчанию (#7aa2f7)..."
    "$DOTFILES/scripts/theme.sh" "#7aa2f7" || true
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
echo "  SUPER+T        — меню выбора темы"
echo "  SUPER+SHIFT+T  — пипетка: выбери цвет из спектра на экране"
