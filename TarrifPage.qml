import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

Rectangle {
    id: tariffRoot
    width: 2560
    height: 720
    color: "white"
    visible: false

    // Signal to notify parent
    signal closePage

    // Helper properties
    property color themeColor: "#007D99"

    // ==========================================================
    // === FALLBACK PROPERTIES (Redis Caching Logic) ===
    // ==========================================================

    // --- DAY TARIFF FALLBACKS ---
    property string fallbackDayStartFee: "12.00"
    property string fallbackDayPerKm: "1.82"
    property string fallbackDayInitialTime: "0"
    property string fallbackDayPerHour: "30.00"
    property string fallbackDayInitialDist: "0"
    property string fallbackDayIncrement: "0.50"

    // --- NIGHT TARIFF FALLBACKS ---
    property string fallbackNightStartFee: "15.00"
    property string fallbackNightPerKm: "2.10"
    property string fallbackNightInitialTime: "0"
    property string fallbackNightPerHour: "30.00"
    property string fallbackNightInitialDist: "0"
    property string fallbackNightIncrement: "0.50"

    function show() {
        tariffRoot.visible = true
    }

    function hide() {
        tariffRoot.visible = false
        // Reset scroll position
        mainScrollView.contentItem.contentY = 0
        tariffRoot.closePage()
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
    // === 2. HEADER ROW ===
    // ==========================================================
    RowLayout {
        id: headerRow
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 40
        height: headerBar.height > 0 ? headerBar.height : 100
        z: 11
        spacing: 20

        Button {
            Layout.preferredWidth: 140
            Layout.preferredHeight: 60
            Layout.alignment: Qt.AlignVCenter
            background: Rectangle {
                color: parent.down ? "#eee" : "transparent"
                border.color: "white"
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
            onClicked: tariffRoot.hide()
        }

        Item {
            Layout.preferredWidth: 50
            Layout.preferredHeight: 50
            Layout.alignment: Qt.AlignVCenter
            Image {
                id: titleIcon
                anchors.fill: parent
                source: "qrc:/images/c_Tarrif.png"
                fillMode: Image.PreserveAspectFit
                visible: false
            }
            ColorOverlay {
                anchors.fill: titleIcon
                source: titleIcon
                color: "white"
            }
        }

        Text {
            text: "TARIFFS"
            color: "white"
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            verticalAlignment: Text.AlignVCenter
            font.family: "Encode Sans"
            font.weight: Font.Bold
            font.pixelSize: 28
            font.capitalization: Font.AllUppercase
        }
    }

    // ==========================================================
    // === 3. REUSABLE BOX COMPONENT ===
    // ==========================================================
    Component {
        id: tariffRectComponent
        Rectangle {
            width: 923.5
            height: 143
            radius: 12

            border.width: 2
            border.color: "#117BB1"
            color: "transparent"

            property string labelText: "Label"
            property string valueText: "0.00"
            property string unitText: "AED"
            property string iconSource: ""

            // --- LABEL (Left Side) ---
            Row {
                anchors.left: parent.left
                anchors.leftMargin: 27
                anchors.verticalCenter: parent.verticalCenter
                spacing: 20

                Item {
                    width: 46
                    height: 46
                    visible: iconSource !== ""
                    Image {
                        id: innerIcon
                        source: iconSource
                        anchors.fill: parent
                        visible: false
                        smooth: true
                        fillMode: Image.PreserveAspectFit
                    }
                    ColorOverlay {
                        anchors.fill: innerIcon
                        source: innerIcon
                        color: "#007D99"
                        visible: iconSource !== ""
                    }
                }

                Text {
                    text: labelText
                    font.family: "Roboto"
                    font.weight: Font.Medium
                    font.pixelSize: 40
                    color: "#007D99"
                    verticalAlignment: Text.AlignVCenter
                }
            }

            // --- VALUE & UNIT (Right Side) ---
            Row {
                anchors.right: parent.right
                anchors.rightMargin: 32
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10

                Text {
                    id: valTxt
                    text: valueText
                    font.family: "Roboto Condensed"
                    font.weight: Font.Bold
                    font.pixelSize: 72
                    color: "#0D0D0D"
                }

                Text {
                    id: unitTxt
                    text: unitText
                    font.family: "Roboto Condensed"
                    font.weight: Font.Bold
                    font.pixelSize: 72
                    color: "#0D0D0D"
                    anchors.baseline: valTxt.baseline
                }
            }
        }
    }

    // ==========================================================
    // === 4. CONTENT SCROLL AREA ===
    // ==========================================================
    ScrollView {
        id: mainScrollView
        anchors.top: headerBar.bottom
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: 2200
        clip: true
        topPadding: 40
        bottomPadding: 60

        ScrollBar.vertical.policy: ScrollBar.AlwaysOff

        Column {
            anchors.centerIn: parent
            spacing: 60

            // ==================================================
            // === GROUP BOX 1: DAY TARIFF ===
            // ==================================================
            Rectangle {
                id: dayGroupBox
                width: 2000
                height: dayColumn.height + 100

                radius: 20
                color: "transparent"
                border.width: 1
                border.color: themeColor

                Column {
                    id: dayColumn
                    anchors.centerIn: parent
                    spacing: 19

                    // TITLE
                    Text {
                        text: "DAY TARIFF"
                        font.family: "Roboto"
                        font.weight: Font.Medium
                        font.pixelSize: 40
                        lineHeight: 1.0
                        font.letterSpacing: 0
                        color: themeColor
                        anchors.left: parent.left
                        bottomPadding: 10
                    }

                    // Row 1: Hire Fee & Distance Tariff
                    Row {
                        spacing: 56
                        Loader {
                            sourceComponent: tariffRectComponent
                            onLoaded: {
                                item.labelText = "Initial Hire Fee"
                                // Logic: Check if appCore exists and has value, else use fallback
                                item.valueText = (typeof appCore !== 'undefined'
                                                  && appCore.dayStartFee) ? appCore.dayStartFee : fallbackDayStartFee
                            }
                        }
                        Loader {
                            sourceComponent: tariffRectComponent
                            onLoaded: {
                                item.labelText = "Tariff Per Distance [KM]"
                                item.valueText = (typeof appCore !== 'undefined'
                                                  && appCore.dayPerKm) ? appCore.dayPerKm : fallbackDayPerKm
                            }
                        }
                    }

                    // Row 2: Initial Time & Hour Tariff
                    Row {
                        spacing: 56
                        Loader {
                            sourceComponent: tariffRectComponent
                            onLoaded: {
                                item.labelText = "Initial Time"
                                item.valueText = (typeof appCore !== 'undefined'
                                                  && appCore.dayInitialTime) ? appCore.dayInitialTime : fallbackDayInitialTime
                                item.unitText = "MIN"
                            }
                        }
                        Loader {
                            sourceComponent: tariffRectComponent
                            onLoaded: {
                                item.labelText = "Tariff Per Hour"
                                item.valueText = (typeof appCore !== 'undefined'
                                                  && appCore.dayPerHour) ? appCore.dayPerHour : fallbackDayPerHour
                            }
                        }
                    }

                    // Row 3: Initial Distance & Fare Increment
                    Row {
                        spacing: 56
                        Loader {
                            sourceComponent: tariffRectComponent
                            onLoaded: {
                                item.labelText = "Initial Distance"
                                item.valueText = (typeof appCore !== 'undefined'
                                                  && appCore.dayInitialDist) ? appCore.dayInitialDist : fallbackDayInitialDist
                                item.unitText = "M"
                            }
                        }
                        Loader {
                            sourceComponent: tariffRectComponent
                            onLoaded: {
                                item.labelText = "Fare Increment"
                                item.valueText = (typeof appCore !== 'undefined'
                                                  && appCore.dayIncrement) ? appCore.dayIncrement : fallbackDayIncrement
                            }
                        }
                    }
                }
            }

            // ==================================================
            // === GROUP BOX 2: NIGHT TARIFF ===
            // ==================================================
            Rectangle {
                id: nightGroupBox
                width: 2000
                height: nightColumn.height + 100

                radius: 20
                color: "transparent"
                border.width: 1
                border.color: themeColor

                Column {
                    id: nightColumn
                    anchors.centerIn: parent
                    spacing: 19

                    // TITLE
                    Text {
                        text: "NIGHT TARIFF"
                        font.family: "Roboto"
                        font.weight: Font.Medium
                        font.pixelSize: 40
                        lineHeight: 1.0
                        font.letterSpacing: 0
                        color: themeColor
                        anchors.left: parent.left
                        bottomPadding: 10
                    }

                    // Row 1
                    Row {
                        spacing: 56
                        Loader {
                            sourceComponent: tariffRectComponent
                            onLoaded: {
                                item.labelText = "Initial Hire Fee"
                                item.valueText = (typeof appCore !== 'undefined'
                                                  && appCore.nightStartFee) ? appCore.nightStartFee : fallbackNightStartFee
                            }
                        }
                        Loader {
                            sourceComponent: tariffRectComponent
                            onLoaded: {
                                item.labelText = "Tariff Per Distance [KM]"
                                item.valueText = (typeof appCore !== 'undefined'
                                                  && appCore.nightPerKm) ? appCore.nightPerKm : fallbackNightPerKm
                            }
                        }
                    }

                    // Row 2
                    Row {
                        spacing: 56
                        Loader {
                            sourceComponent: tariffRectComponent
                            onLoaded: {
                                item.labelText = "Initial Time"
                                item.valueText = (typeof appCore !== 'undefined'
                                                  && appCore.nightInitialTime) ? appCore.nightInitialTime : fallbackNightInitialTime
                                item.unitText = "MIN"
                            }
                        }
                        Loader {
                            sourceComponent: tariffRectComponent
                            onLoaded: {
                                item.labelText = "Tariff Per Hour"
                                item.valueText = (typeof appCore !== 'undefined'
                                                  && appCore.nightPerHour) ? appCore.nightPerHour : fallbackNightPerHour
                            }
                        }
                    }

                    // Row 3
                    Row {
                        spacing: 56
                        Loader {
                            sourceComponent: tariffRectComponent
                            onLoaded: {
                                item.labelText = "Initial Distance"
                                item.valueText = (typeof appCore !== 'undefined'
                                                  && appCore.nightInitialDist) ? appCore.nightInitialDist : fallbackNightInitialDist
                                item.unitText = "M"
                            }
                        }
                        Loader {
                            sourceComponent: tariffRectComponent
                            onLoaded: {
                                item.labelText = "Fare Increment"
                                item.valueText = (typeof appCore !== 'undefined'
                                                  && appCore.nightIncrement) ? appCore.nightIncrement : fallbackNightIncrement
                            }
                        }
                    }
                }
            }

            // Bottom Spacer
            Item {
                width: 1
                height: 50
            }
        }
    }
}
