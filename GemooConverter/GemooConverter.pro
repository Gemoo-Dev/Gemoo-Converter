QT += quick quickcontrols2 network xml widgets

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0
TARGET =$$quote(Gemoo Converter)
RESOURCES += qml.qrc

CONFIG(release, debug|release){

    DESTDIR = ../build/release
    DEFINES += QT_NO_DEBUG_OUTPUT

}else{

    DESTDIR = ../build/debug
}

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH +=$$DESTDIR/plugins

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += \
  #  ffmpegcommand.h \
    fileinfo.h \
    systemversion.h \
    worklist.h

SOURCES += \
   #     ffmpegcommand.cpp \
        fileinfo.cpp \
        main.cpp \
    systemversion.cpp \
        worklist.cpp


TRANSLATIONS +=language/lang_Chinese.ts \
                language/lang_English.ts


RC_ICONS = gemooconverter_logo.ico
ICON =gemooconverter_logo_mac.icns
QMAKE_INFO_PLIST = info.plist
#QMAKE_INFO_PLIST += -CFBundleIdentifier com.mycompany.myapp
APP_BUNDLE_IDENTIFIER = com.gemoo.converter

VERSION = 1.0.0

# win32:CONFIG(release, debug|release): LIBS += -L$$OUT_PWD/../mvvmtool/release/ -lmvvmtool
# else:win32:CONFIG(debug, debug|release): LIBS += -L$$OUT_PWD/../mvvmtool/debug/ -lmvvmtool
# else:unix: LIBS += -L$$OUT_PWD/../mvvmtool/ -lmvvmtool

# INCLUDEPATH += $$PWD/../mvvmtool
# DEPENDPATH += $$PWD/../mvvmtool

# win32-g++:CONFIG(release, debug|release): PRE_TARGETDEPS += $$OUT_PWD/../mvvmtool/release/libmvvmtool.a
# else:win32-g++:CONFIG(debug, debug|release): PRE_TARGETDEPS += $$OUT_PWD/../mvvmtool/debug/libmvvmtool.a
# else:win32:!win32-g++:CONFIG(release, debug|release): PRE_TARGETDEPS += $$OUT_PWD/../mvvmtool/release/mvvmtool.lib
# else:win32:!win32-g++:CONFIG(debug, debug|release): PRE_TARGETDEPS += $$OUT_PWD/../mvvmtool/debug/mvvmtool.lib
# else:unix: PRE_TARGETDEPS += $$OUT_PWD/../mvvmtool/libmvvmtool.a

DISTFILES += \
    gemooconverter_logo_mac.icns
