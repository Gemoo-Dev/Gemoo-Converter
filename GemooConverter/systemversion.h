#ifndef SYSTEMVERSION_H
#define SYSTEMVERSION_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QDomDocument>

class VersionDict :public QObject
{   
public:
    VersionDict(QDomNodeList nodelist)
    {      
        for (int i = 0; i < nodelist.length(); i++)
        {
            auto note = nodelist.at(i).toElement();
            auto name = note.nodeName();

            auto valueNote= nodelist.at(++i).toElement();
            auto valueType = valueNote.nodeName();
            
            if (valueType == "dict")
            {
                mapDict.insert(note.text(), new VersionDict(valueNote.childNodes()));
            }
            else if (valueType == "string")
            {
                dict.insert(note.text(), valueNote.text());
            }
            else  if(valueType == "array")
            {
                for (int j = 0; j < valueNote.childNodes().count(); j++)
                {
                    if (valueNote.childNodes().at(j).toElement().nodeName() == "string")
                        messages.append( valueNote.childNodes().at(j).toElement().text());
                    else if(valueNote.childNodes().at(j).toElement().nodeName() == "dict")
                    {
                        VersionDictList.append(new VersionDict(valueNote.childNodes().at(j).childNodes()));
                    }
                }
            }
        }
    }
    ~VersionDict()
    {
    }   
    QStringList messages;
    QMap<QString, QString> dict;
    QMap<QString, VersionDict*> mapDict;
    QList<VersionDict*> VersionDictList;
    VersionDict* content = nullptr;  
};

class SystemVersion:public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString buildDate  READ buildDate CONSTANT)
    Q_PROPERTY(QString version  READ version CONSTANT)
    Q_PROPERTY(QString minDate  READ minDate CONSTANT)
    Q_PROPERTY(QString packageUrl  READ packageUrl CONSTANT)
    Q_PROPERTY(QString url  READ url CONSTANT)
    Q_PROPERTY(QString text  READ text CONSTANT)
    Q_PROPERTY(QString language  READ language CONSTANT)
    Q_PROPERTY(bool upgrade  READ upgrade NOTIFY upgradeChanged )
    Q_PROPERTY(QString currentBuildDate  READ currentBuildDate CONSTANT)
    Q_PROPERTY(QString currentVersion  READ currentVersion CONSTANT)
public:
    SystemVersion();
    QString buildDate() const;

    QString version() const;

    QString minDate() const;

    QString packageUrl() const;

    QString url() const;

    QString text() const;

    QString language() const;
    Q_INVOKABLE bool skipVersion();
    bool upgrade() const;

    QString currentBuildDate() const;

    QString currentVersion() const;

private:
    QString serverUrl="http://download.gemoo.com/config/gemooconverter.xml";    
    QString m_buildDate;
    QString m_version;
    QString m_minDate;
    QString m_packageUrl;
    QString m_url;
    QString m_text;


#ifdef Q_OS_WIN
    QString system = "win";
#endif

#ifdef Q_OS_LINUX

#endif

#ifdef Q_OS_MAC
    QString system = "mac";
#endif
    QString m_language;

    QString m_skipVersion;
    bool m_upgrade=false;
    QString m_currentBuildDate="20240401";
    QString m_currentVersion="1.0.0";

    QNetworkReply* pReply = nullptr;

signals:
    void upgradeChanged();
};

#endif // SYSTEMVERSION_H
