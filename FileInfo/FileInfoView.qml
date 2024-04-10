import QtQml 2.15
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs 1.3
import QtGraphicalEffects 1.15
import FileInfo 1.0
import Style 1.0
Item {
    id:item
    RowLayout{
        anchors.fill: parent
        anchors.margins: 0
        Rectangle{
            Layout.fillHeight: true
            Layout.fillWidth: false
            implicitWidth: 162
            color: "#FAFBFC"
            border.width: 2
            border.color: "#f7f7f7"
            ButtonGroup{
                id:buttonGroup
            }
            ColumnLayout{
                anchors.fill: parent
                anchors.margins:10
                anchors.rightMargin: 2
                anchors.leftMargin: 2
                SystemRadioButton{
                    id:videoRadioButton
                    text:qsTr("视频转换")
                    implicitHeight:50
                    Layout.fillWidth: true
                    ButtonGroup.group: buttonGroup
                    checked:worklist.currentFileType==Worklist.Video
                    backgroundColor:checked?"#EFF7FF":"#00EFF7FF"
                    textColor:checked?"#4FABFF":"#000000"
                    font.bold: true
                    indicator:Image{
                        width:  18
                        height: 18
                        x:5
                        sourceSize:  Qt.size(width, height)
                        anchors.verticalCenter: parent.verticalCenter
                        source: "qrc:/img/gemooconverter_video.svg"
                        ColorOverlay{
                            anchors.fill: parent
                            source: parent
                            color:videoRadioButton.textColor //修改后的svg图片颜色
                        }
                    }
                }
                SystemRadioButton{
                    id:audioRadioButton
                    text:qsTr("音乐转换")
                    ButtonGroup.group: buttonGroup
                    implicitHeight:50
                    Layout.fillWidth: true
                    checked: worklist.currentFileType==Worklist.Audio
                    backgroundColor:checked?"#EFF7FF":"#00EFF7FF"
                    textColor:checked?"#4FABFF":"#000000"
                    font.bold: true
                    indicator:Image{
                        id:image
                        width:  18
                        height: 18
                        x:5
                        sourceSize:  Qt.size(width, height)
                        // anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        source: "qrc:/img/gemooconverter_music.svg"
                        ColorOverlay{
                            anchors.fill: image
                            source: image
                            color:audioRadioButton.textColor //修改后的svg图片颜色
                        }
                    }
                }
                Item {
                    Layout.fillHeight: true
                }
                SystemButton{
                    text: qsTr("问题反馈")
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                    onClicked: {
                        Qt.openUrlExternally("mailto:example@example.com?to=cs@gemoo.com&subject=Gemoo Converter&body=Please provide detailed information about the issue so we can offer a prompt and effective solution.");
                    }
                }
            }
        }

        Rectangle{
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 60
            clip: true
            ColumnLayout{
                anchors.fill: parent
                anchors.margins: 10
                spacing: 20
                RowLayout{
                    Layout.fillWidth: true
                    Layout.fillHeight: false
                    Layout.leftMargin: 3
                    SystemCheckBox{
                        id:allCheckBox
                        text: qsTr("全选")
                        enabled: listView.count>0
                        checkState: listView.count>0?(listView.checkedCount==0?Qt.Unchecked:(listView.checkedCount<listView.count?Qt.PartiallyChecked:Qt.Checked) ):Qt.Unchecked
                        onCheckedChanged: {
                            if(hovered&&checkState!=Qt.PartiallyChecked)
                                worklist.checkedAll(checkState== Qt.Checked);
                        }
                        onClicked: {
                            if(checkState==Qt.PartiallyChecked)
                            {
                                checkState= Qt.Checked;
                            }
                        }
                    }

                    SystemButton{
                        implicitWidth: 125
                        text:qsTr("添加文件")
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                        onClicked: fileDialog.open();
                        backgroundColor: "#ffffff"
                        borderColor: "#3FA1FF"
                        foreground: "#3FA1FF"
                        borderWidth: 1
                        icon.source:  "qrc:/img/gemooconverter_add.svg"
                    }
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: false
                    }
                    SystemButton{
                        text:qsTr("删除文件")
                        implicitWidth: 125
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        onClicked:worklist.removeItems()//listView.deleteModel();
                        backgroundColor: "#ffffff"
                        borderColor: "#3FA1FF"
                        foreground: "#3FA1FF"
                        borderWidth: 1
                        icon.source: "qrc:/img/gemooconverter_delete.svg"
                    }
                }
                ListView{
                    id:listView
                    visible: listView.count>0
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    property int checkedCount: 0
                    property int runingCount: 0
                    model: videoRadioButton.checked?worklist.videoFiles:worklist.audioFiles

                    signal progressChanged(int index ,double progress);
                    signal deleteModel();
                    //signal checkAll(bool checked);
                    signal outFileArgumengChanged(OutFileInfo fileInfo);
                    signal checkedChanged();
                    signal formatChanged(string format);
                    signal modelStateChange();
                    property int minNameWidth: 70

                    onModelChanged:{
                        listView.checkedCount=0;
                        listView.checkedChanged();
                        listView.runingCount=0;
                        listView.modelStateChange();
                    }

                    delegate:Item {

                        implicitHeight: fileInfoDelegate.height+10
                        implicitWidth: listView.width-(scrollBar2.implicitWidth>0?scrollBar2.implicitWidth+4:0)
                        Rectangle{
                            id:fileInfoDelegate
                            color: "#FCFCFC"
                            anchors.verticalCenter: parent.verticalCenter
                            border.color:  model.checked?GlobalConfig.highlight: "#F1F1F1"
                            border.width: 2
                            radius: 5
                            clip: true
                            width: parent.width
                            height: 140
                            RowLayout{
                                anchors.fill: parent
                                anchors.margins: 4
                                anchors.leftMargin: 8
                                SystemCheckBox{
                                    id:cbx
                                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                    spacing:0
                                    padding:0
                                    Binding{
                                        target: model
                                        property: "checked"
                                        value: cbx.checked
                                    }
                                    Binding{
                                        target: cbx
                                        property: "checked"
                                        value: model.checked
                                    }
                                    onCheckedChanged: {
                                        listView.checkedCount=0;
                                        listView.checkedChanged();
                                    }
                                }

                                Rectangle{
                                    Layout.fillHeight: true
                                    Layout.leftMargin: 2
                                    Layout.rightMargin:2
                                    Layout.topMargin: 15
                                    Layout.bottomMargin: 15
                                    implicitWidth:height*16.0/9;
                                    Image{
                                        id:thumbnailImage
                                        anchors.fill: parent
                                        anchors.margins: 0
                                        anchors.leftMargin: 0
                                        anchors.rightMargin: 0
                                        source:"image://thumbnail/" + model.completeName//
                                        fillMode: Image.PreserveAspectFit
                                        visible: sourceSize.width>0
                                    }
                                    Image{
                                        anchors.fill: parent
                                        anchors.margins: 30
                                        source:"qrc:/img/defaultAduio.png"
                                        fillMode: Image.PreserveAspectFit
                                        visible: !thumbnailImage.visible
                                    }
                                }
                                ColumnLayout{
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    clip: true
                                    RowLayout{
                                        Layout.fillWidth: true
                                        Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                                        implicitHeight:   35
                                        SystemText {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: false
                                            text:model.fileName
                                            font.bold: true
                                            font.pixelSize: 14
                                        }
                                    }
                                    Rectangle{
                                        color: "#FCFCFC"
                                        border.color: "#EFEFF0"
                                        border.width: 2
                                        radius: 5
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        RowLayout{
                                            anchors.fill: parent
                                            GridLayout{
                                                columns: 2
                                                rowSpacing: 5
                                                InfoValue{
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: false
                                                    Layout.preferredWidth: 86
                                                    name: qsTr("格式:")
                                                    value:model.format.toUpperCase()
                                                    nameWidth: listView.minNameWidth
                                                }
                                                InfoValue{
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: false
                                                    Layout.preferredWidth: 100
                                                    name: videoRadioButton.checked? qsTr("分辨率:"):qsTr("采样率:")
                                                    value:videoRadioButton.checked?(model.videoStreams.size()===0?"0X0": (String("%1X%2").arg(model.videoStreams.data(0,"width")).arg(model.videoStreams.data(0,"height")))):
                                                                                    (String("%1").arg(model.audioStreams.data(0,"sample_rate")))

                                                }
                                                InfoValue{
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: false
                                                    Layout.preferredWidth: 86
                                                    name:  qsTr("时长:")
                                                    value:GlobalConfig.intToTimeString(model.duration)
                                                    nameWidth: listView.minNameWidth
                                                }
                                                InfoValue{
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: false
                                                    Layout.preferredWidth: 100
                                                    name:videoRadioButton.checked? qsTr("帧率:"):qsTr("比特率:")
                                                    value:videoRadioButton.checked?model.videoStreams.size()===0?"0FPS":String("%1FPS").arg(model.videoStreams.data(0,"frame_rate").toFixed(0)):
                                                    String("%1Kbps").arg((model.audioStreams.data(0,"bit_rate")/1024).toFixed(0))
                                                }
                                                }
                                                    SystemText {
                                                        Layout.fillWidth: false
                                                        Layout.fillHeight: false
                                                        text:"->"
                                                        font.bold: true
                                                        font.pixelSize: 14
                                                    }
                                                    GridLayout{
                                                        columns: 2
                                                        rowSpacing: 5
                                                        InfoValue{
                                                            id:formatValue
                                                            Layout.fillWidth: true
                                                            Layout.fillHeight: false
                                                            name: qsTr("格式:")
                                                            Layout.preferredWidth: 86
                                                            nameWidth: listView.minNameWidth
                                                            Binding{
                                                                when:model.checked&&(FFmpegCommand.None===model.command.state||
                                                                                     FFmpegCommand.Finish===model.command.state||
                                                                                     FFmpegCommand.Failure===model.command.state )
                                                                target: formatValue
                                                                property: "value"
                                                                value:videoRadioButton.checked? videoFormatCbx.currentText:audioFormatCbx.currentText
                                                            }
                                                            onValueChanged: {
                                                                if(model.checked&&(FFmpegCommand.None===model.command.state||
                                                                                   FFmpegCommand.Finish===model.command.state||
                                                                                   FFmpegCommand.Failure===model.command.state ))
                                                                {
                                                                    model.outFileInfo.format=value;
                                                                    var audioCodes= GlobalConfig.audioCodesFromFormat(value);
                                                                    model.outFileInfo.audioInfo.audioCodes= GlobalConfig.defaultValue2(audioCodes,model.outFileInfo.audioInfo.audioCodes);

                                                                    var  audioChannels=  GlobalConfig.audioChannelsFmtFromCodes(model.outFileInfo.audioInfo.audioCodes);
                                                                    model.outFileInfo.audioInfo.channels=GlobalConfig.defaultValue2(audioChannels, model.outFileInfo.audioInfo.channels);

                                                                    var audioSampleFmt= GlobalConfig.audioSampleFmtFromCodes(model.outFileInfo.audioInfo.audioCodes);
                                                                    model.outFileInfo.audioInfo.audioSamplefmt= GlobalConfig.defaultValue2(audioSampleFmt,  model.outFileInfo.audioInfo.audioSamplefmt);

                                                                    var videoCodes=GlobalConfig.videoCodesFromFormat(model.outFileInfo.format);
                                                                    model.outFileInfo.videoInfo.videoCodes= GlobalConfig.defaultValue2(videoCodes, model.outFileInfo.videoInfo.videoCodes);

                                                                }
                                                            }
                                                        }

                                                        InfoValue{
                                                            Layout.fillWidth: true
                                                            Layout.fillHeight: false
                                                            Layout.preferredWidth: 100
                                                            name:  videoRadioButton.checked? qsTr("分辨率:"):qsTr("采样率:")
                                                            value: videoRadioButton.checked?(model.videoStreams.size()===0?"0X0":(model.outFileInfo.videoInfo.resolution.length>0?
                                                                                                                                      model.outFileInfo.videoInfo.resolution:
                                                                                                                                      ( String("%1X%2").arg( model.videoStreams.data(0,"width")).arg(model.videoStreams.data(0,"height"))))):

                                                                                             model.outFileInfo.audioInfo.audioSamplefmt>0?
                                                                                                 model.outFileInfo.audioInfo.audioSamplefmt:
                                                                                                 (String("%1").arg(model.audioStreams.data(0,"sample_rate")))
                                                        }
                                                        InfoValue{
                                                            Layout.fillWidth: true
                                                            Layout.fillHeight: false
                                                            name:qsTr("时长:")
                                                            value:GlobalConfig.intToTimeString(model.duration)
                                                            nameWidth: listView.minNameWidth
                                                            Layout.preferredWidth: 86
                                                        }
                                                        InfoValue{
                                                            Layout.fillWidth: true
                                                            Layout.fillHeight: false
                                                            Layout.preferredWidth: 100
                                                            name: videoRadioButton.checked? qsTr("帧率:"):qsTr("比特率:")
                                                            value:videoRadioButton.checked?model.videoStreams.size()===0?"0FPS":( model.outFileInfo.videoInfo.frameRate>0?
                                                                                                                                     String("%1FPS").arg(model.outFileInfo.videoInfo.frameRate.toFixed(0)):
                                                                                                                                     ( String("%1FPS").arg(model.videoStreams.data(0,"frame_rate").toFixed(0)))):
                                                            model.outFileInfo.audioInfo.bitRate>0?
                                                            String("%1Kbps").arg( model.outFileInfo.audioInfo.bitRate):
                                                                String("%1Kbps").arg((model.audioStreams.data(0,"bit_rate")>0?model.audioStreams.data(0,"bit_rate")/1024:192).toFixed(0))
                                                        }
                                                    }
                                                }
                                            }
                                            Item {
                                                Layout.fillWidth: true
                                                implicitHeight: 30
                                                Layout.margins: 0
                                                Layout.rightMargin:  5
                                                RowLayout{
                                                    anchors.fill: parent
                                                    ColumnLayout {
                                                        Layout.fillWidth: true
                                                        Layout.fillHeight: true
                                                        SystemText{
                                                            Layout.fillWidth: true
                                                            horizontalAlignment: Text.AlignLeft
                                                            color:FFmpegCommand.Failure===model.command.state?"#ff0000": "#545455"
                                                            visible: FFmpegCommand.None!==model.command.state
                                                            text:String("%1%2").arg(commandStateToString(model.command.state)).
                                                            arg(FFmpegCommand.Running===model.command.state?
                                                            model.duration===0?":"+GlobalConfig.intToTimeString(model.command.progress): String(":%1%").arg((model.command.progress/progressBar.to*100).toFixed(2))
                                                            :"")
                                                        }
                                                        SystemProgressBar {
                                                            id:progressBar
                                                            from: 0
                                                            to:model.duration
                                                            value: model.command.progress
                                                            visible:FFmpegCommand.Running===model.command.state
                                                            implicitHeight: 8
                                                            Layout.fillWidth: true
                                                        }
                                                    }
                                                    SystemButton{
                                                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                                        backgroundColor: "#ffffff"
                                                        borderColor: "#3FA1FF"
                                                        foreground: "#3FA1FF"
                                                        borderWidth: 0
                                                        icon.source: "qrc:/img/cancel.svg"
                                                        implicitWidth: implicitHeight
                                                        icon.width: implicitHeight-4
                                                        icon.height: implicitHeight-4
                                                        padding: 2
                                                        visible:FFmpegCommand.None!==model.command.state&&FFmpegCommand.Finish!==model.command.state&&FFmpegCommand.Failure!==model.command.state
                                                        onClicked: {
                                                            model.command.cancel();
                                                        }
                                                    }
                                                    SystemButton{
                                                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                                        backgroundColor: "#ffffff"
                                                        borderColor: "#3FA1FF"
                                                        foreground: "#3FA1FF"
                                                        borderWidth: 1
                                                        text: qsTr("设置")
                                                        visible:FFmpegCommand.None===model.command.state||
                                                                FFmpegCommand.Finish===model.command.state||
                                                                FFmpegCommand.Failure===model.command.state
                                                        onClicked: {
                                                            // fileOutArgument.format=videoRadioButton.checked?videoFormatCbx.currentText:audioFormatCbx.currentText
                                                            fileOutArgument.audioArgument=model.audioStreams.size()>0
                                                            fileOutArgument.videoArgument=videoRadioButton.checked&&model.videoStreams.size()>0
                                                            fileOutArgument.fileInfo=model;
                                                            outArgumentPopup.title=model.fileName
                                                            outArgumentPopup.open();
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                Connections{
                                    target: listView
                                    enabled: true
                                    // function onCheckAll(checked)
                                    // {
                                    //     if( cbx.checked!==checked)
                                    //     cbx.checked=checked;
                                    // }
                                    function onDeleteModel()
                                    {
                                        if(checked)
                                        {
                                            listView.model.removeAt(model.index);
                                        }
                                    }

                                    function onCheckedChanged()
                                    {
                                        if(cbx.checked)
                                        {
                                            listView.checkedCount++;
                                        }
                                    }
                                    function onOutFileArgumengChanged(fileInfo)
                                    {
                                        if(cbx.checked&&(FFmpegCommand.None===model.command.state||
                                                         FFmpegCommand.Finish===model.command.state||
                                                         FFmpegCommand.Failure===model.command.state))
                                        {
                                            if(model.audioStreams.size()>0)
                                            {
                                                model.outFileInfo.audioInfo.audioCodes=fileInfo.audioInfo.audioCodes;
                                                model.outFileInfo.audioInfo.channels=fileInfo.audioInfo.channels;
                                                model.outFileInfo.audioInfo.audioSamplefmt=fileInfo.audioInfo.audioSamplefmt;
                                                model.outFileInfo.audioInfo.bitRate=fileInfo.audioInfo.bitRate;
                                            }
                                            if(model.videoStreams.size()>0&&worklist.currentFileType==Worklist.Video)
                                            {
                                                model.outFileInfo.videoInfo.videoCodes=fileInfo.videoInfo.videoCodes;
                                                model.outFileInfo.videoInfo.resolution=fileInfo.videoInfo.resolution;
                                                model.outFileInfo.videoInfo.frameRate=fileInfo.videoInfo.frameRate;
                                                model.outFileInfo.videoInfo.bitRate=fileInfo.videoInfo.bitRate;
                                            }
                                            model.outFileInfo.audioInfo.discard=fileInfo.audioInfo.discard;
                                        }
                                    }

                                    function onModelStateChange()
                                    {
                                        if(FFmpegCommand.Running===model.command.state||
                                                FFmpegCommand.Unstart===model.command.state)
                                        {
                                            listView.runingCount++;
                                        }
                                    }
                                }
                                Connections{
                                    target:model.command
                                    function onStateChanged()
                                    {
                                        listView.runingCount=0;
                                        listView.modelStateChange();
                                    }
                                }
                            }
                            ScrollBar.vertical: SystemScrollBar{
                                id:scrollBar2
                            }
                        }
                        Item{
                            visible: listView.count==0
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Rectangle{
                                color: "#FCFCFD"
                                anchors.centerIn: parent
                                implicitWidth: parent.width/2
                                implicitHeight: parent.height/2
                                border.color: GlobalConfig.borderColor
                                radius: 10
                                DropArea {
                                    id: dropContainer1
                                    anchors.fill: parent;
                                    //接受拖放处理
                                    onDropped: {
                                        if (drop.urls.length>0)
                                        {
                                            fileAppend(drop.urls);
                                        }
                                    }
                                }
                                ColumnLayout{
                                    anchors.centerIn: parent
                                    Item {
                                        Layout.fillWidth: true
                                        implicitHeight: 32
                                        SystemButton{
                                            text:qsTr("添加文件")
                                            foreground:"#3FA1FF"
                                            borderColor:"#00ffffff"
                                            font.pixelSize:16
                                            font.bold: true
                                            implicitWidth: 135
                                            anchors.centerIn: parent
                                            onClicked: {
                                                fileDialog.open();
                                            }
                                        }
                                    }
                                    SystemText{
                                        id:dropText
                                        text: videoRadioButton.checked?
                                                  qsTr("点击或者拖拽视频文件到这里"):
                                                  qsTr("点击或拖拽音频视频文件到这里")
                                    }
                                }
                            }
                        }
                        Rectangle{
                            Layout.fillWidth: true
                            implicitHeight: 2
                            color: "#EFEFF0"
                            Layout.leftMargin: -10
                        }
                        RowLayout{
                            Layout.fillWidth: true
                            ColumnLayout{
                                Layout.fillWidth: true
                                RowLayout{
                                    Layout.fillWidth: true
                                    SystemText{
                                        text: qsTr("目标格式:")
                                        Layout.minimumWidth:   100
                                        horizontalAlignment: Text.AlignRight
                                    }
                                    Binding{
                                        target: worklist
                                        property: "videoOutFormat"
                                        value: videoFormatCbx.currentText
                                    }
                                    Binding{
                                        target: worklist
                                        property: "audioOutFormat"
                                        value: audioFormatCbx.currentText
                                    }

                                    SystemComboBox{
                                        id:videoFormatCbx
                                        Layout.fillWidth: true
                                        visible: videoRadioButton.checked
                                        model: GlobalConfig.videoFormat
                                        textRole: "name"
                                        currentIndex:videoFormatCbx.getIndexFromText( worklist.videoOutFormat)
                                    }
                                    SystemComboBox{
                                        id:audioFormatCbx
                                        Layout.fillWidth: true
                                        visible:!videoRadioButton.checked
                                        model:GlobalConfig.audioFormat
                                        textRole: "name"
                                        currentIndex:audioFormatCbx.getIndexFromText(worklist.audioOutFormat)
                                    }

                                    SystemButton{
                                        id:settingBtn
                                        implicitWidth: height
                                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                        padding: 2
                                        Layout.leftMargin: 5
                                        indicator:Image{
                                            width:   24
                                            height:  24
                                            sourceSize:  Qt.size(width, height)
                                            anchors.centerIn:  settingBtn
                                            source:"qrc:/img/设置.svg"
                                            ColorOverlay{
                                                anchors.fill: parent
                                                source: parent
                                                color:settingBtn.hovered?GlobalConfig.highlight: "#666666"
                                            }
                                        }
                                        onClicked: {
                                            fileOutArgument.audioArgument=true
                                            fileOutArgument.videoArgument=videoRadioButton.checked
                                            fileOutArgument.fileInfo=null;
                                            fileOutArgument.outFileInfo=videoRadioButton.checked? worklist.videoOutFileInfo:worklist.audioOutFileInfo;
                                            outArgumentPopup.title="";
                                            outArgumentPopup.open();
                                        }
                                    }
                                }

                                RowLayout{
                                    Layout.fillWidth: true
                                    SystemText{
                                        text:qsTr("输出路径:")
                                        Layout.minimumWidth:  100
                                        horizontalAlignment: Text.AlignRight
                                    }
                                    SystemComboBox{
                                        id:outFolderTbx
                                        Layout.fillWidth: true
                                        currentIndex:0
                                        textRole: "name"
                                        model:ListModel{
                                            id:folderList
                                            ListElement{name:""}
                                            ListElement{name:qsTr("改变目录")}
                                        }
                                        FileDialog {
                                            id: folderDialog
                                            title:qsTr("选择目录")
                                            folder:shortcuts.desktop
                                            selectFolder: true
                                            onAccepted:{
                                                folderList.setProperty(0,"name",GlobalConfig.locationFileUrl( folderDialog.folder));
                                                outFolderTbx.currentIndex=0;
                                            }
                                            onRejected: {
                                                outFolderTbx.currentIndex=0;
                                            }
                                        }
                                        onCurrentIndexChanged: {
                                            if(currentIndex==1)
                                            {
                                                folderDialog.open();
                                            }
                                        }
                                        Component.onCompleted: {
                                            folderList.setProperty(0,"name", worklist.outFileDir);
                                        }
                                    }
                                    SystemButton{
                                        id:changePathBtn
                                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                        implicitWidth: height
                                        // text: qsTr("改变目录")
                                        Layout.leftMargin: 5
                                        onClicked: {
                                            worklist.openOutFolder();
                                            Qt.openUrlExternally("file:///"+(outFolderTbx.currentText))
                                        }
                                        padding: 2
                                        indicator:Image{
                                            width:   24
                                            height:  24
                                            sourceSize:  Qt.size(width, height)
                                            anchors.centerIn: parent
                                            source:"qrc:/img/文件夹.svg"
                                            ColorOverlay{
                                                anchors.fill: parent
                                                source: parent
                                                color:changePathBtn.hovered?GlobalConfig.highlight: "#666666" //修改后的svg图片颜色
                                            }
                                        }
                                    }
                                }
                            }
                            SystemButton{
                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                implicitHeight: 35
                                implicitWidth: 115
                                backgroundColor:"#3FA1FF"/*enabled? "#3FA1FF":"#D6D6D6"*/
                                borderColor: "#3FA1FF"
                                foreground:"#ffffff"/*enabled?"#ffffff":"#666666"*/
                                text: qsTr("开始转换")
                                font.pixelSize: 16
                                enabled:  listView. checkedCount>0&& listView.runingCount==0
                                opacity: enabled?1:0.6
                                onClicked: {
                                    worklist.startup();
                                }
                            }
                        }
                    }
                }
            }
            FileDialog {
                id: fileDialog;
                selectMultiple:true
                title: qsTr("选择文件");
                nameFilters:videoRadioButton.checked? [
                                                          "Video Files ("+worklist.videoSuffixesFilters+")"
                                                      ]:
                                                      [
                                                          "Audio Files ("+worklist.audioSuffixesFilters+" "+worklist.videoSuffixesFilters+")"
                                                      ];

                onAccepted: {
                    fileAppend(fileUrls);
                }
            }

            MessageBoxPopup{
                id:outArgumentPopup
                parent:item
                width:650
                height:!fileOutArgument.videoArgument||!fileOutArgument.audioArgument?240: 400
                x:(parent.width-width)/2
                y:(parent.height-height)/2
                modal:true
                closeButtonText: qsTr("取消")
                okButtonText: qsTr("确定");
                onResult:{
                    if(isOk)
                    {
                        fileOutArgument.resultCommand();
                        if(fileOutArgument.fileInfo==null)
                        {
                            listView.outFileArgumengChanged(fileOutArgument.outFileInfo);
                        }
                    }
                    fileOutArgument.fileInfo=null;
                    fileOutArgument.outFileInfo=null;
                    outArgumentPopup.close();
                }

                FileOutArgument{
                    id:fileOutArgument
                    anchors.fill: parent
                    anchors.margins: 0
                }
            }

            Worklist{
                id:worklist
                currentFileType:videoRadioButton.checked?Worklist.Video:Worklist.Audio
                outFileDir:outFolderTbx.currentText
                onVideoOutFormatChanged: {listView.formatChanged(videoOutFormat)}
                onAudioOutFormatChanged: {listView.formatChanged(audioOutFormat)}
                videoOutFileInfo.format:  videoFormatCbx.currentText
                audioOutFileInfo.format:  audioFormatCbx.currentText
                onCommandFinish: {
                    changePathBtn.clicked();
                }
                onErrorMessage: {
                    messagePopup.open();
                    messageText.text=message;
                }
            }
            Component.onCompleted:{
                worklist.addImageProvider();
            }

            function fileAppend(fileUrls)
            {
                var arr1 = [];

                for(var i=0;i<fileUrls.length;i++)
                {
                    arr1.push(GlobalConfig.locationFileUrl(fileUrls[i]));

                }
                worklist.appends(arr1);
            }

            function fileInfoProgress(index ,progress)
            {
                listView.progressChanged(index ,progress);
            }

            function commandStateToString(state)
            {
                switch(state)
                {
                case  FFmpegCommand.None:
                    return "";
                case  FFmpegCommand.Unstart:
                    return qsTr("等待中...");
                case  FFmpegCommand.Running:
                    return qsTr("转换中");
                case  FFmpegCommand.Finish:
                    return qsTr("转换完成");
                case  FFmpegCommand.Failure:
                    return qsTr("转换失败");
                }
            }

            property QtObject  currentFileInfo;
            signal start();

            Popup{
                id:messagePopup
                parent: item
                width: 400
                height: 80
                x:(parent.width-width)/2
                y:10
                exit: Transition {
                    NumberAnimation { property: "opacity"; from: 1.0; to: 0.0 }
                }

                enter: Transition {
                    NumberAnimation { property: "opacity"; from: 0.0; to: 1.0 }
                }
                background: Rectangle {
                    color: "#C4D3D0"
                    border.color: GlobalConfig.borderColor
                    border.width: 1
                    radius: 10
                }
                SystemText {
                    id:messageText
                    wrapMode: Text.Wrap
                    anchors.margins: 5
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment:  Text.AlignVCenter
                }

                Timer{
                    id:timer
                    interval: 1000*5
                    onTriggered: {
                        messagePopup.close();
                    }
                }

                onOpened: {
                    timer.start();
                }

            }
        }

