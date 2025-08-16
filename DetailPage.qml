import QtQuick

import MetaChampions 1.0

Item {
    id: detail
    width: parent.width
    height: parent.height

    Row {
        id: detailRow
        width: parent.width
        height: parent.height

        Rectangle {
            width: parent.width * 0.6
            height: parent.height

            Image {
                id: detailPic
                width: 250
                height: 250
                anchors.centerIn: parent
                source: "qrc:/assets/logo.png"
                fillMode: Image.PreserveAspectFit
            }
        }

        Rectangle {
            width: parent.width * 0.4
            height: parent.height

            Text {
                id: detailText
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 10
                font.pixelSize: 24
                text: qsTr("Win Rate: <b>" + SharedData.winRateRounded + "%</b>")
            }
        }




    }

}
