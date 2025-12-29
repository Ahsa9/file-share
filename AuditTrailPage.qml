import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    width: 2560
    height: 720
    color: "white"
    visible: false

    signal closePage

    property bool isFiltered: false
    property color themeColor: "black"
    property color textColor: "#333333"

    property int startDayIndex: 0
    property int startMonthIndex: 0
    property int startYearIndex: 0
    property int endDayIndex: 0
    property int endMonthIndex: 0
    property int endYearIndex: 0
    property int baseYear: 2020

    function refreshData() {
        if (typeof auditModel !== "undefined")
            auditModel.refresh()
    }

    function filterByDateRange(startDateStr, endDateStr) {
        if (typeof auditModel !== "undefined") {
            auditModel.applyFilter(startDateStr, endDateStr)
            tableList.contentY = 0
            isFiltered = true
        }
    }

    function pad(n) {
        return n < 10 ? "0" + n : n
    }

    onVisibleChanged: if (visible)
                          refreshData()

    function show() {
        root.visible = true
    }

    function hide() {
        root.visible = false
        root.closePage()
        filterPopup.visible = false
        if (isFiltered && typeof auditModel !== "undefined") {
            auditModel.clearFilter()
            isFiltered = false
        }
    }

    TopBar {
        id: settingsTopBar
        anchors.top: parent.top
        width: parent.width
        z: 10
    }

    RowLayout {
        id: headerRow
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 40
        height: settingsTopBar.height > 0 ? settingsTopBar.height : 100
        z: 11
        spacing: 20

        Button {
            Layout.preferredWidth: 140
            Layout.preferredHeight: 60
            Layout.alignment: Qt.AlignVCenter
            background: Rectangle {
                color: parent.down ? "#eee" : "transparent"
                border.color: root.themeColor
                border.width: 2
                radius: 8
            }
            contentItem: Row {
                spacing: 10
                anchors.centerIn: parent
                Text {
                    text: "◄"
                    color: root.themeColor
                    font.pixelSize: 24
                }
                Text {
                    text: "BACK"
                    color: root.themeColor
                    font.bold: true
                    font.pixelSize: 24
                }
            }
            onClicked: root.hide()
        }

        Item {
            Layout.preferredWidth: 34.4
            Layout.preferredHeight: 38.86
            Layout.alignment: Qt.AlignVCenter
            Image {
                id: titleIcon
                anchors.fill: parent
                source: "qrc:/images/audit_trail.png"
                visible: false
                fillMode: Image.PreserveAspectFit
            }
            ColorOverlay {
                anchors.fill: titleIcon
                source: titleIcon
                color: "white"
            }
        }

        Text {
            text: "AUDIT TRAIL"
            font.family: "Encode Sans"
            font.pixelSize: 28
            color: "white"
            font.weight: Font.Bold
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
        }
    }

    // ==========================================================
    // === SELECTION WHEEL POPUP (FIXED INTERCEPTION) ===
    // ==========================================================
    Rectangle {
        id: bigSlotPopup
        anchors.fill: parent
        color: "#AA000000"
        z: 200
        visible: false
        opacity: 0

        property var currentModel: 1
        property int tempIndex: 0
        property var updateCallback: null

        Behavior on opacity {
            NumberAnimation {
                duration: 200
            }
        }

        MouseArea {
            anchors.fill: parent
            // === FIX: INTERCEPT HOVER AND CLICKS ===
            hoverEnabled: true
            preventStealing: true
            onClicked: bigSlotPopup.close()
        }

        Rectangle {
            width: 250
            height: 375
            color: "#005566"
            radius: 20
            border.color: "white"
            border.width: 2
            anchors.centerIn: parent

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
            } // Internal shield

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Tumbler {
                        id: bigTumbler
                        anchors.fill: parent
                        model: bigSlotPopup.currentModel
                        visibleItemCount: 3
                        delegate: Text {
                            text: (typeof modelData
                                   === "number") ? (modelData
                                                    > 100 ? modelData : root.pad(
                                                                modelData + 1)) : modelData
                            color: "white"
                            font.pixelSize: 50
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            opacity: 1.0 - Math.abs(Tumbler.displacement)
                                     / (Tumbler.tumbler.visibleItemCount / 2)
                            scale: 1.0 - Math.abs(Tumbler.displacement)
                                   / (Tumbler.tumbler.visibleItemCount / 1.5)
                        }
                        background: Item {
                            Rectangle {
                                width: parent.width * 0.6
                                height: 2
                                color: "#0FE6EF"
                                anchors.horizontalCenter: parent.horizontalCenter
                                y: (parent.height / 2) - 35
                            }
                            Rectangle {
                                width: parent.width * 0.6
                                height: 2
                                color: "#0FE6EF"
                                anchors.horizontalCenter: parent.horizontalCenter
                                y: (parent.height / 2) + 35
                            }
                        }
                    }
                }

                Button {
                    text: "OK"
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 60
                    Layout.alignment: Qt.AlignHCenter
                    background: Rectangle {
                        color: parent.down ? "white" : "#007D99"
                        radius: 10
                        border.color: "white"
                    }
                    contentItem: Text {
                        text: parent.text
                        color: parent.down ? "#007D99" : "white"
                        font.pixelSize: 24
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        if (bigSlotPopup.updateCallback)
                            bigSlotPopup.updateCallback(bigTumbler.currentIndex)
                        bigSlotPopup.close()
                    }
                }
            }
        }

        function open(dataModel, initialIndex, callback) {
            currentModel = dataModel
            bigTumbler.positionViewAtIndex(initialIndex, Tumbler.Center)
            bigTumbler.currentIndex = initialIndex
            updateCallback = callback
            visible = true
            opacity = 1
        }
        function close() {
            opacity = 0
            visible = false
        }
    }

    Component {
        id: dateSlotButton
        Button {
            property var slotModel: 31
            property int slotIndex: 0
            property string displayValue: root.pad(slotIndex + 1)
            property var confirmCallback: null
            width: 90
            height: 60
            background: Rectangle {
                color: "transparent"
                border.color: "white"
                border.width: 1
                radius: 4
            }
            contentItem: Text {
                text: parent.displayValue
                color: "white"
                font.bold: true
                font.pixelSize: 32
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            onClicked: bigSlotPopup.open(slotModel, slotIndex, confirmCallback)
        }
    }

    ColumnLayout {
        anchors.top: settingsTopBar.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 40
        anchors.topMargin: 20
        spacing: 20

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: "transparent"
            Row {
                anchors.fill: parent
                component HeaderText: Text {
                    font.family: "Roboto"
                    font.pixelSize: 32
                    font.weight: Font.DemiBold
                    color: root.themeColor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    height: parent.height
                }
                HeaderText {
                    text: "No."
                    width: parent.width * 0.1
                }
                HeaderText {
                    text: "Name"
                    width: parent.width * 0.2
                }
                Item {
                    width: parent.width * 0.25
                    height: parent.height
                    Row {
                        spacing: 10
                        anchors.centerIn: parent
                        HeaderText {
                            text: "Date"
                            width: undefined
                        }
                        Item {
                            width: 40
                            height: 40
                            anchors.verticalCenter: parent.verticalCenter
                            Image {
                                id: filterIcon
                                anchors.fill: parent
                                source: "qrc:/images/filter_icon.png"
                                visible: false
                                fillMode: Image.PreserveAspectFit
                            }
                            ColorOverlay {
                                anchors.fill: filterIcon
                                source: filterIcon
                                color: "black"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: filterPopup.visible = !filterPopup.visible
                            }
                        }
                    }
                }
                HeaderText {
                    text: "Time"
                    width: parent.width * 0.15
                }
                HeaderText {
                    text: "Changes"
                    width: parent.width * 0.30
                }
            }
        }

        ListView {
            id: tableList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: auditModel
            property int rowHeightPx: 70
            delegate: Rectangle {
                width: tableList.width
                height: tableList.rowHeightPx
                radius: 12
                color: "transparent"
                border.width: index % 2 === 0 ? 1 : 0
                border.color: "black"
                Row {
                    anchors.fill: parent
                    component CellText: Text {
                        font.family: "Roboto"
                        font.pixelSize: 32
                        color: root.textColor
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        height: parent.height
                        elide: Text.ElideRight
                    }
                    CellText {
                        text: model.id
                        width: parent.width * 0.1
                    }
                    CellText {
                        text: model.name
                        width: parent.width * 0.2
                    }
                    CellText {
                        text: model.date
                        width: parent.width * 0.25
                    }
                    CellText {
                        text: model.time
                        width: parent.width * 0.15
                    }
                    CellText {
                        text: model.changes
                        width: parent.width * 0.30
                        horizontalAlignment: Text.AlignLeft
                        leftPadding: 20
                    }
                }
            }
        }
    }

    // ==========================================================
    // === FILTER POPUP ===
    // ==========================================================
    DateFilter {
        id: filterPopup
        visible: false
        anchors.centerIn: parent

        // Handle the Cancel Signal
        onCancelClicked: {
            filterPopup.visible = false
        }

        // Handle the Submit Signal
        onSubmitClicked: (start, end) => {
                             console.log("Filtering from", start, "to", end)
                             root.filterByDateRange(start, end)
                             filterPopup.visible = false
                         }
    }
}
