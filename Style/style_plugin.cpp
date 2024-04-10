#include "style_plugin.h"
#include <qqml.h>

void StylePlugin::registerTypes(const char *uri)
{
    // @uri com.mycompany.qmlcomponents 
    qmlRegisterType(QUrl("qrc:/SystemComboBox.qml"),uri,1,0,"SystemComboBox");
    qmlRegisterType(QUrl("qrc:/SystemText.qml"),uri,1,0,"SystemText");
    qmlRegisterType(QUrl("qrc:/SystemTextBox.qml"),uri,1,0,"SystemTextBox");
    qmlRegisterType(QUrl("qrc:/SystemButton.qml"),uri,1,0,"SystemButton");
    qmlRegisterType(QUrl("qrc:/SystemScrollBar.qml"),uri,1,0,"SystemScrollBar");
    qmlRegisterType(QUrl("qrc:/SystemPlayer.qml"),uri,1,0,"SystemPlayer");
    qmlRegisterType(QUrl("qrc:/SystemProgressBar.qml"),uri,1,0,"SystemProgressBar");
    qmlRegisterType(QUrl("qrc:/SystemRadioButton.qml"),uri,1,0,"SystemRadioButton");
    qmlRegisterType(QUrl("qrc:/MessageBoxPopup.qml"),uri,1,0,"MessageBoxPopup");
    qmlRegisterType(QUrl("qrc:/SystemCheckBox.qml"),uri,1,0,"SystemCheckBox");

    qmlRegisterSingletonType(QUrl("qrc:/GlobalConfig.qml"),uri,1,0,"GlobalConfig");
    //  qmlRegisterType<PatientUser>(uri, 1, 0, "PatientUse");
    // qrc:/GlobalConfig.qml
}
