#include "worklist.h"
#include <fileinfo.h>
#include <QFileInfo>
#include <QQmlEngine>
#include <QQmlContext>
#include <QStandardPaths>
#include <QFont>
#include <qmimedatabase.h>
#include <qsettings.h>
#include <qthread.h>
#include <QTimer>
#include <QtConcurrent/QtConcurrentRun>
#include <qdir.h>

ImageProvider* Worklist::thumbnailImageProvider = nullptr;

Worklist::Worklist(QObject* parent)
    : QObject{ parent }
{
    m_videoFiles = new ListViewModel(FileInfo::staticMetaObject, this);
    m_audioFiles = new ListViewModel(FileInfo::staticMetaObject, this);
    m_audioOutFileInfo = new OutFileInfo();
    m_videoOutFileInfo = new OutFileInfo();

    QMimeDatabase db;
    foreach(auto mime, db.allMimeTypes())
    {
        if (mime.name().startsWith("video/"))
        {
            if (mime.suffixes().size() > 0)
                videoSuffixes.append(mime.suffixes());
        }
        else  if (mime.name().startsWith("audio/"))
        {
            if (mime.suffixes().size() > 0)
                audioSuffixes.append(mime.suffixes());
        }
    }
    m_videoSuffixesFilters = videoSuffixes.join(" *.");
    m_audioSuffixesFilters = audioSuffixes.join(" *.");

    if (!m_videoSuffixesFilters.startsWith("*"))
    {
        m_videoSuffixesFilters.insert(0, "*.");
    }
    if (!m_audioSuffixesFilters.startsWith("*"))
    {
        m_audioSuffixesFilters.insert(0, "*.");
    }

    settingPath=   QDir(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) ).absoluteFilePath("setting.ini");

    if (QFile::exists(settingPath))
    {
        QSettings settings(settingPath, QSettings::Format::IniFormat);

        if(settings.value("outFileDir").toString().length()>0)
        {
            m_outFileDir = settings.value("outFileDir").toString();
        }       

        m_audioOutFormat = settings.value("audioOutFormat").toString();

        m_videoOutFormat = settings.value("videoOutFormat").toString();

        m_audioOutFileInfo->audioInfo()->setAudioCodes(settings.value("audio_audioCodes").toString());
        m_audioOutFileInfo->audioInfo()->setChannels(settings.value("audio_audioChannels").toInt());
        m_audioOutFileInfo->audioInfo()->setAudioSamplefmt(settings.value("audio_audioSamplefmt").toInt());
        m_audioOutFileInfo->audioInfo()->setBitRate(settings.value("audio_audioBitRate").toFloat());
        m_audioOutFileInfo->audioInfo()->setDiscard(settings.value("audio_audioDiscard").toBool());

        m_videoOutFileInfo->audioInfo()->setAudioCodes(settings.value("video_audioCodes").toString());
        m_videoOutFileInfo->audioInfo()->setChannels(settings.value("video_audioChannels").toInt());
        m_videoOutFileInfo->audioInfo()->setAudioSamplefmt(settings.value("video_audioSamplefmt").toInt());
        m_videoOutFileInfo->audioInfo()->setBitRate(settings.value("video_audioBitRate").toFloat());
        m_videoOutFileInfo->audioInfo()->setDiscard(settings.value("video_audioDiscard").toBool());

        m_videoOutFileInfo->videoInfo()->setVideoCodes(settings.value("video_videoCodes").toString());
        m_videoOutFileInfo->videoInfo()->setResolution(settings.value("video_videoResolution").toString());
        m_videoOutFileInfo->videoInfo()->setFrameRate(settings.value("video_videoFrameRate").toFloat());
        m_videoOutFileInfo->videoInfo()->setBitRate(settings.value("video_videoBitRate").toFloat());
        m_videoOutFileInfo->videoInfo()->setDiscard(settings.value("video_videoDiscard").toBool());
    }
    if(m_outFileDir.isEmpty())
    {
#ifdef Q_OS_WIN
        m_outFileDir="C:/GemooConverter";
#endif

#ifdef Q_OS_LINUX

#endif

#ifdef Q_OS_MAC
        m_outFileDir=QStandardPaths::writableLocation(QStandardPaths::MoviesLocation)+"/GemooConverter";
#endif
    }
}

Worklist::~Worklist()
{
    QSettings settings(settingPath, QSettings::Format::IniFormat);
    settings.setValue("outFileDir", m_outFileDir);
    settings.setValue("audioOutFormat", m_audioOutFormat);
    settings.setValue("videoOutFormat", m_videoOutFormat);

    settings.setValue("audio_audioCodes", m_audioOutFileInfo->audioInfo()->audioCodes());
    settings.setValue("audio_audioChannels", m_audioOutFileInfo->audioInfo()->channels());
    settings.setValue("audio_audioSamplefmt", m_audioOutFileInfo->audioInfo()->audioSamplefmt());
    settings.setValue("audio_audioBitRate", m_audioOutFileInfo->audioInfo()->bitRate());
    settings.setValue("audio_audioDiscard", m_audioOutFileInfo->audioInfo()->discard());


    settings.setValue("video_audioCodes", m_videoOutFileInfo->audioInfo()->audioCodes());
    settings.setValue("video_audioChannels", m_videoOutFileInfo->audioInfo()->channels());
    settings.setValue("video_audioSamplefmt", m_videoOutFileInfo->audioInfo()->audioSamplefmt());
    settings.setValue("video_audioBitRate", m_videoOutFileInfo->audioInfo()->bitRate());
    settings.setValue("video_audioDiscard", m_videoOutFileInfo->audioInfo()->discard());


    settings.setValue("video_videoCodes", m_videoOutFileInfo->videoInfo()->videoCodes());
    settings.setValue("video_videoResolution", m_videoOutFileInfo->videoInfo()->resolution());
    settings.setValue("video_videoFrameRate", m_videoOutFileInfo->videoInfo()->frameRate());
    settings.setValue("video_videoBitRate", m_videoOutFileInfo->videoInfo()->bitRate());
    settings.setValue("video_videoDiscard", m_videoOutFileInfo->videoInfo()->discard());

    // delete m_videoFiles;
    // delete m_audioFiles;
}

ListViewModel* Worklist::videoFiles() const
{
    return m_videoFiles;
}

bool Worklist::addImageProvider()
{
    if (thumbnailImageProvider == nullptr)
    {
        thumbnailImageProvider = new ImageProvider(this);
        connect(thumbnailImageProvider, &ImageProvider::request, this, &Worklist::onRequest);
        auto context = QQmlEngine::contextForObject(this);
        auto engine = context->engine();
        engine->addImageProvider(("thumbnail"), thumbnailImageProvider);
    }
    return true;
}

bool Worklist::appends(QVariantList urls)
{
    QObjectList  list;
    QString message;
    bool errorType=false;
    bool errorType2=false;
    foreach (auto url , urls)
    {
        if (QFileInfo::exists(url.toString()))
        {
            FileInfo* info = new FileInfo(this);
            QQmlEngine::setObjectOwnership(info, QQmlEngine::CppOwnership);
            info->setCompleteName(url.toString());

            if (info->videoStreams()->size() == 0 && info->audioStreams()->size() == 0)
            {
                errorType=true;

                delete info;
                continue;
            }

            auto destOutInfo = this->videoOutFileInfo();
            if (m_currentFileType == Worklist::Video)
            {
                info->setConvert("video");
                destOutInfo = this->videoOutFileInfo();
            }
            else
            {
                info->setConvert("audio");
                destOutInfo = this->audioOutFileInfo();
                if(info->audioStreams()->size()==0)
                {
                    errorType2=true;
                    delete info;
                    continue;
                }
            }

            info->outFileInfo()->videoInfo()->setBitRate(destOutInfo->videoInfo()->bitRate());
            info->outFileInfo()->videoInfo()->setVideoCodes(destOutInfo->videoInfo()->videoCodes());
            info->outFileInfo()->videoInfo()->setDiscard(destOutInfo->videoInfo()->discard());
            info->outFileInfo()->videoInfo()->setFrameRate(destOutInfo->videoInfo()->frameRate());
            info->outFileInfo()->videoInfo()->setResolution(destOutInfo->videoInfo()->resolution());

            info->outFileInfo()->audioInfo()->setAudioCodes(destOutInfo->audioInfo()->audioCodes());
            info->outFileInfo()->audioInfo()->setAudioSamplefmt(destOutInfo->audioInfo()->audioSamplefmt());
            info->outFileInfo()->audioInfo()->setBitRate(destOutInfo->audioInfo()->bitRate());
            info->outFileInfo()->audioInfo()->setChannels(destOutInfo->audioInfo()->channels());
            info->outFileInfo()->audioInfo()->setDiscard(destOutInfo->audioInfo()->discard());
            connect(info->command(), &FFmpegCommand::finishChanged, this, &Worklist::onCommandFinishChanged);

            list.append(info);
        }
    }

    if (list.size() > 0)
    {
        mutex.lock();
        if (m_currentFileType == Worklist::Video)
        {
            m_videoFiles->append(list);
        }
        else
        {
            m_audioFiles->append(list);
        }
        mutex.unlock();
    }
    if(errorType&&errorType2)
    {
         message.append(QString(tr("The file is corrupted and no audio stream in the video, cannot convert.")));
    }
    else{
        if(errorType){
            message.append(QString(tr("The file is corrupted and cannot be added to the conversion list.")));

        }
        if(errorType2){
            message.append(QString(tr("No audio detected in the video file, cannot convert.")));
        }
    }
    if(message.length()>0)
    {
        emit errorMessage(message);
    }
    return true;
}

bool Worklist::append(QString url)
{
    if (QFileInfo::exists(url))
    {
        FileInfo* info = new FileInfo(this);
        info->setCompleteName(url);
        if (info->videoStreams()->size() == 0 && info->audioStreams()->size() == 0)
        {
            delete info;
            return false;
        }
        mutex.lock();
        auto destOutInfo = this->videoOutFileInfo();
        if (m_currentFileType == Worklist::Video)
        {
            info->setConvert("video");
            destOutInfo = this->videoOutFileInfo();
            m_videoFiles->append(info);
        }
        else
        {
            info->setConvert("audio");
            destOutInfo = this->audioOutFileInfo();
            m_audioFiles->append(info);
        }

        info->outFileInfo()->videoInfo()->setBitRate(destOutInfo->videoInfo()->bitRate());
        info->outFileInfo()->videoInfo()->setVideoCodes(destOutInfo->videoInfo()->videoCodes());
        info->outFileInfo()->videoInfo()->setDiscard(destOutInfo->videoInfo()->discard());
        info->outFileInfo()->videoInfo()->setFrameRate(destOutInfo->videoInfo()->frameRate());
        info->outFileInfo()->videoInfo()->setResolution(destOutInfo->videoInfo()->resolution());

        info->outFileInfo()->audioInfo()->setAudioCodes(info->outFileInfo()->audioInfo()->audioCodes());
        info->outFileInfo()->audioInfo()->setAudioSamplefmt(info->outFileInfo()->audioInfo()->audioSamplefmt());
        info->outFileInfo()->audioInfo()->setBitRate(info->outFileInfo()->audioInfo()->bitRate());
        info->outFileInfo()->audioInfo()->setChannels(info->outFileInfo()->audioInfo()->channels());
        info->outFileInfo()->audioInfo()->setDiscard(info->outFileInfo()->audioInfo()->discard());

        emit info->checkedChanged();
        connect(info->command(), &FFmpegCommand::finishChanged, this, &Worklist::onCommandFinishChanged);
        mutex.unlock();
        return true;
    }

    return false;
}

void Worklist::onCommandFinishChanged(bool successful)
{
    ListViewModel* convertList = nullptr;
    FFmpegCommand* command = qobject_cast<FFmpegCommand*>(sender());
    if (command != nullptr)
    {
        FileInfo* fileInfo = qobject_cast<FileInfo*>(command->parent());
        if (fileInfo != nullptr)
        {
            if (fileInfo->convert() == "video")
            {
                convertList = m_videoFiles;
            }
            else {
                convertList = m_audioFiles;
            }
        }
    }
    if (convertList == nullptr)
    {
        if (m_currentFileType == Worklist::Video)
        {
            convertList = m_videoFiles;
        }
        else {
            convertList = m_audioFiles;
        }
    }

    int count = 0;

    foreach(auto file, convertList->values())
    {
        auto fileInfo = qobject_cast<FileInfo*>(file);
        if (fileInfo != nullptr)
        {
            if (fileInfo->command()->state() == FFmpegCommand::Running)
            {
                count++;
            }
        }
    }

    if (count < processMaxCount)
    {
        foreach(auto file, convertList->values())
        {
            auto fileInfo = qobject_cast<FileInfo*>(file);
            if (fileInfo == nullptr)
            {
                continue;
            }
            if (fileInfo->command()->state() == FFmpegCommand::Unstart)
            {
                fileInfo->command()->executeCommand(fileInfo->completeName(), m_outFileDir, fileInfo->outFileInfo(), fileInfo);
                count++;
            }
            if (count >= processMaxCount)
            {
                break;
            }
        }
    }
    if(count==0)
    {
        emit commandFinish();
    }
}

QImage Worklist::onRequest(QString name)
{
    mutex.lock();
    auto list = m_videoFiles;
    if (m_currentFileType == Worklist::Audio)
    {
        list = m_audioFiles;
    }
    foreach(auto file, list->values())
    {
        auto fileInfo = qobject_cast<FileInfo*>(file);
        if (fileInfo != nullptr && fileInfo->completeName() == name)
        {
            if (!fileInfo->thumbnail().isNull())
            {
                mutex.unlock();
                return fileInfo->thumbnail().copy();
            }
        }
    }
    mutex.unlock();
    return QImage();
}

ListViewModel* Worklist::audioFiles() const
{
    return m_audioFiles;
}

Worklist::FileType Worklist::currentFileType() const
{
    return m_currentFileType;
}

void Worklist::setCurrentFileType(const FileType& newCurrentFileType)
{
    if (m_currentFileType == newCurrentFileType)
        return;
    m_currentFileType = newCurrentFileType;
    emit currentFileTypeChanged();
}

OutFileInfo* Worklist::videoOutFileInfo() const
{
    return m_videoOutFileInfo;
}

QString Worklist::videoOutFormat() const
{
    return m_videoOutFormat;
}

void Worklist::setVideoOutFormat(const QString& newVideoOutFormat)
{
    if (m_videoOutFormat == newVideoOutFormat)
        return;
    m_videoOutFormat = newVideoOutFormat;
    emit videoOutFormatChanged();
}

OutFileInfo* Worklist::audioOutFileInfo() const
{
    return m_audioOutFileInfo;
}

QString Worklist::audioOutFormat() const
{
    return m_audioOutFormat;
}

void Worklist::setAudioOutFormat(const QString& newAudioOutFormat)
{
    if (m_audioOutFormat == newAudioOutFormat)
        return;
    m_audioOutFormat = newAudioOutFormat;
    emit audioOutFormatChanged();
}

QString Worklist::videoSuffixesFilters() const
{
    return m_videoSuffixesFilters;
}

QString Worklist::audioSuffixesFilters() const
{
    return m_audioSuffixesFilters;
}

bool  Worklist::startup()
{
    auto list = m_videoFiles;
    if (m_currentFileType == Worklist::Audio)
    {
        list = m_audioFiles;
    }
    // foreach(auto file, *((QObjectList*)list))
    // {
    // 	auto fileInfo = qobject_cast<FileInfo*>(file);
    // 	if (fileInfo->command()->state() != FFmpegCommand::None &&
    //            fileInfo->command()->state() != FFmpegCommand::Finish)
    // 	{
    // 		return false;
    // 	}
    // }
    foreach(auto file, list->values())
    {
        auto fileInfo = qobject_cast<FileInfo*>(file);
        if (fileInfo->checked() && (
                fileInfo->command()->state() == FFmpegCommand::None ||
                fileInfo->command()->state() == FFmpegCommand::Finish ||
                fileInfo->command()->state() == FFmpegCommand::Failure))
        {
            if (m_currentFileType == Worklist::Audio)
                fileInfo->outFileInfo()->videoInfo()->setDiscard(true);

            fileInfo->outFileInfo()->setFormat(m_currentFileType == Worklist::Audio ? m_audioOutFormat : m_videoOutFormat);
            fileInfo->command()->awaitStart();
        }
    }
    onCommandFinishChanged(true);
    return false;
}

QString Worklist::outFileDir() const
{
    return m_outFileDir;
}

void Worklist::setOutFileDir(const QString& newOutFileDir)
{
    if(!newOutFileDir.isEmpty())
        m_outFileDir = newOutFileDir;
}
bool Worklist::openOutFolder()
{
    QDir dir(m_outFileDir);
    if (!dir.exists())
    {
        return dir.mkpath(m_outFileDir);
    }
    return true;
}
bool  Worklist::removeItems()
{
    auto list = m_videoFiles;
    if (m_currentFileType == Worklist::Audio)
    {
        list = m_audioFiles;
    }
    QObjectList removeList;
    foreach(auto file, list->values())
    {
        auto fileInfo = qobject_cast<FileInfo*>(file);
        if (fileInfo->checked() && (
                fileInfo->command()->state() == FFmpegCommand::None ||
                fileInfo->command()->state() == FFmpegCommand::Finish ||
                fileInfo->command()->state() == FFmpegCommand::Failure))
        {
            removeList.append(file);
        }
    }
    foreach (auto file , removeList)
    {
        list->removeOne(file);
        file->deleteLater();
    }
    // qDeleteAll(removeList);
    removeList.clear();
    return true;
}
void  Worklist:: checkedAll(bool checked)
{
    auto list = m_videoFiles;
    if (m_currentFileType == Worklist::Audio)
    {
        list = m_audioFiles;
    }
    int index=0;
    foreach(auto file, list->values())
    {
        auto fileInfo = qobject_cast<FileInfo*>(file);
        fileInfo->setChecked(checked);
        list->dataChang(index);
        index++;
    }
    //list->resetModel();
}
