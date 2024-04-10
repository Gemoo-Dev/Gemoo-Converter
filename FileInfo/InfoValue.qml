import QtQuick 2.15
import Style 1.0

Item {
    property alias name: nameText.text
    property alias value: valueText.text
    property alias nameWidth: nameText.width
    implicitHeight: 30
    clip: true
    SystemText {
        id: nameText
        width: 81
        x: 10
        anchors.verticalCenter:parent.verticalCenter
        horizontalAlignment: Text.AlignLeft
        clip: true
        color: "#545455"
    }
    SystemText {
        id: valueText
        anchors.verticalCenter:parent.verticalCenter
        anchors.left:  nameText.right
        anchors.right: parent.right
        anchors.rightMargin: 2
        horizontalAlignment: Text.AlignLeft
        clip: true
        color: "#545455"
    }
}
