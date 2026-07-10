//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QSG_RENDER_LOOP=threaded
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=9000

import QtQuick
import Quickshell
import Quickshell.Io
import "bar"
import "components"
import "."

ShellRoot {
    id: root

    Variants {
        model: Quickshell.screens
        Bar {}
    }

    ToastWindow {}

    IpcHandler {
        target: "fablium"
        function toggle(menu: string): void {
            if (State.activeMenu === menu && State.popupShown) State.close()
            else State.open(menu)
        }
        function close(): void { State.close() }
        function toast(text: string): void { State.showToast(text) }
    }
}
