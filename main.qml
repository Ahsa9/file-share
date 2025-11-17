import QtQuick 2.15
import QtQuick.Window 2.15
import "components"

Window {
    id: root
    width: 2560
    height: 720
    visible: true
    color: "#121217"
    title: "TaxiMeter"
    flags: Qt.Window
    visibility: "Windowed"

    // Add this property
    property var totalizerPopup: null
    // === MAP ALWAYS BEHIND EVERYTHING ===
    Loader {
        id: mapLoader
        anchors.fill: parent
        source: "qrc:/components/Map.qml"
        z: 0
    }

    // === MAIN SCREEN ABOVE MAP ===
    Loader {
        id: screenLoader
        anchors.fill: parent
        sourceComponent: homeScreen
        z: 1
    }

    // === HOME SCREEN ===
    Component {
        id: homeScreen

        Item {
            anchors.fill: parent

            // Background image removed
            HiredPanel {
                id: hiredPanel
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.leftMargin: 52
                visible: appCore.taxiMeterStatus.toUpperCase() === "HIRED"
                z: 10
            }

            StoppedPanel {
                id: stoppedPanel
                anchors.left: parent.left
                anchors.top: parent.top
                visible: appCore.taxiMeterStatus.toUpperCase() === "STOPPED"
                z: 20
            }

            TopBar {
                id: headerBar
                anchors.top: parent.top
                width: parent.width
                z: 4
            }

            TripButton {
                id: tripButton
                anchors.left: parent.left
                anchors.leftMargin: 52
                anchors.bottom: parent.bottom
                z: 5
            }

            BottomBar {
                id: bottomBar
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                z: 5
                windowRef: root // pass the Window reference like MainBar
            }

            // ✅ MAP BUTTON REMOVED
        }
    }
}
