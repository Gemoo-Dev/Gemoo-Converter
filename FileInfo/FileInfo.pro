TEMPLATE = lib
TARGET = FileInfo
# Input
SOURCES += \
        audioinfo.cpp \
        ffmpegcommand.cpp \
        fileinfo_plugin.cpp \
        fileinfo.cpp \
        mediastreaminfo.cpp \
        outfileinfo.cpp \
        subtitleinfo.cpp \
        videoinfo.cpp \
        worklist.cpp

HEADERS += \
        audioinfo.h \
        ffmpegcommand.h \
        fileinfo_plugin.h \
        fileinfo.h \
        mediastreaminfo.h \
        outfileinfo.h \
        subtitleinfo.h \
        videoinfo.h \
        worklist.h

include(../common.pri)

win32:CONFIG(release, debug|release): LIBS += -L$$DESTDIR/../../ -lmvvmtool
else:win32:CONFIG(debug, debug|release): LIBS += -L$$DESTDIR/../../ -lmvvmtool
else:macx: LIBS +=  -L$$DESTDIR/../../ -lmvvmtool

INCLUDEPATH += $$PWD/../mvvmtool
DEPENDPATH += $$PWD/../mvvmtool


win32:CONFIG(release, debug|release): LIBS += -L$$PWD/../lib/ffmpeg-4.4-full_build-shared/lib/ -lavformat  -lavcodec -lavutil -lavfilter -lpostproc -lswresample -lswscale
else:win32:CONFIG(debug, debug|release): LIBS += -L$$PWD/../lib/ffmpeg-4.4-full_build-shared/lib/ -lavformat  -lavcodec -lavutil -lavfilter -lpostproc -lswresample -lswscale
macx: LIBS += -L$$PWD/../lib/ffmpeg-4.4-full_build-shared/mac/lib/ -lavcodec.58 -lavformat.58  -lavutil.56 -lavfilter.7 -lpostproc.55 -lswresample.3 -lswscale.5

INCLUDEPATH += $$PWD/../lib/ffmpeg-4.4-full_build-shared/include
DEPENDPATH += $$PWD/../lib/ffmpeg-4.4-full_build-shared/include


RESOURCES += \
    qml.qrc

TRANSLATIONS += language/lang_Chinese.ts\
                language/lang_English.ts



# INCLUDEPATH += $$PWD/../lib/ffmpeg-4.4-full_build-shared/mac/lib
# DEPENDPATH += $$PWD/../lib/ffmpeg-4.4-full_build-shared/mac/lib
