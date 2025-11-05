import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: hiredPanel
    width: 500
    height: 598

    anchors.left: parent.left
    anchors.leftMargin: 52
    anchors.top: parent.top
    visible: (typeof appCore !== "undefined"
              && appCore.taxiMeterStatus) ? appCore.taxiMeterStatus.toUpperCase(
                                                ) === "HIRED" : true
    z: 20

    // === Background ===
    Rectangle {
        anchors.fill: parent
        anchors.rightMargin: 0
        anchors.bottomMargin: 0
        anchors.leftMargin: 0
        anchors.topMargin: -40
        color: Qt.rgba(1 / 255, 2 / 255, 25 / 255, 0.68)
        radius: 40
    }

    // === HIRED Indicator ===
    Rectangle {
        id: hiredIndicator
        width: 162
        height: 52
        radius: 6
        color: "#07BF00"
        anchors.left: parent.left
        anchors.leftMargin: 25
        anchors.top: parent.top
        anchors.topMargin: 30

        Text {
            anchors.centerIn: parent
            text: "HIRED"
            color: "#FFFFFF"
            font.family: fontMain
            font.pixelSize: 32
            font.weight: Font.Bold
        }
    }

    // === Content ===
    Column {
        anchors.left: parent.left
        anchors.leftMargin: 36
        anchors.top: parent.top
        anchors.topMargin: 110
        spacing: 28

        // === TOTAL FARE ===
        Item {
            width: parent.width
            height: 90

            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Text {
                    id: fareValue
                    text: Number(appCore.fare).toFixed(2)
                    color: "#FFFFFF"
                    font.family: fontMain
                    font.pixelSize: 62
                    font.bold: true
                }

                Text {
                    id: fareUnit
                    text: "AED"
                    color: "#FFFFFF"
                    font.family: fontUnit
                    font.pixelSize: 32
                    font.weight: Font.Medium
                    anchors.baseline: fareValue.baseline
                }
            }
        }

        // === EXTRAS (constant for now) ===
        Row {
            spacing: 18
            Image {
                source: "qrc:/images/extras_icon.png"
                width: 32
                height: 32
            }
            Column {
                Text {
                    text: "EXTRAS"
                    color: "#FFFFFF"
                    font.family: fontUnit
                    font.pixelSize: 28
                    font.weight: Font.DemiBold
                }
                Item {
                    width: parent.width
                    height: 60
                    Text {
                        id: extrasValue
                        text: "2.25"
                        color: "#FFFFFF"
                        font.family: "Ubuntu"
                        font.pixelSize: 48
                        font.bold: true
                    }
                    Text {
                        id: extrasUnit
                        text: "AED"
                        color: "#FFFFFF"
                        font.family: fontUnit
                        font.pixelSize: 28
                        font.weight: Font.Medium
                        property int gap: 12
                        x: Math.round(
                               extrasValue.x + extrasValue.paintedWidth + gap)
                        y: extrasValue.y + extrasValue.baselineOffset
                           - extrasUnit.baselineOffset + 6
                    }
                }
            }
        }

        // === DISTANCE ===
        Row {
            spacing: 12
            Image {
                source: "qrc:/images/street_icon.png"
                width: 32
                height: 18.57
            }
            Column {
                Text {
                    text: "DISTANCE"
                    color: "#FFFFFF"
                    font.family: fontUnit
                    font.pixelSize: 28
                    font.weight: Font.DemiBold
                }
                Item {
                    width: parent.width
                    height: 60
                    Text {
                        id: distanceValue
                        // 🔹 Use tripDistance from AppCore
                        text: Number(appCore.tripDistance).toFixed(3)
                        color: "#FFFFFF"
                        font.family: "Ubuntu"
                        font.pixelSize: 48
                        font.bold: true
                    }
                    Text {
                        id: distanceUnit
                        text: "KM"
                        color: "#FFFFFF"
                        font.family: fontUnit
                        font.pixelSize: 28
                        font.weight: Font.Medium
                        property int gap: 12
                        x: Math.round(
                               distanceValue.x + distanceValue.paintedWidth + gap)
                        y: distanceValue.y + distanceValue.baselineOffset
                           - distanceUnit.baselineOffset + 6
                    }
                }
            }
        }

        // === DURATION ===
        Row {
            spacing: 12
            Image {
                source: "qrc:/images/duration_icon.png"
                width: 29.81
                height: 29.81
            }
            Column {
                Text {
                    text: "DURATION"
                    color: "#FFFFFF"
                    font.family: fontUnit
                    font.pixelSize: 28
                    font.weight: Font.DemiBold
                }
                Item {
                    width: parent.width
                    height: 60
                    Text {
                        id: durationValue
                        // 🔹 Use tripTime (formatted string "HH:MM:SS")
                        text: appCore.tripTime
                        color: "#FFFFFF"
                        font.family: "Ubuntu"
                        font.pixelSize: 48
                        font.bold: true
                    }
                    Text {
                        id: durationUnit
                        text: "Hr"
                        color: "#FFFFFF"
                        font.family: fontUnit
                        font.pixelSize: 28
                        font.weight: Font.Medium
                        property int gap: 10
                        x: Math.round(
                               durationValue.x + durationValue.paintedWidth + gap)
                        y: durationValue.y + durationValue.baselineOffset
                           - durationUnit.baselineOffset + 6
                    }
                }
            }
        }
    }
}
