import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import ".."
import "../components"

Item {
    id: root
    implicitWidth: 430
    implicitHeight: 540
    property var entries: []
    property string query: search.text.toLowerCase()
    property var filtered: entries.filter(item => !query || item.text.toLowerCase().includes(query))

    Process {
        id: loadProc; command: ["cliphist", "list"]
        stdout: SplitParser { onRead: line => { const tab = line.indexOf("\t"); if (tab > 0) root.entries = root.entries.concat([{ id: line.slice(0, tab), text: line.slice(tab + 1) }]) } }
    }
    Process { id: actionProc; property string idValue: ""; command: ["bash", "-lc", "cliphist decode " + idValue.replace(/[^0-9]/g, "") + " | wl-copy"] }
    Process { id: clearProc; command: ["cliphist", "wipe"] }
    Component.onCompleted: { entries = []; loadProc.running = true; search.forceActiveFocus() }

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 18; spacing: 11
        RowLayout {
            Layout.fillWidth: true
            TextField { id: search; Layout.fillWidth: true; placeholderText: "Поиск в буфере…"; color: State.text; font.family: State.fontFamily; Keys.onEscapePressed: State.close(); background: Rectangle { color: State.surfaceHigh; radius: 14; border.color: search.activeFocus ? State.accent : "transparent" } }
            IconButton { icon: "󰃢"; tooltip: "Очистить историю"; onClicked: { clearProc.running = true; entries = [] } }
            IconButton { icon: "󰅖"; onClicked: State.close() }
        }
        ListView {
            Layout.fillWidth: true; Layout.fillHeight: true; clip: true; spacing: 7; model: root.filtered
            delegate: MenuCard {
                required property var modelData
                width: ListView.view.width; title: modelData.text.replace(/\n/g, " ").slice(0, 70); subtitle: "Нажмите, чтобы скопировать"; icon: modelData.text.includes("[[ binary data") ? "󰋩" : "󰅍"
                onClicked: { actionProc.idValue = modelData.id; actionProc.running = true; State.showToast("Скопировано"); State.close() }
            }
            Text { anchors.centerIn: parent; visible: root.filtered.length === 0; text: "История буфера пуста"; color: State.muted; font.family: State.fontFamily }
        }
    }
}
