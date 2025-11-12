import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

Item {
    id: totalizer
    width: parent ? parent.width : 2560
    height: parent ? parent.height : 720
    visible: false
    opacity: 0
    property string fontTotalizer: "Roboto"

    Timer {
        id: hideTimer
        interval: 400
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
        anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
        y: height
        radius: 40
        color: Qt.rgba(1 / 255, 2 / 255, 25 / 255, 0.6)
        border.color: "#FFFFFF"

        layer.enabled: true
        layer.effect: DropShadow {
            color: "#00000040"
            x: 0
            y: 4
        }

        Rectangle {
            id: sideBar
            width: 16
            height: 412
            radius: 90
            color: "#082F43"
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 20
            anchors.rightMargin: 20
        }

        ScrollView {
            id: scrollArea
            anchors.fill: parent
            anchors.leftMargin: 32
            anchors.rightMargin: 32
            anchors.topMargin: 20
            anchors.bottomMargin: 20
            clip: true
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
                                source: "qrc:/images/totalizer.png"
                            }
                            Text {
                                text: "TOTALIZERS"
                                font.family: fontTotalizer
                                font.pixelSize: 40
                                color: "white"
                            }
                        }
                    }
                }

                // Rows 2, 3, 4 fully populated with content in all rectangles

                // Row 2
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
                        border.color: "#117BB1"
                        color: "transparent"

                        Rectangle {
                            id: frame1568_row2_left
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
                                    source: "qrc:/images/sliders 1.png"
                                    width: 52.536
                                    height: 46.744
                                }

                                Text {
                                    text: "Number of Journeys"
                                    font.family: fontTotalizer
                                    font.pixelSize: 40
                                    color: "#0FE6EF"
                                }
                            }

                            Item {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right
                                anchors.rightMargin: 20
                                height: 60
                                width: numText_row2_left.width + unitText_row2_left.width + 16

                                Text {
                                    id: numText_row2_left
                                    text: "250"
                                    font.family: fontBoldCondensed
                                    font.pixelSize: 62
                                    color: "white"
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.right: parent.left
                                    anchors.rightMargin: 8
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
                        border.color: "#117BB1"
                        color: "transparent"

                        Rectangle {
                            id: frame1568_row2_right
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
                                    source: "qrc:/images/add-text-line 1.png"
                                    width: 52.536
                                    height: 46.744
                                }

                                Text {
                                    text: "Money Charged\n[Supplements]"
                                    font.family: fontTotalizer
                                    font.pixelSize: 40
                                    color: "#0FE6EF"
                                }
                            }

                            Item {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right
                                anchors.rightMargin: 20
                                height: 60
                                width: numText_row2_right.width + unitText_row2_right.width + 16

                                Text {
                                    id: unitText_row2_right
                                    text: "AED"
                                    font.family: fontBoldCondensed
                                    font.pixelSize: 52
                                    color: "white"
                                    anchors.right: parent.right
                                    anchors.baseline: numText_row2_right.baseline
                                }

                                Text {
                                    id: numText_row2_right
                                    text: "25.000"
                                    font.family: fontBoldCondensed
                                    font.pixelSize: 62
                                    color: "white"
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.right: unitText_row2_right.left
                                    anchors.rightMargin: 8
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
                        border.color: "#117BB1"
                        color: "transparent"

                        // Copy content from original
                        Rectangle {
                            id: frame1568_row3_left
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
                                    source: "qrc:/images/Group 118 1.png"
                                    width: 52.536
                                    height: 46.744
                                }

                                Text {
                                    text: "Distance Traveled\nWhen Hired"
                                    font.family: fontTotalizer
                                    font.pixelSize: 40
                                    color: "#0FE6EF"
                                }
                            }

                            Item {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right
                                anchors.rightMargin: 20
                                height: 60
                                width: numText_row3_left.width + unitText_row3_left.width + 16

                                Text {
                                    id: unitText_row3_left
                                    text: "KM"
                                    font.family: fontBoldCondensed
                                    font.pixelSize: 52
                                    color: "white"
                                    anchors.right: parent.right
                                    anchors.baseline: numText_row3_left.baseline
                                }

                                Text {
                                    id: numText_row3_left
                                    text: "500"
                                    font.family: fontBoldCondensed
                                    font.pixelSize: 62
                                    color: "white"
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.right: unitText_row3_left.left
                                    anchors.rightMargin: 8
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
                        border.color: "#117BB1"
                        color: "transparent"

                        Rectangle {
                            id: frame1568_row3_right
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
                                    source: "qrc:/images/Group 115 1.png"
                                    width: 51.8
                                    height: 28.76
                                }

                                Text {
                                    text: "Money Charged\n[Fare]"
                                    font.family: fontTotalizer
                                    font.pixelSize: 40
                                    color: "#0FE6EF"
                                }
                            }

                            Item {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right
                                anchors.rightMargin: 20
                                height: 60
                                width: numText_row3_right.width + unitText_row3_right.width + 16

                                Text {
                                    id: unitText_row3_right
                                    text: "AED"
                                    font.family: fontBoldCondensed
                                    font.pixelSize: 52
                                    color: "white"
                                    anchors.right: parent.right
                                    anchors.baseline: numText_row3_right.baseline
                                }

                                Text {
                                    id: numText_row3_right
                                    text: "55.000"
                                    font.family: fontBoldCondensed
                                    font.pixelSize: 62
                                    color: "white"
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.right: unitText_row3_right.left
                                    anchors.rightMargin: 8
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
                        border.color: "#117BB1"
                        color: "transparent"

                        Rectangle {
                            id: frame1568_row4_left
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
                                    source: "qrc:/images/Group 178 1.png"
                                    width: 57.5
                                    height: 43.7
                                }

                                Text {
                                    text: "Distance Traveled By\nThe Taxi"
                                    font.family: fontTotalizer
                                    font.pixelSize: 40
                                    color: "#0FE6EF"
                                }
                            }

                            Item {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right
                                anchors.rightMargin: 20
                                height: 60
                                width: numText_row4_left.width + unitText_row4_left.width + 16

                                Text {
                                    id: unitText_row4_left
                                    text: "KM"
                                    font.family: fontBoldCondensed
                                    font.pixelSize: 52
                                    color: "white"
                                    anchors.right: parent.right
                                    anchors.baseline: numText_row4_left.baseline
                                }

                                Text {
                                    id: numText_row4_left
                                    text: "700"
                                    font.family: fontBoldCondensed
                                    font.pixelSize: 62
                                    color: "white"
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.right: unitText_row4_left.left
                                    anchors.rightMargin: 8
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
                        border.color: "#117BB1"
                        color: "transparent"

                        Rectangle {
                            id: frame1568_row4_right
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
                                    source: "qrc:/images/Group 115 1.png"
                                    width: 51.8
                                    height: 28.76
                                }

                                Text {
                                    text: "Total Idle Distance"
                                    font.family: fontTotalizer
                                    font.pixelSize: 40
                                    color: "#0FE6EF"
                                }
                            }

                            Item {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right
                                anchors.rightMargin: 20
                                height: 60
                                width: numText_row4_right.width + unitText_row4_right.width + 16

                                Text {
                                    id: unitText_row4_right
                                    text: "KM"
                                    font.family: fontBoldCondensed
                                    font.pixelSize: 52
                                    color: "white"
                                    anchors.right: parent.right
                                    anchors.baseline: numText_row4_right.baseline
                                }

                                Text {
                                    id: numText_row4_right
                                    text: "82"
                                    font.family: fontBoldCondensed
                                    font.pixelSize: 62
                                    color: "white"
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.right: unitText_row4_right.left
                                    anchors.rightMargin: 8
                                }
                            }
                        }
                    }
                }
            }
        }

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AlwaysOn
            width: 32
            contentItem: Rectangle {
                implicitWidth: 32
                radius: 16
                color: "#029BBE"
            }
            background: Rectangle {
                implicitWidth: 32
                color: "#082F43"
                radius: 16
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
                duration: 200
            }
        }
    }

    function show() {
        visible = true
        opacity = 1
        popupRect.y = totalizer.height - popupRect.height - 118
    }

    function hide() {
        popupRect.y = totalizer.height
        opacity = 1
        hideTimer.start()
    }
}
