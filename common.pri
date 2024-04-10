TEMPLATE = lib
QT += qml quick gui
CONFIG +=c++11 plugin

CONFIG(release, debug|release){

    DESTDIR = ../build/release/plugins/$$TARGET
    DEFINES += QT_NO_DEBUG_OUTPUT

}else{

    DESTDIR = ../build/debug/plugins/$$TARGET
}

DISTFILES = qmldir

qmldir.files = qmldir

!equals(_PRO_FILE_PWD_, $$DESTDIR) {

    copy_qmldir.target = $$DESTDIR/qmldir
    copy_qmldir.depends = $$_PRO_FILE_PWD_/qmldir
    copy_qmldir.commands = $(COPY_FILE) "$$replace(copy_qmldir.depends, /, $$QMAKE_DIR_SEP)" "$$replace(copy_qmldir.target, /, $$QMAKE_DIR_SEP)"
    QMAKE_EXTRA_TARGETS += copy_qmldir
    PRE_TARGETDEPS += $$copy_qmldir.target
}

unix {
    installPath = $$[QT_INSTALL_QML]/$$replace(uri, \., /)
    qmldir.path = $$installPath
    target.path = $$installPath
    INSTALLS += target qmldir
}
QML_IMPORT_PATH +=  $$DESTDIR/../

#C:\Qt\5.15.2\msvc2019_64\bin\qmlplugindump.exe Style 1.0 D:\build-MediaFileTool-Desktop_Qt_5_15_2_MSVC2019_64bit-Release\build\release\plugins >  D:\build-MediaFileTool-Desktop_Qt_5_15_2_MSVC2019_64bit-Release\build\release\plugins\Style\plugins.qmltypes
TargetQML = $$_PRO_FILE_PWD_/*.qml
#将输入目录中的"/"替换为"\"
TargetQML = $$replace(TargetQML, /, \\)
#将输出目录中的"/"替换为"\"
OutputDir = $$DESTDIR/
OutputDir = $$replace(OutputDir, /, \\)

QMAKE_POST_LINK += copy /Y $$TargetQML $$OutputDir

TARGET =$$qt5LibraryTarget($$TARGET)
