#include "ffmpegcommand.h"
#include <qfileinfo.h>
#include <qdir.h>
#include <QCommandLineOption>
#include <fileinfo.h>
#include <QThread>
#include <QCoreApplication>

FFmpegCommand::FFmpegCommand(QObject* parent)
    : QObject{ parent }
{
    ffmpeg=  QDir(QCoreApplication::applicationDirPath()).absoluteFilePath(ffmpeg);
    QFileInfo file(ffmpeg);
    if (!file.exists())
    {
        qFatal("not find ffmpeg");
    }

    process.setProcessChannelMode(QProcess::MergedChannels);

    QObject::connect(&process, &QProcess::readyReadStandardOutput, [&]() 
                     {
                         auto output = QString::fromUtf8(process.readAllStandardOutput());

                         QRegExp reg("time=([0-9]?[0-9]):([0-5][0-9]):([0-5][0-9])");
                         auto result = reg.indexIn(output);
                         double time = 0;
                         auto count = reg.captureCount();
                         if (result > 0&& count>=3)
                         {
                             time = reg.capturedTexts().at(1).toInt() * 3600 + reg.capturedTexts().at(2).toInt() * 60 + reg.capturedTexts().at(3).toInt();
                             m_progress = time;
                         }
                         qDebug().noquote() << "StandardOutput :" << output;
                         qDebug().noquote() << "StandardOutput m_progress:" << m_progress;

                         if (output.contains("Conversion failed"))
                         {
                             emit progressMessage("Conversion failed", 0);
                             this->m_state = FFmpegCommand::Failure;
                             emit stateChanged();
                         }
                         else
                         {
                             emit progressMessage(output, m_progress);
                         }
                     });

    QObject::connect(&process, &QProcess::readyReadStandardError, [this]() {

        auto errorOutput = process.readAllStandardError();
        emit progressMessage(errorOutput, 0);
    });

    QObject::connect(&process, static_cast<void(QProcess::*)(int, QProcess::ExitStatus)>(&QProcess::finished),
                     [&](int exitCode, QProcess::ExitStatus exitStatus)
                     {
                         this->m_state = FFmpegCommand::Finish;
                         QFileInfo outInfo(outfile);
                         if(!outInfo.exists()||outInfo.size()==0)
                         {
                             this->m_state = FFmpegCommand::Failure;
                         }
                         emit stateChanged();
                         emit finishChanged(true);
                     });
}

QString codesToName(QString codes)
{
    if (codes.compare("vorbis", Qt::CaseInsensitive) == 0)
    {
        return "libvorbis";
    }
    else if (codes.compare("opus", Qt::CaseInsensitive) == 0)
    {
        return "libopus";
    }
    else if (codes.compare("pcm", Qt::CaseInsensitive) == 0 ||
             codes.compare("amr", Qt::CaseInsensitive) == 0)
    {
        return "";
    }
    return codes.toLower();
}

bool FFmpegCommand::executeCommand(const QString input, const QString outdir,
                                   const  OutFileInfo* outInfo, const FileInfo* sourcefileInfo)
{
    QFileInfo fileInfo(input);
    QString command;

    if (!fileInfo.exists())
    {
        m_state = FFmpegCommand::Failure;
        emit stateChanged();
        emit  finishChanged(false);
        return false;
    }
    QDir dir(outdir);
    if (!dir.exists())
    {
        dir.mkpath(outdir);
    }
    if (outInfo->videoInfo()->discard() || sourcefileInfo->videoStreams()->size() == 0)
    {
        command.append(QString(" -vn"));
    }
    else
    {
        VideoInfo* videoStreams = qobject_cast<VideoInfo*> (sourcefileInfo->videoStreams()->at(0));
        ///视频
        if (!outInfo->videoInfo()->videoCodes().isEmpty())
        {
            command.append(QString(" -c:v %1").arg(outInfo->videoInfo()->videoCodes().toLower()));
        }
        if (!outInfo->videoInfo()->resolution().isEmpty())
        {
            command.append(QString(" -vf scale=%1").arg(outInfo->videoInfo()->resolution()));
        }
        if (outInfo->videoInfo()->bitRate() > 0)
        {
            command.append(QString(" -b:v %1K").arg(outInfo->videoInfo()->bitRate()));
        }
        else
        {
            if (videoStreams->bit_rate() > 0)
            {
                command.append(QString(" -b:v %1K").arg(videoStreams->bit_rate() / 1024));
            }
            else if (sourcefileInfo->overallBitRate() > 0)
            {
                command.append(QString(" -b:v %1K").arg(sourcefileInfo->overallBitRate() / 1024));
            }
        }

        if (outInfo->videoInfo()->frameRate() > 0)
        {
            command.append(QString(" -r %1").arg(outInfo->videoInfo()->frameRate()));
        }
        else  if (videoStreams->frame_rate() > 0)
        {
            command.append(QString(" -r %1").arg(videoStreams->frame_rate()));
        }
    }
    ///音频
    if (outInfo->audioInfo()->discard() || sourcefileInfo->audioStreams()->size() == 0)
    {
        command.append(QString(" -an"));
    }
    else
    {
        AudioInfo* audioStreams = qobject_cast<AudioInfo*> (sourcefileInfo->audioStreams()->at(0));
        auto audioCodes = codesToName(outInfo->audioInfo()->audioCodes());
        if (!audioCodes.isEmpty())
        {
            command.append(QString(" -acodec %1").arg(audioCodes));
        }

        if (outInfo->audioInfo()->audioCodes().compare("amr", Qt::CaseInsensitive) == 0)
        {
            outInfo->audioInfo()->setChannels(1);
            outInfo->audioInfo()->setAudioSamplefmt(8000);
        }
        //      

        if (outInfo->format().compare("wmv", Qt::CaseInsensitive) == 0)
        {
            if (outInfo->audioInfo()->audioSamplefmt() > 48000)
            {
                outInfo->audioInfo()->setAudioSamplefmt(48000);
            }
            else if (outInfo->audioInfo()->audioSamplefmt() == 0)
            {
                if (sourcefileInfo->audioStreams()->size() > 0)
                {
                    AudioInfo* info = qobject_cast<AudioInfo*> (sourcefileInfo->audioStreams()->at(0));
                    if (info->sample_rate() > 48000)
                    {
                        outInfo->audioInfo()->setAudioSamplefmt(48000);
                    }
                }
            }
        }

        if (outInfo->format().compare("M4R", Qt::CaseInsensitive) == 0)
        {
            command.append(QString(" -f ipod").arg(outInfo->audioInfo()->bitRate()));
        }

        if (outInfo->audioInfo()->audioCodes().compare("ac3", Qt::CaseInsensitive) == 0 ||
            outInfo->format().compare("ac3", Qt::CaseInsensitive) == 0)
        {
            if (outInfo->audioInfo()->audioSamplefmt() > 48000 || outInfo->audioInfo()->audioSamplefmt() < 32000)
            {
                outInfo->audioInfo()->setAudioSamplefmt(48000);
            }
            else if (outInfo->audioInfo()->audioSamplefmt() == 0)
            {

                if (audioStreams->sample_rate() > 48000 || audioStreams->sample_rate() < 32000)
                {
                    outInfo->audioInfo()->setAudioSamplefmt(48000);
                }
            }
        }

        if (outInfo->audioInfo()->channels() > 0)
        {
            command.append(QString(" -ac %1").arg(outInfo->audioInfo()->channels()));
        }
        else {

        }
        if (outInfo->audioInfo()->audioSamplefmt() > 0)
        {
            command.append(QString(" -ar %1").arg(outInfo->audioInfo()->audioSamplefmt()));
        }

        if (outInfo->audioInfo()->bitRate() > 0)
        {
            if (outInfo->audioInfo()->audioCodes().compare("vorbis", Qt::CaseInsensitive) == 0 &&
                (outInfo->audioInfo()->bitRate() > 480 || outInfo->audioInfo()->bitRate() < 48))
            {
                command.append(QString(" -b:a %1K").arg(256));
            }
            else
            {
                command.append(QString(" -b:a %1K").arg(outInfo->audioInfo()->bitRate()));
            }
        }
        else
        {
            auto bitRate = audioStreams->bit_rate() / 1024;
            if (bitRate <= 0)
            {
                bitRate = 192;
            }
            if (bitRate > 0)
            {
                if (outInfo->audioInfo()->audioCodes().compare("vorbis", Qt::CaseInsensitive) == 0 &&
                    (bitRate > 480 || bitRate < 48))
                {
                    command.append(QString(" -b:a %1K").arg(256));
                }
                else
                {
                    command.append(QString(" -b:a %1K").arg(bitRate));
                }
            }
        }
    }

    outfile = QString("%1/%2.%3").arg(outdir).arg(fileInfo.completeBaseName()).arg(outInfo->format());

    int index = 1;
    while (QFile::exists(outfile))
    {
        outfile = QString("%1/%2_%4.%3").arg(outdir).arg(fileInfo.completeBaseName()).arg(outInfo->format()).arg(index++);
    }
    m_progress = 0;
    auto  arguments = QStringList() << QString::fromUtf8("-i \"%1\" %3 -y \"%2\"").arg(input).arg(outfile).arg(command).replace("\\", "/");
    process.start(QString::fromUtf8("\"%1\" %2").arg(ffmpeg).arg(arguments[0]));
    qDebug().noquote() << "ffmpegCommand :" << arguments[0];

    auto result = process.waitForStarted();

    if (result)
    {
        m_state = FFmpegCommand::Running;
    }
    else
    {
        m_state = FFmpegCommand::Failure;
        emit  finishChanged(false);
    }
    emit stateChanged();
    QThread::msleep(500);
    return result;
}

FFmpegCommand::CommandState FFmpegCommand::state() const
{
    return m_state;
}

double FFmpegCommand::progress() const
{
    return m_progress;
}

bool FFmpegCommand::awaitStart()
{
    if (this->m_state == FFmpegCommand::None||
        this->m_state== FFmpegCommand::Finish||
        this->m_state== FFmpegCommand::Failure)
    {
        this->m_state = FFmpegCommand::Unstart;
        emit stateChanged();
        return true;
    }
    else {
        return false;
    }
}

bool  FFmpegCommand::cancel()
{
    this->m_state = FFmpegCommand::None;
    m_progress = 0;
    emit progressMessage("process stop", m_progress);
    if (process.state() == QProcess::ProcessState::Running)
    {
        process.kill();
        process.waitForFinished(1000 * 3);
        if (!outfile.isEmpty())
        {
            if (QFileInfo::exists(outfile))
            {
                QFile::remove(outfile);
            }
        }
    }
    this->m_state = FFmpegCommand::None;
    emit stateChanged();
    return true;
}
