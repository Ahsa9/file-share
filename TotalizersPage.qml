import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

Rectangle {
    id: totalizerRoot
    width: 2560
    height: 720
    color: "white" // White Background
    visible: false

    // Signal to notify parent
    signal closePage

    // Helper properties
    property color themeColor: "#007D99" // Teal color for body text/borders

    // Fallback variables for appCore values
    property string fallbackNumberOfJourneys: "0"
    property string fallbackMoneyChargedSupplements: "0.00"
    property string fallbackHiredDistance: "0"
    property string fallbackMoneyChargedFare: "0"
    property string fallbackTaxiDistance: "0"

    function show() {
        totalizerRoot.visible = true
    }

    function hide() {
        totalizerRoot.visible = false
        totalizerRoot.closePage()
    }

    // Prevents clicks from falling through
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        preventStealing: true
    }

    // ==========================================================
    // === 1. TOP BAR ===
    // ==========================================================
    TopBar {
        id: headerBar
        anchors.top: parent.top
        width: parent.width
        z: 4
    }

    // ==========================================================
    // === 2. HEADER ROW (Icon, Title, Back) - OVERLAYING TOP BAR ===
    // ==========================================================
    RowLayout {
        id: headerRow
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 40

        // Ensure this row has height to center items vertically in the TopBar
        height: headerBar.height > 0 ? headerBar.height : 100
        z: 11 // Above TopBar
        spacing: 20

        // --- Back Button ---
        Button {
            Layout.preferredWidth: 140
            Layout.preferredHeight: 60
            Layout.alignment: Qt.AlignVCenter
            background: Rectangle {
                color: parent.down ? "#eee" : "transparent"
                border.color: "white" // White border to match Audit Trail header style
                border.width: 2
                radius: 8
            }
            contentItem: Row {
                spacing: 10
                anchors.centerIn: parent
                Text {
                    text: "◄"
                    color: "white"
                    font.pixelSize: 24
                }
                Text {
                    text: "BACK"
                    color: "white"
                    font.bold: true
                    font.pixelSize: 24
                }
            }
            onClicked: totalizerRoot.hide()
        }

        // --- Title Icon ---
        Item {
            // Fixed: Container size matches the desired icon size for proper centering
            Layout.preferredWidth: 50
            Layout.preferredHeight: 50
            Layout.alignment: Qt.AlignVCenter

            Image {
                id: titleIcon
                anchors.fill: parent
                source: "qrc:/images/totalizer(light).png"
                fillMode: Image.PreserveAspectFit
                smooth: true
                visible: false // Hidden for overlay
            }

            ColorOverlay {
                anchors.fill: titleIcon
                source: titleIcon
                color: "white"
            }
        }

        // --- Title Text ---
        Text {
            text: "TOTALIZERS"
            color: "white"

            // Alignment Logic
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter // Align the item in the layout
            verticalAlignment: Text.AlignVCenter // Align the text inside its bounding box

            // Specs
            font.family: "Encode Sans"
            font.weight: Font.Bold // 700
            font.pixelSize: 28 // 28px
            font.letterSpacing: 0.56 // 2%
            font.capitalization: Font.AllUppercase
            lineHeight: 1.5 // 150%
            lineHeightMode: Text.ProportionalHeight
        }
    }

    // ==========================================================
    // === 3. CONTENT AREA ===
    // ==========================================================
    ScrollView {
        id: scrollArea
        // Anchor to bottom of the TopBar
        anchors.top: headerBar.bottom
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: 1731
        clip: true

        // Add some top margin so content doesn't touch the bar immediately
        topPadding: 30
        bottomPadding: 30

        ScrollBar.vertical.policy: ScrollBar.AlwaysOff

        Column {
            id: contentArea
            width: parent.width
            spacing: 19
            anchors.centerIn: parent

            // --- Row 2: Journeys & Extras ---
            Row {
                width: parent.width
                height: 124
                spacing: 56

                // 2.1 Number of Journeys
                Rectangle {
                    width: 837.5
                    height: 124
                    radius: 12
                    border.width: 2
                    border.color: themeColor
                    color: "transparent"

                    Rectangle {
                        width: 777.14
                        height: 63.3
                        anchors.centerIn: parent
                        color: "transparent"

                        Row {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 28

                            Item {
                                width: 52.536
                                height: 46.744
                                Image {
                                    id: iconJourneys
                                    source: "qrc:/images/numberOfJourneys(light).png"
                                    anchors.fill: parent
                                    visible: false
                                    smooth: true
                                }
                                ColorOverlay {
                                    anchors.fill: iconJourneys
                                    source: iconJourneys
                                    color: themeColor
                                }
                            }

                            Text {
                                text: "Number of Journeys"
                                font.family: "Roboto"
                                font.pixelSize: 40
                                color: themeColor
                                font.weight: Font.Medium
                            }
                        }

                        Text {
                            text: typeof appCore !== 'undefined'
                                  && appCore.totalizerNumberOfJourneys ? appCore.totalizerNumberOfJourneys : fallbackNumberOfJourneys
                            font.family: "Roboto Condensed"
                            font.pixelSize: 62
                            color: "black"
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            font.weight: Font.Bold
                        }
                    }
                }

                // 2.2 Extras (Supplements)
                Rectangle {
                    width: 837.5
                    height: 124
                    radius: 12
                    border.width: 2
                    border.color: themeColor
                    color: "transparent"

                    Rectangle {
                        width: 777.14
                        height: 63.3
                        anchors.centerIn: parent
                        color: "transparent"

                        Row {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 28

                            Item {
                                width: 52.536
                                height: 46.744
                                Image {
                                    id: iconExtras
                                    source: "qrc:/images/totalExtras(light).png"
                                    anchors.fill: parent
                                    visible: false
                                    smooth: true
                                }
                                ColorOverlay {
                                    anchors.fill: iconExtras
                                    source: iconExtras
                                    color: themeColor
                                }
                            }

                            Text {
                                text: "Extras"
                                font.family: "Roboto"
                                font.pixelSize: 40
                                color: themeColor
                                font.weight: Font.Medium
                            }
                        }

                        Text {
                            id: moneyChargedSupplements_unit
                            text: "AED"
                            font.family: "Roboto Condensed"
                            font.pixelSize: 52
                            color: "black"
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
                            color: "black"
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: moneyChargedSupplements_unit.left
                            anchors.rightMargin: 8
                            font.weight: Font.Bold
                        }
                    }
                }
            }

            // --- Row 3: Hired Distance & Fare ---
            Row {
                width: parent.width
                height: 124
                spacing: 56

                // 3.1 Hired Distance
                Rectangle {
                    width: 837.5
                    height: 124
                    radius: 12
                    border.width: 2
                    border.color: themeColor
                    color: "transparent"

                    Rectangle {
                        width: 777.14
                        height: 63.3
                        anchors.centerIn: parent
                        color: "transparent"

                        Row {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 28

                            Item {
                                width: 52.536
                                height: 46.744
                                Image {
                                    id: iconHired
                                    source: "qrc:/images/distance(light).png"
                                    anchors.fill: parent
                                    visible: false
                                    smooth: true
                                }
                                ColorOverlay {
                                    anchors.fill: iconHired
                                    source: iconHired
                                    color: themeColor
                                }
                            }

                            Text {
                                text: "Hired Distance"
                                font.family: "Roboto"
                                font.pixelSize: 40
                                color: themeColor
                                font.weight: Font.Medium
                            }
                        }

                        Text {
                            id: hiredDistance_unit
                            text: "km"
                            font.family: "Roboto Condensed"
                            font.pixelSize: 52
                            color: "black"
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
                            color: "black"
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: hiredDistance_unit.left
                            anchors.rightMargin: 8
                            font.weight: Font.Bold
                        }
                    }
                }

                // 3.2 Fare
                Rectangle {
                    width: 837.5
                    height: 124
                    radius: 12
                    border.width: 2
                    border.color: themeColor
                    color: "transparent"

                    Rectangle {
                        width: 777.14
                        height: 63.3
                        anchors.centerIn: parent
                        color: "transparent"

                        Row {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 28

                            Item {
                                width: 51.8
                                height: 28.76
                                Image {
                                    id: iconFare
                                    source: "qrc:/images/money(light).png"
                                    anchors.fill: parent
                                    visible: false
                                    smooth: true
                                }
                                ColorOverlay {
                                    anchors.fill: iconFare
                                    source: iconFare
                                    color: themeColor
                                }
                            }

                            Text {
                                text: "Fare"
                                font.family: "Roboto"
                                font.pixelSize: 40
                                color: themeColor
                                font.weight: Font.Medium
                            }
                        }

                        Text {
                            id: moneyChargedFare_unit
                            text: "AED"
                            font.family: "Roboto Condensed"
                            font.pixelSize: 52
                            color: "black"
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
                            color: "black"
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: moneyChargedFare_unit.left
                            anchors.rightMargin: 8
                            font.weight: Font.Bold
                        }
                    }
                }
            }

            // --- Row 4: Total Distance ---
            Row {
                width: parent.width
                height: 124
                spacing: 56

                Rectangle {
                    width: 837.5
                    height: 124
                    radius: 12
                    border.width: 2
                    border.color: themeColor
                    color: "transparent"

                    Rectangle {
                        width: 777.14
                        height: 63.3
                        anchors.centerIn: parent
                        color: "transparent"

                        Row {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 28

                            Item {
                                width: 57.5
                                height: 43.7
                                Image {
                                    id: iconTotalDist
                                    source: "qrc:/images/distancebytaxi(light).png"
                                    anchors.fill: parent
                                    visible: false
                                    smooth: true
                                }
                                ColorOverlay {
                                    anchors.fill: iconTotalDist
                                    source: iconTotalDist
                                    color: themeColor
                                }
                            }

                            Text {
                                text: "Total Distance"
                                font.family: "Roboto"
                                font.pixelSize: 40
                                color: themeColor
                                font.weight: Font.Medium
                            }
                        }

                        Text {
                            id: taxiDistance_unit
                            text: "km"
                            font.family: "Roboto Condensed"
                            font.pixelSize: 52
                            color: "black"
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
                            color: "black"
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
