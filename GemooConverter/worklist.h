#ifndef WORKLIST_H
#define WORKLIST_H

#include <QObject>
// #include <listviewmodel.h>
#include <QUrl>

class WorkList : public QObject
{
    Q_OBJECT
   // Q_PROPERTY(ListViewModel* files  READ files CONSTANT)
public:
    explicit WorkList(QObject *parent = nullptr);

};

#endif // WORKLIST_H
