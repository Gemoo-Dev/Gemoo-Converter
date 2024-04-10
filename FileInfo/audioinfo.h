#ifndef AUDIOINFO_H
#define AUDIOINFO_H

#include <QObject>
#include "mediastreaminfo.h"

class AudioInfo : public MediaStreamInfo
{
    Q_OBJECT
    Q_PROPERTY(int channels  READ channels CONSTANT)
    Q_PROPERTY(QString sample_fmt  READ sample_fmt CONSTANT)
    Q_PROPERTY(int sample_rate  READ sample_rate CONSTANT)
    Q_PROPERTY(QString channel_description  READ channel_description CONSTANT)

public:
    explicit AudioInfo(const AVStream* stream,QObject *parent = nullptr);

    int channels() const;

    QString sample_fmt() const;

    int sample_rate() const;
    Q_INVOKABLE const QString channel_description()
    {
        return QString::fromUtf8(av_get_channel_name(m_channels));
    }

signals:
private:
    int m_channels=0;
    QString m_sample_fmt;
    int m_sample_rate=0;
};

#endif // AUDIOINFO_H
