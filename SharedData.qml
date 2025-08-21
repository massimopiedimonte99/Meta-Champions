pragma Singleton
import QtQuick

QtObject {
    property string summonerName: "Vex"
    property real winRateRounded: -1
    property bool isLoading: false

    signal clearInputBox()
}
