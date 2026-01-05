#include "AuditModel.h"
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include <QFile>
#include <QSqlRecord>
#include <QDateTime>

AuditModel::AuditModel(QObject *parent) : QSqlQueryModel(parent)
{
    if (initDatabase()) {
        refresh();
    }
}

bool AuditModel::initDatabase()
{
    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");
    QString fullPath = "/taximeter-config/audit_trail.db";

    if (!QFile::exists(fullPath)) {
        qDebug() << "❌ Database missing at:" << fullPath;
        return false;
    }

    db.setDatabaseName(fullPath);
    if (!db.open()) return false;

    return db.tables().contains("logs");
}

void AuditModel::refresh()
{
    this->setQuery("SELECT id, name, date, time, changes FROM logs ORDER BY id DESC LIMIT 50");
}

void AuditModel::applyFilter(const QString &startDate, const QString &endDate)
{
    // Dates must arrive in "yyyy-MM-dd" format
    qDebug() << "🔍 SQL Filtering between:" << startDate << "and" << endDate;

    QSqlQuery query;
    query.prepare("SELECT id, name, date, time, changes FROM logs "
                  "WHERE date BETWEEN :start AND :end ORDER BY id DESC");
    query.bindValue(":start", startDate);
    query.bindValue(":end", endDate);

    if (!query.exec()) {
        qDebug() << "❌ SQL Error:" << query.lastError().text();
    }
    this->setQuery(query);
}

void AuditModel::clearFilter()
{
    refresh();
}

bool AuditModel::addLog(const QString &name, const QString &jsonContent)
{
    QSqlQuery query;
    query.prepare("INSERT INTO logs (name, date, time, changes) VALUES (:name, :date, :time, :changes)");
    query.bindValue(":name", name);

    // Store as ISO format (yyyy-MM-dd) for SQLite compatibility
    query.bindValue(":date", QDate::currentDate().toString("yyyy-MM-dd"));
    query.bindValue(":time", QTime::currentTime().toString("HH:mm:ss"));
    query.bindValue(":changes", jsonContent);

    if (query.exec()) {
        refresh();
        return true;
    }
    return false;
}

QHash<int, QByteArray> AuditModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[Qt::UserRole + 1] = "id";
    roles[Qt::UserRole + 2] = "name";
    roles[Qt::UserRole + 3] = "date";
    roles[Qt::UserRole + 4] = "time";
    roles[Qt::UserRole + 5] = "changes";
    return roles;
}

QVariant AuditModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) return QVariant();

    // The 'date' role (Qt::UserRole + 3)
    if (role == Qt::UserRole + 3) {
        QString rawDate = record(index.row()).value("date").toString();

        // 1. Try to parse as ISO (yyyy-MM-dd)
        QDate date = QDate::fromString(rawDate, "yyyy-MM-dd");

        // 2. Fallback to parsing slashes if old data exists
        if (!date.isValid()) {
            date = QDate::fromString(rawDate, "dd/MM/yyyy");
        }

        // 3. RETURN WITH DASHES: dd-MM-yyyy
        // This is what the QML Text element will display.
        return date.isValid() ? date.toString("dd-MM-yyyy") : rawDate;
    }

    // ... rest of the column logic ...
    int columnIndex = role - (Qt::UserRole + 1);
    if (columnIndex >= 0 && columnIndex < record().count()) {
        return record(index.row()).value(columnIndex);
    }

    return QSqlQueryModel::data(index, role);
}
