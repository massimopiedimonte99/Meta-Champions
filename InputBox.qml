import QtQuick
import QtQuick.Window
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

import MetaChampions 1.0

Item {
    id: inputBoxWrapper
    width: parent.width
    height: parent.height / 2

    property alias inputBtn: inputBtn
    signal searchSummoner(string summoner)

    Row {
        id: inputBox
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10

        TextField {
            id: inputBtn
            width: 500
            placeholderText: "Ahri, Jarvan IV, Sienna, Jhin..."
            renderType: Text.QtRendering
        }

        Button {
            id: searchBtn
            width: inputBtn.height
            height: inputBtn.height
            enabled: inputBtn.text !== '' && !SharedData.isLoading

            background: Rectangle {
                id: rect1
                anchors.fill: parent
                radius: 5
                border.color: searchBtnColor
                opacity: searchBtn.enabled ? 1 : 0.5
            }

            contentItem: Image {
                id: searchBtnIcon
                fillMode: Image.PreserveAspectFit
                anchors.fill: parent
                anchors.margins: 20
                opacity: searchBtn.enabled ? 1 : 0.5
                source: "qrc:/assets/search.png" // https://www.flaticon.com/free-icons/magnifying-glass
            }

            MouseArea {
                anchors.fill: parent
                enabled: parent.enabled
                cursorShape: parent.enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                hoverEnabled: true
                onClicked: {
                        SharedData.isLoading = true
                        inputBoxWrapper.searchSummoner(inputBtn.text)
                }
            }
        }
    }
}
