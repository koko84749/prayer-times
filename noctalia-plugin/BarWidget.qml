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
  property string prayerTooltip: ""

  readonly property real maxWidth: 160

  implicitWidth: Math.min(textMetrics.advanceWidth + 24, maxWidth)
  implicitHeight: capsuleHeight

  TextMetrics {
    id: textMetrics
    font.family: "monospace"
    font.pixelSize: 13
    font.weight: Font.Medium
    text: root.prayerText
  }

  Process {
    id: proc
    command: ["sh", "-c", "/home/hamo/.config/prayer-times/status.sh"]
    running: true
    stdout: SplitParser {
      onRead: data => {
        try {
          var obj = JSON.parse(data.trim())
          root.prayerText = obj.text || "🌙 ?"
          root.prayerTooltip = obj.tooltip || ""
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

  Rectangle {
    id: pill
    anchors.fill: parent
    anchors.margins: 2
    radius: height / 2
    color: root.prayerClass === "error" ? Color.errorContainer
         : Color.surfaceContainerHigh
    opacity: 0.85

    NText {
      anchors.centerIn: parent
      text: root.prayerText
      font.pixelSize: 12
      font.family: "monospace"
      font.weight: Font.Medium
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
      elide: Text.ElideRight
      color: root.prayerClass === "error" ? Color.onErrorContainer
           : Color.mOnSurface
    }
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: mouse => {
      if (mouse.button === Qt.LeftButton)
        Quickshell.execDetached(["sh", "-c", "/home/hamo/.config/prayer-times/prayer-times.sh select"])
      else if (mouse.button === Qt.RightButton)
        PanelService.showContextMenu(contextMenu, root, screen)
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
