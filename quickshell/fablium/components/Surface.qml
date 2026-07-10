import QtQuick
import QtQuick.Effects
import ".."

Rectangle {
    id: root
    property bool elevated: true
    property bool interactive: false

    color: State.styleName === "minimal" ? State.background : Qt.rgba(State.surface.r, State.surface.g, State.surface.b, State.styleName === "neon" ? 0.93 : 0.84)
    radius: State.radius
    border.width: State.styleName === "minimal" ? 1 : 1
    border.color: State.styleName === "neon" ? State.accent : Qt.rgba(State.text.r, State.text.g, State.text.b, 0.10)

    layer.enabled: elevated
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: State.styleName === "neon" ? Qt.rgba(State.accent.r, State.accent.g, State.accent.b, 0.35) : "#99000000"
        shadowBlur: State.styleName === "minimal" ? 0.35 : 0.75
        shadowVerticalOffset: 8
    }

    Behavior on color { ColorAnimation { duration: 220 } }
    Behavior on border.color { ColorAnimation { duration: 220 } }
    Behavior on radius { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }
}
