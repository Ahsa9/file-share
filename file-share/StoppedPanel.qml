import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: stoppedPanel
    width: 1122
    height: 596
    visible: true
    anchors.left: parent ? parent.left : undefined
    anchors.leftMargin: 52
    anchors.top: parent ? parent.top : undefined
    z: 20

    // Context property: appCore (set from C++)
    property string extrasValue: "10.00" // optional static extra value

    Rectangle {
        anchors.fill: parent
        anchors.rightMargin: 0
        anchors.bottomMargin: 0
        anchors.leftMargin: 0
        anchors.topMargin: -40
        radius: 40
        color: Qt.rgba(1 / 255, 2 / 255, 25 / 255, 0.75)
        clip: true

        Rectangle {
            id: stoppedIndicator
            width: 205
            height: 52
            radius: 4
            color: "#CB0615"
            anchors.left: parent.left
            anchors.leftMargin: 25
            anchors.top: parent.top
            anchors.topMargin: 76

            Text {
                anchors.centerIn: parent
                text: "STOPPED"
                color: "white"
                font.family: fontMain
                font.pixelSize: 28
                font.weight: Font.DemiBold
            }
        }

        Rectangle {
            id: totalimage
            radius: 20
            color: Qt.rgba(15 / 255, 230 / 255, 239 / 255, 0.3)
            width: 394
            height: 124
            anchors.left: parent.left
            anchors.leftMargin: -20
            anchors.top: stoppedIndicator.bottom
            anchors.topMargin: 40
        }
        // TOTAL BOX
        Rectangle {
            id: totalBox
            width: 400
            height: 110
            color: "transparent"
            anchors.left: parent.left
            anchors.leftMargin: 36
            anchors.top: stoppedIndicator.bottom
            anchors.topMargin: 32

            // CONTAINER FOR ICON + LABEL + VALUE
            Item {
                id: totalContainer
                anchors.fill: parent // container fills the totalBox

                // HEADER (icon + "Total" label)
                Rectangle {
                    id: totalHeader
                    width: childrenRect.width
                    height: childrenRect.height
                    color: "transparent"
                    anchors.left: parent.left
                    anchors.leftMargin: -10
                    anchors.top: parent.top
                    anchors.topMargin: 10

                    Image {
                        id: totalIcon
                        width: 20
                        height: 28
                        source: "qrc:/images/total_icon.png"
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.topMargin: 8
                    }
                    Text {
                        text: "Total"
                        font.family: fontMain
                        font.pixelSize: 24
                        font.weight: Font.DemiBold
                        color: "white"
                        anchors.left: totalIcon.right
                        anchors.leftMargin: 10
                        anchors.verticalCenter: totalIcon.verticalCenter
                    }
                }

                // TOTAL AMOUNT BOX (invisible)
                Rectangle {
                    id: totalAmountBox
                    width: 238
                    height: 78
                    color: "transparent"
                    anchors.left: parent.left

                    anchors.top: totalHeader.bottom
                    anchors.topMargin: 13
                    Text {
                        id: totalVal
                        text: (appCore
                               && appCore.fare) ? (Number(
                                                       appCore.fare) + Number(
                                                       extrasValue)).toFixed(
                                                      2).padStart(
                                                      7, '0') : "0000.00"
                        font.family: fontMain
                        font.pixelSize: 62
                        anchors.verticalCenterOffset: 0
                        anchors.horizontalCenterOffset: -20
                        font.bold: true
                        color: "white"
                        anchors.centerIn: parent
                    }
                }

                // UNIT outside the box (still part of container)
                Text {
                    id: totalUnit
                    text: "AED"
                    font.family: fontUnit
                    font.pixelSize: 20
                    anchors.verticalCenterOffset: 20
                    color: "white"
                    opacity: .8
                    anchors.verticalCenter: totalAmountBox.verticalCenter
                    anchors.left: totalAmountBox.right
                    anchors.leftMargin: -10
                }
            }
        }

        // FARE BOX
        Rectangle {
            id: fareBox
            width: 374
            height: 93
            color: "transparent"
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: totalBox.bottom
            anchors.topMargin: 25

            // Icon and Label
            Rectangle {
                width: childrenRect.width
                height: childrenRect.height
                color: "transparent"
                anchors.left: parent.left
                anchors.leftMargin: 38
                anchors.top: parent.top
                anchors.topMargin: 25

                Image {
                    id: fareIcon
                    width: 26
                    height: 14
                    source: "qrc:/images/fare_icon.png"
                    anchors.left: parent.left
                }
                Text {
                    text: "FARE"
                    font.family: fontMain
                    font.pixelSize: 20
                    font.weight: Font.DemiBold
                    color: "white"
                    anchors.left: fareIcon.right
                    anchors.leftMargin: 12
                    anchors.verticalCenter: fareIcon.verticalCenter
                }
            }

            // Value and Unit
            Rectangle {
                width: childrenRect.width
                height: childrenRect.height
                color: "transparent"
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.top: parent.top
                anchors.topMargin: 45

                Text {
                    id: fareVal
                    text: appCore ? appCore.fare : "0.000"
                    font.family: fontMain
                    font.pixelSize: 32
                    font.bold: true
                    color: "white"
                    anchors.left: parent.left
                    anchors.leftMargin: 63
                }

                Text {
                    id: fareUnit
                    text: "AED"
                    font.family: fontUnit
                    font.pixelSize: 16
                    color: "white"
                    opacity: .8
                    anchors.left: fareVal.right
                    anchors.leftMargin: 5
                    anchors.baseline: fareVal.baseline
                    anchors.baselineOffset: 5
                }
            }
        }

        // EXTRAS BOX
        Rectangle {
            id: extrasBox
            width: 374
            height: 93
            color: "transparent"
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: fareBox.bottom

            // Icon and Label
            Rectangle {
                width: childrenRect.width
                height: childrenRect.height
                color: "transparent"
                anchors.left: parent.left
                anchors.leftMargin: 38
                anchors.top: parent.top
                anchors.topMargin: 25

                Image {
                    id: extrasIcon
                    width: 26
                    height: 26
                    source: "qrc:/images/extras_icon.png"
                    anchors.left: parent.left
                }
                Text {
                    text: "EXTRAS"
                    font.family: fontMain
                    font.pixelSize: 22
                    font.weight: Font.DemiBold
                    color: "white"
                    anchors.left: extrasIcon.right
                    anchors.leftMargin: 10
                    anchors.verticalCenter: extrasIcon.verticalCenter
                }
            }

            // Value and Unit
            Rectangle {
                width: childrenRect.width
                height: childrenRect.height
                color: "transparent"
                anchors.left: parent.left
                anchors.leftMargin: 74
                anchors.top: parent.top
                anchors.topMargin: 45

                Text {
                    id: extraVal
                    text: extrasValue
                    font.family: fontMain
                    font.pixelSize: 32
                    anchors.leftMargin: 10

                    font.bold: true
                    color: "white"
                }

                Text {
                    id: extrasUnit
                    text: "AED"
                    font.family: fontUnit
                    font.pixelSize: 16
                    color: "white"
                    opacity: .8
                    anchors.left: extraVal.right
                    anchors.leftMargin: 6
                    anchors.baseline: extraVal.baseline
                    anchors.baselineOffset: 5
                }
            }
        }

        // DISTANCE BOX
        Rectangle {
            id: distBox
            width: 374
            height: 93
            color: "transparent"
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: extrasBox.bottom

            // Icon and Label
            Rectangle {
                width: childrenRect.width
                height: childrenRect.height
                color: "transparent"
                anchors.left: parent.left
                anchors.leftMargin: 38
                anchors.top: parent.top
                anchors.topMargin: 25

                Image {
                    id: distIcon
                    width: 24
                    height: 14
                    source: "qrc:/images/street_icon.png"
                    anchors.left: parent.left
                }
                Text {
                    text: "DISTANCE"
                    font.family: fontMain
                    font.pixelSize: 22
                    font.weight: Font.DemiBold
                    color: "white"
                    anchors.left: distIcon.right
                    anchors.leftMargin: 10
                    anchors.verticalCenter: distIcon.verticalCenter
                }
            }

            // Value and Unit
            Rectangle {
                width: childrenRect.width
                height: childrenRect.height
                color: "transparent"
                anchors.left: parent.left
                anchors.leftMargin: 74
                anchors.top: parent.top
                anchors.topMargin: 45

                Text {
                    id: distVal
                    text: appCore ? appCore.tripDistance : "0.000"
                    font.family: fontMain
                    font.pixelSize: 32
                    anchors.leftMargin: 10
                    font.bold: true
                    color: "white"
                }

                Text {
                    id: distUnit
                    text: "KM"
                    font.family: fontUnit
                    font.pixelSize: 16
                    color: "white"
                    opacity: .8

                    anchors.left: distVal.right
                    anchors.leftMargin: 6
                    anchors.baseline: distVal.baseline
                    anchors.baselineOffset: 5
                }
            }
        }

        // RIGHT SIDE CONTAINER FOR DURATION, START TIME, END TIME
        Rectangle {
            id: timeInfoBox
            width: 374
            height: 372
            color: "transparent"
            anchors.left: totalimage.right
            anchors.top: totalimage.bottom
            anchors.leftMargin: 0
            anchors.topMargin: -93
            // === DURATION BOX ===
            Rectangle {
                id: durBox
                width: 374
                height: 93
                color: "transparent"
                anchors.top: parent.top

                // Icon + Label
                Rectangle {
                    width: childrenRect.width
                    height: childrenRect.height
                    color: "transparent"
                    anchors.left: parent.left
                    anchors.leftMargin: 38
                    anchors.top: parent.top
                    anchors.topMargin: 25

                    Image {
                        id: durationIcon
                        width: 28
                        height: 28
                        source: "qrc:/images/duration_icon.png"
                        anchors.left: parent.left
                    }
                    Text {
                        text: "DURATION"
                        font.family: fontMain
                        font.pixelSize: 20
                        font.weight: Font.DemiBold
                        color: "white"
                        anchors.left: durationIcon.right
                        anchors.leftMargin: 10
                        anchors.verticalCenter: durationIcon.verticalCenter
                    }
                }

                // Value + Unit
                Rectangle {
                    width: childrenRect.width
                    height: childrenRect.height
                    color: "transparent"
                    anchors.left: parent.left
                    anchors.leftMargin: 74
                    anchors.top: parent.top
                    anchors.topMargin: 47

                    Text {
                        id: durationVal
                        text: appCore ? appCore.tripTime : "00:00:00"
                        font.family: fontMain
                        font.pixelSize: 32
                        font.bold: true
                        color: "white"
                    }

                    Text {
                        id: durationUnit
                        text: "Hr"
                        font.family: fontUnit
                        font.pixelSize: 16
                        color: "white"
                        opacity: .8
                        anchors.left: durationVal.right
                        anchors.leftMargin: 6
                        anchors.baseline: durationVal.baseline
                        anchors.baselineOffset: 5
                    }
                }
            }

            // === START TIME BOX ===
            Rectangle {
                id: startBox
                width: 374
                height: 93
                color: "transparent"
                anchors.top: durBox.bottom

                // Icon + Label
                Rectangle {
                    width: childrenRect.width
                    height: childrenRect.height
                    color: "transparent"
                    anchors.left: parent.left
                    anchors.leftMargin: 38
                    anchors.top: parent.top
                    anchors.topMargin: 25

                    Image {
                        id: startTimeIcon
                        width: 28
                        height: 28
                        source: "qrc:/images/start_time_icon.png"
                        anchors.left: parent.left
                    }
                    Text {
                        text: "START TIME"
                        font.family: fontMain
                        font.pixelSize: 20
                        font.weight: Font.DemiBold
                        color: "white"
                        anchors.left: startTimeIcon.right
                        anchors.leftMargin: 10
                        anchors.verticalCenter: startTimeIcon.verticalCenter
                    }
                }

                // Value + Unit
                Rectangle {
                    width: childrenRect.width
                    height: childrenRect.height
                    color: "transparent"
                    anchors.left: parent.left
                    anchors.leftMargin: 74
                    anchors.top: parent.top
                    anchors.topMargin: 47

                    Text {
                        id: startVal
                        text: appCore ? appCore.tripStartTime : "--:--:--"
                        font.family: fontMain
                        font.pixelSize: 32
                        font.bold: true
                        color: "white"
                    }

                    Text {
                        id: startUnit
                        text: appCore ? appCore.tripStopMeridiem : ""
                        font.family: fontUnit
                        font.pixelSize: 16
                        color: "white"
                        opacity: .8
                        anchors.left: startVal.right
                        anchors.leftMargin: 6
                        anchors.baseline: startVal.baseline
                        anchors.baselineOffset: 5
                    }
                }
            }

            // === END TIME BOX ===
            Rectangle {

                id: endBox
                width: 374
                height: 93
                color: "transparent"
                anchors.top: startBox.bottom

                // Icon + Label
                Rectangle {
                    width: childrenRect.width
                    height: childrenRect.height
                    color: "transparent"
                    anchors.left: parent.left
                    anchors.leftMargin: 38
                    anchors.top: parent.top
                    anchors.topMargin: 25

                    Image {
                        id: endTimeIcon
                        width: 28
                        height: 28
                        source: "qrc:/images/end_time_icon.png"
                        anchors.left: parent.left
                    }
                    Text {
                        text: "END TIME"
                        font.family: fontMain
                        font.pixelSize: 20
                        font.weight: Font.DemiBold
                        color: "white"
                        anchors.left: endTimeIcon.right
                        anchors.leftMargin: 10
                        anchors.verticalCenter: endTimeIcon.verticalCenter
                    }
                }

                // Value + Unit
                Rectangle {
                    width: childrenRect.width
                    height: childrenRect.height
                    color: "transparent"
                    anchors.left: parent.left
                    anchors.leftMargin: 76

                    anchors.top: parent.top
                    anchors.topMargin: 47

                    Text {
                        id: endVal
                        text: appCore ? appCore.tripStopTime : "--:--:--"
                        font.family: fontMain
                        font.pixelSize: 32
                        font.bold: true
                        color: "white"
                    }

                    Text {
                        id: endUnit
                        text: appCore ? appCore.tripStartMeridiem : ""
                        font.family: fontUnit
                        font.pixelSize: 16
                        color: "white"
                        opacity: .8
                        anchors.left: endVal.right
                        anchors.leftMargin: 6
                        anchors.baseline: endVal.baseline
                        anchors.baselineOffset: 5
                    }
                }
            }

            // === VERTICAL LINE SERIES ===
            Column {
                id: verticalLines
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.top: parent.top
                spacing: 20

                // Top short line
                Rectangle {
                    width: 1
                    height: 10.25
                    color: "white"
                    opacity: 0.4
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                // Repeated long lines
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

                // Bottom short line
                Rectangle {
                    width: 1
                    height: 10.25
                    color: "white"
                    opacity: 0.4
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }
}
