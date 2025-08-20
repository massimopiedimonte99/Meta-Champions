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

            Column {

            }

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

        ListView {
            id: findSummoner
            width: inputBtn.width
            height: inputBoxWrapper.height
            clip: true
            visible: inputBtn.text !== ''

            // TODO: Interrogare la Riot API per ottenere una lista completa e aggiornata (qui lascio un po' di placeholder...)
            // TODO: Spostare questo model in un file .qml dedicato
            ListModel {
                id: summonerModel
                ListElement { name: "Aatrox";       riotParsedName: "Aatrox" }
                ListElement { name: "Ahri";         riotParsedName: "Ahri" }
                ListElement { name: "Akali";        riotParsedName: "Akali" }
                ListElement { name: "Akshan";       riotParsedName: "Akshan" }
                ListElement { name: "Alistar";      riotParsedName: "Alistar" }
                ListElement { name: "Ambessa";      riotParsedName: "Ambessa" }
                ListElement { name: "Amumu";        riotParsedName: "Amumu" }
                ListElement { name: "Varus";        riotParsedName: "Varus" }
                ListElement { name: "Vayne";        riotParsedName: "Vayne" }
                ListElement { name: "Veigar";       riotParsedName: "Veigar" }
                ListElement { name: "Velkoz";       riotParsedName: "Velkoz" }
                ListElement { name: "Vex";          riotParsedName: "Vex" }
                ListElement { name: "Vi";           riotParsedName: "Vi" }
                ListElement { name: "Viego";        riotParsedName: "Viego" }
                ListElement { name: "Viktor";       riotParsedName: "Viktor" }
                ListElement { name: "Vladimir";     riotParsedName: "Vladimir" }
            }

            model: ListModel {
                id: findSummonerBoxModel
            }

            delegate: Rectangle {
                id: findSummonerBox
                width: findSummoner.width
                height: inputBtn.height
                radius: 5
                border.width: 1
                border.color: '#e3e3e3'

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
                    onClicked: function () {
                        console.log(name)
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
