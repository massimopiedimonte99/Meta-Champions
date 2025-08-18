import QtQuick
import QtQuick.Window
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

import MetaChampions 1.0

Item {
    id: detail
    width: parent.width
    height: parent.height

    property int avatarSize: 150

    Button {
        id: backButton
        width: 50
        height: 50
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 10
        anchors.topMargin: 10

        background: Rectangle {
            id: rect1
            anchors.fill: parent
            radius: 5
            border.color: searchBtnColor
        }

        contentItem: Image {
            id: searchBtnIcon
            fillMode: Image.PreserveAspectFit
            anchors.fill: parent
            anchors.margins: 15
            source: "qrc:/assets/back.png" // https://www.flaticon.com/free-icons/back
        }

        MouseArea {
            anchors.fill: parent
            enabled: parent.enabled
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onClicked: stackView.pop()
        }
    }

    Row {
        id: detailRow
        anchors.top: backButton.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        Rectangle {
            width: parent.width * 0.5
            height: parent.height

            // TODO: Sostituire la versione 15.16.1 con l'ultima disponibile da API (https://ddragon.leagueoflegends.com/api/versions.json)
            Image {
                id: detailPic
                width: avatarSize
                height: avatarSize
                anchors.centerIn: parent
                source: "https://ddragon.leagueoflegends.com/cdn/15.16.1/img/champion/" + SharedData.summonerName + ".png"
                fillMode: Image.PreserveAspectFit
            }
        }

        Rectangle {
            width: parent.width * 0.6
            height: parent.height

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10

                Text {
                    id: summonerNameText
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    font.pointSize: 20
                    text: qsTr("Summoner Name: <b>" + SharedData.summonerName + "</b>")
                }

                Text {
                    id: winRateText
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    font.pointSize: 20
                    text: qsTr("Win Rate: <b>" + SharedData.winRateRounded + "%</b>")
                }
            }
        }
    }
}
