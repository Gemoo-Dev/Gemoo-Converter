import QtQml 2.15
import QtQuick 2.15
import QtQuick.Controls 2.15
import Style 1.0
Item {
    property alias title: nameText.text
    property alias value: numberBox.value
    property alias to: numberBox.to
    property alias from: numberBox.from
    property alias unit: unitText.text
    property alias  titleWidth: nameText.width
    implicitHeight: 35
    implicitWidth: 300
    SystemText {
        id: nameText
        width: 80
        anchors.verticalCenter:parent.verticalCenter
        horizontalAlignment: Text.AlignRight
    }
    SystemNumberBox  {
        id: numberBox
        anchors.verticalCenter:parent.verticalCenter
        anchors.left: nameText.right
        anchors.right: unitText.left
        anchors.rightMargin: 5
    }
    SystemText {
        id: unitText
        anchors.right:parent.right
        anchors.verticalCenter:parent.verticalCenter
        horizontalAlignment: Text.AlignLeft

    }
}

