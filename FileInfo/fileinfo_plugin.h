#ifndef FILEINFO_PLUGIN_H
#define FILEINFO_PLUGIN_H

#include <QQmlExtensionPlugin>

class FileInfoPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID QQmlExtensionInterface_iid)

public:
    void registerTypes(const char *uri) override;
};

#endif // FILEINFO_PLUGIN_H
