import QtQuick
import ".."

Rectangle {
    id: root
    property string title: ""
    property string subtitle: ""
    property string icon: ""
    property bool selected: false
    signal clicked

    implicitHeight: 66
    radius: 14
    color: selected ? Qt.rgba(State.accent.r, State.accent.g, State.accent.b, 0.18)
                    : hover.hovered ? Qt.rgba(State.text.r, State.text.g, State.text.b, 0.075)
                    : Qt.rgba(State.surfaceHigh.r, State.surfaceHigh.g, State.surfaceHigh.b, 0.45)
    border.width: selected ? 1 : 0
    border.color: State.accent
    scale: tap.pressed ? 0.975 : 1

    Row {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12
        Text { anchors.verticalCenter: parent.verticalCenter; text: root.icon; color: selected ? State.accent : State.muted; font.family: "Symbols Nerd Font Mono"; font.pixelSize: 20 }
        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2
            Text { text: root.title; color: State.text; font.family: State.fontFamily; font.pixelSize: 14; font.weight: 600 }
            Text { text: root.subtitle; color: State.muted; font.family: State.fontFamily; font.pixelSize: 11 }
        }
    }
    HoverHandler { id: hover }
    TapHandler { id: tap; onTapped: root.clicked() }
    Behavior on color { ColorAnimation { duration: 180 } }
    Behavior on scale { NumberAnimation { duration: 120 } }
}
