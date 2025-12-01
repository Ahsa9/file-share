import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

Item {
    id: stoppedPanel
    width: 785
    height: 569
    visible: true
    anchors.left: parent.left
    anchors.leftMargin: 52
    anchors.top: parent.top

    z: 20

    property string totalValue: "0028.10"
    property string extrasValue: "10.00"
    property string fareValue: (appCore
                                && appCore.fare) ? String(appCore.fare) : "0.00"
    property string distanceValue: (appCore
                                    && appCore.tripDistance) ? String(
                                                                   appCore.tripDistance) : "0.000"
    property string durationValue: (appCore
                                    && appCore.tripTime) ? String(
                                                               appCore.tripTime) : "00:00:00"
    property string startTimeValue: (appCore
                                     && appCore.tripStartTime) ? String(
                                                                     appCore.tripStartTime) : "--:--:--"
    property string startMeridiem: (appCore
                                    && appCore.tripStartMeridiem) ? String(
                                                                        appCore.tripStartMeridiem) : ""
    property string endTimeValue: (appCore
                                   && appCore.tripStopTime) ? String(
                                                                  appCore.tripStopTime) : "--:--:--"
    property string endMeridiem: (appCore
                                  && appCore.tripStopMeridiem) ? String(
                                                                     appCore.tripStopMeridiem) : ""

    Rectangle {
        id: panelBackground
        anchors.fill: parent
        anchors.rightMargin: 0
        anchors.bottomMargin: 0
        anchors.leftMargin: 0
        anchors.topMargin: -40
        radius: 40
        color: Qt.rgba(0, 0.49, 0.60, 0.68)
        clip: true

        // --- Dismiss MouseArea ---
        MouseArea {
            id: dismissArea
            anchors.fill: parent
            visible: paymentBox.dropdownVisible
            onClicked: {
                if (paymentBox.dropdownVisible) {
                    paymentBox.dropdownVisible = false
                }
            }
        }

        Rectangle {
            id: stoppedIndicator
            width: 205
            height: 52
            radius: 6
            color: "#CB0615"
            anchors.left: parent.left
            anchors.leftMargin: 25
            anchors.top: parent.top
            anchors.topMargin: 58 + 20

            Text {
                anchors.centerIn: parent
                text: "STOPPED"
                color: "white"
                font.family: "Encode Sans"
                font.pixelSize: 30
                font.weight: Font.Bold
            }
        }

        Rectangle {
            id: totalimage_bg
            radius: 12
            color: "transparent"
            width: 384
            height: 130
            anchors.left: parent.left
            anchors.leftMargin: -10
            anchors.top: stoppedIndicator.bottom
            anchors.topMargin: 28

            LinearGradient {
                anchors.fill: parent
                anchors.leftMargin: 8
                start: Qt.point(0, parent.height / 2)
                end: Qt.point(parent.width, parent.height / 2)
                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color: "#007D99"
                    }
                    GradientStop {
                        position: 1.0
                        color: "transparent"
                    }
                }
            }
        }

        Rectangle {
            id: leftRect
            width: 400
            anchors.left: parent.left
            anchors.leftMargin: 36
            anchors.top: stoppedIndicator.bottom
            anchors.topMargin: 42
            color: "transparent"

            Rectangle {
                id: totalBox
                width: parent.width
                height: 110
                color: "transparent"

                Row {
                    id: totalHeader
                    spacing: 6
                    anchors.left: parent.left
                    anchors.leftMargin: -10
                    anchors.top: parent.top
                    anchors.topMargin: 10
                    Image {
                        width: 26
                        height: 34
                        source: "qrc:/images/total_icon.png"
                    }
                    Text {
                        text: "Total"
                        font.family: "Montserrat"
                        font.pixelSize: 20
                        font.weight: Font.DemiBold
                        color: "white"
                    }
                }

                Row {
                    spacing: 6
                    anchors.left: parent.left
                    anchors.leftMargin: -10
                    anchors.top: totalHeader.bottom
                    anchors.topMargin: 4
                    Text {
                        id: totalVal
                        text: totalValue
                        font.family: "Ubuntu"
                        font.pixelSize: 62
                        font.bold: true
                        color: "white"
                    }
                    Text {
                        id: totalUnit
                        text: "AED"
                        font.family: "Montserrat"
                        font.pixelSize: 16
                        color: "white"
                        anchors.baseline: totalVal.baseline
                    }
                }
            }

            Rectangle {
                id: fareBox
                width: parent.width
                height: 70
                anchors.top: totalBox.bottom
                anchors.topMargin: 14
                color: "transparent"

                Row {
                    spacing: 10
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.topMargin: 12
                    Image {
                        width: 26
                        height: 14
                        source: "qrc:/images/fare_icon.png"
                    }
                    Text {
                        text: "FARE"
                        font.family: "Montserrat"
                        font.pixelSize: 20
                        font.weight: Font.DemiBold
                        color: "white"
                    }
                }
                Text {
                    id: fareVal
                    x: 36
                    y: 40
                    text: fareValue
                    font.family: "Ubuntu"
                    font.pixelSize: 32
                    font.bold: true
                    color: "white"
                }
                Text {
                    id: fareUnit
                    text: "AED"
                    font.family: "Montserrat"
                    font.pixelSize: 16
                    color: "white"
                    x: fareVal.x + fareVal.paintedWidth + 6
                    y: fareVal.y + fareVal.baselineOffset - fareUnit.baselineOffset + 6
                }
            }

            Rectangle {
                id: extrasBox
                width: parent.width
                height: 70
                anchors.top: fareBox.bottom
                anchors.topMargin: 26
                color: "transparent"

                Row {
                    spacing: 10
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.topMargin: 12
                    Image {
                        width: 26
                        height: 26
                        source: "qrc:/images/extras_icon.png"
                    }
                    Text {
                        text: "EXTRAS"
                        font.family: "Montserrat"
                        font.pixelSize: 20
                        font.weight: Font.DemiBold
                        color: "white"
                    }
                }
                Text {
                    id: extraVal
                    x: 36
                    y: 40
                    text: extrasValue
                    font.family: "Ubuntu"
                    font.pixelSize: 32
                    font.bold: true
                    color: "white"
                }
                Text {
                    id: extrasUnit
                    text: "AED"
                    font.family: "Montserrat"
                    font.pixelSize: 16
                    color: "white"
                    x: extraVal.x + extraVal.paintedWidth + 6
                    y: extraVal.y + extraVal.baselineOffset - extrasUnit.baselineOffset + 6
                }
            }

            Rectangle {
                id: distBox
                width: parent.width
                height: 70
                anchors.top: extrasBox.bottom
                anchors.topMargin: 26
                color: "transparent"

                Row {
                    spacing: 10
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.topMargin: 16
                    Image {
                        width: 26
                        height: 18
                        source: "qrc:/images/street_icon.png"
                    }
                    Text {
                        text: "DISTANCE"
                        font.family: "Montserrat"
                        font.pixelSize: 20
                        font.weight: Font.DemiBold
                        color: "white"
                    }
                }
                Text {
                    id: distVal
                    x: 36
                    y: 40
                    text: distanceValue
                    font.family: "Ubuntu"
                    font.pixelSize: 32
                    font.bold: true
                    color: "white"
                }
                Text {
                    id: distUnit
                    text: "KM"
                    font.family: "Montserrat"
                    font.pixelSize: 16
                    color: "white"
                    x: distVal.x + distVal.paintedWidth + 6
                    y: distVal.y + distVal.baselineOffset - distUnit.baselineOffset + 6
                }
            }
        }

        Column {
            id: verticalLines
            x: 374
            anchors.top: leftRect.top
            spacing: 20
            Rectangle {
                width: 1
                height: 10.25
                color: "white"
                opacity: 0.4
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Repeater {
                model: 8
                Rectangle {
                    width: 1
                    height: 20.25
                    color: "white"
                    opacity: 0.4
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
            Rectangle {
                width: 1
                height: 10.25
                color: "white"
                opacity: 0.4
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        Rectangle {
            id: rightRect
            width: 360
            anchors.left: leftRect.right
            anchors.leftMargin: 2
            anchors.top: stoppedIndicator.bottom
            anchors.topMargin: 42
            color: "transparent"
            y: leftRect.y - stoppedIndicator.bottom
               - stoppedPanel.anchors.topMargin + leftRect.anchors.topMargin

            Rectangle {
                id: durBox
                width: parent.width
                height: 60
                color: "transparent"
                Row {
                    spacing: 10
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.topMargin: 12
                    Image {
                        width: 28
                        height: 28
                        source: "qrc:/images/duration_icon.png"
                    }
                    Text {
                        text: "DURATION"
                        color: "white"
                        font.family: "Montserrat"
                        font.pixelSize: 20
                        font.weight: Font.DemiBold
                    }
                }
                Text {
                    id: durationVal
                    x: 36
                    y: 40
                    text: durationValue
                    font.family: "Ubuntu"
                    font.pixelSize: 32
                    font.bold: true
                    color: "white"
                }
                Text {
                    id: durationUnit
                    text: "Hr"
                    font.family: "Montserrat"
                    font.pixelSize: 16
                    color: "white"
                    x: durationVal.x + durationVal.paintedWidth + 6
                    y: durationVal.y + durationVal.baselineOffset - durationUnit.baselineOffset + 6
                }
            }

            Rectangle {
                id: startBox
                width: parent.width
                height: 60
                anchors.top: durBox.bottom
                anchors.topMargin: 26
                color: "transparent"
                Row {
                    spacing: 10
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.topMargin: 12
                    Image {
                        width: 28
                        height: 28
                        source: "qrc:/images/start_time_icon.png"
                    }
                    Text {
                        text: "START TIME"
                        color: "white"
                        font.family: "Montserrat"
                        font.pixelSize: 20
                        font.weight: Font.DemiBold
                    }
                }
                Text {
                    id: startVal
                    x: 36
                    y: 40
                    text: startTimeValue
                    font.family: "Ubuntu"
                    font.pixelSize: 32
                    font.bold: true
                    color: "white"
                }
                Text {
                    id: startUnit
                    text: startMeridiem
                    font.family: "Montserrat"
                    font.pixelSize: 16
                    color: "white"
                    x: startVal.x + startVal.paintedWidth + 6
                    y: startVal.y + startVal.baselineOffset - startUnit.baselineOffset + 6
                }
            }

            Rectangle {
                id: endBox
                width: parent.width
                height: 60
                anchors.top: startBox.bottom
                anchors.topMargin: 26
                color: "transparent"
                Row {
                    spacing: 10
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.topMargin: 12
                    Image {
                        width: 28
                        height: 28
                        source: "qrc:/images/end_time_icon.png"
                    }
                    Text {
                        text: "END TIME"
                        color: "white"
                        font.family: "Montserrat"
                        font.pixelSize: 20
                        font.weight: Font.DemiBold
                    }
                }
                Text {
                    id: endVal
                    x: 36
                    y: 40
                    text: endTimeValue
                    font.family: "Ubuntu"
                    font.pixelSize: 32
                    font.bold: true
                    color: "white"
                }
                Text {
                    id: endUnit
                    text: endMeridiem
                    font.family: "Montserrat"
                    font.pixelSize: 16
                    color: "white"
                    x: endVal.x + endVal.paintedWidth + 6
                    y: endVal.y + endVal.baselineOffset - endUnit.baselineOffset + 6
                }
            }

            Rectangle {
                id: paymentBox
                width: parent.width
                height: 230
                anchors.top: endBox.bottom
                anchors.topMargin: 26
                color: "transparent"
                z: 10

                property string selectedMethod: "CASH"
                property bool dropdownVisible: false

                Row {
                    spacing: 10
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.topMargin: 12
                    Image {
                        width: 24
                        height: 17.05
                        source: "qrc:/images/credit-card.png"
                    }
                    Text {
                        text: "PAYMENT METHOD"
                        color: "white"
                        font.family: "Montserrat"
                        font.pixelSize: 20
                        font.weight: Font.Bold
                    }
                }

                // **Dropdown Box (methodsBox)**
                Rectangle {
                    id: methodsBox
                    width: 206
                    height: 48
                    anchors.top: parent.top
                    anchors.topMargin: 49
                    anchors.left: parent.left
                    anchors.leftMargin: 38
                    radius: 12
                    border.color: "white"
                    border.width: 1
                    color: Qt.rgba(0, 0.49, 0.60, 0.68)
                    clip: true
                    z: 20

                    Column {
                        id: dropdownContent
                        width: parent.width
                        spacing: 0

                        // Item 1: The Currently Selected Method (Toggle)
                        Rectangle {
                            id: selectedOption
                            width: parent.width
                            height: 48
                            color: "transparent"

                            // --- NEW HOVER OVERLAY FOR SELECTED OPTION ---
                            Rectangle {
                                id: selectedHoverOverlay
                                anchors.fill: parent
                                color: Qt.rgba(1, 1, 1,
                                               0.1) // 10% white overlay
                                // Visible only when expanded AND hovering this item
                                visible: toggleMouseArea.containsMouse
                                         && paymentBox.dropdownVisible
                            }

                            // ---------------------------------------------
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 12
                                text: paymentBox.selectedMethod
                                color: "white"
                                font.family: "Montserrat"
                                font.pixelSize: 24
                                font.weight: Font.DemiBold
                            }

                            Image {
                                source: "qrc:/images/dropdown.png"
                                height: 32
                                width: 32
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right
                                anchors.rightMargin: 12
                                rotation: paymentBox.dropdownVisible ? 180 : 0
                                Behavior on rotation {
                                    RotationAnimation {
                                        duration: 150
                                    }
                                }
                            }

                            MouseArea {
                                id: toggleMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: paymentBox.dropdownVisible = !paymentBox.dropdownVisible
                            }
                        }

                        // Item 2: The Alternative Method (Visible when expanded)
                        Rectangle {
                            id: alternativeOption
                            width: parent.width
                            height: 48
                            color: "transparent"
                            visible: paymentBox.dropdownVisible

                            // --- HOVER OVERLAY FOR ALTERNATIVE OPTION ---
                            Rectangle {
                                id: hoverOverlay
                                anchors.fill: parent
                                color: Qt.rgba(1, 1, 1, 0.1)
                                visible: alternativeMouseArea.containsMouse
                            }

                            // --------------------------------------------
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 12
                                text: (paymentBox.selectedMethod === "CASH") ? "CARD" : "CASH"
                                color: "white"
                                font.family: "Montserrat"
                                font.pixelSize: 24
                                font.weight: Font.DemiBold
                            }

                            MouseArea {
                                id: alternativeMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    paymentBox.selectedMethod = (paymentBox.selectedMethod
                                                                 === "CASH") ? "CARD" : "CASH"
                                    console.log("Payment method selected:",
                                                paymentBox.selectedMethod)
                                    paymentBox.dropdownVisible = false
                                }
                            }
                        }
                    }

                    states: [
                        State {
                            name: "Expanded"
                            when: paymentBox.dropdownVisible
                            PropertyChanges {
                                target: methodsBox
                                height: 96
                            }
                            PropertyChanges {
                                target: methodsBox
                                color: Qt.rgba(0, 0.49, 0.60, 0.9)
                            }
                        },
                        State {
                            name: "CollapsedHovered"
                            when: !paymentBox.dropdownVisible
                                  && (toggleMouseArea.pressed
                                      || toggleMouseArea.containsMouse)
                            PropertyChanges {
                                target: methodsBox
                                color: Qt.rgba(0, 0.49, 0.60, 0.9)
                            }
                        },
                        State {
                            name: "Collapsed"
                            when: !paymentBox.dropdownVisible
                            PropertyChanges {
                                target: methodsBox
                                height: 48
                            }
                            PropertyChanges {
                                target: methodsBox
                                color: Qt.rgba(0, 0.49, 0.60, 0.68)
                            }
                        }
                    ]

                    transitions: Transition {
                        NumberAnimation {
                            properties: "height"
                            duration: 250
                            easing.type: Easing.OutCubic
                        }
                        ColorAnimation {
                            properties: "color"
                            duration: 150
                        }
                    }
                }
            }
        }
    }
}
