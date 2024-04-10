import QtQml 2.15
import QtQuick 2.15
import QtQuick.Layouts 1.12
import FileInfo 1.0
import Style 1.0
Item {
    property QtObject  fileInfo;
    property OutFileInfo outFileInfo;
    property bool audioArgument: true
    property bool videoArgument: true
    property string format;
    property string autoName: qsTr("自动");
    property string defaultName: qsTr("默认");
    property string aboriginalName: qsTr("原始");

    // onFormatChanged: {
    //     var formatAudioCodes=GlobalConfig.audioCodesFromFormat(format).split(",");
    //     setComboboxItem(audioCodes,GlobalConfig.audioCodesFromFormat(format));
    //     audioCodesCbx.currentIndex=0;

    //     setComboboxItem(videocodecId,GlobalConfig.videoCodesFromFormat(format));
    //     videoCodesCbx.currentIndex=0;
    // }
    function setComboboxItem(listModel,values)
    {
        listModel.clear();
        var v=  values.split(",");
        if(v.length>0)
        {
            listModel.append({name:String("%1(%2)").arg(defaultName).arg(v[0]),value:v[0]});
            for(var i=1;i<v.length;i++)
            {
                listModel.append({name:v[i].trim(),value:v[i]});
            }
        }
    }

    onFileInfoChanged:
    {
        if(fileInfo!=null&&fileInfo.videoStreams.size()>0)
        {

            videoResolution.setProperty(0,"name",String("%1(%2X%3)").arg(aboriginalName)
                                        .arg( fileInfo.videoStreams.data(0,"width"))
                                        .arg(fileInfo.videoStreams.data(0,"height")))

            videoframeRate.setProperty(0,"name",String("%1(%2FPS)").arg(aboriginalName)
                                       .arg(Math.floor(fileInfo.videoStreams.data(0,"frame_rate").toFixed(0))))

            var videoB_R=fileInfo.videoStreams.data(0,"bit_rate");

            if(videoB_R>0)
            {
                videoBitRate.setProperty(0,"name",String("%1(%2Kbps)").arg(aboriginalName).arg( (videoB_R/1024).toFixed(0)))
            }
            else
            {
                videoBitRate.setProperty(0,"name",aboriginalName)
            }
        }
        else
        {
            videocodecId.setProperty(0,"name",autoName);

            videoResolution.setProperty(0,"name",autoName);

            videoframeRate.setProperty(0,"name",autoName);

            videoBitRate.setProperty(0,"name",autoName);
        }

        if(fileInfo!=null&&fileInfo.audioStreams.size()>0)
        {
            var audioB_R=fileInfo.audioStreams.data(0,"bit_rate");
            if(audioB_R>0)
            {
                audioBitRate.setProperty(0,"name",String("%1(%2Kbps)").arg(aboriginalName).arg((audioB_R/1024).toFixed(0)))
            }
            else
            {
                audioBitRate.setProperty(0,"name",aboriginalName)
            }
        }
        else
        {
            audioCodes.setProperty(0,"name",autoName);

            audioChannels.setProperty(0,"name",autoName);

            audioSample_fmt.setProperty(0,"name",autoName);

            audioBitRate.setProperty(0,"name",autoName);
        }

        if(fileInfo!=null)
        {
            outFileInfo= fileInfo.outFileInfo;
        }
    }

    onOutFileInfoChanged:{

        if(outFileInfo!=null)
        {
            format=  outFileInfo.format

            var formatAudioCodes=GlobalConfig.audioCodesFromFormat(format).split(",");
            setComboboxItem(audioCodes,GlobalConfig.audioCodesFromFormat(format));
            audioCodesCbx.currentIndex=0;

            setComboboxItem(videocodecId,GlobalConfig.videoCodesFromFormat(format));
            videoCodesCbx.currentIndex=0;
        }

        if(videoArgument)
        {
            videoCodesCbx.currentIndex=0;
            resolutionCombobox.currentIndex=0;
            frameRateCbx.currentIndex=0;
            bitRateCbx.currentIndex=0;

            if(outFileInfo!=null&&outFileInfo.videoInfo!=null)
            {
                if(outFileInfo.videoInfo.videoCodes.length>0)
                {
                    GlobalConfig.comboboxCurrentText(videoCodesCbx,outFileInfo.videoInfo.videoCodes);
                }

                if(outFileInfo.videoInfo.resolution.length>0)
                {
                    if(!GlobalConfig.comboboxCurrentText(resolutionCombobox,outFileInfo.videoInfo.resolution))
                    {
                        resolutionCombobox.currentIndex=1;
                        resolutionWidthBox.value= outFileInfo.videoInfo.resolution.split("X")[0];
                        resolutionHeightBox.value= outFileInfo.videoInfo.resolution.split("X")[1];
                    }
                }

                if(outFileInfo.videoInfo.frameRate>0)
                {
                    GlobalConfig.comboboxCurrentText(frameRateCbx,outFileInfo.videoInfo.frameRate.toFixed(0)+"FPS")
                }
                if(outFileInfo.videoInfo.bitRate>0)
                {
                    if(!GlobalConfig.comboboxCurrentText(bitRateCbx,outFileInfo.videoInfo.bitRate.toFixed(0)+"Kbps"))
                    {
                        bitRateCbx.currentIndex=1;
                        videoBitRateBox.value=outFileInfo.videoInfo.bitRate;
                    }
                }
                audiodiscardCbx.checked=outFileInfo.audioInfo.discard;
            }
        }
        else
        {
            audiodiscardCbx.checked=false;
        }

        if(audioArgument)
        {
            audioCodesCbx.currentIndex=0;
            audioChannelsCbx.currentIndex=0;
            audioSample_fmtCbx.currentIndex=0;
            audioBitRateCbx.currentIndex=0;

            if(outFileInfo!=null&&outFileInfo.audioInfo!=null)
            {
                GlobalConfig.comboboxCurrentText(audioCodesCbx,outFileInfo.audioInfo.audioCodes);

                GlobalConfig.comboboxCurrentText(audioChannelsCbx,outFileInfo.audioInfo.channels);

                GlobalConfig.comboboxCurrentText(audioSample_fmtCbx,String("%1").arg(outFileInfo.audioInfo.audioSamplefmt));

                if(outFileInfo.audioInfo.bitRate>0)
                {
                    if(!GlobalConfig.comboboxCurrentText(audioBitRateCbx,String("%1Kbps").arg(outFileInfo.audioInfo.bitRate)))
                    {
                        audioBitRateCbx.currentIndex=1;
                        audioBitRateBox.value=outFileInfo.audioInfo.bitRate;
                    }
                }
            }
        }
    }


    ColumnLayout{
        anchors.fill: parent
        Rectangle{
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible:videoArgument//!audioOnly&& (fileInfo!=null&&fileInfo.videoStreams!==null&& fileInfo.videoStreams.size()>0)
            GridLayout{
                anchors.horizontalCenter:  parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: 5
                columnSpacing: 30
                columns: 2
                SystemText
                {
                    text:qsTr("视频设置")
                    font.bold: true
                    Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                    Layout.columnSpan: 2
                    height:  50
                }
                TitleCombobox{
                    id:videoCodesCbx
                    title:qsTr("编码器:")
                    textRole:"name"
                    model:ListModel{
                        id:videocodecId
                        ListElement{ name:qsTr("自动")}
                        ListElement{ name:"MPEG4"}
                        ListElement{ name:"H264" }
                        ListElement{ name:"HEVC"}
                        ListElement{ name:"VP9"}
                    }
                }
                TitleCombobox{
                    id:resolutionCombobox
                    title:qsTr("分辨率:")
                    width: parent.width
                    textRole:"name"
                    model:ListModel{
                        id:videoResolution
                        ListElement{ name:qsTr("自动")}
                        ListElement{ name:qsTr("自定义")}
                        ListElement{ name:"3840X2160"}
                        ListElement{ name:"2560X1440" }
                        ListElement{ name:"1920X1080"}
                        ListElement{ name:"1280X720"}
                        ListElement{ name:"720X480"}
                        ListElement{ name:"640X480"}
                    }
                    Rectangle{
                        anchors.fill: parent
                        visible: resolutionCombobox.currentIndex==1
                        RowLayout{
                            anchors.fill: parent
                            SystemNumberBox{
                                id:resolutionWidthBox
                                from: 100
                                to:10000
                                Layout.fillWidth: true
                            }
                            SystemText{
                                text: "X"
                            }
                            SystemNumberBox{
                                id:resolutionHeightBox
                                from: 100
                                to:10000
                                Layout.fillWidth: true
                            }
                        }
                    }

                }
                TitleCombobox{
                    id:frameRateCbx
                    title:qsTr("帧率:")
                    textRole:"name"
                    model:ListModel{
                        id:videoframeRate
                        ListElement{ name:qsTr("自动")}
                        ListElement{ name:"8FPS"}
                        ListElement{ name:"12FPS"}
                        ListElement{ name:"15FPS"}
                        ListElement{ name:"24FPS"}
                        ListElement{ name:"25FPS"}
                        ListElement{ name:"30FPS"}
                        ListElement{ name:"40FPS"}
                        ListElement{ name:"50FPS"}
                        ListElement{ name:"60FPS"}
                    }
                }
                TitleCombobox{
                    id:bitRateCbx
                    title:qsTr("比特率:")
                    textRole:"name"
                    model:ListModel{
                        id:videoBitRate
                        ListElement{ name:qsTr("自动")}
                        ListElement{ name:qsTr("自定义")}
                        ListElement{ name:"250Kbps"}
                        ListElement{ name:"2000Kbps" }
                        ListElement{ name:"5000Kbps"}
                        ListElement{ name:"8000Kbps"}
                        ListElement{ name:"16000Kbps"}
                        ListElement{ name:"25000Kbps"}
                    }
                    TitleNumberBox{
                        id:videoBitRateBox
                        titleWidth:0
                        anchors.verticalCenter: parent.verticalCenter
                        visible: bitRateCbx.currentIndex==1
                        unit: "Kbps"
                        to:50000
                        from:250
                        anchors.fill: parent
                    }
                }
            }
        }
        Rectangle{
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible:audioArgument//fileInfo!=null&&fileInfo.audioStreams!=null&& fileInfo.audioStreams.size()>0
            GridLayout{
                anchors.horizontalCenter:  parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                columnSpacing: 30
                columns: 2
                anchors.margins: 5
                Item{
                    Layout.columnSpan: 2
                    Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                    implicitHeight: 50
                    SystemText {
                        id:audiotext
                        text:qsTr("音频设置")
                        font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    SystemCheckBox{
                        id:audiodiscardCbx
                        text: qsTr("静音")
                        anchors.left: audiotext.right
                        anchors.leftMargin: 10
                        visible: videoArgument
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                TitleCombobox{
                    id:audioCodesCbx
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                    title:qsTr("编码器:")
                    textRole:"name"
                    model:ListModel{
                        id:audioCodes
                        ListElement{ name:qsTr("自动")}
                        ListElement{ name:"AAC"}
                        ListElement{ name:"AC3" }
                        ListElement{ name:"OPUS"}
                    }
                    onCurrentIndexChanged: {
                        var codes="";
                        if(currentIndex>=0)
                        {
                            codes=audioCodes.get(currentIndex)["value"];
                        }
                        setComboboxItem(audioChannels,GlobalConfig.audioChannelsFmtFromCodes(codes));
                        setComboboxItem(audioSample_fmt,GlobalConfig.audioSampleFmtFromCodes(codes));
                        audioSample_fmtCbx.currentIndex=0;
                        audioChannelsCbx.currentIndex=0;
                        if(outFileInfo!=null)
                        {
                            if(outFileInfo.audioInfo.audioSamplefmt>0)
                            {
                                var index= GlobalConfig.listModelContains(audioSample_fmt,"value",outFileInfo.audioInfo.audioSamplefmt);
                                if(index>=0)
                                {
                                    audioSample_fmtCbx.currentIndex=index;
                                }
                            }
                            if(outFileInfo.audioInfo.channels>0)
                            {
                                var index= GlobalConfig.listModelContains(audioChannels,"value",outFileInfo.audioInfo.channels);
                                if(index>=0)
                                {
                                    audioChannelsCbx.currentIndex=index;
                                }
                            }
                        }
                    }
                }

                TitleCombobox{
                    id:audioChannelsCbx
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                    title:qsTr("声道:")
                    textRole:"name"
                    model:ListModel{
                        id:audioChannels
                        ListElement{ name:qsTr("自动")}
                        ListElement{ name:"1"}
                        ListElement{ name:"2"}
                    }
                }
                TitleCombobox{
                    id:audioSample_fmtCbx
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                    title:qsTr("采样率:")
                    textRole:"name"
                    model:ListModel{
                        id:audioSample_fmt
                        ListElement{ name:qsTr("自动")}
                        ListElement{ name:"8000HZ"}
                        ListElement{ name:"11025HZ"}
                        ListElement{ name:"32000HZ"}
                        ListElement{ name:"44100HZ"}
                        ListElement{ name:"48000HZ"}
                        ListElement{ name:"96000HZ"}
                    }
                }
                TitleCombobox{
                    id:audioBitRateCbx
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                    title:qsTr("比特率:")
                    textRole:"name"
                    model:ListModel{
                        id:audioBitRate
                        ListElement{ name:qsTr("自动")}
                        ListElement{ name:qsTr("自定义")}
                        ListElement{ name:"64Kbps"}
                        ListElement{ name:"128Kbps" }
                        ListElement{ name:"160Kbps"}
                        ListElement{ name:"192Kbps"}
                        ListElement{ name:"256Kbps"}
                        ListElement{ name:"320Kbps"}
                    }
                    TitleNumberBox{
                        id:audioBitRateBox
                        implicitWidth: 150
                        titleWidth:0
                        visible: audioBitRateCbx.currentIndex==1
                        unit: "Kbps"
                        to:512
                        from:64
                        anchors.fill: parent
                    }
                }
            }
        }
    }

    function resultCommand()
    {
        if(videoArgument)
        {
            if(videoCodesCbx.currentIndex>=0){

                outFileInfo.videoInfo.videoCodes=videocodecId.get(videoCodesCbx.currentIndex)["value"];
            }
            else{
                outFileInfo.videoInfo.videoCodes="";
            }

            if(resolutionCombobox.currentIndex>1)
            {
                outFileInfo.videoInfo.resolution=resolutionCombobox.currentText;
            }
            else if(resolutionCombobox.currentIndex==1)
            {
                outFileInfo.videoInfo.resolution=String("%0X%1").arg( resolutionWidthBox.value).arg(resolutionHeightBox.value);
            }
            else
            {
                outFileInfo.videoInfo.resolution="";
            }

            if(frameRateCbx.currentIndex>0)
            {
                outFileInfo.videoInfo.frameRate=frameRateCbx.currentText.replace("FPS","");
            }
            else
            {
                outFileInfo.videoInfo.frameRate=0;
            }

            if(bitRateCbx.currentIndex==1)
            {
                outFileInfo.videoInfo.bitRate=  videoBitRateBox.value;
            }
            else if(bitRateCbx.currentIndex>1){

                outFileInfo.videoInfo.bitRate=  bitRateCbx.currentText.replace("Kbps","");
            }
            else{
                outFileInfo.videoInfo.bitRate=0;
            }
            outFileInfo.audioInfo.discard=audiodiscardCbx.checked;
        }

        if(audioArgument)
        {
            if(audioCodesCbx.currentIndex>=0)
            {
                outFileInfo.audioInfo.audioCodes=audioCodes.get(audioCodesCbx.currentIndex)["value"];
            }
            else
            {
                outFileInfo.audioInfo.audioCodes="";
            }
            if(audioChannelsCbx.currentIndex>=0)
            {
                outFileInfo.audioInfo.channels=audioChannels.get(audioChannelsCbx.currentIndex)["value"];
            }
            else
            {
                outFileInfo.audioInfo.channels=0;
            }
            if(audioSample_fmtCbx.currentIndex>=0)
            {
             var ccc=   audioSample_fmt.get(audioSample_fmtCbx.currentIndex)["value"];
                outFileInfo.audioInfo.audioSamplefmt=audioSample_fmt.get(audioSample_fmtCbx.currentIndex)["value"];
            }
            else
            {
                outFileInfo.audioInfo.audioSamplefmt=0;
            }

            if(audioBitRateCbx.currentIndex==1)
            {
                outFileInfo.audioInfo.bitRate= audioBitRateBox.value;
            }
            else if(audioBitRateCbx.currentIndex>1)
            {
                outFileInfo.audioInfo.bitRate=audioBitRateCbx.currentText.replace("Kbps","")
            }
            else
            {
                outFileInfo.audioInfo.bitRate=0;
            }

            if(outFileInfo.audioInfo.bitRate>0)
            {
                if(!GlobalConfig.comboboxCurrentText(audioBitRateCbx,String("%1Kbps").arg(outFileInfo.audioInfo.bitRate)))
                {
                    audioBitRateCbx.currentIndex=1;
                    audioBitRateBox.value=outFileInfo.audioInfo.bitRate;
                }
            }
        }
        return ;
    }

}
