import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io
import ".."
import "../components"

Item {
    id: root
    implicitWidth: 420
    implicitHeight: 650
    property string home: Quickshell.env("HOME")
    property string status: "Изменения применяются сразу"

    function run(proc, message) {
        proc.running = true
        status = message
    }

    Process { id: themeProc; command: [home + "/.config/hypr/scripts/theme.sh", State.accent]; onExited: code => { status = code === 0 ? "Тема применена" : "Не удалось применить тему"; if (code === 0) State.showToast(status) } }
    Process { id: styleProc; command: [home + "/.config/hypr/scripts/style.sh", State.styleName]; onExited: code => { status = code === 0 ? "Стиль применён" : "Ошибка стиля"; if (code === 0) State.showToast(status) } }
    Process { id: fontProc; command: [home + "/.config/hypr/scripts/font.sh", State.fontFamily]; onExited: code => { status = code === 0 ? "Шрифт применён без перезапуска" : "Ошибка шрифта"; if (code === 0) State.showToast(status) } }
    Process { id: wallProc; property string path: ""; command: [home + "/.config/hypr/scripts/wallpaper.sh", path]; onExited: code => status = code === 0 ? "Обои применены" : "Ошибка смены обоев" }
    Process {
        id: importProc
        command: [home + "/.config/hypr/scripts/wallpaper-import.sh"]
        stdout: SplitParser { onRead: data => { try { const result = JSON.parse(data); root.status = result.ok ? "Обои добавлены из буфера" : result.error } catch (_) { root.status = data } } }
        onExited: code => { if (code === 0) { wallpapers.folder = ""; wallpapers.folder = "file://" + home + "/Pictures/wallpapers"; State.showToast("Обои добавлены") } else root.status = "Не удалось импортировать буфер" }
    }
    Process { id: folderProc; command: ["xdg-open", home + "/Pictures/wallpapers"] }

    FolderListModel {
        id: wallpapers
        folder: "file://" + home + "/Pictures/wallpapers"
        nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.webp"]
        showDirs: false
        sortField: FolderListModel.Time
        sortReversed: true
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        RowLayout {
            Layout.fillWidth: true; Layout.margins: 20
            ColumnLayout {
                spacing: 2
                Text { text: "Настройки"; color: State.text; font.family: State.fontFamily; font.pixelSize: 22; font.weight: 700 }
                Text { text: root.status; color: State.muted; font.family: State.fontFamily; font.pixelSize: 11 }
            }
            Item { Layout.fillWidth: true }
            IconButton { icon: "󰅖"; tooltip: "Закрыть"; onClicked: State.close() }
        }

        ScrollView {
            id: scroll
            Layout.fillWidth: true; Layout.fillHeight: true
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            contentWidth: availableWidth

            ColumnLayout {
                width: scroll.availableWidth
                spacing: 14
                leftPadding: 20; rightPadding: 20; bottomPadding: 24

                Text { text: "ЦВЕТ И АТМОСФЕРА"; color: State.muted; font.family: State.fontFamily; font.pixelSize: 10; font.letterSpacing: 1.5 }
                GridLayout {
                    Layout.fillWidth: true; columns: 6; columnSpacing: 10
                    Repeater {
                        model: ["#7aa2f7", "#89b4fa", "#94e2d5", "#a6e3a1", "#f9e2af", "#f38ba8", "#fab387", "#cba6f7", "#74c7ec", "#eba0ac", "#b4befe", "#ffffff"]
                        Rectangle {
                            required property string modelData
                            width: 46; height: 46; radius: 15; color: modelData
                            border.width: State.accent.toString().toLowerCase() === modelData ? 3 : 1
                            border.color: State.accent.toString().toLowerCase() === modelData ? State.text : Qt.rgba(1,1,1,0.18)
                            scale: colorTap.pressed ? 0.86 : 1
                            TapHandler { id: colorTap; onTapped: { State.accent = modelData; root.run(themeProc, "Применяю тему…") } }
                            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                        }
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    TextField {
                        id: hexField; Layout.fillWidth: true; placeholderText: "#RRGGBB"; text: State.accent
                        color: State.text; font.family: State.fontFamily
                        background: Rectangle { color: State.surfaceHigh; radius: 12; border.color: hexField.activeFocus ? State.accent : "transparent" }
                        onAccepted: if (/^#[0-9a-fA-F]{6}$/.test(text)) { State.accent = text; root.run(themeProc, "Применяю свой цвет…") }
                    }
                    IconButton { icon: "󰈊"; label: "Пипетка"; onClicked: { pickerProc.running = true } }
                    Process { id: pickerProc; command: [home + "/.config/hypr/scripts/theme-picker.sh"] }
                }

                Text { text: "СТИЛЬ ПОВЕРХНОСТЕЙ"; color: State.muted; font.family: State.fontFamily; font.pixelSize: 10; font.letterSpacing: 1.5; Layout.topMargin: 10 }
                RowLayout {
                    Layout.fillWidth: true; spacing: 8
                    Repeater {
                        model: [{ key: "glass", title: "Glass", icon: "󰂖" }, { key: "minimal", title: "Minimal", icon: "󰝤" }, { key: "neon", title: "Neon", icon: "󰐾" }]
                        MenuCard { required property var modelData; Layout.fillWidth: true; title: modelData.title; subtitle: modelData.key === "glass" ? "мягкий blur" : modelData.key === "minimal" ? "чистый ритм" : "световой контур"; icon: modelData.icon; selected: State.styleName === modelData.key; onClicked: { State.styleName = modelData.key; root.run(styleProc, "Применяю " + modelData.title + "…") } }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true; Layout.topMargin: 10
                    Text { text: "ОБОИ"; color: State.muted; font.family: State.fontFamily; font.pixelSize: 10; font.letterSpacing: 1.5 }
                    Item { Layout.fillWidth: true }
                    IconButton { icon: "󰅧"; label: "Из буфера"; onClicked: root.run(importProc, "Импортирую буфер…") }
                    IconButton { icon: "󰉋"; tooltip: "Открыть папку"; onClicked: folderProc.running = true }
                }
                GridView {
                    Layout.fillWidth: true; Layout.preferredHeight: Math.min(236, Math.ceil(wallpapers.count / 3) * 94)
                    model: wallpapers; cellWidth: width / 3; cellHeight: 94; clip: true
                    delegate: Item {
                        required property string fileUrl; required property string filePath; required property string fileName
                        width: GridView.view.cellWidth; height: 94
                        Rectangle {
                            anchors.fill: parent; anchors.margins: 4; radius: 14; clip: true; color: State.surfaceHigh
                            Image { anchors.fill: parent; source: fileUrl; fillMode: Image.PreserveAspectCrop; asynchronous: true; cache: true }
                            Rectangle { anchors.fill: parent; color: imageHover.hovered ? "#26000000" : "transparent"; Behavior on color { ColorAnimation { duration: 150 } } }
                            HoverHandler { id: imageHover }
                            TapHandler { onTapped: { wallProc.path = filePath; root.run(wallProc, "Меняю обои…") } }
                        }
                    }
                }

                Text { text: "ШРИФТ ИНТЕРФЕЙСА"; color: State.muted; font.family: State.fontFamily; font.pixelSize: 10; font.letterSpacing: 1.5; Layout.topMargin: 10 }
                ColumnLayout {
                    Layout.fillWidth: true; spacing: 7
                    Repeater {
                        model: ["JetBrainsMono Nerd Font", "FiraCode Nerd Font", "Iosevka Nerd Font", "Hack Nerd Font", "CaskaydiaCove Nerd Font"]
                        MenuCard { required property string modelData; Layout.fillWidth: true; title: modelData.replace(" Nerd Font", ""); subtitle: "Aa Бб 0123 — быстрый просмотр"; icon: "󰛖"; selected: State.fontFamily === modelData; onClicked: { State.fontFamily = modelData; root.run(fontProc, "Применяю шрифт…") } }
                    }
                }
            }
        }
    }
}
