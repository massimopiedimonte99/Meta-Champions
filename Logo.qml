import QtQuick

Item {
    id: logoWrapper
    width: root.width
    height: root.height / 2

    property real _logoSize

    Image {
        id: logo
        width: _logoSize
        height: _logoSize
        anchors.centerIn: parent
        source: "qrc:/assets/logo.png"
        fillMode: Image.PreserveAspectFit
    }
}
