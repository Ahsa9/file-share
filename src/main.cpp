#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QFontDatabase>
#include <QDebug>

// Backend Headers
#include "appcore.h"
#include "AuditModel.h"

int main(int argc, char *argv[])
{
    // 1. Enable High DPI Scaling (Essential for older Qt versions on modern screens)
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    QGuiApplication app(argc, argv);

    // 2. Register Custom Fonts
    QStringList fontFiles = {
        ":/fonts/Montserrat-Medium.ttf",
        ":/fonts/Montserrat-SemiBold.ttf",
        ":/fonts/EncodeSans-Bold.ttf",
        ":/fonts/EncodeSans-SemiBold.ttf",
        ":/fonts/EncodeSans-Regular.ttf",
        ":/fonts/Roboto-Medium.ttf",
        ":/fonts/RobotoCondensed-Bold.ttf",
        ":/fonts/CourierPrime-Bold.ttf",
        ":/fonts/Ubuntu-Bold.ttf",
        ":/fonts/SFPRODISPLAYREGULAR.OTF"
    };

    for (const QString &file : fontFiles) {
        if (QFontDatabase::addApplicationFont(file) == -1) {
            qWarning() << "❌ Failed to load font:" << file;
        }
    }

    // 3. Initialize Backends
    AppCore core;           // Your existing logic (Redis, Hardware, etc.)
    AuditModel auditModel;  // The new Database logic (SQLite)

    // 4. Initialize QML Engine
    QQmlApplicationEngine engine;

    // 5. Inject Context Properties into QML
    // These names ("appCore", "auditModel") are what you use inside QML files.
    engine.rootContext()->setContextProperty("appCore", &core);
    engine.rootContext()->setContextProperty("auditModel", &auditModel);

    // 6. Load Main QML
    const QUrl url(QStringLiteral("qrc:/main.qml"));

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
        &app, [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        }, Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}
