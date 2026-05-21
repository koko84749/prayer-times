import QtQuick
import Quickshell
import qs.Commons
import qs.Widgets

Item {
  id: root
  property ShellScreen screen
  property var pluginApi: null

  NText {
    anchors.centerIn: parent
    text: "Prayer Times plugin active"
    color: Color.mOnSurface
  }
}
