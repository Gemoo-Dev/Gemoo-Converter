pragma Singleton
import QtQuick 2.15
import QtQuick.Window 2.15
import QtQml 2.15
import QtQuick.Controls 2.15

QtObject {

    property var dateRegExp:RegExp("(([0-9]{3}[1-9]|[0-9]{2}[1-9][0-9]{1}|[0-9]{1}[1-9][0-9]{2}|[1-9][0-9]{3})-(((0[13578]|1[02])-(0[1-9]|[12][0-9]|3[01]))|((0[469]|11)-(0[1-9]|[12][0-9]|30))|(02-(0[1-9]|[1][0-9]|2[0-8]))))|((([0-9]{2})(0[48]|[2468][048]|[13579][26])|((0[48]|[2468][048]|[3579][26])00))-02-29)")
    property var timeRegExp:RegExp("([0-1]?[0-9]|2[0-3]):([0-5][0-9]):([0-5][0-9])")
    property var dateTimeRegExp:RegExp("((([0-9]{3}[1-9]|[0-9]{2}[1-9][0-9]{1}|[0-9]{1}[1-9][0-9]{2}|[1-9][0-9]{3})-(((0[13578]|1[02])-(0[1-9]|[12][0-9]|3[01]))|((0[469]|11)-(0[1-9]|[12][0-9]|30))|(02-(0[1-9]|[1][0-9]|2[0-8]))))|((([0-9]{2})(0[48]|[2468][048]|[13579][26])|((0[48]|[2468][048]|[3579][26])00))-02-29)) ([0-1]?[0-9]|2[0-3]):([0-5][0-9]):([0-5][0-9])")

    property var dateTimeRegex :RegExpValidator{
        regExp:dateTimeRegExp
    }

    property var font:Qt.font({pixelSize: 13})
    property color borderColor: "#dDdDdD"
    property color highlight : "#0078D7"
    property color selectionColor : "#0078D7"
    property color selectedTextColor : "#ffffff"


    function intToTimeString( duration)
    {
        var h=Math.floor(duration/3600);
        var m=Math.floor((duration-3600*h)/60);
        var s=Math.floor(duration-3600*h-m*60);
        return ("%1:%2:%3").
        arg(h.toString().padStart(2,'0')).
        arg(m.toString().padStart(2,'0')).
        arg(s.toString().padStart(2,'0'))
    }
    function intToSize(size)
    {
        if(size>1024*1024*1024){
            return ("%1 Gb").arg((size/(1024.0*1024*1024)).toFixed(2))
        }
        else if(size>1024*1024){
            return ("%1 Mb").arg((size/(1024.0*1024)).toFixed(2))
        }
        else if(size>1024){
            return ("%1 Kb").arg((size/1024.0).toFixed(2))
        }
        else{
            return ("%1 B").arg((size).toFixed(2))
        }
    }

    function locationFileUrl(url)
    {

        if(Qt.platform.os === "windows"){
            return  decodeURIComponent( String(url).replace(/^(file:\/{3})/,""));
        }
        else if(Qt.platform.os === "osx")
        {
            return  decodeURIComponent(String(url).replace(/^(file:\/{2})/,""));
        }
    }

    property var videoFormat:  ListModel{

        ListElement{ name:"MP4"}
        ListElement{ name:"MOV" }
        ListElement{ name:"MKV"}
        ListElement{ name:"M4V"}
        ListElement{ name:"AVI"}
        ListElement{ name:"WMV"}
        ListElement{ name:"WEBM"}
        ListElement{ name:"FLV"}
        ListElement{ name:"TS"}
    }

    property var audioFormat:  ListModel{
        ListElement{ name:"MP3"}
        ListElement{ name:"M4A"}// mp4
        ListElement{ name:"WAV"}
        ListElement{ name:"M4R"}
        ListElement{ name:"AIFF"}
        ListElement{ name:"FLAC"}
        ListElement{ name:"AC3"}
        ListElement{ name:"AAC"}
        ListElement{ name:"OGG"}
        ListElement{ name:"CAF"}
        ListElement{ name:"AMR"}
        ListElement{ name:"MP2"}
    }

    property var audioCodes: ListModel{
        ListElement{ name:"AAC"}
        ListElement{ name:"AC3"}
        ListElement{ name:"OPUS"}
    }

    property var videoCodes: ListModel{
        ListElement{ name:"MPEG4"}
        ListElement{ name:"H264" }
        ListElement{ name:"HEVC"}
        ListElement{ name:"VP9"}
    }

    function videoCodesFromFormat(format)
    {
        switch(format.toLowerCase()){

        case "mp4":
        case "mkv":
            return "h264,hevc,mpeg4,vp9";
        case "m4v":
            return "h264,mpeg4";
        case "mov":
        case "ts":
            return "h264,hevc,mpeg4";
        case "avi":
        case "wmv":
            return "h264,mpeg4,vp9";
        case "webm":
            return "vp9";//vp8
        case "flv":
            return "h264";//mp3
        }
        return "";
    }

    function audioCodesFromFormat(format)
    {
        switch(format.toLowerCase())
        {
        case "mp3":
            return "mp3";//"mp3";
        case "wav":
            return "pcm_u8";//"pcm";
        case "m4r"://-f ipod
            return "aac";//"aac";
        case "aiff"://aac
            return "pcm_s16be";
        case "flac"://pcm
            return "flac";
        case "ac3":
            return "ac3";
        case "aac":
            return "aac";
        case "caf":
            return "pcm_s16be";//pcm 16-se
        case "amr":// -ar 8000 -ab 500k -ac 1
            return "amr";//"amr-nb"
        case "mp2":
            return "ac3";//ac3 mpeg            mpeg-1 systems / mpeg program stream
        case "m4a":
        case "mov":
        case "m4v":
        case "avi":
        case "wmv":
        case "ts":
            return "aac,ac3";
        case "mp4":
        case "mkv":
            return "aac,ac3,opus";
        case "ogg":
        case "webm":
            return "vorbis,opus";
        case "flv":
            return "aac,mp3";
        }
        return "";
    }

    function audioSampleFmtFromCodes(codes)
    {
        switch(codes.toLowerCase())
        {
        case "vorbis":
        case "wmav2":
            return "44100,32000,48000";
        case "mp3":
            return "44100,11025,32000,48000";
        case "ac3":
            return "44100,32000,48000";
        case "aac":      
        case "flac":
        case "pcm_s16be":
        case "pcm_u8":
            return "44100,11025,32000,48000,96000";
        case "opus":
            return "48000";
        case "amr":
            return "8000";
        }
        return "";
    }

    function audioChannelsFmtFromCodes(codes)
    {
        switch(codes.toLowerCase())
        {
        case "wmav2":
        case "mp3":
        case "aac":
        case "ac3":
        case "flac":
        case "pcm_s16be":
        case "pcm_u8":
            return "2,1";
        case "opus":
        case "vorbis":
            return "2";
        case "amr":
            return "1";
        }
        return "";
    }

    function defaultValue(valueString)
    {
        if(!valueString.includes(","))
        {
            return valueString;
        }

        var values=valueString.split(",");
        if(values.length>0)
        {
            return values[0];
        }
        return valueString;
    }

    function defaultValue2(valueString,value)
    {
        if(!valueString.includes(","))
        {
            return valueString;
        }

        var values=valueString.split(",");
        if(values.length>0)
        {
            for(var i=0;i<values.length;i++)
            {
                var ccc=   values[i];
                if(values[i]==value){
                    return value;
                }
            }
        }
        return values[0];
    }

    function comboboxCurrentText(comboBox,currentText)
    {
        var items= comboBox.model;
        for(var i=0;i<items.count;i++)
        {
            if(items.get(i)[comboBox.textRole]==currentText)
            {
                comboBox.currentIndex=i;
                return true;
            }
        }
        return false;
    }

    function listModelContains(list,textRole,value)
    {
        for(var i=0;i<list.count;i++)
        {
            if(list.get(i)[textRole]==value)
            {
                return i;
            }
        }
        return -1;
    }

}
