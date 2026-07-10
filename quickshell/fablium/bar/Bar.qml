import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import ".."
import "../components"
import "../popouts"

PanelWindow {
    id: bar
    required property var modelData
    screen: modelData
    implicitHeight: 54
    color: "transparent"
    exclusionMode: ExclusionMode.Auto
    WlrLayershell.namespace: "fablium-shell"
    anchors { top: true; left: true; right: true }

    function pop(menu, item) { State.toggle(menu, bar, item.x + item.width / 2) }
    Component.onCompleted: if (!State.anchorWindow) { State.anchorWindow = bar; State.anchorX = bar.width - 220 }
    Process { id: hyprDispatch; property string workspace: "1"; command: ["hyprctl", "dispatch", "workspace", workspace] }

    Surface {
        anchors.fill: parent
        anchors.leftMargin: 10; anchors.rightMargin: 10; anchors.topMargin: 8; anchors.bottomMargin: 2
        radius: State.styleName === "minimal" ? 10 : 16

        RowLayout {
            anchors.fill: parent; anchors.leftMargin: 8; anchors.rightMargin: 8; spacing: 6

            IconButton { id: launcher; icon: "󰣇"; tooltip: "Приложения"; active: State.activeMenu === "launcher"; onClicked: bar.pop("launcher", launcher) }

            Row {
                spacing: 3
                Repeater {
                    model: 5
                    Rectangle {
                        required property int index
                        width: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === index + 1 ? 26 : 9
                        height: 9; radius: 5
                        color: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === index + 1 ? State.accent : State.surfaceHigh
                        anchors.verticalCenter: parent.verticalCenter
                        TapHandler { onTapped: { hyprDispatch.workspace = String(index + 1); hyprDispatch.running = true } }
                        Behavior on width { NumberAnimation { duration: 240; easing.type: Easing.OutBack } }
                        Behavior on color { ColorAnimation { duration: 180 } }
                    }
                }
            }

            Text {
                Layout.leftMargin: 8; Layout.maximumWidth: 270; Layout.fillWidth: true
                text: Hyprland.activeToplevel ? Hyprland.activeToplevel.title : "Рабочий стол"
                elide: Text.ElideRight; color: State.muted; font.family: State.fontFamily; font.pixelSize: 12
            }

            IconButton { id: clipboard; icon: "󰅍"; tooltip: "Буфер обмена"; active: State.activeMenu === "clipboard"; onClicked: bar.pop("clipboard", clipboard) }
            IconButton { id: notifications; icon: State.dnd ? "󰂛" : "󰂚"; tooltip: "Уведомления"; active: State.activeMenu === "notifications"; onClicked: bar.pop("notifications", notifications) }
            IconButton { id: control; icon: "󰒓"; tooltip: "Центр управления"; active: State.activeMenu === "control"; onClicked: bar.pop("control", control) }
            IconButton {
                id: clock; icon: "󰥔"; label: Qt.formatDateTime(clockTimer.now, "HH:mm"); tooltip: Qt.formatDateTime(clockTimer.now, "dddd, d MMMM")
                active: State.activeMenu === "settings"; onClicked: bar.pop("settings", clock)
                property date now: new Date()
                Timer { id: clockTimer; property date now: new Date(); interval: 1000; running: true; repeat: true; onTriggered: now = new Date() }
            }
            IconButton { id: power; icon: "󰐥"; tooltip: "Питание"; active: State.activeMenu === "power"; onClicked: bar.pop("power", power) }
        }
    }

    PopoutHost { hostWindow: bar }
}
