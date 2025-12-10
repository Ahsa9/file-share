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

    // ---- APPLICATION STATE MACHINE ----
    property string appState: "splash"
    // Popup References (Used to close them remotely)
    property var totalizerPopup: null
    property var infoPopup: null
    property var driverInfoPopup: null
    property var historyPopup: null
    function openAdminPanel() {
        console.log("Opening Admin Panel - Closing other popups...")

        // 1. Force close all popups if they exist
        if (root.totalizerPopup)
            root.totalizerPopup.visible = false
        if (root.infoPopup)
            root.infoPopup.visible = false
        if (root.driverInfoPopup)
            root.driverInfoPopup.visible = false
        if (root.historyPopup)
            root.historyPopup.visible = false

        // 2. Load and Show Admin Settings on top
        adminLoader.active = true
    }

    // ---------------------------------------------------------
    // ADMIN SETTINGS LOADER (Overlay)
    // ---------------------------------------------------------
    Loader {
        id: adminLoader
        active: false // Only load when needed
        source: "qrc:/components/AdminSettings.qml" // Adjust path if needed
        anchors.fill: parent
        z: 999 // Ensure it covers EVERYTHING (Home, BottomBar, Popups)

        onLoaded: {
            // connect the requestClose signal from AdminSettings
            item.onRequestClose.connect(function () {
                adminLoader.active = false
            })
        }
    }

    // ---------------------------------------------------------
    // LISTEN FOR LOGIN SUCCESS / FAILED FROM C++ (AppCore)
    // ---------------------------------------------------------
    Connections {
        target: appCore

        function onLoginSuccess() {
            console.log("LOGIN SUCCESS → Navigating to HOME")
            appState = "home"
            screenLoader.source = ""
            screenLoader.sourceComponent = homeScreen
        }

        function onLoginFailed(reason) {
            console.log("LOGIN FAILED:", reason)
            // TODO: show error popup
        }
    }

    // ---------------------------------------------------------
    // MAP LOADER — Loads only after splash
    // ---------------------------------------------------------
    Loader {
        id: mapLoader
        anchors.fill: parent
        source: "" // load after splash
        z: 0
    }

    // ---------------------------------------------------------
    // SCREEN LOADER — Splash → Login → Home
    // ---------------------------------------------------------
    Loader {
        id: screenLoader
        anchors.fill: parent
        source: "qrc:/components/SplashScreen.qml"
        z: 10

        onLoaded: {
            if (!item)
                return

            // ---- Step 1: When splash finishes → go to Login ----
            if (appState === "splash" && item.splashFinished) {

                item.splashFinished.connect(function () {

                    // load map in background
                    mapLoader.source = "qrc:/components/Map.qml"

                    // switch to login screen
                    appState = "login"
                    screenLoader.source = ""
                    screenLoader.source = "qrc:/components/LogginPage.qml"
                })
            }
        }
    }

    // ---------------------------------------------------------
    // HOME SCREEN (Main UI)
    // ---------------------------------------------------------
    Component {
        id: homeScreen

        Item {
            anchors.fill: parent

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
                windowRef: root
                visible: appCore.taxiMeterStatus.toUpperCase() === "FOR HIRE"
                z: 5
            }

            WarningsWindow {
                id: warningsWindow
                anchors.centerIn: parent
                anchors.horizontalCenter: parent.horizontalCenter
                windowRef: root
                z: 5
            }
        }
    }
}
