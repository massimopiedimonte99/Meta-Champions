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

    Column {
        id: wrapperLayout
        anchors.horizontalCenter: parent.horizontalCenter

        Row {
            id: inputBox
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10

            TextField {
                id: inputBtn
                width: 500
                placeholderText: "Ahri, Jarvan IV, Sienna, Jhin..."
                renderType: Text.QtRendering
                onTextChanged: function () {
                    findSummonerBoxModel.clear()

                    for(let i = 0; i < summonerModel.count; i++) {
                        let summonerInfo    = summonerModel.get(i)
                        let summonerName    = summonerInfo.name.replace(/\s+/g, '').toLowerCase();
                        let userInput       = inputBtn.text.replace(/\s+/g, '').toLowerCase();

                        if(summonerName.startsWith(userInput)) {
                            findSummonerBoxModel.append({
                                                            name: summonerInfo.name,
                                                            riotParsedName: summonerInfo.riotParsedName
                                                        })
                        }
                    }
                }
            }
        }

        ListView {
            id: findSummoner
            width: inputBtn.width
            height: inputBoxWrapper.height
            clip: true
            visible: inputBtn.text !== ''

            SummonerModel { id: summonerModel }

            model: ListModel {
                id: findSummonerBoxModel
            }

            delegate: Rectangle {
                id: findSummonerBox
                width: findSummoner.width
                height: inputBtn.height
                radius: 5
                border.width: 1
                border.color: searchBtnColor

                Row {
                    anchors.fill: parent
                    spacing: 10
                    anchors.margins: 5

                    Image {
                       id: champIcon
                       width: 40
                       height: 40
                       fillMode: Image.PreserveAspectFit
                       source: "https://ddragon.leagueoflegends.com/cdn/15.16.1/img/champion/" + riotParsedName + ".png"
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: qsTr(name)
                    }
                }

                MouseArea {
                    id: findSummonerMouseEvent
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    enabled: !SharedData.isLoading

                    onClicked: function () {
                        SharedData.isLoading = true
                        inputBoxWrapper.searchSummoner(riotParsedName)
                    }
                }
            }

            // Pre-loader un po' rudimentale ma funzionante per il pool di informazioni che ci servono (usa RAM)
            // TODO: Si potrebbe renderlo più scalabile implementando un sistema di salvataggio sulla memoria cache (usa il disco)
            Item {
                id: preloader
                visible: false

                Repeater {
                    model: summonerModel
                    Image {
                        source: "https://ddragon.leagueoflegends.com/cdn/15.16.1/img/champion/" + model.riotParsedName + ".png"
                        cache: true
                    }
                }
            }
        }
    }
}
