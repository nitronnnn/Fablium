pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import ".."

QtObject {
    id: root
    property var items: []

    NotificationServer {
        id: server
        keepOnReload: true
        bodySupported: true
        imageSupported: true
        actionsSupported: true
        onNotification: notification => {
            notification.tracked = true
            if (!State.dnd) root.items = [notification].concat(root.items).slice(0, 80)
        }
    }

    function dismiss(notification) {
        notification.dismiss()
        items = items.filter(item => item !== notification)
    }
    function clear() {
        items.forEach(item => item.dismiss())
        items = []
    }
}
