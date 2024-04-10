#ifndef STYLE_PLUGIN_H
#define STYLE_PLUGIN_H

#include <QQmlExtensionPlugin>

class StylePlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID QQmlExtensionInterface_iid)

public:
    void registerTypes(const char *uri) override;
};

#endif // STYLE_PLUGIN_H
