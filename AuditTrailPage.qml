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

        // Removed opacity behavior here too for instant feel
        property var currentModel: 1
        property int tempIndex: 0
        property var updateCallback: null

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
                            text: (typeof modelData === "number") ? root.pad(
                                                                        modelData + 1) : modelData
                            color: "white"
                            font.pixelSize: 50
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            opacity: 1.0 - Math.abs(Tumbler.displacement)
                                     / (Tumbler.tumbler.visibleItemCount / 2)
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
        }
        function close() {
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
        border.color: "white"
        border.width: 2
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
            for (var i = 0; i < 20; i++)
                arr.push(root.baseYear + i)
            return arr
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 40
            Item {
                Layout.preferredWidth: filterPopup.width
                Layout.preferredHeight: 60
                Rectangle {
                    id: vSep
                    width: 2
                    height: 47
                    color: Qt.rgba(1, 1, 1, 0.2)
                    anchors.centerIn: parent
                }
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
                    Loader {
                        sourceComponent: dateSlotButton
                        onLoaded: {
                            item.slotModel = 31
                            item.slotIndex = Qt.binding(
                                        () => root.startDayIndex)
                            item.confirmCallback = idx => root.startDayIndex = idx
                        }
                    }
                    Loader {
                        sourceComponent: colonSeparator
                    }
                    Loader {
                        sourceComponent: dateSlotButton
                        onLoaded: {
                            item.slotModel = 12
                            item.slotIndex = Qt.binding(
                                        () => root.startMonthIndex)
                            item.confirmCallback = idx => root.startMonthIndex = idx
                        }
                    }
                    Loader {
                        sourceComponent: colonSeparator
                    }
                    Loader {
                        sourceComponent: dateSlotButton
                        onLoaded: {
                            item.slotModel = filterPopup.yearModel
                            item.displayValue = Qt.binding(
                                        () => root.baseYear + root.startYearIndex)
                            item.slotIndex = Qt.binding(
                                        () => root.startYearIndex)
                            item.confirmCallback = idx => root.startYearIndex = idx
                        }
                    }
                }
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
                    Loader {
                        sourceComponent: dateSlotButton
                        onLoaded: {
                            item.slotModel = 31
                            item.slotIndex = Qt.binding(() => root.endDayIndex)
                            item.confirmCallback = idx => root.endDayIndex = idx
                        }
                    }
                    Loader {
                        sourceComponent: colonSeparator
                    }
                    Loader {
                        sourceComponent: dateSlotButton
                        onLoaded: {
                            item.slotModel = 12
                            item.slotIndex = Qt.binding(
                                        () => root.endMonthIndex)
                            item.confirmCallback = idx => root.endMonthIndex = idx
                        }
                    }
                    Loader {
                        sourceComponent: colonSeparator
                    }
                    Loader {
                        sourceComponent: dateSlotButton
                        onLoaded: {
                            item.slotModel = filterPopup.yearModel
                            item.displayValue = Qt.binding(
                                        () => root.baseYear + root.endYearIndex)
                            item.slotIndex = Qt.binding(() => root.endYearIndex)
                            item.confirmCallback = idx => root.endYearIndex = idx
                        }
                    }
                }
            }
            Row {
                Layout.alignment: Qt.AlignHCenter
                spacing: 40
                Button {
                    text: "Cancel"
                    width: 200
                    height: 60
                    background: Rectangle {
                        color: parent.down ? "#eee" : "transparent"
                        border.color: "white"
                        radius: 10
                    }
                    contentItem: Text {
                        text: parent.text
                        color: parent.down ? "#007D99" : "white"
                        font.pixelSize: 24
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: filterPopup.visible = false
                }
                Button {
                    text: "Submit"
                    width: 200
                    height: 60
                    background: Rectangle {
                        color: parent.down ? "#eee" : "transparent"
                        border.color: "white"
                        radius: 10
                    }
                    contentItem: Text {
                        text: parent.text
                        color: parent.down ? "#007D99" : "white"
                        font.pixelSize: 24
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
