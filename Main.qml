import QtQuick
import QtQuick.Window
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

import MetaChampions 1.0

/**
    Per questioni di tempo/interesse non sono andato a coprire alcuni aspetti implementativi volti a migliorare le funzionalità
    e la robustezza del programma e del codice. Lascio di seguito una to-do list con una serie di voci (alcune da implementare,
    altre già implementate).

    Il programma verrà fornito con licenza MIT

    TODO:
        - Normalizzare l'input utente (e.g. Cho' Gath -> Chogath) - ✅
        - Implementate un Singleton per gestire le proprietà condivise (ref. https://chatgpt.com/c/689f81f1-a190-8331-934f-34cfccfc9ad2) - ✅
        - Dividere il file "Main.qml" in "Logo.qml" e "InputBox.qml" - ✅
        - Implementare lo StackView per la pagina dettaglio - ✅
        - Scrittura della pagina di dettaglio
        - Implementare un meccanismo di auto-complete sul campo di testo per evitare errori di ortografia
        - Gestire il click del button di ricerca in modo tale da bloccarsi se la ricerca è in corso
        - Implementare gestione try/catch
        - Implementare un loader che blocchi le interazioni dell'utente con l'applicazione
        - Animare il cambio pagina

    Di seguito un link con la bozza di progetto e la to-do list originale: https://pastebin.com/raw/FrDXWMtr */

ApplicationWindow {
    id: root
    width: 640
    height: 480
    visible: true
    title: qsTr("Meta Champions")

    Material.theme: Material.Light
    Material.accent: Material.BlueGrey

    property int logoSize: 300
    property int searchBtnSize: 70
    property var searchBtnColor: Qt.rgba(0.608, 0.608, 0.608, 1)

    // ---- StackView
    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: detailPage
        focus: true
    }

    // ---- Home Page
    Component {
        id: homePage

        Item {
            id: homePageWrapper

            width: root.width
            height: root.height

            // MouseArea globale per la Home Page
            MouseArea {
                anchors.fill: parent
                z: -1
                onClicked: inputBoxWrapper.inputBtn.focus = false
            }

            // Logo
            Logo {
                id: logoWrapper
                _logoSize: logoSize
            }

            // Input BOX
            InputBox {
                id: inputBoxWrapper
                anchors.top: logoWrapper.bottom

                onSearchSummoner: function(summoner) {
                    submit(summoner);
                }
            }
        }
    }

    // ---- Detail Page
    Component {
        id: detailPage

        Item {
            id: detailPageWrapper

            DetailPage {
                id: detailPageRow
            }
        }
    }

    // ---- Connessione con Net
    Connections {
        target: Net

        function onChampionsFetched(obj) {
            console.log(JSON.stringify(obj))
        }

        // TODO: ritorna un oggetto con winrate e nome campione normalizzato
        function onGamesFetched(winRate) {
            SharedData.isLoading = false

            if(winRate === -1) {
                console.log("Dati insufficienti")
                return
            }

            stackView.push(detailPage)
            SharedData.winRateRounded = Math.round(winRate * 10) / 10
            console.log(SharedData.winRateRounded)
        }

        function onErrorOccurred(msg) {
            console.log("Errore: " + msg)
        }
    }

    // ---- Utilities
    function submit(summonerName) {
        console.log("Chiamo -> Net.fetchGames() passandogli il summoner: " + summonerName)
        Net.fetchGames(summonerName)
    }
}
