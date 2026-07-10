import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import ".."
import "../components"

Item {
    id: root
    implicitWidth: 380
    implicitHeight: confirmAction.length ? 230 : 360
    property string confirmAction: ""
    property string confirmLabel: ""
    Process { id: powerProc; property var args: []; command: args }
    function ask(action, label) { confirmAction = action; confirmLabel = label }
    function execute() {
        const map = { lock: ["hyprlock"], logout: ["hyprctl", "dispatch", "exit"], suspend: ["systemctl", "suspend"], reboot: ["systemctl", "reboot"], poweroff: ["systemctl", "poweroff"] }
        powerProc.args = map[confirmAction]; powerProc.running = true; State.close()
    }

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 18; spacing: 10
        RowLayout { Layout.fillWidth: true; Text { text: confirmAction ? "Подтверждение" : "Сеанс и питание"; color: State.text; font.family: State.fontFamily; font.pixelSize: 21; font.weight: 700 } Item { Layout.fillWidth: true } IconButton { icon: "󰅖"; onClicked: State.close() } }
        ColumnLayout {
            visible: !confirmAction; Layout.fillWidth: true; spacing: 8
            MenuCard { Layout.fillWidth: true; title: "Заблокировать"; subtitle: "Сеанс останется активен"; icon: "󰌾"; onClicked: ask("lock", "заблокировать сеанс") }
            MenuCard { Layout.fillWidth: true; title: "Сон"; subtitle: "Быстро продолжить позже"; icon: "󰒲"; onClicked: ask("suspend", "перевести компьютер в сон") }
            MenuCard { Layout.fillWidth: true; title: "Выйти"; subtitle: "Завершить сеанс Hyprland"; icon: "󰍃"; onClicked: ask("logout", "выйти из сеанса") }
            MenuCard { Layout.fillWidth: true; title: "Перезагрузить"; subtitle: "Перезапустить систему"; icon: "󰜉"; onClicked: ask("reboot", "перезагрузить компьютер") }
            MenuCard { Layout.fillWidth: true; title: "Выключить"; subtitle: "Завершить работу"; icon: "󰐥"; onClicked: ask("poweroff", "выключить компьютер") }
        }
        ColumnLayout {
            visible: confirmAction.length > 0; Layout.fillWidth: true; spacing: 14
            Text { Layout.fillWidth: true; wrapMode: Text.Wrap; text: "Точно " + confirmLabel + "?"; color: State.text; font.family: State.fontFamily; font.pixelSize: 16 }
            RowLayout { Layout.fillWidth: true; IconButton { icon: "󰅖"; label: "Отмена"; onClicked: confirmAction = "" } Item { Layout.fillWidth: true } IconButton { icon: "󰐥"; label: "Подтвердить"; active: true; onClicked: root.execute() } }
        }
        Item { Layout.fillHeight: true }
    }
    Behavior on implicitHeight { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }
}
