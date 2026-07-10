import QtQuick
import QtQuick.Layouts
import ".."
import "../components"
import "../services"

Item {
    implicitWidth: 390
    implicitHeight: 560
    ColumnLayout {
        anchors.fill: parent; anchors.margins: 18; spacing: 12
        RowLayout {
            Layout.fillWidth: true
            Column { Text { text: "Уведомления"; color: State.text; font.family: State.fontFamily; font.pixelSize: 21; font.weight: 700 } Text { text: Notifications.items.length + " в истории"; color: State.muted; font.family: State.fontFamily; font.pixelSize: 11 } }
            Item { Layout.fillWidth: true }
            IconButton { icon: "󰎟"; tooltip: "Очистить"; onClicked: Notifications.clear() }
            IconButton { icon: "󰅖"; onClicked: State.close() }
        }
        ListView {
            Layout.fillWidth: true; Layout.fillHeight: true; clip: true; spacing: 8
            model: Notifications.items
            delegate: Surface {
                required property var modelData
                width: ListView.view.width; height: Math.max(78, bodyText.implicitHeight + 52); elevated: false
                Row {
                    anchors.fill: parent; anchors.margins: 13; spacing: 12
                    Rectangle { width: 42; height: 42; radius: 13; color: Qt.rgba(State.accent.r, State.accent.g, State.accent.b, 0.17); Text { anchors.centerIn: parent; text: "󰂚"; color: State.accent; font.family: "Symbols Nerd Font Mono"; font.pixelSize: 18 } }
                    Column { width: parent.width - 98; spacing: 4; Text { width: parent.width; elide: Text.ElideRight; text: modelData.summary || modelData.appName; color: State.text; font.family: State.fontFamily; font.pixelSize: 13; font.weight: 600 } Text { id: bodyText; width: parent.width; wrapMode: Text.Wrap; maximumLineCount: 3; elide: Text.ElideRight; text: modelData.body || ""; color: State.muted; font.family: State.fontFamily; font.pixelSize: 11 } }
                    IconButton { icon: "󰅖"; onClicked: Notifications.dismiss(modelData) }
                }
            }
            Text { anchors.centerIn: parent; visible: Notifications.items.length === 0; text: State.dnd ? "Режим «Не беспокоить» включён" : "Здесь пока тихо"; color: State.muted; font.family: State.fontFamily }
        }
    }
}
