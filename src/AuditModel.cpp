#include "AuditModel.h"
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include <QFile>
#include <QSqlRecord>

AuditModel::AuditModel(QObject *parent) : QSqlQueryModel(parent)
{
    // Only try to load data if connection was successful
    if (initDatabase()) {
        refresh();
    }
}

bool AuditModel::initDatabase()
{
    // 1. Setup SQLite Driver
    QSqlDatabase db;
    if (QSqlDatabase::contains("qt_sql_default_connection")) {
        db = QSqlDatabase::database("qt_sql_default_connection");
    } else {
        db = QSqlDatabase::addDatabase("QSQLITE");
    }

    // 2. Define exact path
    QString fullPath = "/taximeter-config/audit_trail.db";

    // 3. STRICT CHECK: Does the file exist?
    if (!QFile::exists(fullPath)) {
        qDebug() << "❌ ERROR: Database file not found at:" << fullPath;
        qDebug() << "   -> Please ensure the file exists and permissions are correct.";
        return false; // Stop here. Do not create anything.
    }

    // 4. Open Connection
    db.setDatabaseName(fullPath);
    if (!db.open()) {
        qDebug() << "❌ CRITICAL: Found file but could not open database:" << db.lastError().text();
        return false;
    }

    // 5. Verify Table Exists
    // Even if file exists, it might be empty or corrupt.
    if (!db.tables().contains("logs")) {
        qDebug() << "❌ ERROR: Database exists, but table 'logs' is missing.";
        return false;
    }

    qDebug() << "✅ Successfully connected to existing database at:" << fullPath;
    return true;
}

void AuditModel::refresh()
{
    QSqlDatabase db = QSqlDatabase::database();

    // Safety: Do not run query if DB is closed or invalid
    if (!db.isOpen()) {
        qWarning() << "⚠️ Cannot refresh: Database is not connected.";
        return;
    }

    this->setQuery("SELECT id, name, date, time, changes FROM logs ORDER BY id DESC LIMIT 50", db);

    if (lastError().isValid()) {
        qDebug() << "❌ Query Error:" << lastError().text();
    }
}

void AuditModel::applyFilter(const QString &startDate, const QString &endDate)
{
    QSqlDatabase db = QSqlDatabase::database();
    if (!db.isOpen()) return;

    QString qStr = QString("SELECT id, name, date, time, changes FROM logs WHERE date BETWEEN '%1' AND '%2' ORDER BY id DESC")
                       .arg(startDate, endDate);

    this->setQuery(qStr, db);

    if (lastError().isValid()) {
        qDebug() << "❌ Filter Error:" << lastError().text();
    }
}

void AuditModel::clearFilter()
{
    refresh();
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

    int columnIndex = role - (Qt::UserRole + 1);

    if (columnIndex >= 0 && columnIndex < record().count()) {
        return record(index.row()).value(columnIndex);
    }

    return QSqlQueryModel::data(index, role);
}
