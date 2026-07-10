import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import ".."
import "../components"

Item {
    implicitWidth: 380
    implicitHeight: 500
    Process { id: command; property var next: []; command: next }
    function run(args) { command.next = args; command.running = true }

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 20; spacing: 14
        RowLayout { Layout.fillWidth: true; Text { text: "Центр управления"; color: State.text; font.family: State.fontFamily; font.pixelSize: 21; font.weight: 700 } Item { Layout.fillWidth: true } IconButton { icon: "󰅖"; onClicked: State.close() } }
        GridLayout {
            Layout.fillWidth: true; columns: 2; columnSpacing: 9; rowSpacing: 9
            MenuCard { Layout.fillWidth: true; title: "Wi-Fi"; subtitle: "Управление сетями"; icon: "󰖩"; onClicked: run(["nm-connection-editor"]) }
            MenuCard { Layout.fillWidth: true; title: "Bluetooth"; subtitle: "Устройства"; icon: "󰂯"; onClicked: run(["blueman-manager"]) }
            MenuCard { Layout.fillWidth: true; title: "Не беспокоить"; subtitle: State.dnd ? "Включено" : "Выключено"; icon: State.dnd ? "󰂛" : "󰂚"; selected: State.dnd; onClicked: State.dnd = !State.dnd }
            MenuCard { Layout.fillWidth: true; title: "Скриншот"; subtitle: "Выбрать область"; icon: "󰹑"; onClicked: { run(["bash", "-lc", "grim -g \"$(slurp)\" - | wl-copy"]); State.close() } }
        }

        Text { text: "ЗВУК"; color: State.muted; font.family: State.fontFamily; font.pixelSize: 10; font.letterSpacing: 1.5 }
        RowLayout { Layout.fillWidth: true; IconButton { icon: "󰕾"; onClicked: run(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]) } Slider { id: volume; Layout.fillWidth: true; from: 0; to: 1.4; value: 0.55; onMoved: run(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", value.toFixed(2)]) } Text { text: Math.round(volume.value * 100) + "%"; color: State.muted; font.family: State.fontFamily } }
        Text { text: "ЯРКОСТЬ"; color: State.muted; font.family: State.fontFamily; font.pixelSize: 10; font.letterSpacing: 1.5 }
        RowLayout { Layout.fillWidth: true; IconButton { icon: "󰃠" } Slider { id: brightness; Layout.fillWidth: true; from: 1; to: 100; value: 65; onMoved: run(["brightnessctl", "set", Math.round(value) + "%"]) } Text { text: Math.round(brightness.value) + "%"; color: State.muted; font.family: State.fontFamily } }

        Surface {
            Layout.fillWidth: true; Layout.preferredHeight: 110; elevated: false
            Row { anchors.fill: parent; anchors.margins: 16; spacing: 14
                Rectangle { width: 78; height: 78; radius: 15; color: State.surfaceHigh; Text { anchors.centerIn: parent; text: "󰎆"; color: State.accent; font.family: "Symbols Nerd Font Mono"; font.pixelSize: 28 } }
                Column { anchors.verticalCenter: parent.verticalCenter; spacing: 6; Text { text: "Медиа"; color: State.text; font.family: State.fontFamily; font.pixelSize: 15; font.weight: 600 } Text { text: "playerctl compatible"; color: State.muted; font.family: State.fontFamily; font.pixelSize: 11 } Row { spacing: 8; IconButton { icon: "󰒮"; onClicked: run(["playerctl", "previous"]) } IconButton { icon: "󰐎"; onClicked: run(["playerctl", "play-pause"]) } IconButton { icon: "󰒭"; onClicked: run(["playerctl", "next"]) } } }
            }
        }
        Item { Layout.fillHeight: true }
    }
}
