#ifndef FFMPEGCOMMAND_H
#define FFMPEGCOMMAND_H

#include <QObject>
#include <QProcess>
#include <qdebug.h>
#include <QLoggingCategory>
#include <outfileinfo.h>

class FileInfo;
class FFmpegCommand : public QObject
{
    Q_OBJECT
    Q_PROPERTY(double progress  READ progress  NOTIFY progressMessage)
    Q_PROPERTY(CommandState   state   READ state   NOTIFY stateChanged)

public:
    enum CommandState
    {
        None,
        Unstart,
        Running,
        Finish,
        Failure
    };
    Q_ENUM(CommandState);

    explicit FFmpegCommand(QObject *parent = nullptr);
    Q_INVOKABLE  bool awaitStart();
    Q_INVOKABLE  bool cancel();
    Q_INVOKABLE  bool executeCommand(const QString input,const QString outdir, const  OutFileInfo* outInfo,const FileInfo* fileInfo);

    CommandState state() const;

    double progress() const;

signals:
    void progressMessage(QString message,double time);
    void finishChanged(bool successful);
private:
#ifdef Q_OS_WIN
    QString ffmpeg="ffmpeg.exe";
#endif
#ifdef Q_OS_MACOS
    QString ffmpeg="ffmpeg";
#endif
    QProcess process;
    CommandState m_state=None;
    double m_progress=0;
    QString outfile;
signals:
    void stateChanged();
    void progressChanged();
};

#endif // FFMPEGCOMMAND_H
