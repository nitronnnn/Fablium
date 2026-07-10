import QtQuick
import Quickshell
import Quickshell.Wayland
import ".."

PanelWindow {
    id: toast
    implicitWidth: 320
    implicitHeight: 64
    color: "transparent"
    visible: State.toastText.length > 0
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "fablium-shell"
    anchors { right: true; bottom: true }
    margins { right: 18; bottom: 18 }

    Surface {
        anchors.fill: parent
        opacity: State.toastVisible ? 1 : 0
        scale: State.toastVisible ? 1 : 0.93
        Row {
            anchors.fill: parent; anchors.margins: 14; spacing: 11
            Text { anchors.verticalCenter: parent.verticalCenter; text: "󰄬"; color: State.success; font.family: "Symbols Nerd Font Mono"; font.pixelSize: 19 }
            Text { anchors.verticalCenter: parent.verticalCenter; width: parent.width - 44; elide: Text.ElideRight; text: State.toastText; color: State.text; font.family: State.fontFamily; font.pixelSize: 12 }
        }
        Behavior on opacity { NumberAnimation { duration: 180 } }
        Behavior on scale { NumberAnimation { duration: 220; easing.type: Easing.OutBack } }
    }
}
