import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

Item {
    id: info
    width: parent ? parent.width : 2520
    height: parent ? parent.height : 720
    visible: false
    opacity: 0

    // Fallback variables for appCore values
    property string fallbackSerialNumber: "123452789"
    property string fallbackK_ConstantRange: "1-6000"
    property string fallbackSoftwareVersion: "V0.0"
    property string fallbackReleaseDate: "3/12/2025"
    property string fallbackMd5_Hash: "2f:e8:d7:cf:83:98"

    Timer {
        id: hideTimer
        interval: 400
        repeat: false
        running: false
        onTriggered: info.visible = false
    }

    MouseArea {
        anchors.fill: parent
        onClicked: info.hide()
        propagateComposedEvents: false
        hoverEnabled: true
    }

    Rectangle {
        id: popupRect
        width: 1859
        height: 454
        anchors.centerIn: parent
        y: height // Initial position for the slide-in animation
        radius: 40
        color: Qt.rgba(0 / 255, 125 / 255, 153 / 262, 0.8)
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
                width: scrollArea.width // Takes up the width of the ScrollView's content area
                spacing: 19

                // Row 1 - Header
                Row {
                    width: parent.width
                    height: 74
                    spacing: 28

                    Rectangle {
                        width: 1731
                        height: parent.height
                        radius: 12
                        color: "transparent"

                        Row {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 28
                            Image {
                                width: 50
                                height: 50
                                source: "qrc:/images/info.png"
                            }
                            Text {
                                text: "Device Info"
                                font.family: "Roboto"
                                font.pixelSize: 40
                                color: "white"
                                font.bold: true
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
                            id: manufacturername
                            width: 777.14
                            height: parent.height
                            anchors.centerIn: parent
                            color: "transparent"

                            Row {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 56

                                Text {
                                    text: "Manufacturer Name"
                                    font.family: "Roboto"
                                    font.pixelSize: 40
                                    color: "white"
                                }
                            }

                            Item {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right
                                anchors.rightMargin: 20
                                height: 60

                                width: manufacturer.width + 16

                                Text {
                                    id: manufacturer
                                    text: "IOTISTIC"
                                    font.family: "Roboto Condensed"
                                    font.pixelSize: 55
                                    color: "white"
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.right: parent.right
                                }
                            }
                        }
                    }

                    // Right Rectangle (K Constant Range)
                    Rectangle {
                        width: 837.5
                        height: 124
                        radius: 2
                        border.width: 2
                        border.color: "white"
                        color: "transparent"

                        Rectangle {
                            id: kconstantrange_box
                            width: 777.14
                            height: parent.height
                            anchors.centerIn: parent
                            color: "transparent"

                            Row {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 56

                                Text {
                                    text: "K Constant Range"
                                    font.family: "Roboto"
                                    font.pixelSize: 40
                                    color: "white"
                                }
                            }

                            Item {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right
                                anchors.rightMargin: 20
                                height: 60
                                width: kconstantrange_value.width + 16

                                Text {
                                    id: kconstantrange_value
                                    text: "1-6000 pulse/km"
                                    font.family: "Roboto Condensed"
                                    font.pixelSize: 55
                                    color: "white"
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.right: parent.right
                                }
                            }
                        }
                    }
                }

                // Row 3 (Serial Number and Certificates)
                Row {
                    width: parent.width
                    height: 124
                    spacing: 56

                    // Left Rectangle (Serial Number)
                    Rectangle {
                        width: 837.5
                        height: 124
                        radius: 2
                        border.width: 2
                        border.color: "white"
                        color: "transparent"

                        Rectangle {
                            id: serialnumber
                            width: 777.14
                            height: parent.height
                            anchors.centerIn: parent
                            color: "transparent"

                            Row {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 56

                                Text {
                                    text: "Serial Number"
                                    font.family: "Roboto"
                                    font.pixelSize: 40
                                    color: "white"
                                }
                            }

                            Item {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right
                                anchors.rightMargin: 20
                                height: 60
                                width: serialnumber_value.width + 16

                                Text {
                                    id: serialnumber_value
                                    text: typeof appCore !== 'undefined'
                                          && appCore.SerialNumber ? appCore.SerialNumber : fallbackSerialNumber // Corrected to use appCore if available
                                    font.family: "Roboto Condensed"
                                    font.pixelSize: 55
                                    color: "white"
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.right: parent.right
                                }
                            }
                        }
                    }
                    Rectangle {
                        width: 837.5
                        height: 124
                        radius: 2
                        border.width: 2
                        border.color: "white"
                        color: "transparent"

                        Rectangle {
                            id: softwareversion
                            width: 777.14
                            height: parent.height
                            anchors.centerIn: parent
                            color: "transparent"

                            Row {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 56

                                Text {
                                    text: "Software Version"
                                    font.family: "Roboto"
                                    font.pixelSize: 40
                                    color: "white"
                                }
                            }

                            Item {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right
                                anchors.rightMargin: 20
                                height: 60
                                width: softwareversion_value.width + 16

                                Text {
                                    id: softwareversion_value
                                    text: typeof appCore !== 'undefined'
                                          && appCore.SoftwareVersion ? appCore.SoftwareVersion : fallbackSoftwareVersion // Corrected to use appCore if available
                                    font.family: "Roboto Condensed"
                                    font.pixelSize: 55
                                    color: "white"
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.right: parent.right
                                }
                            }
                        }
                    }
                }
                Row {
                    width: parent.width
                    height: 124
                    spacing: 56

                    // Left Rectangle (Serial Number)
                    Rectangle {
                        width: 837.5
                        height: 124
                        radius: 2
                        border.width: 2
                        border.color: "white"
                        color: "transparent"

                        Rectangle {
                            id: releasedate
                            width: 777.14
                            height: parent.height
                            anchors.centerIn: parent
                            color: "transparent"

                            Row {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 56

                                Text {
                                    text: "Release Date"
                                    font.family: "Roboto"
                                    font.pixelSize: 40
                                    color: "white"
                                }
                            }

                            Item {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right
                                anchors.rightMargin: 20
                                height: 60
                                width: releasedate_value.width + 16

                                Text {
                                    id: releasedate_value
                                    text: typeof appCore !== 'undefined'
                                          && appCore.ReleaseDate ? appCore.ReleaseDate : fallbackReleaseDate // Corrected to use appCore if available
                                    font.family: "Roboto Condensed"
                                    font.pixelSize: 55
                                    color: "white"
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.right: parent.right
                                }
                            }
                        }
                    }
                    Rectangle {
                        width: 837.5
                        height: 124
                        radius: 2
                        border.width: 2
                        border.color: "white"
                        color: "transparent"

                        Rectangle {
                            id: md5_hash
                            width: 777.14
                            height: parent.height
                            anchors.centerIn: parent
                            color: "transparent"

                            Row {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 56

                                Text {
                                    text: "Md5 Hash"
                                    font.family: "Roboto"
                                    font.pixelSize: 40
                                    color: "white"
                                }
                            }

                            Item {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right
                                anchors.rightMargin: 20
                                height: 60
                                width: smd5_hash_value.width + 16

                                Text {
                                    id: md5_hash_value
                                    text: typeof appCore !== 'undefined'
                                          && appCore.Md5_Hash ? appCore.Md5_Hash : fallbackMd5_Hash // Corrected to use appCore if available
                                    font.family: "Roboto Condensed"
                                    font.pixelSize: 55
                                    color: "white"
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.right: parent.right
                                }
                            }
                        }
                    }
                }
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
        popupRect.y = (info.height - popupRect.height) / 2
    }

    function hide() {
        popupRect.y = info.height
        opacity = 0
        scrollArea.contentItem.contentY = 0

        hideTimer.start()
    }
}
