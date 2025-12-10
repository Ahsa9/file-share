#include "AuditModel.h"
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include <QStandardPaths>
#include <QDir>
#include <QSqlRecord>

AuditModel::AuditModel(QObject *parent) : QSqlQueryModel(parent)
{
    initDatabase();
    refresh(); // Load data on startup
}

void AuditModel::initDatabase()
{
    // 1. Setup the SQLite Driver
    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");

    // 2. Define the path (Standard AppData location)
    QString path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir dir(path);
    if (!dir.exists()) dir.mkpath(".");

    QString dbPath = path + "/SystemLogs.db";
    db.setDatabaseName(dbPath);

    // 3. Open Connection
    if (!db.open()) {
        qDebug() << "CRITICAL: Could not open database!" << db.lastError().text();
        return;
    }

    qDebug() << "Database connected successfully at:" << dbPath;

    // 4. Create Table if it doesn't exist
    QSqlQuery query;
    bool success = query.exec(
        "CREATE TABLE IF NOT EXISTS logs ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "name TEXT, "
        "date TEXT, "
        "time TEXT, "
        "changes TEXT)"
        );

    if (!success) qDebug() << "Table creation failed:" << query.lastError().text();

    // 5. (Optional) Seed dummy data if empty
    query.exec("SELECT count(*) FROM logs");
    if (query.next() && query.value(0).toInt() == 0) {
        query.exec("INSERT INTO logs (name, date, time, changes) VALUES ('Admin', '10/12/2025', '09:00 AM', 'System Boot')");
        query.exec("INSERT INTO logs (name, date, time, changes) VALUES ('Driver 1', '10/12/2025', '09:15 AM', 'Shift Start')");
        query.exec("INSERT INTO logs (name, date, time, changes) VALUES ('System', '10/12/2025', '12:00 PM', 'Auto Update')");
    }
}

void AuditModel::refresh()
{
    this->setQuery("SELECT id, name, date, time, changes FROM logs ORDER BY id DESC LIMIT 50");
    if (lastError().isValid()) qDebug() << "Refresh error:" << lastError().text();
}

void AuditModel::applyFilter(const QString &startDate, const QString &endDate)
{
    // Note: Simple string comparison for dates.
    // Ensure your date format in DB matches what you pass here.
    QString qStr = QString("SELECT id, name, date, time, changes FROM logs WHERE date BETWEEN '%1' AND '%2' ORDER BY id DESC")
                       .arg(startDate, endDate);

    this->setQuery(qStr);
    if (lastError().isValid()) qDebug() << "Filter error:" << lastError().text();
}

void AuditModel::clearFilter()
{
    refresh();
}

// Map SQL column indexes to QML role names
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

// Retrieve data for QML
QVariant AuditModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) return QVariant();

    // Calculate column index based on role
    // Qt::UserRole + 1 maps to column 0 (id), etc.
    int columnIndex = role - (Qt::UserRole + 1);

    if (columnIndex >= 0 && columnIndex < record().count()) {
        return record(index.row()).value(columnIndex);
    }

    return QSqlQueryModel::data(index, role);
}
