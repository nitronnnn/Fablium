import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.DesktopEntries
import ".."
import "../components"

Item {
    id: root
    implicitWidth: 560
    implicitHeight: 520
    property string query: search.text.toLowerCase()
    property var apps: DesktopEntries.applications.values.filter(app => !query || app.name.toLowerCase().includes(query) || (app.genericName || "").toLowerCase().includes(query)).slice(0, 60)

    Component.onCompleted: search.forceActiveFocus()

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 18; spacing: 12
        RowLayout {
            Layout.fillWidth: true
            TextField {
                id: search; Layout.fillWidth: true; placeholderText: "Приложения, команды и действия…"
                color: State.text; font.family: State.fontFamily; font.pixelSize: 16
                Keys.onEscapePressed: State.close()
                background: Rectangle { color: State.surfaceHigh; radius: 15; border.width: search.activeFocus ? 1 : 0; border.color: State.accent }
            }
            IconButton { icon: "󰅖"; onClicked: State.close() }
        }
        Text { text: query ? "РЕЗУЛЬТАТЫ" : "ПРИЛОЖЕНИЯ"; color: State.muted; font.family: State.fontFamily; font.pixelSize: 10; font.letterSpacing: 1.5 }
        GridView {
            Layout.fillWidth: true; Layout.fillHeight: true; clip: true
            model: root.apps; cellWidth: width / 2; cellHeight: 72
            delegate: Item {
                required property var modelData
                width: GridView.view.cellWidth; height: 72
                Rectangle {
                    anchors.fill: parent; anchors.margins: 4; radius: 14
                    color: hover.hovered ? Qt.rgba(State.accent.r, State.accent.g, State.accent.b, 0.15) : Qt.rgba(State.surfaceHigh.r, State.surfaceHigh.g, State.surfaceHigh.b, 0.48)
                    Row {
                        anchors.fill: parent; anchors.margins: 12; spacing: 12
                        IconImage { anchors.verticalCenter: parent.verticalCenter; implicitSize: 38; source: modelData.icon }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter; width: parent.width - 56
                            Text { width: parent.width; elide: Text.ElideRight; text: modelData.name; color: State.text; font.family: State.fontFamily; font.pixelSize: 13; font.weight: 600 }
                            Text { width: parent.width; elide: Text.ElideRight; text: modelData.genericName || "Запустить"; color: State.muted; font.family: State.fontFamily; font.pixelSize: 10 }
                        }
                    }
                    HoverHandler { id: hover }
                    TapHandler { onTapped: { modelData.execute(); State.close() } }
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
            }
        }
    }
}
