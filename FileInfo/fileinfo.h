#ifndef FILEINFO_H
#define FILEINFO_H

#include <QObject>
#include <listviewmodel.h>
#include <QImage>
#include <imageprovider.h>
#include <outfileinfo.h>
#include <ffmpegcommand.h>
#include <videoinfo.h>
#include "audioinfo.h"
#include "subtitleinfo.h"

class FileInfo : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString completeName READ completeName WRITE setCompleteName NOTIFY completeNameChanged)
    Q_PROPERTY(QString fileName READ fileName NOTIFY completeNameChanged)
    Q_PROPERTY(QString format READ format NOTIFY completeNameChanged)
    Q_PROPERTY(QString formatVersion READ formatVersion NOTIFY completeNameChanged)
    Q_PROPERTY(double fileSize READ fileSize NOTIFY completeNameChanged)
    Q_PROPERTY(double duration READ duration NOTIFY completeNameChanged)
    Q_PROPERTY(double overallBitRate  READ overallBitRate NOTIFY completeNameChanged)
    Q_PROPERTY(double encodedDate  READ encodedDate NOTIFY completeNameChanged)
    Q_PROPERTY(QString encoder  READ encoder NOTIFY completeNameChanged)
    Q_PROPERTY(QString creation_time  READ creation_time NOTIFY completeNameChanged)
    Q_PROPERTY(QImage thumbnail  READ thumbnail NOTIFY completeNameChanged)
    Q_PROPERTY(ListViewModel* videoStreams  READ videoStreams NOTIFY completeNameChanged)
    Q_PROPERTY(ListViewModel* audioStreams  READ audioStreams NOTIFY completeNameChanged)
    Q_PROPERTY(ListViewModel* subtitleStreams  READ subtitleStreams NOTIFY completeNameChanged)
    Q_PROPERTY(OutFileInfo* outFileInfo  READ outFileInfo  NOTIFY outFileInfoChanged)    
    Q_PROPERTY(FFmpegCommand* command  READ command NOTIFY completeNameChanged)
    Q_PROPERTY(bool checked  READ checked WRITE setChecked  NOTIFY checkedChanged)
    Q_PROPERTY(QString convert  READ convert WRITE setConvert  NOTIFY completeNameChanged)

public:  

    explicit FileInfo(QObject *parent = nullptr);

    ~FileInfo() override;

    QString completeName() const;

    QString  fileName() const;

    void setCompleteName(const QString &newCompleteName);

    QString format() const;

    QString formatVersion() const;

    double fileSize() const;

    double duration() const;

    double overallBitRate() const;

    double encodedDate() const;

    ListViewModel* videoStreams() const;

    ListViewModel *audioStreams() const;

    ListViewModel *subtitleStreams() const;

    QString encoder() const;

    QString creation_time() const;

    QImage thumbnail() const;

    OutFileInfo *outFileInfo() const;

    bool checked() const;
    void setChecked(bool newChecked);

    FFmpegCommand *command() const;

    QString convert() const;
    void setConvert(const QString &newConvert);

signals:
    void completeNameChanged();
    void commandChanged();
    void outFileInfoChanged();
    void checkedChanged();

private:
    QString m_completeName;
    QString m_format;
    QString m_formatVersion;
    double m_fileSize=0;
    double m_duration=0;
    double m_overallBitRate=0;
    double m_encodedDate=0;
    ListViewModel* m_videoStreams= nullptr;
    ListViewModel* m_audioStreams = nullptr;
    ListViewModel* m_subtitleStreams = nullptr;
    QString m_encoder;
    QString m_creation_time;
    QString m_fileName;
    QImage m_thumbnail ;

    OutFileInfo *m_outFileInfo = nullptr;
    bool m_checked=true;
    FFmpegCommand *m_command = nullptr;
    QString m_convert;
    bool frameToImage(AVFrame* frame);
};

#endif // FILEINFO_H
