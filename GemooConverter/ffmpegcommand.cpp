#include "ffmpegcommand.h"
#include <qfileinfo.h>
#include <QCommandLineOption>

FFmpegCommand::FFmpegCommand(QObject* parent)
    : QObject{ parent }
{
    QFileInfo file(ffmpeg);
    ffmpeg = file.absoluteFilePath();
    if (!file.exists())
    {
        qFatal("not find ffmpeg");
    }

    process.setProcessChannelMode(QProcess::MergedChannels);
    //process.setProgram(ffmpeg);
    QObject::connect(&process, &QProcess::readyReadStandardOutput, [&]() {
        auto output = QString::fromUtf8(process.readAllStandardOutput());

        QRegExp reg("([0-9]?[0-9]):([0-5][0-9]):([0-5][0-9])");        
        auto result = reg.indexIn(output);
        double time=0;
        if(result>0)
        {
            time=reg.capturedTexts().at(1).toInt()*3600+ reg.capturedTexts().at(2).toInt()*60+reg.capturedTexts().at(3).toInt();
        }
        emit porcessMessage(output,time);
    });

    QObject::connect(&process, &QProcess::readyReadStandardError, [&]() {
        auto errorOutput = process.readAllStandardError();
        //	qDebug() << errorOutput;
        emit porcessMessage(errorOutput,0);
    });

    QObject::connect(&process, static_cast<void(QProcess::*)(int, QProcess::ExitStatus)>(&QProcess::finished), [&](int exitCode, QProcess::ExitStatus exitStatus) {

        emit  finish(true);
    });
}

bool FFmpegCommand::executeCommand(QString input, QString output, QString commands)
{
    auto  arguments = QStringList() << QString::fromUtf8("-i %1 %3 -y %2").arg(input).arg(output).arg(commands).replace("\\", "/");
    process.start(QString::fromUtf8("%1 %2").arg(ffmpeg).arg(arguments[0]));
    auto result = process.waitForStarted();
    return result;
}
