#include "fileinfo_plugin.h"

#include "fileinfo.h"

#include <qqml.h>
#include <listviewmodel.h>
#include <worklist.h>
#include <QQmlApplicationEngine>
#include <outfileinfo.h>
#include <ffmpegcommand.h>

void FileInfoPlugin::registerTypes(const char* uri)
{
    // @uri FileInfo
    qmlRegisterType<FileInfo>(uri, 1, 0, "FileInfo");
    qmlRegisterType<Worklist>(uri, 1, 0, "Worklist");
    qmlRegisterType<FFmpegCommand>(uri, 1, 0, "FFmpegCommand");

    qmlRegisterType(QUrl("qrc:/FileInfoView.qml"), uri, 1, 0, "FileInfoView");

    qmlRegisterUncreatableType<ListViewModel>(uri, 1, 0, "ListViewModel", "ListViewModel create not");
    qmlRegisterUncreatableType<OutFileInfo>(uri, 1, 0, "OutFileInfo", "OutFileInfo create not");
    qmlRegisterUncreatableType<OutAudioInfo>(uri, 1, 0, "OutAudioInfo", "OutAudioInfo create not");
    qmlRegisterUncreatableType<OutVideoInfo>(uri, 1, 0, "OutVideoInfo", "OutVideoInfo create not");

    //QQmlApplicationEngine::
    //m_pImgProvider
}
