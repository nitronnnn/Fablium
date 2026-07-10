import QtQuick
import QtQuick.Controls
import ".."

Rectangle {
    id: root
    property string icon: ""
    property string label: ""
    property bool active: false
    property string tooltip: label
    signal clicked

    implicitWidth: label.length > 0 ? content.implicitWidth + 24 : 38
    implicitHeight: 36
    radius: 12
    color: active ? Qt.rgba(State.accent.r, State.accent.g, State.accent.b, 0.20)
                  : hover.hovered ? Qt.rgba(State.text.r, State.text.g, State.text.b, 0.09) : "transparent"
    border.width: active ? 1 : 0
    border.color: Qt.rgba(State.accent.r, State.accent.g, State.accent.b, 0.52)
    scale: tap.pressed ? 0.92 : 1

    Row {
        id: content
        anchors.centerIn: parent
        spacing: 7
        Text { text: root.icon; color: root.active ? State.accent : State.text; font.family: "Symbols Nerd Font Mono"; font.pixelSize: 17 }
        Text { visible: root.label.length > 0; text: root.label; color: State.text; font.family: State.fontFamily; font.pixelSize: 13; font.weight: 600 }
    }

    HoverHandler { id: hover }
    TapHandler { id: tap; onTapped: root.clicked() }
    ToolTip { visible: hover.hovered && root.tooltip.length > 0; text: root.tooltip; delay: 650 }

    Behavior on color { ColorAnimation { duration: 160 } }
    Behavior on scale { NumberAnimation { duration: 130; easing.type: Easing.OutBack } }
}
