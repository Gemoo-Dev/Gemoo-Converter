import QtQml 2.15
import QtQuick 2.15
import QtQuick.Controls 2.15
import Style 1.0

Item {
    property alias title: nameText.text
    property alias model: comboBox.model
    property alias textRole: comboBox.textRole
    property alias currentIndex:comboBox.currentIndex
    property alias currentText:comboBox.currentText
    default property alias extendChildren: childItem.children
    implicitHeight: 35
    implicitWidth: 300
    SystemText {
        id: nameText
        width: 80
        anchors.verticalCenter:parent.verticalCenter
        horizontalAlignment: Text.AlignRight
        clip: false
    }
    SystemComboBox{
        id: comboBox
        anchors.verticalCenter:  parent.verticalCenter
        anchors.left:  nameText.right
        anchors.right: parent.right
        Item {
            id: childItem
            anchors.left:  comboBox.contentItem.left
            anchors.right:  comboBox.indicator.left
            anchors.top: comboBox.contentItem.top
            anchors.bottom: comboBox.contentItem.bottom
            clip: true
        }
    }

}

