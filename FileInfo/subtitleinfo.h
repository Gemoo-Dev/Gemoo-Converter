#ifndef SUBTITLEINFO_H
#define SUBTITLEINFO_H

#include <QObject>
#include "mediastreaminfo.h"

class SubtitleInfo : public MediaStreamInfo
{
    Q_OBJECT
public:
    explicit SubtitleInfo(const AVStream* stream,QObject *parent = nullptr);

signals:
};

#endif // SUBTITLEINFO_H
