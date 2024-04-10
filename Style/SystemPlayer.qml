import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12

Rectangle {
    color: "#a0a0a0"
    border.color: "#000000"
    border.width: 1
    RowLayout{
        implicitHeight: 50
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        Text {
            id: name
            text: qsTr("00:00:00")
        }
        Slider{
            id:durationTimeSlider
            Layout.fillWidth: true
            Layout.preferredWidth: 100
            implicitHeight: 8
            hoverEnabled: true
            orientation: Qt.Horizontal
            visible:true
            implicitWidth: bar2.size<1?10:0
            snapMode: ScrollBar.SnapAlways

            background: Rectangle {
               // color: "#f0f0f0"
                radius: height / 2
            }
            // contentItem: Rectangle {
            //     implicitWidth:scrollBar.width
            //     radius: height / 2
            //    // color: scrollBar.pressed ? "#303030":"#A0303030"
            // }
            handle: Rectangle {
                antialiasing: true
                implicitWidth: durationTimeSlider.height+6
                implicitHeight: implicitWidth
                x:  durationTimeSlider.visualPosition*durationTimeSlider.availableWidth
                  // * (durationTimeSlider.availableWidth - width)

                y:// durationTimeSlider.topPadding
                  (durationTimeSlider.height - implicitHeight) / 2

                radius: height/2
                //color: durationTimeSlider.pressed ? "#f0f0f0" : "#f6f6f6"
                border.width: durationTimeSlider.pressed ? 3 : 2
                border.color: durationTimeSlider.pressed ? "#bdbeff" : "#bdbebf"
                Rectangle {
                    width: parent.heigh*0.6
                    height: width
                    radius: width/2
                    color: "red"
                    anchors.centerIn: parent
                }
            }
        }
        Text {
            text: qsTr("00:00:00")
        }

        Slider{
            id:bar2
            Layout.fillWidth: true
            Layout.preferredWidth: 20
            implicitHeight: 10
            hoverEnabled: true

            orientation: Qt.Horizontal
            visible:true
            implicitWidth: bar2.size<1?10:0
            snapMode: ScrollBar.SnapAlways

            background: Rectangle {
                color: "#B0f0f0f0"
                radius: height / 2
            }
            contentItem: Rectangle {
                implicitWidth:  bar2.width
                radius: height / 2
                color: bar2.pressed ? "#303030":"#A0303030"
            }
        }
        GridLayout{
            rows: 1
            Button{
                implicitHeight: 30
                implicitWidth: 30
            }
            Button{
                implicitHeight: 30
                implicitWidth: 30
            }
            Button{
                implicitHeight: 30
                implicitWidth: 30
            }
            Button{
                implicitHeight: 30
                implicitWidth: 30
            }
        }
    }
}
