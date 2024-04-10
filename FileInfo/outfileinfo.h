#ifndef OUTFILEINFO_H
#define OUTFILEINFO_H
#include <QObject>

class OutVideoInfo:public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString videoCodes READ videoCodes  WRITE setVideoCodes NOTIFY videoCodesChanged)
    Q_PROPERTY(QString resolution READ resolution  WRITE setResolution NOTIFY resolutionChanged)
    Q_PROPERTY(float frameRate READ frameRate  WRITE setFrameRate NOTIFY frameRateChanged)
    Q_PROPERTY(float bitRate READ bitRate  WRITE setBitRate NOTIFY bitRateChanged)
    Q_PROPERTY(bool discard READ discard  WRITE setDiscard NOTIFY discardChanged)
public:
    OutVideoInfo();

    QString videoCodes() const;
    void setVideoCodes(const QString &newVideoCodes);
    QString resolution() const;
    void setResolution(const QString &newResolution);

    float frameRate() const;
    void setFrameRate(float newFrameRate);

    float bitRate() const;
    void setBitRate(float newBitRate);

    bool discard() const;
    void setDiscard(bool newDiscard);

signals:
    void videoCodesChanged();
    void resolutionChanged();

    void frameRateChanged();

    void bitRateChanged();

    void discardChanged();

private:
    QString m_videoCodes;
    QString m_resolution;
    float m_frameRate=0;
    float m_bitRate=0;
    bool m_discard=false;
};
class OutAudioInfo:public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString audioCodes READ audioCodes  WRITE setAudioCodes NOTIFY audioCodesChanged)
    Q_PROPERTY(int channels READ channels  WRITE setChannels NOTIFY channelsChanged)
    Q_PROPERTY(int audioSamplefmt READ audioSamplefmt  WRITE setAudioSamplefmt NOTIFY audioSamplefmtChanged)
    Q_PROPERTY(float bitRate READ bitRate  WRITE setBitRate NOTIFY bitRateChanged)
    Q_PROPERTY(bool discard READ discard  WRITE setDiscard NOTIFY discardChanged)
public:
    OutAudioInfo();
    QString audioCodes() const;
    void setAudioCodes(const QString &newAudioCodes);
    int channels() const;
    void setChannels(const int &newChannels);

    int audioSamplefmt() const;
    void setAudioSamplefmt(const int &newAudioSamplefmt);

    float bitRate() const;
    void setBitRate(float newBitRate);

    bool discard() const;
    void setDiscard(bool newDiscard);

signals:
    void audioCodesChanged();
    void channelsChanged();

    void audioSamplefmtChanged();

    void bitRateChanged();

    void discardChanged();

private:
    QString m_audioCodes;
    int m_channels=0;
    int m_audioSamplefmt=0;
    float m_bitRate=0;
    bool m_discard=false;
};

class OutFileInfo:public QObject
{
    Q_OBJECT
    ///格式
    Q_PROPERTY(QString format READ format  WRITE setFormat NOTIFY formatChanged)
    Q_PROPERTY(OutAudioInfo* audioInfo READ audioInfo  NOTIFY audioInfoChanged)
    Q_PROPERTY(OutVideoInfo* videoInfo READ videoInfo  NOTIFY videoInfoChanged)
public:
    OutFileInfo();
    QString format() const;
    void setFormat(const QString &newFormat);
    OutAudioInfo *audioInfo() const;

    OutVideoInfo *videoInfo() const;

signals:
    void formatChanged();
    void audioInfoChanged();
    void videoInfoChanged();

private:
    QString m_format;
    OutAudioInfo *m_audioInfo = nullptr;
    OutVideoInfo *m_videoInfo = nullptr;
};

#endif // OUTFILEINFO_H
