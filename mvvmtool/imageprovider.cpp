#include "imageprovider.h"

ImageProvider::ImageProvider(QObject *parent):QObject(),
    QQuickImageProvider(ImageType::Image){}

QImage ImageProvider::requestImage(const QString& id, QSize* size, const QSize& requestedSize)
{
    QImage img;
    emit img = request(id);
    return img;
}
ImageProvider::~ImageProvider()
{
    this->disconnect();
}
