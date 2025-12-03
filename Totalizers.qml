import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

Item {
    id: totalizer
    width: parent ? parent.width : 2560
    height: parent ? parent.height : 720
    visible: false
    opacity: 0

    // Fallback variables for appCore values
    property string fallbackNumberOfJourneys: "0"
    property string fallbackMoneyChargedSupplements: "0.00"
    property string fallbackHiredDistance: "0"
    property string fallbackMoneyChargedFare: "0"
    property string fallbackTaxiDistance: "0"

    // === AUTOCLOSE LOGIC ===
    property real progressValue: 0 // 0 → 1 in 10 seconds
    property bool progressActive: false
    property bool progressFinished: false
    property real speedValue: 0

    onVisibleChanged: {
        if (visible) {
            progressValue = 0
            progressActive = true
            progressFinished = false
            autoCloseTimer.start()

            speedValue = Number(appCore.speed) // read initial speed
        } else {
            progressActive = false
            autoCloseTimer.stop()
        }
    }

    Timer {
        id: autoCloseTimer
        interval: 100 // update every 100 ms
        repeat: true

        onTriggered: {
            if (!totalizer.progressActive)
                return

            totalizer.progressValue += 0.01 // 0.01 × 100ms × 100 = 10s

            if (totalizer.progressValue > 1.0)
                totalizer.progressValue = 1.0

            // When finished
            if (totalizer.progressValue >= 1.0) {
                totalizer.progressActive = false
                totalizer.progressFinished = true
                autoCloseTimer.stop()

                totalizer.speedValue = Number(appCore.speed)
                if (totalizer.speedValue > 0) {
                    console.log("Totalizer auto-hide (progress 100% and speed > 0)")
                    totalizer.hide()
                }
            }
        }
    }

    Connections {
        target: appCore

        function onSpeedChanged() {
            if (!totalizer.visible)
                return

            if (!totalizer.progressFinished)
                return

            // only check AFTER countdown
            var v = Number(appCore.speed)
            totalizer.speedValue = v

            if (v > 0) {
                console.log("Totalizer auto-hide (speed became > 0 after progress finished)")
                totalizer.hide()
            }
        }
    }

    Timer {
        id: hideTimer
        interval: 400 // Matches info.qml
        repeat: false
        running: false
        onTriggered: totalizer.visible = false
    }

    MouseArea {
        anchors.fill: parent
        onClicked: totalizer.hide()
        propagateComposedEvents: false
        hoverEnabled: true
    }

    Rectangle {
        id: popupRect
        width: 1859
        height: 454
        anchors.centerIn: parent
        y: height
        radius: 40
        color: Qt.rgba(0 / 255, 125 / 255, 153 / 255, 0.8)
        border.color: "#FFFFFF"
        border.width: 1

        layer.enabled: true
        layer.effect: DropShadow {
            color: "#40000000"
            horizontalOffset: 0
            verticalOffset: 4
            radius: 14
            samples: 29
            spread: 0
        }

        // Backdrop filter effect (approximation since Qt doesn't have direct backdrop-filter)
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            opacity: 0.3
            layer.enabled: true
            layer.effect: FastBlur {
                radius: 2
            }
        }

        Rectangle {
            id: sideBar
            width: 16
            height: 412
            radius: 90
            color: "white"
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 20
            anchors.rightMargin: 20
        }

        ScrollView {
            id: scrollArea
            anchors.fill: parent
            anchors.margins: 20
            clip: true

            // Keep the scrollbar always off or change policy if needed
            ScrollBar.vertical.policy: ScrollBar.AlwaysOff

            Column {
                id: contentArea
                width: scrollArea.width
                spacing: 19

                // Row 1 - Header
                Row {
                    width: parent.width
                    height: 74
                    spacing: 28

                    Rectangle {
                        width: 1731
                        height: 74
                        radius: 12
                        color: "transparent"

                        Row {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 28
                            Image {
                                width: 50
                                height: 50
                                source: "qrc:/images/totalizer(light).png"
                            }
                            Text {
                                text: "TOTALIZERS"
                                font.family: "Roboto"
                                font.pixelSize: 40
                                color: "white"
                                font.weight: Font.Medium
                            }
                        }
                    }
                }

                // Row 2
                Row {
                    width: parent.width
                    height: 124
                    spacing: 56

                    Rectangle {
                        width: 837.5
                        height: 124
                        radius: 2
                        border.width: 2
                        border.color: "white"
                        color: "transparent"

                        Rectangle {
                            id: numberOfJourneys_box
                            width: 777.14
                            height: 63.3
                            anchors.centerIn: parent
                            color: "transparent"

                            Row {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 28

                                Image {
                                    anchors.verticalCenter: parent.verticalCenter
                                    source: "qrc:/images/numberOfJourneys(light).png"
                                    width: 52.536
                                    height: 46.744
                                }

                                Text {
                                    text: "Number of Journeys"
                                    font.family: "Roboto"
                                    font.pixelSize: 40
                                    color: "white"
                                    font.weight: Font.Medium
                                }
                            }

                            Item {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right
                                anchors.rightMargin: 20
                                height: 60
                                width: numberOfJourneys_value.width + 16

                                Text {
                                    id: numberOfJourneys_value
                                    text: appCore.totalizerNumberOfJourneys
                                          || fallbackNumberOfJourneys
                                    font.family: "Roboto Condensed"
                                    font.pixelSize: 62
                                    color: "white"
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.right: parent.right
                                    font.weight: Font.Bold
                                }
                            }
                        }
                    }

                    // Right Rectangle stays the same
                    Rectangle {
                        width: 837.5
                        height: 124
                        radius: 2
                        border.width: 2
                        border.color: "white"
                        color: "transparent"

                        Rectangle {
                            id: moneyChargedSupplements_box
                            width: 777.14
                            height: 63.3
                            anchors.centerIn: parent
                            color: "transparent"

                            Row {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 28

                                Image {
                                    anchors.verticalCenter: parent.verticalCenter
                                    source: "qrc:/images/totalExtras(light).png"
                                    width: 52.536
                                    height: 46.744
                                }

                                Text {
                                    text: "Extras"
                                    font.family: "Roboto"
                                    font.pixelSize: 40
                                    color: "white"
                                    font.weight: Font.Medium
                                }
                            }

                            Item {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right
                                anchors.rightMargin: 20
                                height: 60
                                width: moneyChargedSupplements_value.width
                                       + moneyChargedSupplements_unit.width + 16

                                Text {
                                    id: moneyChargedSupplements_unit
                                    text: "AED"
                                    font.family: "Roboto Condensed"
                                    font.pixelSize: 52
                                    color: "white"
                                    anchors.right: parent.right
                                    anchors.baseline: moneyChargedSupplements_value.baseline
                                    font.weight: Font.Bold
                                }

                                Text {
                                    id: moneyChargedSupplements_value
                                    text: typeof appCore !== 'undefined'
                                          && appCore.moneyChargedSupplements ? appCore.moneyChargedSupplements : fallbackMoneyChargedSupplements
                                    font.family: "Roboto Condensed"
                                    font.pixelSize: 62
                                    color: "white"
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.right: moneyChargedSupplements_unit.left
                                    anchors.rightMargin: 8
                                    font.weight: Font.Bold
                                }
                            }
                        }
                    }
                }

                // Row 3
                Row {
                    width: parent.width
                    height: 124
                    spacing: 56

                    // Left Rectangle
                    Rectangle {
                        width: 837.5
                        height: 124
                        radius: 2
                        border.width: 2
                        border.color: "white"
                        color: "transparent"

                        Rectangle {
                            id: hiredDistance_box
                            width: 777.14
                            height: 63.3
                            anchors.centerIn: parent
                            color: "transparent"

                            Row {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 28

                                Image {
                                    anchors.verticalCenter: parent.verticalCenter
                                    source: "qrc:/images/distance(light).png"
                                    width: 52.536
                                    height: 46.744
                                }

                                Text {
                                    text: "Hired Distance"
                                    font.family: "Roboto"
                                    font.pixelSize: 40
                                    color: "white"
                                    font.weight: Font.Medium
                                }
                            }

                            Item {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right
                                anchors.rightMargin: 20
                                height: 60
                                width: hiredDistance_value.width + hiredDistance_unit.width + 16

                                Text {
                                    id: hiredDistance_unit
                                    text: "km"
                                    font.family: "Roboto Condensed"
                                    font.pixelSize: 52
                                    color: "white"
                                    anchors.right: parent.right
                                    anchors.baseline: hiredDistance_value.baseline
                                    font.weight: Font.Bold
                                }

                                Text {
                                    id: hiredDistance_value
                                    text: typeof appCore !== 'undefined'
                                          && appCore.totalizerDistanceHired ? appCore.totalizerDistanceHired : fallbackHiredDistance
                                    font.family: "Roboto Condensed"
                                    font.pixelSize: 62
                                    color: "white"
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.right: hiredDistance_unit.left
                                    anchors.rightMargin: 8
                                    font.weight: Font.Bold
                                }
                            }
                        }
                    }

                    // Right Rectangle
                    Rectangle {
                        width: 837.5
                        height: 124
                        radius: 2
                        border.width: 2
                        border.color: "white"
                        color: "transparent"

                        Rectangle {
                            id: moneyChargedFare_box
                            width: 777.14
                            height: 63.3
                            anchors.centerIn: parent
                            color: "transparent"

                            Row {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 28

                                Image {
                                    anchors.verticalCenter: parent.verticalCenter
                                    source: "qrc:/images/money(light).png"
                                    width: 51.8
                                    height: 28.76
                                }

                                Text {
                                    text: "Fare"
                                    font.family: "Roboto"
                                    font.pixelSize: 40
                                    color: "white"
                                    font.weight: Font.Medium
                                }
                            }

                            Item {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right
                                anchors.rightMargin: 20
                                height: 60
                                width: moneyChargedFare_value.width
                                       + moneyChargedFare_unit.width + 16

                                Text {
                                    id: moneyChargedFare_unit
                                    text: "AED"
                                    font.family: "Roboto Condensed"
                                    font.pixelSize: 52
                                    color: "white"
                                    anchors.right: parent.right
                                    anchors.baseline: moneyChargedFare_value.baseline
                                    font.weight: Font.Bold
                                }

                                Text {
                                    id: moneyChargedFare_value
                                    text: typeof appCore !== 'undefined'
                                          && appCore.totalizerFare ? appCore.totalizerFare : fallbackMoneyChargedFare
                                    font.family: "Roboto Condensed"
                                    font.pixelSize: 62
                                    color: "white"
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.right: moneyChargedFare_unit.left
                                    anchors.rightMargin: 8
                                    font.weight: Font.Bold
                                }
                            }
                        }
                    }
                }

                // Row 4
                Row {
                    width: parent.width
                    height: 124
                    spacing: 56

                    // Left Rectangle
                    Rectangle {
                        width: 837.5
                        height: 124
                        radius: 2
                        border.width: 2
                        border.color: "white"
                        color: "transparent"

                        Rectangle {
                            id: taxiDistance_box
                            width: 777.14
                            height: 63.3
                            anchors.centerIn: parent
                            color: "transparent"

                            Row {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 28

                                Image {
                                    anchors.verticalCenter: parent.verticalCenter
                                    source: "qrc:/images/distancebytaxi(light).png"
                                    width: 57.5
                                    height: 43.7
                                }

                                Text {
                                    text: "Total Distance"
                                    font.family: "Roboto"
                                    font.pixelSize: 40
                                    color: "white"
                                    font.weight: Font.Medium
                                }
                            }

                            Item {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right
                                anchors.rightMargin: 20
                                height: 60
                                width: taxiDistance_value.width + taxiDistance_unit.width + 16

                                Text {
                                    id: taxiDistance_unit
                                    text: "km"
                                    font.family: "Roboto Condensed"
                                    font.pixelSize: 52
                                    color: "white"
                                    anchors.right: parent.right
                                    anchors.baseline: taxiDistance_value.baseline
                                    font.weight: Font.Bold
                                }

                                Text {
                                    id: taxiDistance_value
                                    text: typeof appCore !== 'undefined'
                                          && appCore.totalizerDistance ? appCore.totalizerDistance : fallbackTaxiDistance
                                    font.family: "Roboto Condensed"
                                    font.pixelSize: 62
                                    color: "white"
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.right: taxiDistance_unit.left
                                    anchors.rightMargin: 8
                                    font.weight: Font.Bold
                                }
                            }
                        }
                    }
                }
            }
        }

        // **MODIFIED BEHAVIORS TO MATCH info.qml**
        Behavior on y {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutCubic
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 400
            }
        }
    }

    Behavior on y {
        NumberAnimation {
            duration: 400
            easing.type: Easing.OutCubic
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 400
        }
    }

    function show() {
        visible = true
        opacity = 1
        popupRect.y = (totalizer.height - popupRect.height) / 2
    }

    function hide() {
        popupRect.y = totalizer.height
        opacity = 0
        scrollArea.contentItem.contentY = 0

        hideTimer.start()
    }
}
