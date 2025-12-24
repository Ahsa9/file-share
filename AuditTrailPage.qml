import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    // === 1. FULL PAGE SETUP ===
    width: 2560
    height: 720
    color: "white"
    visible: false
    // Removed opacity: 0 since we aren't animating it

    // Signal to tell parent to hide this page
    signal closePage

    property bool isFiltered: false

    // Theme Color for Text/Borders
    property color themeColor: "black"
    property color textColor: "#333333"

    // === DATE STATE VARIABLES ===
    property int startDayIndex: 0
    property int startMonthIndex: 0
    property int startYearIndex: 0
    property int endDayIndex: 0
    property int endMonthIndex: 0
    property int endYearIndex: 0

    property int baseYear: 2020

    // === DATA FUNCTIONS ===
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

    // === TRANSITIONS (ANIMATIONS REMOVED) ===
    function show() {
        root.visible = true
    }

    function hide() {
        // Immediate close logic
        root.visible = false
        root.closePage()

        // Reset Filter UI
        filterPopup.visible = false
        if (isFiltered && typeof auditModel !== "undefined") {
            auditModel.clearFilter()
            isFiltered = false
        }
    }

    // ==========================================================
    // === 2. TOP BAR ===
    // ==========================================================
    TopBar {
        id: settingsTopBar
        anchors.top: parent.top
        width: parent.width
        z: 10
    }

    // ==========================================================
    // === 3. HEADER ROW (Icon, Title, Back) - OVERLAYING TOP BAR ===
    // ==========================================================
    RowLayout {
        id: headerRow
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 40
        height: settingsTopBar.height > 0 ? settingsTopBar.height : 100
        z: 11
        spacing: 20

        // Back Button
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

        // Title Icon
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

        // Title Text
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
    // === REUSABLE POPUPS ===
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
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Tumbler {
                        id: bigTumbler
                        anchors.centerIn: parent
                        width: parent.width
                        height: parent.height
                        model: bigSlotPopup.currentModel
                        visibleItemCount: 3

                        delegate: Text {
                            // === FIX IS HERE ===
                            // If modelData > 100 (it's a Year like 2025), show as is.
                            // If modelData < 100 (it's an index 0-30), add 1 and pad.
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

                        background: Rectangle {
                            anchors.fill: parent
                            color: "transparent"
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
                        if (bigSlotPopup.updateCallback) {
                            bigSlotPopup.updateCallback(bigTumbler.currentIndex)
                        }
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

    // ==========================================================
    // === MAIN PAGE CONTENT (Table) ===
    // ==========================================================
    ColumnLayout {
        anchors.top: settingsTopBar.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 40
        anchors.topMargin: 20
        spacing: 20

        // --- 4. TABLE HEADERS ---
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: "transparent"
            radius: 8

            Row {
                anchors.fill: parent
                spacing: 0

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

                // Date Header with Filter Icon
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

        // --- 5. LIST VIEW ---
        ListView {
            id: tableList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: auditModel
            property int rowHeightPx: 70
            flickDeceleration: 1500
            maximumFlickVelocity: 2500

            ScrollBar.vertical: ScrollBar {
                width: 10
                active: true
            }

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
    // ==========================================================
    // === FILTER POPUP (Restored Style) ===
    // ==========================================================
    Rectangle {
        id: filterPopup
        visible: false
        width: 1054
        height: 285
        radius: 24
        color: "#007D99"
        anchors.centerIn: parent
        z: 100
        clip: true
        border.color: "#FFFFFF"
        border.width: 1

        // Shadow Effect
        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 10
            radius: 16
            samples: 24
            color: "#40000000"
        }

        MouseArea {
            anchors.fill: parent
        }

        // --- RESOURCES ---
        Component {
            id: colonSeparator
            Text {
                text: ":"
                color: "white"
                font.bold: true
                font.pixelSize: 50
                height: 47
                verticalAlignment: Text.AlignVCenter
            }
        }

        property var yearModel: {
            var arr = []
            // Generates 30 years starting from baseYear (e.g., 2020-2049)
            for (var i = 0; i < 30; i++)
                arr.push(root.baseYear + i)
            return arr
        }

        // --- MAIN LAYOUT ---
        // We use a ColumnLayout to separate the Date Pickers from the Action Buttons
        ColumnLayout {
            anchors.fill: parent
            anchors.topMargin: 66 // Push down to vertically center the date row
            spacing: 66 // Gap between dates and buttons

            // 1. DATE SELECTION ROW
            Item {
                Layout.preferredWidth: filterPopup.width
                Layout.preferredHeight: 60

                // Vertical Divider Line (Centered)
                Rectangle {
                    id: vSep
                    width: 2
                    height: 47
                    color: Qt.rgba(1, 1, 1, 0.2)
                    anchors.centerIn: parent
                }

                // --- FROM SECTION (Left of Divider) ---
                RowLayout {
                    spacing: 15
                    anchors.right: vSep.left
                    anchors.rightMargin: 30
                    anchors.verticalCenter: vSep.verticalCenter

                    Text {
                        text: "From"
                        color: "#0FE6EF" // Cyan Accent
                        font.family: "Roboto"
                        font.pixelSize: 40
                    }

                    Loader {
                        sourceComponent: dateSlotButton
                        onLoaded: {
                            item.slotModel = 31
                            item.slotIndex = Qt.binding(function () {
                                return root.startDayIndex
                            })
                            item.confirmCallback = function (idx) {
                                root.startDayIndex = idx
                            }
                        }
                    }
                    Loader {
                        sourceComponent: colonSeparator
                    }
                    Loader {
                        sourceComponent: dateSlotButton
                        onLoaded: {
                            item.slotModel = 12
                            item.slotIndex = Qt.binding(function () {
                                return root.startMonthIndex
                            })
                            item.confirmCallback = function (idx) {
                                root.startMonthIndex = idx
                            }
                        }
                    }
                    Loader {
                        sourceComponent: colonSeparator
                    }
                    Loader {
                        sourceComponent: dateSlotButton
                        onLoaded: {
                            item.slotModel = filterPopup.yearModel
                            item.displayValue = Qt.binding(function () {
                                return filterPopup.yearModel[root.startYearIndex]
                            })
                            item.slotIndex = Qt.binding(function () {
                                return root.startYearIndex
                            })
                            item.confirmCallback = function (idx) {
                                root.startYearIndex = idx
                            }
                        }
                    }
                }

                // --- TO SECTION (Right of Divider) ---
                RowLayout {
                    spacing: 15
                    anchors.left: vSep.right
                    anchors.leftMargin: 30
                    anchors.verticalCenter: vSep.verticalCenter

                    Text {
                        text: "To"
                        color: "#0FE6EF" // Cyan Accent
                        font.family: "Roboto"
                        font.pixelSize: 40
                    }

                    Loader {
                        sourceComponent: dateSlotButton
                        onLoaded: {
                            item.slotModel = 31
                            item.slotIndex = Qt.binding(function () {
                                return root.endDayIndex
                            })
                            item.confirmCallback = function (idx) {
                                root.endDayIndex = idx
                            }
                        }
                    }
                    Loader {
                        sourceComponent: colonSeparator
                    }
                    Loader {
                        sourceComponent: dateSlotButton
                        onLoaded: {
                            item.slotModel = 12
                            item.slotIndex = Qt.binding(function () {
                                return root.endMonthIndex
                            })
                            item.confirmCallback = function (idx) {
                                root.endMonthIndex = idx
                            }
                        }
                    }
                    Loader {
                        sourceComponent: colonSeparator
                    }
                    Loader {
                        sourceComponent: dateSlotButton
                        onLoaded: {
                            item.slotModel = filterPopup.yearModel
                            item.displayValue = Qt.binding(function () {
                                return filterPopup.yearModel[root.endYearIndex]
                            })
                            item.slotIndex = Qt.binding(function () {
                                return root.endYearIndex
                            })
                            item.confirmCallback = function (idx) {
                                root.endYearIndex = idx
                            }
                        }
                    }
                }
            }

            // 2. ACTION BUTTONS ROW
            Row {
                Layout.alignment: Qt.AlignHCenter
                spacing: 20

                // CANCEL BUTTON
                Button {
                    text: "Cancel"
                    width: 478
                    height: 74
                    background: Rectangle {
                        color: parent.down ? "white" : "transparent"
                        border.color: "white"
                        radius: 10
                        opacity: 0.8
                    }
                    contentItem: Text {
                        text: parent.text
                        color: parent.down ? "#007D99" : "white"
                        font.pixelSize: 26
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: filterPopup.visible = false
                }

                // SUBMIT BUTTON
                Button {
                    text: "Submit"
                    width: 478
                    height: 74
                    background: Rectangle {
                        color: parent.down ? "white" : "transparent"
                        border.color: "white"
                        radius: 10
                        opacity: 0.8
                    }
                    contentItem: Text {
                        text: parent.text
                        color: parent.down ? "#007D99" : "white"
                        font.pixelSize: 26
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        var sD = root.pad(root.startDayIndex + 1)
                        var sM = root.pad(root.startMonthIndex + 1)
                        // LOGIC FIX: Access array directly to prevent off-by-one errors
                        var sY = filterPopup.yearModel[root.startYearIndex]

                        var eD = root.pad(root.endDayIndex + 1)
                        var eM = root.pad(root.endMonthIndex + 1)
                        // LOGIC FIX: Access array directly
                        var eY = filterPopup.yearModel[root.endYearIndex]

                        filterByDateRange(sD + "/" + sM + "/" + sY,
                                          eD + "/" + eM + "/" + eY)
                        filterPopup.visible = false
                    }
                }
            }
        }
    }
}
