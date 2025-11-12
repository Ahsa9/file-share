import QtQuick 2.15
import QtQuick.Window 2.15
import "components"

Window {
    id: root
    width: 2560
    height: 720
    visible: true
    color: "black"
    flags: Qt.FramelessWindowHint | Qt.Window
    visibility: Window.FullScreen

    property var totalizerPopup: undefined

    // === TOTALIZER POPUP ===
    Item {
        id: totalizerPopup
        width: root.width
        height: root.height
        visible: false
        z: 50 // above everything

        Rectangle {
            anchors.fill: parent
            color: "#00000080" // semi-transparent overlay
        }

        Column {
            anchors.centerIn: parent
            spacing: 20

            Text {
                text: "TOTALIZER"
                font.pixelSize: 60
                color: "white"
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                text: "0.00 KM"
                font.pixelSize: 48
                color: "white"
                horizontalAlignment: Text.AlignHCenter
            }
        }

        Timer {
            id: hidePopupTimer
            interval: 3000
            running: false
            repeat: false
            onTriggered: totalizerPopup.visible = false
        }
    }

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

    // === HOME SCREEN COMPONENT ===
    Component {
        id: homeScreen
        Item {
            anchors.fill: parent

            // --- HIRED PANEL (ON TOP OF TOPBAR) ---
            HiredPanel {
                id: hiredPanel
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.leftMargin: 52
                visible: appCore.taxiMeterStatus.toUpperCase() === "HIRED"
                z: 3
            }

            // --- STOPPED PANEL (HIGHEST PRIORITY WHEN ACTIVE) ---
            StoppedPanel {
                id: stoppedPanel
                anchors.left: parent.left
                anchors.top: parent.top
                visible: appCore.taxiMeterStatus.toUpperCase() === "STOPPED"
                z: 20
            }

            // --- TOP BAR (BELOW HIRED PANEL, ABOVE MAP) ---
            TopBar {
                id: headerBar
                anchors.top: parent.top
                width: parent.width
                z: 2
            }

            // --- TRIP BUTTON ---
            TripButton {
                id: tripButton
                anchors.left: parent.left
                anchors.leftMargin: 52
                anchors.bottom: parent.bottom
                z: 5
            }

            // --- BOTTOM BAR ---
            BottomBar {
                id: bottomBar
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                z: 5
            }

            // ✅ MAP BUTTON REMOVED COMPLETELY
        }
    }
}
