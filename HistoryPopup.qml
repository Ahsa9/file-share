import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import QtQuick.Layouts 1.15

Item {
    id: root
    width: parent ? parent.width : 2560
    height: parent ? parent.height : 720
    visible: false
    opacity: 0

    property bool isFiltered: false

    // === 1. DATE STATE VARIABLES ===
    // We store the current selection here so buttons update automatically
    property int startDayIndex: 0
    property int startMonthIndex: 0
    property int startYearIndex: 0 // Offset from baseYear
    property int endDayIndex: 0
    property int endMonthIndex: 0
    property int endYearIndex: 0

    property int baseYear: 2020

    // === C++ INTERFACE ===
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

    // Helper to format numbers (1 -> "01")
    function pad(n) {
        return n < 10 ? "0" + n : n
    }

    onVisibleChanged: if (visible)
                          refreshData()

    // === POPUP ANIMATION ===
    function show() {
        visible = true
        opacity = 1
        popupRect.y = ((root.height - popupRect.height) / 2) - 45
    }

    function hide() {
        popupRect.y = root.height
        opacity = 0
        tableList.contentY = 0
        hideTimer.start()
        filterPopup.visible = false
        if (isFiltered && typeof auditModel !== "undefined") {
            auditModel.clearFilter()
            isFiltered = false
        }
    }

    Timer {
        id: hideTimer
        interval: 400
        repeat: false
        onTriggered: root.visible = false
    }
    Behavior on opacity {
        NumberAnimation {
            duration: 400
        }
    }
    MouseArea {
        anchors.fill: parent
        onClicked: root.hide()
    }

    // ==========================================================
    // === NEW COMPONENT: THE POPPED OUT SELECTION WHEEL ===
    // ==========================================================
    Rectangle {
        id: bigSlotPopup
        anchors.fill: parent
        color: "#AA000000" // Dark overlay
        z: 200 // Above everything
        visible: false
        opacity: 0

        property var currentModel: 1
        property int tempIndex: 0
        property var updateCallback: null // Function to run on OK

        // Animation for showing/hiding
        Behavior on opacity {
            NumberAnimation {
                duration: 200
            }
        }

        // Click outside to cancel
        MouseArea {
            anchors.fill: parent
            onClicked: bigSlotPopup.close()
        }

        // The Modal Box
        Rectangle {
            width: 250
            height: 375
            color: "#005566"
            radius: 20
            border.color: "white"
            border.width: 2
            anchors.centerIn: parent

            // Prevent clicks inside from closing
            MouseArea {
                anchors.fill: parent
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20

                Text {
                    text: "Select Value"
                    color: "white"
                    font.pixelSize: 30
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }

                // The Enlarged Tumbler
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Tumbler {
                        id: bigTumbler
                        anchors.centerIn: parent
                        width: parent.width
                        height: parent.height
                        model: bigSlotPopup.currentModel
                        visibleItemCount: 3 // Shows previous, current, next

                        // Set font styles
                        delegate: Text {
                            text: (typeof modelData === "number") ? root.pad(
                                                                        modelData + 1) : modelData
                            color: "white"
                            font.pixelSize: 50 // Enlarged font
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            opacity: 1.0 - Math.abs(Tumbler.displacement)
                                     / (Tumbler.tumbler.visibleItemCount / 2)
                            scale: 1.0 - Math.abs(Tumbler.displacement)
                                   / (Tumbler.tumbler.visibleItemCount / 1.5)
                        }

                        // Highlights the center selection
                        background: Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            Rectangle {
                                width: parent.width * 0.6
                                height: 2
                                color: "#0FE6EF" // Cyan highlight line top
                                anchors.horizontalCenter: parent.horizontalCenter
                                y: (parent.height / 2) - 35
                            }
                            Rectangle {
                                width: parent.width * 0.6
                                height: 2
                                color: "#0FE6EF" // Cyan highlight line bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                y: (parent.height / 2) + 35
                            }
                        }
                    }
                }

                // OK Button
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

    // ==========================================================
    // === REUSABLE COMPONENT: DATE SLOT BUTTON ===
    // ==========================================================
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
                color: "#15000000"
                border.color: "#AACCFF"
                border.width: 1
                radius: 4

                // Visual feedback when pressed
                Rectangle {
                    anchors.fill: parent
                    color: "white"
                    opacity: parent.parent.down ? 0.2 : 0
                }
            }

            contentItem: Text {
                text: parent.displayValue
                color: "white"
                font.bold: true
                font.pixelSize: 32
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: {
                // Open the big popup
                bigSlotPopup.open(slotModel, slotIndex, confirmCallback)
            }
        }
    }

    // === MAIN AUDIT BOX ===
    Rectangle {
        id: popupRect
        width: 1859
        height: 550
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height
        radius: 40
        color: Qt.rgba(0, 0.49, 0.60, 0.8)
        border.color: "#FFFFFF"
        border.width: 1
        MouseArea {
            anchors.fill: parent
        }

        Behavior on y {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutCubic
            }
        }

        // [SCROLLBAR CODE REMOVED FOR BREVITY - KEEP YOUR ORIGINAL SCROLLBAR HERE]
        // ... (Keep your scrollbar and ListView code exactly as it was) ...
        Column {
            anchors.fill: parent
            anchors.margins: 40
            spacing: 20

            // Header
            Row {
                height: 60
                spacing: 20
                Image {
                    width: 50
                    height: 50
                    source: "qrc:/images/audit-trail.png"
                    fillMode: Image.PreserveAspectFit
                }
                Text {
                    text: "AUDIT TRAIL"
                    font.family: "Encode Sans"
                    font.pixelSize: 40
                    color: "white"
                    font.weight: Font.Medium
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Columns Header
            Rectangle {
                width: parent.width - 40
                height: 50
                color: "transparent"
                Row {
                    anchors.fill: parent
                    component HeaderText: Text {
                        font.family: "Roboto"
                        font.pixelSize: 40
                        font.weight: Font.Medium
                        color: "white"
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
                            spacing: 15
                            anchors.centerIn: parent
                            Text {
                                text: "Date"
                                font.family: "Roboto"
                                font.pixelSize: 40
                                font.weight: Font.Medium
                                color: "white"
                            }
                            Rectangle {
                                width: 40
                                height: 40
                                color: "transparent"
                                Image {
                                    anchors.fill: parent
                                    source: "qrc:/images/filter_icon.png"
                                    fillMode: Image.PreserveAspectFit
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
                Rectangle {
                    width: parent.width
                    height: 2
                    color: "white"
                    anchors.bottom: parent.bottom
                }
            }

            // List
            ListView {
                id: tableList
                width: parent.width - 40
                height: parent.height - 150
                clip: true
                model: auditModel
                property int rowHeightPx: 62
                property real manualContentHeight: count * rowHeightPx
                flickDeceleration: 1500
                maximumFlickVelocity: 2500
                delegate: Rectangle {
                    width: tableList.width
                    height: tableList.rowHeightPx
                    color: index % 2 === 0 ? "#10FFFFFF" : "transparent"
                    Row {
                        anchors.fill: parent
                        component CellText: Text {
                            font.family: "Roboto"
                            font.pixelSize: 32
                            color: "white"
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
                        }
                    }
                }
            }
        }

        // === MODIFIED FILTER POPUP ===
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
            MouseArea {
                anchors.fill: parent
            } // Consume events

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

            // Generate Year Model (2020 -> 2039)
            property var yearModel: {
                var arr = []
                for (var i = 0; i < 20; i++)
                    arr.push(root.baseYear + i)
                return arr
            }

            ColumnLayout {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.topMargin: 66
                spacing: 66
                Item {
                    Layout.preferredWidth: filterPopup.width
                    Layout.preferredHeight: 60 // Slightly taller for buttons

                    Rectangle {
                        id: vSep
                        width: 2
                        height: 47
                        color: Qt.rgba(1, 1, 1, 0.2)
                        visible: false
                        anchors.centerIn: parent
                    }

                    // --- START DATE ROW ---
                    RowLayout {
                        spacing: 15
                        anchors.right: vSep.left
                        anchors.rightMargin: 30
                        anchors.verticalCenter: vSep.verticalCenter
                        Text {
                            text: "From"
                            color: "#0FE6EF"
                            font.family: "Roboto"
                            font.pixelSize: 40
                        }

                        // Start Day Button
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
                        // Start Month Button
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
                        // Start Year Button
                        Loader {
                            sourceComponent: dateSlotButton
                            onLoaded: {
                                item.slotModel = filterPopup.yearModel
                                item.displayValue = Qt.binding(function () {
                                    return root.baseYear + root.startYearIndex
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

                    // --- END DATE ROW ---
                    RowLayout {
                        spacing: 15
                        anchors.left: vSep.right
                        anchors.leftMargin: 30
                        anchors.verticalCenter: vSep.verticalCenter
                        Text {
                            text: "To"
                            color: "#0FE6EF"
                            font.family: "Roboto"
                            font.pixelSize: 40
                        }

                        // End Day Button
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
                        // End Month Button
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
                        // End Year Button
                        Loader {
                            sourceComponent: dateSlotButton
                            onLoaded: {
                                item.slotModel = filterPopup.yearModel
                                item.displayValue = Qt.binding(function () {
                                    return root.baseYear + root.endYearIndex
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

                // Action Buttons
                Row {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 20
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
                            var sY = root.baseYear + root.startYearIndex
                            var eD = root.pad(root.endDayIndex + 1)
                            var eM = root.pad(root.endMonthIndex + 1)
                            var eY = root.baseYear + root.endYearIndex

                            filterByDateRange(sD + "/" + sM + "/" + sY,
                                              eD + "/" + eM + "/" + eY)
                            filterPopup.visible = false
                        }
                    }
                }
            }
        }
    }
}
