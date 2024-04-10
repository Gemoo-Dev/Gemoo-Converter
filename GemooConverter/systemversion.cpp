#include "systemversion.h"
#include <QEventLoop>
#include <QNetworkReply>
#include <QXmlStreamReader>
#include <qdebug.h>
#include <QDomDocument>
#include <QSettings>
#include <QCoreApplication>
#include <QVersionNumber>

SystemVersion::SystemVersion()
{
    QSettings settings("setting.ini", QSettings::Format::IniFormat);
    m_skipVersion = settings.value("skipVersion").toString();
    QVersionNumber v1 = QVersionNumber::fromString(m_currentVersion);//qApp->applicationVersion());

  //  m_currentVersion = QString("%1.%2.%3").arg(v1.majorVersion()).arg(v1.minorVersion()).arg(v1.microVersion());

    QUrl url(serverUrl);
    QNetworkAccessManager* manager = new QNetworkAccessManager();

    manager->setTransferTimeout(2000);
    manager->clearAccessCache();
    manager->clearConnectionCache();

    QNetworkRequest* request = new QNetworkRequest(url);
    QByteArray param;
    pReply = manager->post(*request, param);

    QObject::connect(pReply, &QNetworkReply::finished, [&] {

        auto isfinished = pReply->isFinished();
        auto error = pReply->error();
        if (pReply->error() == QNetworkReply::NetworkError::NoError)
        {
            auto buffer = pReply->readAll();
            qDebug() << buffer;
            QDomDocument document;
            document.setContent(QString::fromUtf8(buffer));

            auto root = document.firstChildElement();
            auto name = root.nodeName();
            auto child = root.childNodes();
            QList<VersionDict*> list;

            for (int i = 0; i < child.count(); i++)
            {
                auto note = child.at(i).toElement();
                auto name = note.nodeName();
                if (name == "dict")
                {
                    auto rootNode = note.childNodes().at(0).toElement();
                    list.append(new VersionDict(note.childNodes()));
                }
            }
            foreach (auto dict  , list)
            {
                if (dict->mapDict.contains(system))
                {
                    auto myversion = dict->mapDict[system];
                    if (myversion->mapDict.contains("update"))
                    {
                        auto update = myversion->mapDict["update"];
                        auto text = update->VersionDictList[0];// ->mapDict["text"];
                        auto product = update->mapDict["product"];
                        foreach (auto item , product->dict.keys())
                        {
                            auto value = product->dict[item];
                            if (item == "build") {
                                m_buildDate = value;
                            }
                            else if (item == "version") {
                                m_version = value;
                            }
                            else if (item == "min") {
                                m_minDate = value;
                            }
                        }
                        foreach (auto item , text->dict.keys())
                        {
                            auto value = text->dict[item];
                            if (item == "packageUrl") {
                                m_packageUrl = value;
                            }
                            else if (item == "url") {
                                m_url = value;
                            }
                            else if (item == "language") {
                                m_language = value;
                            }
                        }
                        this->m_text = text->messages.join("\n");
                    }
                }
            }
        }

        QVersionNumber v2 = QVersionNumber::fromString(m_version);

        if (!m_buildDate.isEmpty())
        {
            if (m_buildDate == m_skipVersion)
            {
                m_upgrade = false;
            }
            else if (m_currentBuildDate < m_buildDate)
            {
                m_upgrade = true;
                emit upgradeChanged();
            }
        }
        });
}

QString SystemVersion::buildDate() const
{
    return m_buildDate;
}

QString SystemVersion::version() const
{
    return m_version;
}

QString SystemVersion::minDate() const
{
    return m_minDate;
}

QString SystemVersion::packageUrl() const
{
    return m_packageUrl;
}

QString SystemVersion::url() const
{
    return m_url;
}

QString SystemVersion::text() const
{
    return m_text;
}

QString SystemVersion::language() const
{
    return m_language;
}

bool SystemVersion:: skipVersion()
{
    QSettings settings("setting.ini", QSettings::Format::IniFormat);
    settings.setValue("skipVersion", m_buildDate);
    return true;
}

bool SystemVersion::upgrade() const
{
    return m_upgrade;
}

QString SystemVersion::currentBuildDate() const
{
    return m_currentBuildDate;
}

QString SystemVersion::currentVersion() const
{
    return m_currentVersion;
}
