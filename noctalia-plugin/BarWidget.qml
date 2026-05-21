import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Services.UI
import qs.Widgets

Item {
  id: root

  property ShellScreen screen
  property string widgetId: ""
  property string section: ""
  property int sectionWidgetIndex: -1
  property int sectionWidgetsCount: 0

  property var pluginApi: null

  readonly property string screenName: screen ? screen.name : ""
  readonly property real capsuleHeight: Style.getCapsuleHeightForScreen(screenName)

  property string prayerText: "🌙 ?"
  property string prayerClass: ""

  implicitWidth: 24
  implicitHeight: capsuleHeight

  Process {
    id: proc
    command: ["sh", "-c", "/home/hamo/.config/prayer-times/status.sh"]
    running: true

    stdout: SplitParser {
      onRead: data => {
        try {
          var obj = JSON.parse(data.trim())
          root.prayerText = obj.text || "🌙 ?"
          root.prayerClass = obj.class || ""
        } catch (e) {}
      }
    }

    onExited: timer.restart()
  }

  Timer {
    id: timer
    interval: 60000
    repeat: true
    onTriggered: proc.running = true
  }

  NText {
    anchors.centerIn: parent
    text: root.prayerText
    font.pixelSize: 13
    font.family: "monospace"
    color: root.prayerClass === "error" ? Color.error
         : Color.mOnSurface
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    onClicked: mouse => {
      if (mouse.button === Qt.LeftButton) {
        Quickshell.execDetached(["sh", "-c", "/home/hamo/.config/prayer-times/prayer-times.sh select"])
      } else if (mouse.button === Qt.RightButton) {
        PanelService.showContextMenu(contextMenu, root, screen)
      }
    }
  }

  NPopupContextMenu {
    id: contextMenu

    model: [
      { "label": "Select Athan", "action": "select-athan", "icon": "music" },
      { "label": "Restart Daemon", "action": "toggle-daemon", "icon": "power" },
    ]

    onTriggered: action => {
      contextMenu.close()
      PanelService.closeContextMenu(screen)
      if (action === "select-athan")
        Quickshell.execDetached(["sh", "-c", "/home/hamo/.config/prayer-times/prayer-times.sh select"])
      else if (action === "toggle-daemon")
        Quickshell.execDetached(["sh", "-c", "/home/hamo/.config/prayer-times/prayer-times.sh restart"])
    }
  }
}
