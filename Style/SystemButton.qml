import QtQuick 2.15
import QtQuick.Templates 2.15 as T
import QtQuick.Controls 2.15
import QtQuick.Controls.impl 2.15
T.Button {
    id: control
    implicitWidth: 95
    implicitHeight: 28
    font: GlobalConfig.font
    property color foreground :"#000000"
    property color backgroundColor: "#ffffff"
    property color borderColor:GlobalConfig.borderColor
    property int borderWidth: 1
    property bool useSystemFocusVisuals: true
    padding: 8
    verticalPadding: padding - 4
    spacing: 2
    hoverEnabled: true
    icon.width: 24
    icon.height: 24
    icon.color: Color.transparent(foreground, enabled ? 1.0 : 0.2)
    opacity: control.hovered ? 0.8 : control.checked
                               || control.highlighted ? 0.8 : 1

    contentItem: IconLabel {
        spacing: control.spacing
        mirrored: control.mirrored
        display: control.display
        icon: control.icon
        text: control.text
        font: control.font
        color: control.foreground// Color.transparent(, enabled ? 1.0 : 0.2)
    }

    background: Rectangle {
        visible: !control.flat || control.down || control.checked || control.highlighted
        color:control.backgroundColor
        border.color:hovered?GlobalConfig.highlight: control.borderColor
        border.width: control.borderWidth
        opacity: 1
        radius: 4
        anchors.fill: parent
        anchors.margins: control.down ? 2 : 0
    }
}
