import QtQml 2.15
import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import FileInfo 1.0
import Style 1.0
Window {
    id:window
    width:1080//Math.min(Screen.width*0.75,1280);//Screen.devicePixelRatio
    height:620//Math.min(Screen.height*0.75,720);//Screen.devicePixelRatio
    minimumWidth: 1080;//Screen.width*0.56
    minimumHeight: 620;// Screen.height*0.56
    visible: true
    title: qsTr("Gemoo Converter %1").arg(versionUpgrade.currentVersion)

    property int  screenW : Screen.width;
    property int screenH:Screen.height;
    ColumnLayout{
        anchors.fill: parent
        FileInfoView{
            id:fileInfo
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }
    Popup{
        id:popup
        parent: window
        width: parent.width
        height: parent.height
        closePolicy:Popup.NoAutoClose|Popup.CloseOnEscape
        Rectangle{
            anchors.fill: parent
            VersionUpgrade{
                id:versionUpgrade
                width: 640
                height: 320
                anchors.centerIn: parent
                onUpgradeChanged: {
                    window.minimumHeight=340;
                    window.minimumWidth=640;
                    window.width=640;
                    window.height=340;
                    window.x =(screenW-window.width)/2;
                    window.y =(screenH-window.height)/2;
                    popup.open();
                }

                onClose:
                {
                    if(versionUpgrade.compelUpgrade)
                    {
                        window.close();
                    }
                    else{

                        popup.close();
                        window.minimumHeight=620;
                        window.minimumWidth=1080;
                        window.width=1080//Math.min(screenW*0.75,1280);
                        window.height=620//Math.min(screenH*0.75,720);
                        window.x = (screenW-window.width)/2;
                        window.y =(screenH-window.height)/2;

                    }
                }
            }
        }
    }
    onClosing:{
        if(popup.opened)
        {
            if(versionUpgrade.compelUpgrade)
            {
                // window.close();
            }
            else
            {
                window.minimumHeight=620;
                window.minimumWidth=1080;
                window.width=1080//Math.min(screenW*0.75,1280);
                window.height=620//Math.min(Screen.height*0.75,720);

                window.x =(screenW-window.width)/2;
                window.y =(screenH-window.height)/2;
                popup.close();
                close.accepted = false;
            }
        }
    }
}
