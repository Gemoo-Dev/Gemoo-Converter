import QtQml 2.15
import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12
import FileInfo 1.0
import Style 1.0
import SystemInfo 1.0
Item {
    id:upgradewindow
    property alias upgrade: version.upgrade
    property alias currentVersion: version.currentVersion
    property  bool  compelUpgrade:version.upgrade&& version.currentBuildDate<version.minDate
    visible:  version.upgrade
    SystemVersion{
        id:version
    }
    signal close();
    Rectangle{
        anchors.fill: parent
        color: "#00ffffff"
        ColumnLayout{
            anchors.fill: parent
            anchors.margins: 30
            RowLayout{
                Layout.fillWidth: true
                implicitHeight: 50
                Item {
                    implicitHeight:30
                    implicitWidth: implicitHeight
                    Image {
                        anchors.fill: parent
                        source: "qrc:/img/gemooconverter_install_winlogo.svg"
                        sourceSize: Qt.size(width,height)
                    }
                }

                SystemText{
                    text:"Gemoo Converter"
                }
                SystemText{
                    horizontalAlignment: Text.AlignRight
                    text: String("Version:%1 %2")
                    .arg(version.currentVersion).
                    arg(version.currentBuildDate)
                    Layout.fillWidth: true
                }
            }
            Rectangle{
                Layout.fillHeight: true
                Layout.fillWidth: true
                color: "#FCFCFC"
                border.color: "#EFEFF0"
                border.width: 2
                radius: 5
                SystemText{
                    anchors.margins: 10
                    clip: true
                    anchors.fill: parent
                    text:String("Please update Gemoo Converter to explore more.\nNew version:%1 Build on:%2 \n%3")
                    .arg(version.version).arg(version.buildDate).arg( version.text)
                    wrapMode: Text.Wrap
                }
            }
            Item{
                Layout.fillWidth: true
                implicitHeight: 50
                RowLayout{
                    // anchors.right: parent.right
                    anchors.centerIn: parent
                    SystemButton{
                        text: "Skip this version"
                        implicitWidth: 140
                        visible:!compelUpgrade;
                        onClicked: {
                            upgradewindow.close()
                            version.skipVersion();
                        }
                    }
                    SystemButton{
                        text: "Remind me later"
                        visible: !compelUpgrade;
                        implicitWidth: 140
                        onClicked: {
                            upgradewindow.close();
                        }
                    }
                    SystemButton{
                        text: "Update Now"
                        implicitWidth: 140
                        onClicked: {
                            upgradewindow.close()
                            Qt.openUrlExternally(version.packageUrl);
                        }
                    }
                }
            }
        }
    }
}
