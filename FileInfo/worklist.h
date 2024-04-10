#ifndef WORKLIST_H
#define WORKLIST_H

#include <QObject>
#include <listviewmodel.h>
#include <fileinfo.h>
#include <imageprovider.h>
#include <qimage.h>
#include <QMutex>

class Worklist : public QObject
{
    Q_OBJECT
    Q_PROPERTY(ListViewModel* videoFiles  READ videoFiles CONSTANT)
    Q_PROPERTY(OutFileInfo* videoOutFileInfo  READ videoOutFileInfo CONSTANT)
    Q_PROPERTY(QString videoOutFormat  READ videoOutFormat WRITE setVideoOutFormat NOTIFY videoOutFormatChanged)
    Q_PROPERTY(QString videoSuffixesFilters  READ videoSuffixesFilters CONSTANT)

    Q_PROPERTY(ListViewModel* audioFiles  READ audioFiles CONSTANT)
    Q_PROPERTY(OutFileInfo* audioOutFileInfo  READ audioOutFileInfo CONSTANT)
    Q_PROPERTY(QString audioOutFormat  READ audioOutFormat WRITE setAudioOutFormat NOTIFY audioOutFormatChanged)
    Q_PROPERTY(QString audioSuffixesFilters  READ audioSuffixesFilters CONSTANT)

    Q_PROPERTY(FileType currentFileType  READ currentFileType WRITE setCurrentFileType NOTIFY currentFileTypeChanged)
    Q_PROPERTY(QString outFileDir  READ outFileDir  WRITE setOutFileDir CONSTANT)
public:
    enum FileType
    {
        Video,
        Audio
    };
    Q_ENUM(FileType);
    explicit Worklist(QObject *parent = nullptr);
    ~Worklist();

    Q_INVOKABLE bool addImageProvider();
    Q_INVOKABLE bool append(QString url);
    Q_INVOKABLE bool appends(QVariantList urls);
    Q_INVOKABLE bool removeItems();
    Q_INVOKABLE bool startup();
    Q_INVOKABLE bool openOutFolder();
    Q_INVOKABLE void checkedAll(bool checked);
    ListViewModel *videoFiles() const;

    ListViewModel *audioFiles() const;

    FileType currentFileType() const;
    void setCurrentFileType(const FileType &newCurrentFileType);

    OutFileInfo *videoOutFileInfo() const;

    QString videoOutFormat() const;
    void setVideoOutFormat(const QString &newVideoOutFormat);

    OutFileInfo *audioOutFileInfo() const;

    QString audioOutFormat() const;
    void setAudioOutFormat(const QString &newAudioOutFormat);

    QString videoSuffixesFilters() const;

    QString audioSuffixesFilters() const;

    QString outFileDir() const;
    void setOutFileDir(const QString &newOutFileDir);

signals:
    void currentFileTypeChanged();

    void videoOutFormatChanged();

    void audioOutFormatChanged();

    void commandFinish();
    void errorMessage(QString message);

private:
    ListViewModel *m_videoFiles = nullptr;

    static ImageProvider* thumbnailImageProvider;
    ListViewModel *m_audioFiles = nullptr;

    FileType m_currentFileType=Video;

    OutFileInfo *m_videoOutFileInfo = nullptr;

    QString m_videoOutFormat="MP4";

    OutFileInfo *m_audioOutFileInfo = nullptr;

    QString m_audioOutFormat="MP3";

    QStringList videoSuffixes;

    QStringList audioSuffixes;

    QString m_videoSuffixesFilters;

    QString m_audioSuffixesFilters;

    QString settingPath;
    int processMaxCount = 3;
    QString m_outFileDir="";
    QMutex mutex;
private   slots:
    QImage onRequest(QString name);
    void onCommandFinishChanged(bool successful);

};

#endif // WORKLIST_H
