import QtQuick
import Quickshell
import Quickshell.Wayland
import ".."
import "../components"

PopupWindow {
    id: popup
    required property var hostWindow
    property int targetWidth: State.activeMenu === "launcher" ? 560 : State.activeMenu === "settings" ? 420 : State.activeMenu === "clipboard" ? 430 : State.activeMenu === "notifications" ? 390 : 380
    property int targetHeight: State.activeMenu === "settings" ? 650 : State.activeMenu === "notifications" ? 560 : State.activeMenu === "clipboard" ? 540 : State.activeMenu === "launcher" ? 520 : State.activeMenu === "control" ? 500 : 360

    anchor.window: hostWindow
    anchor.rect.x: Math.max(10, Math.min(hostWindow.width - targetWidth - 10, State.anchorX - targetWidth / 2))
    anchor.rect.y: hostWindow.height + 8
    width: targetWidth
    height: targetHeight
    color: "transparent"
    visible: State.activeMenu.length > 0 && State.anchorWindow === hostWindow
    dismissible: true
    onVisibleChanged: if (!visible && State.popupShown) State.close()

    Surface {
        id: surface
        anchors.fill: parent
        opacity: State.popupShown ? 1 : 0
        scale: State.popupShown ? 1 : 0.94
        transformOrigin: Item.TopRight

        Loader {
            anchors.fill: parent
            source: State.activeMenu === "settings" ? "SettingsView.qml"
                  : State.activeMenu === "control" ? "ControlCenter.qml"
                  : State.activeMenu === "notifications" ? "NotificationsView.qml"
                  : State.activeMenu === "clipboard" ? "ClipboardView.qml"
                  : State.activeMenu === "power" ? "PowerView.qml"
                  : State.activeMenu === "launcher" ? "../launcher/LauncherView.qml" : ""
        }

        Behavior on opacity { NumberAnimation { duration: State.popupShown ? 210 : 170; easing.type: Easing.OutCubic } }
        Behavior on scale { NumberAnimation { duration: State.popupShown ? 300 : 190; easing.type: State.popupShown ? Easing.OutBack : Easing.InCubic } }
    }
}
