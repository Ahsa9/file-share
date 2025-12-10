import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

Item {
    id: topBar
    width: 2560
    height: 138
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top

    // === SIGNAL TO NOTIFY PARENT ===
    signal adminTriggered

    // === CLICK COUNTER LOGIC ===
    property int logoClickCount: 0

    Timer {
        id: resetClickTimer
        interval: 2000 // Reset count if 2 seconds pass without a click
        onTriggered: topBar.logoClickCount = 0
    }

    // === TOP BAR BACKGROUND WITH BLACK GRADIENT ===
    Rectangle {
        id: bgColor
        anchors.fill: parent
        color: "black"
        visible: false
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: Qt.rgba(0, 0, 0, 0.8)
            }
            GradientStop {
                position: 1.0
                color: Qt.rgba(0, 0, 0, 0.0)
            }
        }
    }

    Image {
        id: logo
        source: "../images/client_logo.png"
        width: 279
        height: 83
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 30
        fillMode: Image.PreserveAspectFit
        scale: 1.0
        z: 10

        // === LOGO CLICK AREA ===
        MouseArea {
            anchors.fill: parent
            onClicked: {
                topBar.logoClickCount += 1
                resetClickTimer.restart() // Restart the 2-second timer

                if (topBar.logoClickCount >= 5) {
                    topBar.logoClickCount = 0
                    topBar.adminTriggered() // Fire signal
                    console.log("top clicked")
                }
            }
        }
    }

    // === STATUS BOX ===
    Rectangle {
        id: statusBox
        width: 221
        height: 52
        anchors.left: parent.left
        anchors.leftMargin: 52
        anchors.verticalCenter: parent.verticalCenter
        radius: 4
        color: Qt.rgba(151 / 255, 151 / 255, 151 / 255, 0.15)
        border.color: "transparent"
        z: 10
        visible: appCore.taxiMeterStatus.toUpperCase() === "FOR HIRE"

        Text {
            id: statusText
            text: appCore.taxiMeterStatus
            anchors.centerIn: parent
            color: "white"
            font.family: "Encode Sans"
            font.bold: true
            font.pixelSize: 28
        }
    }

    // === RIGHT INFO SECTION ===
    Row {
        id: rightInfo
        spacing: 52
        anchors.right: parent.right
        anchors.rightMargin: 52
        anchors.verticalCenter: parent.verticalCenter
        z: 1

        // --- K Constant ---
        Item {
            width: 221
            height: 62
            Image {
                id: speedIcon
                source: "../images/speed_icon.png"
                width: 36
                height: 36
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                id: kConstantText
                text: appCore.kConstant
                anchors.left: speedIcon.right
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                color: "white"
                font.family: "Encode Sans"
                font.weight: Font.DemiBold
                font.pixelSize: 28
            }
        }

        // --- Date ---
        Item {
            width: 271
            height: 62
            Image {
                id: dateIcon
                source: "../images/date_icon.png"
                width: 32
                height: 32
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                id: dateText
                text: appCore.rtcDate
                anchors.left: dateIcon.right
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                color: "white"
                font.family: "Encode Sans"
                font.weight: Font.DemiBold
                font.pixelSize: 28
            }
        }

        // --- Time ---
        Item {
            width: 140
            height: 62
            Text {
                id: timeText
                text: appCore.rtcTime
                anchors.centerIn: parent
                color: "white"
                font.family: "Encode Sans"
                font.weight: Font.DemiBold
                font.pixelSize: 28
            }
        }
    }
}
