#ifndef VIDEOINFO_H
#define VIDEOINFO_H

#include <QObject>
#include "mediastreaminfo.h"

class VideoInfo : public MediaStreamInfo
{
    Q_OBJECT
public:
    Q_PROPERTY(int width  READ width CONSTANT)
    Q_PROPERTY(int height  READ height CONSTANT)
    Q_PROPERTY(QString  formatProfile READ formatProfile CONSTANT)
    Q_PROPERTY(double  frame_rate READ frame_rate CONSTANT)
    Q_PROPERTY(QString pix_fmt READ pix_fmt CONSTANT)
    Q_PROPERTY(QString  color_primaries READ color_primaries CONSTANT)
    explicit VideoInfo(const AVStream* stream,QObject *parent = nullptr);

    int width() const;

    int height() const;

    QString formatProfile() const;

    double frame_rate() const;

    QString pix_fmt() const;
    QString color_primaries() const;
signals:
private:
    int m_width=0;
    int m_height=0;
    QString m_formatProfile;
    double m_frame_rate=0;
    QString m_pix_fmt;
    QString m_color_primaries;
};

#endif // VIDEOINFO_H
