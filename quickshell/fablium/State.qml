pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    property string activeMenu: ""
    property bool popupShown: false
    property real anchorX: 0
    property var anchorWindow: null
    property string accent: "#7aa2f7"
    property string styleName: "glass"
    property string fontFamily: "JetBrainsMono Nerd Font"
    property string toastText: ""
    property bool toastVisible: false
    property bool dnd: false

    readonly property color background: mix(accent, "#05070b", 0.94)
    readonly property color surface: mix(accent, "#10141d", 0.84)
    readonly property color surfaceHigh: mix(accent, "#252b37", 0.72)
    readonly property color text: mix(accent, "#ffffff", 0.90)
    readonly property color muted: mix(accent, "#aab2c0", 0.58)
    readonly property color danger: "#f38ba8"
    readonly property color success: "#a6e3a1"
    readonly property real radius: styleName === "minimal" ? 10 : 18
    readonly property real motionScale: 1.0

    function mix(a, b, amount) {
        const ca = Qt.color(a), cb = Qt.color(b)
        return Qt.rgba(ca.r * (1 - amount) + cb.r * amount,
                       ca.g * (1 - amount) + cb.g * amount,
                       ca.b * (1 - amount) + cb.b * amount, 1)
    }

    function toggle(menu, window, x) {
        if (activeMenu === menu && popupShown) {
            close()
            return
        }
        anchorWindow = window
        anchorX = x
        activeMenu = menu
        popupShown = true
    }

    function open(menu) {
        activeMenu = menu
        popupShown = true
    }

    function close() {
        popupShown = false
        closeTimer.restart()
    }

    function showToast(text) {
        toastText = text
        toastVisible = true
        toastTimer.restart()
    }

    Timer {
        id: closeTimer
        interval: 260
        onTriggered: if (!root.popupShown) root.activeMenu = ""
    }

    Timer {
        id: toastTimer
        interval: 1800
        onTriggered: root.toastVisible = false
    }
}
