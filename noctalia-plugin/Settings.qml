import QtQuick
import QtQuick.Controls
import Quickshell
import qs.Commons
import qs.Modules.Panels.Settings

SettingsPage {
  id: root
  title: pluginApi?.tr("pages.settings") ?? "Prayer Times Settings"

  property var mainSettings: pluginApi?.mainInstance ?? null

  Column {
    spacing: 12

    NText {
      text: "Click the bar widget to open the Athan selector (Rofi)."
      color: Color.mOnSurface
      wrapMode: Text.WordWrap
    }

    NButton {
      text: "Select Athan"
      onClicked: Quickshell.execDetached(["sh", "-c", "/home/hamo/.config/prayer-times/prayer-times.sh select"])
    }

    NButton {
      text: "Test API"
      onClicked: Quickshell.execDetached(["konsole", "-e", "bash", "-c", "/home/hamo/.config/prayer-times/prayer-times.sh test; echo; read -p 'Press enter...'"])
    }
  }
}
