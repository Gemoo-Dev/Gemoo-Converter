#ifndef FILEINFO_H
#define FILEINFO_H

#include <QObject>

class MediaFileInfo : public QObject
{
    Q_OBJECT
public:
    explicit MediaFileInfo(QObject *parent = nullptr);

signals:

};

#endif // FILEINFO_H
