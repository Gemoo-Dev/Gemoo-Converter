#ifndef MEDIASTREAMINFO_H
#define MEDIASTREAMINFO_H

#include <QObject>
#include <listviewmodel.h>
extern "C"
{
#include "libavutil/avstring.h"
#include "libavutil/eval.h"
#include "libavutil/mathematics.h"
#include "libavutil/pixdesc.h"
#include "libavutil/imgutils.h"
#include "libavutil/dict.h"
#include "libavutil/fifo.h"
#include "libavutil/parseutils.h"
#include "libavutil/samplefmt.h"
#include "libavutil/avassert.h"
#include "libavutil/time.h"
#include "libavutil/bprint.h"
#include "libavformat/avformat.h"
#include "libavdevice/avdevice.h"
#include "libswscale/swscale.h"
#include "libavutil/opt.h"
#include "libavcodec/avfft.h"
#include "libswresample/swresample.h"
}
class Metadata : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString key READ key CONSTANT)
    Q_PROPERTY(QString value  READ value CONSTANT)
public:
    Metadata(const QString key, const  QString value)
    {
        m_key = key;
        m_value = value;
    }
    ~Metadata()
    {

    }
    QString key() const
    {
        return m_key;
    }
    QString value() const
    {
        return m_value;
    }
private:
    QString m_key;
    QString m_value;
};


class MediaStreamInfo : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int id READ id CONSTANT)
    Q_PROPERTY(QString format READ format CONSTANT)
    Q_PROPERTY(QString formatInfo  READ formatInfo CONSTANT)
    Q_PROPERTY(QString codecId  READ codecId CONSTANT)
    Q_PROPERTY(double duration  READ duration CONSTANT)
    Q_PROPERTY(double  bit_rate READ bit_rate CONSTANT)
    Q_PROPERTY(double streamSize  READ streamSize CONSTANT)
    Q_PROPERTY(ListViewModel* metadata  READ metadata CONSTANT)

public:
    explicit MediaStreamInfo(const AVStream* stream, QObject* parent = nullptr);
    virtual   ~MediaStreamInfo();
    int id() const;

    QString format() const;

    QString codecId() const;

    double duration() const;

    double streamSize() const;

    QString formatInfo() const;

    ListViewModel* metadata() const;

    double bit_rate() const;

signals:
protected:
    int m_id;
    QString m_format;
    QString m_codecId;
    double m_duration = 0;
    double m_streamSize = 0;
    QString m_formatInfo;

    ListViewModel* m_metadata = nullptr;

    double m_bit_rate=0;
};

#endif // MEDIASTREAMINFO_H
