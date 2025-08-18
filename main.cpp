/**
 * This is free and unencumbered software released into the public domain.
 * Anyone is free to copy, modify, publish, use, compile, sell, or distribute this software, either in source code form or as a compiled binary, for any purpose, commercial or non-commercial, and by any means.
 *
 * For more information, please refer to <https://unlicense.org>
 *
 *
 *
 * Author: Massimo Piedimonte */

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQuickControls2/QQuickStyle>
#include <QQmlContext>

#include "net.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQuickStyle::setStyle("Material");

    QQmlApplicationEngine engine;

    Net *net = new Net(&app);
    net->setRegionInfo("europe.api.riotgames.com");
    net->setApiKey("RGAPI-1dfd2fc9-0ff3-448c-b5ca-0194f7dc9527");

    engine.rootContext()->setContextProperty("Net", net);

    const QUrl url(u"qrc:/MetaChampions/Main.qml"_qs);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
