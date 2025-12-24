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
    property int startDayIndex: 0
    property int startMonthIndex: 0
    property int startYearIndex: 0
    property int endDayIndex: 0
    property int endMonthIndex: 0
    property int endYearIndex: 0

    property int baseYear: 2020

    // === ADDED: AUTOCLOSE LOGIC ===
    property real progressValue: 0
    property bool progressActive: false
    property bool progressFinished: false
    property real speedValue: 0

    Timer {
        id: autoCloseTimer
        interval: 100
        repeat: true

        onTriggered: {
            if (!progressActive)
                return

            progressValue += 0.01 // 10 seconds

            if (progressValue > 1.0)
                progressValue = 1.0

            if (progressValue >= 1.0) {
                progressActive = false
                progressFinished = true
                autoCloseTimer.stop()

                speedValue = Number(appCore.speed)
                if (speedValue > 0) {
                    hide()
                }
            }
        }
    }

    Connections {
        target: appCore

        function onSpeedChanged() {
            if (!visible)
                return
            if (!progressFinished)
                return

            var v = Number(appCore.speed)
            speedValue = v

            if (v > 0) {
                hide()
            }
        }
    }

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

    function pad(n) {
        return n < 10 ? "0" + n : n
    }

    // === MODIFIED: onVisibleChanged ===
    onVisibleChanged: {
        if (visible) {
            // Existing logic
            refreshData()

            // Added Auto-close logic
            progressValue = 0
            progressActive = true
            progressFinished = false
            autoCloseTimer.start()

            speedValue = Number(appCore.speed)
        } else {
            // Stop logic on hide
            progressActive = false
            autoCloseTimer.stop()
        }
    }

    // === POPUP ANIMATION (FADE ONLY) ===
    function show() {
        visible = true
        opacity = 1
    }

    function hide() {
        // 1. Start Fade Out
        opacity = 0
        hideTimer.start()

        // 2. Reset Filter Popup Visibility
        filterPopup.visible = false

        // 3. Reset Scroll Position
        tableList.contentY = 0

        // 4. Reset Date Picker Indices (Reset values)
        startDayIndex = 0
        startMonthIndex = 0
        startYearIndex = 0
        endDayIndex = 0
        endMonthIndex = 0
        endYearIndex = 0

        // 5. Clear C++ Filter if applied
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

    // This controls the Fade In / Fade Out speed
    Behavior on opacity {
        NumberAnimation {
            duration: 400
            easing.type: Easing.InOutQuad
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.hide()
    }

    // ==========================================================
    // === REUSABLE COMPONENT: SELECTION WHEEL POPUP ===
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
                            // Fix: Pad numbers < 100, leave years > 100 as is
                            text: (typeof modelData
                                   === "number") ? (modelData
                                                    > 100 ? modelData : root.pad(
                                                                modelData + 1)) : modelData

                            color: "white"
                            font.family: "Roboto" // Added Roboto
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
                        font.family: "Roboto"
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
                Rectangle {
                    anchors.fill: parent
                    color: "white"
                    opacity: parent.parent.down ? 0.2 : 0
                }
            }

            contentItem: Text {
                text: parent.displayValue
                color: "white"
                font.family: "Roboto" // <--- Added Roboto for the numbers
                font.bold: true
                font.pixelSize: 32
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: {
                bigSlotPopup.open(slotModel, slotIndex, confirmCallback)
            }
        }
    }

    // === MAIN AUDIT BOX ===
    Rectangle {
        id: popupRect
        width: 1859
        height: 550

        anchors.centerIn: parent
        anchors.verticalCenterOffset: -45

        radius: 40
        color: Qt.rgba(0, 0.49, 0.60, 0.8)
        border.color: "#FFFFFF"
        border.width: 1

        MouseArea {
            anchors.fill: parent
        }

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
                    source: "qrc:/images/audit_trail.png"
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

        // === FILTER POPUP ===
        Rectangle {
            id: filterPopup
            visible: false
            // INCREASED WIDTH to prevent "From" word cutoff on wider screens
            width: 1054
            height: 285
            radius: 24
            color: "#007D99"
            anchors.centerIn: parent
            z: 100
            clip: true
            border.color: "#FFFFFF"
            border.width: 1
            MouseArea {
                anchors.fill: parent
            }

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
                for (var i = 0; i < 30; i++)
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
                    Layout.preferredHeight: 60

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
                        spacing: 12 // Reduced spacing slightly to help fit
                        anchors.right: vSep.left
                        anchors.rightMargin: 30
                        anchors.verticalCenter: vSep.verticalCenter
                        Text {
                            text: "From"
                            color: "#0FE6EF"
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
                        spacing: 12 // Reduced spacing slightly
                        anchors.left: vSep.right
                        anchors.leftMargin: 30
                        anchors.verticalCenter: vSep.verticalCenter
                        Text {
                            text: "To"
                            color: "#0FE6EF"
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
                        // === HOVERED EFFECT ADDED ===
                        background: Rectangle {
                            color: parent.down
                                   || parent.hovered ? "white" : "transparent"
                            border.color: "white"
                            radius: 10
                            opacity: 0.8
                        }
                        contentItem: Text {
                            text: parent.text
                            // === HOVERED TEXT COLOR CHANGE ===
                            color: parent.down
                                   || parent.hovered ? "#007D99" : "white"
                            font.family: "Roboto"
                            font.weight: Font.Medium
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
                        // === HOVERED EFFECT ADDED ===
                        background: Rectangle {
                            color: parent.down
                                   || parent.hovered ? "white" : "transparent"
                            border.color: "white"
                            radius: 10
                            opacity: 0.8
                        }
                        contentItem: Text {
                            text: parent.text
                            // === HOVERED TEXT COLOR CHANGE ===
                            color: parent.down
                                   || parent.hovered ? "#007D99" : "white"
                            font.family: "Roboto"
                            font.weight: Font.Medium
                            font.pixelSize: 26
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: {
                            var sD = root.pad(root.startDayIndex + 1)
                            var sM = root.pad(root.startMonthIndex + 1)
                            var eD = root.pad(root.endDayIndex + 1)
                            var eM = root.pad(root.endMonthIndex + 1)
                            var sY = filterPopup.yearModel[root.startYearIndex]
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
}
