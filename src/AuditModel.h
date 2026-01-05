#ifndef AUDITMODEL_H
#define AUDITMODEL_H

#include <QSqlQueryModel>
#include <QObject>

class AuditModel : public QSqlQueryModel
{
    Q_OBJECT

public:
    explicit AuditModel(QObject *parent = nullptr);

    // QML Invokable functions
    Q_INVOKABLE void refresh();
    Q_INVOKABLE void applyFilter(const QString &startDate, const QString &endDate);
    Q_INVOKABLE void clearFilter();

    // Function to add new logs (can be called from terminal or C++)
    Q_INVOKABLE bool addLog(const QString &name, const QString &jsonContent);

    // Mapping roles for QML
    QHash<int, QByteArray> roleNames() const override;
    QVariant data(const QModelIndex &index, int role) const override;

private:
    bool initDatabase();
};

#endif // AUDITMODEL_H
