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

  NText {
    anchors.centerIn: parent
    text: root.prayerText
    font.pixelSize: 12
    font.family: "monospace"
    font.weight: Font.Medium
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
    color: root.prayerClass === "error" ? Color.error
         : Color.mOnSurface
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: mouse => {
      if (mouse.button === Qt.LeftButton)
        Quickshell.execDetached(["bash", "-c", "C=$HOME/.local/share/prayer-times/timings.json; JQ='if type==\"object\" and has(\"timings\") then .timings else . end'; F=$(jq -r \"$JQ | .Fajr\" $C); D=$(jq -r \"$JQ | .Dhuhr\" $C); A=$(jq -r \"$JQ | .Asr\" $C); M=$(jq -r \"$JQ | .Maghrib\" $C); I=$(jq -r \"$JQ | .Isha\" $C); notify-send -a prayer-times -u normal -t 10000 \"🕌 Today's Prayer Times\" \"Fajr: $F\\nDhuhr: $D\\nAsr: $A\\nMaghrib: $M\\nIsha: $I\""])
      else if (mouse.button === Qt.RightButton)
        PanelService.showContextMenu(contextMenu, root, screen)
    }
  }

  NPopupContextMenu {
    id: contextMenu
    model: [
      { "label": "Show Times", "action": "show-times", "icon": "calendar" },
      { "label": "Select Athan", "action": "select-athan", "icon": "music" },
      { "label": "Add Custom Athan", "action": "add-athan", "icon": "plus" },
      { "label": "Set Location", "action": "set-location", "icon": "map" },
      { "label": "Restart Daemon", "action": "toggle-daemon", "icon": "power" },
    ]
    onTriggered: action => {
      contextMenu.close()
      PanelService.closeContextMenu(screen)
      if (action === "show-times")
        Quickshell.execDetached(["bash", "-c", "C=$HOME/.local/share/prayer-times/timings.json; JQ='if type==\"object\" and has(\"timings\") then .timings else . end'; F=$(jq -r \"$JQ | .Fajr\" $C); D=$(jq -r \"$JQ | .Dhuhr\" $C); A=$(jq -r \"$JQ | .Asr\" $C); M=$(jq -r \"$JQ | .Maghrib\" $C); I=$(jq -r \"$JQ | .Isha\" $C); notify-send -a prayer-times -u normal -t 10000 \"🕌 Today's Prayer Times\" \"Fajr: $F\\nDhuhr: $D\\nAsr: $A\\nMaghrib: $M\\nIsha: $I\""])
      else if (action === "select-athan")
        Quickshell.execDetached(["bash", "-c", "exec $HOME/.config/prayer-times/select-athan.sh"])
      else if (action === "add-athan")
        Quickshell.execDetached(["bash", "-c", "exec $HOME/.config/prayer-times/add-athan.sh"])
      else if (action === "set-location")
        Quickshell.execDetached(["bash", "-c", "exec $HOME/.config/prayer-times/set-location.sh"])
      else if (action === "toggle-daemon")
        Quickshell.execDetached(["bash", "-c", "pkill -f 'python.*prayer-times.*daemon' 2>/dev/null; sleep 1; nohup python3 $HOME/.config/prayer-times/daemon.py >/dev/null 2>&1 & notify-send -a prayer-times -u normal -t 3000 'Daemon' 'Restarted'"])
    }
  }
}
