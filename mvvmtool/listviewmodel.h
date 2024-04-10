#ifndef LISTVIEWMODEL_H
#define LISTVIEWMODEL_H
#include <QList>
#include <QAbstractListModel>
#include <QMetaObject>
#include <QMetaProperty>
#include <qmutex.h>

class ListViewModel :public QAbstractListModel
{
    Q_OBJECT
public:
    explicit  ListViewModel(const  QMetaObject& metaObject, QObject* parent = nullptr)
    {
        className = metaObject.className();
        for (int i = 0; i < metaObject.propertyCount(); i++)
        {
            QMetaProperty oneProperty = metaObject.property(i);
            auto name = oneProperty.name();
            cloumnHash.insert(i, name);
        }
    }

    ~ListViewModel()
    {
        this->disconnect();
        qDeleteAll(list);
    }

    int rowCount(const QModelIndex& parent = QModelIndex()) const
    {
        return list.size();
    }

    int columnCount(const QModelIndex& parent = QModelIndex()) const
    {
        return cloumnHash.size();
    }

    Q_INVOKABLE QVariant data(int index, QString column)
    {
        mutex.lock();
        if (index >= 0 && index < this->size())
        {
            auto model = this->list.at(index);
            if (model != nullptr) {
                auto value = model->property(column.toUtf8());
                mutex.unlock();
                return value;
            }
        }
        mutex.unlock();
        return QVariant();
    }

    QVariant data(const QModelIndex& index, int role = Qt::UserRole) const
    {
        if (!index.isValid())
            return QVariant();
        auto i = index.row();
        int column = role;
        if (role == 0)
        {
            column = index.column();
        }
        if (i >= this->list.count())
        {
            return QVariant();
        }

        auto hash = cloumnHash;
        if (hash.contains(column))
        {
            if (this->list.at(index.row()) == nullptr)
            {

                return QVariant();
            }
            auto model = this->list.at(i);
            auto property = hash.find(column).value();

            if (property.contains('.')) {
                auto value = qobject_cast<QObject*> (model);
                auto tt = value->property(property);
                return  tt;
            }
            else
            {
                auto value = model->property(property);
                return  value;
            }
        }

        return QVariant();
    }

    bool setData(const QModelIndex& index, const QVariant& value, int role = Qt::EditRole)
    {
        if (!index.isValid())
            return false;
        if (index.row() >= size())
            return false;
        mutex.lock();
        auto hash = cloumnHash;
        if (hash.contains(role))
        {
            this->list.at(index.row())->setProperty(hash.find(role).value(), value);

            emit dataChanged(index, index, QVector<int>() << role);
        }
        mutex.unlock();
        return  true;
    }

    QObject* at(int index)
    {
        return list.at(index);
    }

    QVariant headerData(int section, Qt::Orientation orientation, int role = Qt::DisplayRole) const
    {
        return cloumnHash[section];
    }

    QHash<int, QByteArray> roleNames() const
    {
        return cloumnHash;
    }

    Q_INVOKABLE int size() const
    {
        return list.size();
    }

    Q_INVOKABLE void clear()
    {
        beginResetModel();
        qDeleteAll(list);
        list.clear();
        endResetModel();
    }

    template <typename T>
    void prepend(const T& t)
    {
        auto modelIndex = QAbstractListModel::index(this->size());
        beginInsertRows(modelIndex, 0, 0);
        list.prepend(t);
        endInsertRows();
    }

    template <typename T>
    void append(const QList<T>& t)
    {
        if (t.size() == 0)
        {
            return;
        }
        mutex.lock();
        auto modelIndex = createIndex(this->size(),0);
        beginInsertRows(QModelIndex(), this->size(), this->size() + t.size()-1);
        foreach (auto item , t)
        {
            list.append(item);
        }
        endInsertRows();
        mutex.unlock();
    }

    template <typename T>
    void append(const T& t)
    {
        mutex.lock();
        auto modelIndex = QAbstractListModel::index(this->size());
        beginInsertRows(modelIndex, this->size(), this->size());
        list.append(t);
        endInsertRows();
        mutex.unlock();
    }

    template <typename T>
    void insert(int i, const T& t)
    {
        auto modelIndex = QAbstractListModel::index(i);
        beginInsertRows(modelIndex, i, i);
        list.insert(i, t);
        endInsertRows();
    }

    Q_INVOKABLE  void removeAt(int i)
    {
        mutex.lock();
        if (this->size() > i)
        {
            auto dest = this->list.at(i);
            beginRemoveRows(QModelIndex(), i, i);
            list.removeAt(i);
            endRemoveRows();
            /*	if (dest != nullptr)
			{
				dest->deleteLater();
			}*/
        }
        mutex.unlock();
    }

    template <typename T>
    int removeAll(const T& t)
    {
        int count = 0;
        while (removeOne(t)) {
            count++;
        }
        return count;
    }
    template <typename T>
    bool removeOne(const T& t)
    {
        auto index = list.indexOf(t);
        if (index >= 0)
        {
            removeAt(index);
        }
        return index >= 0;
    }
    QObjectList values()
    {
        return list;
    }
    void dataChang(int index)
    {

        emit dataChanged(  this->index(index),  this->index(index));
    }
    void resetModel()
    {
        beginResetModel();
        endResetModel();
    }

private:
    QHash<int, QByteArray> cloumnHash;
    QString className;
    QMutex mutex;
    QObjectList list;

};

#endif // LISTVIEWMODEL_H
