#ifndef FFMPEGCOMMAND_H
#define FFMPEGCOMMAND_H

#include <QObject>
#include <QProcess>
#include <qdebug.h>
#include <QLoggingCategory>

class FFmpegCommand : public QObject
{
    Q_OBJECT
   // Q_PROPERTY(double overallBitRate  READ overallBitRate WRITE setCompleteName  NOTIFY completeNameChanged)
public:
    explicit FFmpegCommand(QObject *parent = nullptr);

    Q_INVOKABLE  bool executeCommand(QString input,QString output,QString commands);

signals:
    void porcessMessage(QString message,double time);
    void finish(bool successful);
private:
    QString ffmpeg="ffmpeg.exe";
    QProcess process;
signals:
};

#endif // FFMPEGCOMMAND_H
