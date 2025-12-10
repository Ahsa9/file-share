#ifndef AUDITMODEL_H
#define AUDITMODEL_H

#include <QSqlQueryModel>
#include <QObject>

class AuditModel : public QSqlQueryModel
{
    Q_OBJECT

public:
    explicit AuditModel(QObject *parent = nullptr);

    // Methods QML can call
    Q_INVOKABLE void refresh();
    Q_INVOKABLE void applyFilter(const QString &startDate, const QString &endDate);
    Q_INVOKABLE void clearFilter();

    // Map SQL columns to QML variable names
    QHash<int, QByteArray> roleNames() const override;
    QVariant data(const QModelIndex &index, int role) const override;

private:
    void initDatabase();
};

#endif // AUDITMODEL_H
