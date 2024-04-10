#include <QApplication>
#include <QQmlApplicationEngine>
#include <QDir>
#include <QQuickWindow>
#include <ffmpegcommand.h>
#include <QQuickStyle>
#include <QFont>
#include <QTranslator>
#include <systemversion.h>
#include <QMessageBox>
#include <QProcess>

int main(int argc, char* argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    // QQuickWindow::setTextRenderType(QQuickWindow::NativeTextRendering);
    QApplication app(argc, argv);
    //app.setWindowIcon(QIcon("qrc:/gemooconverter_wipit_logo.ico"));
    QLocale local = QLocale::system();
    QLocale::Language lang = local.language();
    qDebug() << "lang=" << lang;

    QLocale::Country country = local.country();
    qDebug() << "country=" << country;

    QString name = local.name();
    qDebug() << "name=" << name;

    {
        auto languageName = QLocale::languageToString(lang);

        QString languageFile = QDir(QApplication::applicationDirPath()).absoluteFilePath(QString("language/%1.qm").arg(languageName));

        if (!QFile::exists(languageFile))
        {
            languageFile = QDir(QApplication::applicationDirPath()).absoluteFilePath(QString("language/%1.qm").arg("English"));
        }
        if (QFile::exists(languageFile))
        {
            auto  m_translator = new QTranslator;
            if (m_translator->load(languageFile))
            {  //文件是否存在
                app.installTranslator(m_translator);
            }
        }
    }
    qmlRegisterType<SystemVersion>("SystemInfo", 1, 0, "SystemVersion");

    QQmlApplicationEngine engine;
    QString plugins = QDir(QGuiApplication::applicationDirPath()).absoluteFilePath("plugins");//("Setting.ini");

    engine.addImportPath(plugins);
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject* obj, const QUrl& objUrl) 
        {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);
    engine.load(url);
    auto result = app.exec();
    return result;
}
