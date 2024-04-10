import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12
import QtQuick.Templates 2.15 as T

T.Popup {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding)

    default property alias  children :content.children
    property alias title: titleText.text
    closePolicy:Popup.NoAutoClose|Popup.CloseOnEscape
    padding: 1
    property alias okButtonText : okButton.text
    property alias closeButtonText : closeButton.text
    property alias okButtonVisible: okButton.visible
    property alias closeButtonVisible: closeButton.visible
    property alias bottmItemHeight: bottmItem.implicitWidth
    contentItem: Item{
        Rectangle{
            id:topItem
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            implicitHeight: 32
            radius: 0
            color: "#F2F8FF"
            SystemText{
                id:titleText
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: topCloseBtn.left
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                font.pixelSize: 14
                clip: true
                elide: Text.ElideLeft
            }

            SystemButton{
                id:topCloseBtn
                anchors.right: parent.right
                anchors.rightMargin:4
                borderColor:"#00000000"
                borderWidth:0
                width: 20
                height: width
                anchors.verticalCenter: parent.verticalCenter
                Image {
                    source:topCloseBtn.down?"qrc:/img/gemooconverter_install_close_click.svg":
                               topCloseBtn.hovered?"qrc:/img/gemooconverter__install_close_hover.svg":
                                                "qrc:/img/gemooconverter_install_close.svg"
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                    sourceSize: Qt.size(width, height)
                }
                onClicked: {
                    result(false);
                }
            }
        }
        Item {
            id:content
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: topItem.bottom
            anchors.bottom:bottmItem.top
            anchors.margins: 2
        }

        Rectangle{
            id:bottmItem
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            implicitHeight: 38
            radius: 0
            color: "#ffffff"
            SystemButton{
                id:okButton
                anchors.right: closeButton.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 20
                text: qsTr("确定")
                onClicked: {
                    result(true);
                }
            }
            SystemButton{
                id:closeButton
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 10
                text: qsTr("关闭")
                onClicked: {
                    result(false);
                }
            }
        }
    }
    background: Rectangle {
        color: "#f0f0f0"
        border.color: GlobalConfig.borderColor
        border.width: 1 // FlyoutBorderThemeThickness
        radius: 2
    }

    T.Overlay.modal: Rectangle {
        color: "#aa666666"
    }

    T.Overlay.modeless: Rectangle {
        color:  "#ffff00"
    }
    signal result(bool isOk);
}
