# Fablium — Hyprland shell, полностью созданный ИИ

Arch Linux + Hyprland 0.53+ + Quickshell. Весь репозиторий — QML-интерфейс, конфиги и скрипты — создаётся и поддерживается ИИ (v0 by Vercel) по задачам и реальным отчётам пользователя.

## Что это

Fablium заменяет связку Waybar + eww + Rofi + Dunst одним GPU-анимированным процессом **Quickshell**:

- bar на каждом мониторе, popout открывается только у нажатой кнопки;
- launcher, настройки, control center, уведомления, clipboard history и power menu;
- тема из любого hex-цвета, режимы glass/minimal/neon и пять Nerd Fonts;
- live-применение без закрытия настроек и без лишних `notify-send`;
- обои из папки или прямо из clipboard: изображение, локальный путь либо HTTPS URL;
- точная интерактивная область окна — невидимые оверлеи не блокируют рабочий стол;
- Waybar остаётся только безопасным fallback, если Quickshell отсутствует.

## Установка

```bash
git clone https://github.com/nitronnnn/Fablium.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

Нужны актуальные Arch Linux, Hyprland **0.53+**, `yay` или `paru`. Установщик ставит `quickshell`, создаёт `~/.config/quickshell/fablium`, сохраняет старые реальные конфиги в `~/.dotfiles-backup-*` и применяет безопасные дефолты.

После обновления:

```bash
cd ~/dotfiles && git pull
./install.sh
~/.config/hypr/scripts/fablium-shell.sh restart
```

## Меню и хоткеи

| Хоткей | Действие |
|---|---|
| `SUPER + D` | Launcher приложений |
| `SUPER + T` | Настройки: тема, стиль, обои, шрифт |
| `SUPER + C` | Control center |
| `SUPER + N` | Уведомления |
| `SUPER + SHIFT + V` | История буфера |
| `SUPER + SHIFT + P` | Lock / logout / sleep / reboot / shutdown |
| `SUPER + SHIFT + T` | Пипетка цвета |
| `SUPER + Enter` | Kitty |
| `SUPER + L` | Hyprlock |

Клик по кнопкам bar открывает меню пространственно из той же точки. Escape, кнопка закрытия или клик снаружи закрывает popout; окно проигрывает обратную анимацию и не забирает ввод у других приложений.

## Настройки

Настройки — одна непрерывная прокручиваемая поверхность:

- **Theme:** 12 пресетов, hex и `hyprpicker`;
- **Style:** glass, minimal, neon; валидные анимации Hyprland 0.53+;
- **Wallpaper:** responsive grid из `~/Pictures/wallpapers`, `swww` transition, кнопки «Из буфера» и «Открыть папку»;
- **Font:** JetBrainsMono, FiraCode, Iosevka, Hack, Cascadia; пиктограммы используют отдельный Symbols Nerd Font и не ломаются при смене текста.

Выбор остаётся в открытой панели. Результат показывается тихим внутренним toast вместо системного уведомления.

### Импорт обоев

Скопируй картинку, путь к PNG/JPEG/WebP или HTTPS URL и нажми **«Из буфера»**. `wallpaper-import.sh` проверяет MIME, разрешает только HTTPS, ограничивает файл 25 МБ и сохраняет уникальное имя в `~/Pictures/wallpapers`.

```bash
~/.config/hypr/scripts/wallpaper-import.sh
~/.config/hypr/scripts/wallpaper.sh ~/Pictures/wallpapers/example.webp
```

## Архитектура

| Путь | Назначение |
|---|---|
| `quickshell/fablium/shell.qml` | entrypoint, multi-monitor instances и IPC |
| `quickshell/fablium/bar/` | bar и workspace state |
| `quickshell/fablium/popouts/` | settings/control/notifications/clipboard/power |
| `quickshell/fablium/launcher/` | desktop-entry launcher |
| `quickshell/fablium/components/` | поверхности, карточки, кнопки, toast |
| `quickshell/fablium/services/` | notification server и общие сервисы |
| `hypr/styles/` | поддерживаемые glass/minimal/neon overrides |
| `scripts/` | детерминированные команды темы, стиля, шрифта и обоев |

Скрипты возвращают JSON и не перезапускают Quickshell. GUI меняет реактивное состояние сразу, а Hyprland/Kitty получают свои небольшие generated-файлы.

## Управление и диагностика

```bash
# restart / stop / rollback к Waybar
~/.config/hypr/scripts/fablium-shell.sh restart
~/.config/hypr/scripts/fablium-shell.sh stop
~/.config/hypr/scripts/fablium-shell.sh rollback

# полная проверка зависимостей, линков, шрифтов, IPC и configerrors
~/.config/hypr/scripts/fablium-doctor.sh

# лог shell
tail -f ~/.local/state/fablium/shell.log
```

Если Quickshell не установлен или не запускается, `fablium-shell.sh start` автоматически поднимает Waybar, поэтому свежая установка не оставляет систему без панели. Legacy-папки `waybar/`, `eww/`, `rofi/`, `dunst/` сохранены для rollback, но в штатной сессии не запускаются.
