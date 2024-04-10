TEMPLATE = lib
TARGET = Style
QT += multimedia
# Input
SOURCES += \
        style_plugin.cpp \
        # myitem.cpp

HEADERS += \
        style_plugin.h \
        # myitem.h

include(../common.pri)

RESOURCES += \
    img.qrc \
    qml.qrc
