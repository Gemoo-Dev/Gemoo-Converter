#ifndef IMAGEPROVIDER_H
#define IMAGEPROVIDER_H

#include<QQuickImageProvider>
#include <QObject>

class Q_DECL_EXPORT ImageProvider:public QObject, public QQuickImageProvider
{
    Q_OBJECT
public:
    ImageProvider(QObject *parent=nullptr);
    ~ImageProvider();
    QImage requestImage(const QString& id, QSize* size, const QSize& requestedSize) override;
signals:
    QImage request(QString id);
};

#endif // IMAGEPROVIDER_H
