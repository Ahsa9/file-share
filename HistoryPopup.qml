import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import QtQuick.LocalStorage 2.0
import QtQuick.Layouts 1.15

Item {
    id: root
    width: parent ? parent.width : 2560
    height: parent ? parent.height : 720
    visible: false
    opacity: 0

    // Internal model for the view
    ListModel {
        id: viewModel
    }

    // === DATABASE LOGIC ===
    function getDatabase() {
        return LocalStorage.openDatabaseSync("SystemLogsDB", "1.0",
                                             "Logs Storage", 1000000)
    }

    function initDatabase() {
        var db = getDatabase()
        db.transaction(function (tx) {
            tx.executeSql(
                        'CREATE TABLE IF NOT EXISTS logs(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, date TEXT, time TEXT, changes TEXT)')
        })
    }

    function addEntry(name, changes) {
        var db = getDatabase()
        var d = new Date()
        // --- CHANGE 1: Used / instead of - ---
        var dateStr = Qt.formatDate(d, "dd/MM/yyyy")
        var timeStr = Qt.formatTime(d, "hh:mm AP")

        db.transaction(function (tx) {
            tx.executeSql('INSERT INTO logs VALUES(?, ?, ?, ?, ?)',
                          [null, name, dateStr, timeStr, changes])
        })
    }

    function refreshData() {
        tableList.contentY = 0
        viewModel.clear()
        var db = getDatabase()
        db.transaction(function (tx) {
            var rs = tx.executeSql(
                        'SELECT * FROM logs ORDER BY id DESC LIMIT 20')
            for (var i = 0; i < rs.rows.length; i++) {
                viewModel.append(rs.rows.item(i))
            }
        })
    }

    function filterByDateRange(startDateStr, endDateStr) {
        tableList.contentY = 0
        viewModel.clear()
        var db = getDatabase()
        db.transaction(function (tx) {
            var rs = tx.executeSql(
                        'SELECT * FROM logs WHERE date BETWEEN ? AND ? ORDER BY id DESC LIMIT 20',
                        [startDateStr, endDateStr])
            for (var i = 0; i < rs.rows.length; i++) {
                viewModel.append(rs.rows.item(i))
            }
        })
    }

    // === SIMULATION ===
    Timer {
        id: dummyDataTimer
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            var randomId = Math.floor(Math.random() * 1000)
            addEntry("Driver " + randomId, "Trip #" + randomId + " Completed")
            if (root.visible && !isFiltered)
                refreshData()
        }
    }

    property bool isFiltered: false

    Component.onCompleted: initDatabase()
    onVisibleChanged: if (visible)
                          refreshData()

    // === ANIMATION & POPUP LOGIC ===
    function show() {
        visible = true
        popupRect.y = (root.height - popupRect.height) / 2
        opacity = 1
    }

    function hide() {
        popupRect.y = root.height
        opacity = 0
        hideTimer.start()
        filterPopup.visible = false
        isFiltered = false
    }

    Timer {
        id: hideTimer
        interval: 400
        repeat: false
        onTriggered: root.visible = false
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.hide()
        propagateComposedEvents: false
    }

    // === MAIN POPUP RECTANGLE ===
    Rectangle {
        id: popupRect
        width: 1859
        height: 600
        anchors.centerIn: parent
        y: parent.height
        radius: 40
        color: Qt.rgba(0 / 255, 125 / 255, 153 / 255, 0.8)
        border.color: "#FFFFFF"
        border.width: 1

        layer.enabled: true
        layer.effect: DropShadow {
            color: "#40000000"
            horizontalOffset: 0
            verticalOffset: 4
            radius: 14
            samples: 29
        }

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

        // === CUSTOM SCROLL BAR ===
        Rectangle {
            id: sideBar
            width: 16
            height: parent.height - 40
            radius: 90
            color: "white"
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 20
            clip: true

            Rectangle {
                id: scrollHandle
                color: "#007D99"
                width: parent.width - 4
                radius: width / 2
                anchors.horizontalCenter: parent.horizontalCenter
                height: {
                    var contentH = tableList.manualContentHeight
                    var viewH = tableList.height
                    if (contentH <= viewH)
                        return parent.height - 4
                    var ratio = viewH / contentH
                    var h = parent.height * ratio
                    return Math.max(30, h)
                }
                Connections {
                    target: tableList
                    function onContentYChanged() {
                        if (!dragArea.drag.active) {
                            var listRange = tableList.manualContentHeight - tableList.height
                            var trackRange = sideBar.height - scrollHandle.height
                            if (listRange > 0) {
                                scrollHandle.y = (tableList.contentY / listRange) * trackRange
                            } else {
                                scrollHandle.y = 0
                            }
                        }
                    }
                }
                MouseArea {
                    id: dragArea
                    anchors.fill: parent
                    drag.target: scrollHandle
                    drag.axis: Drag.YAxis
                    drag.minimumY: 0
                    drag.maximumY: sideBar.height - scrollHandle.height
                    onMouseYChanged: {
                        if (drag.active) {
                            var trackAvailable = sideBar.height - scrollHandle.height
                            var listAvailable = tableList.manualContentHeight - tableList.height
                            if (trackAvailable > 0) {
                                var ratio = scrollHandle.y / trackAvailable
                                tableList.contentY = ratio * listAvailable
                            }
                        }
                    }
                }
            }
        }

        Column {
            anchors.fill: parent
            anchors.margins: 40
            spacing: 20

            // 1. Header Row
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
                    font.family: "Roboto"
                    font.pixelSize: 40
                    color: "white"
                    font.weight: Font.Medium
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // 2. Table Headers
            Rectangle {
                width: parent.width - 40
                height: 50
                color: "transparent"
                Row {
                    anchors.fill: parent
                    spacing: 0

                    component HeaderText: Text {
                        font.family: "Roboto"
                        font.pixelSize: 40
                        font.weight: Font.Medium
                        lineHeight: 1.0
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

                    // Date Header (Complex Item)
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
                                lineHeight: 1.0
                                color: "white"
                                verticalAlignment: Text.AlignVCenter
                            }
                            // Filter Icon
                            Rectangle {
                                width: 30
                                height: 30
                                color: "transparent"
                                anchors.verticalCenter: parent.verticalCenter
                                Image {
                                    anchors.fill: parent
                                    source: "qrc:/images/filter_icon.png"
                                    fillMode: Image.PreserveAspectFit
                                    onStatusChanged: if (status === Image.Error)
                                                         visible = false
                                }
                                Rectangle {
                                    anchors.fill: parent
                                    color: "transparent"
                                    border.color: "white"
                                    border.width: 2
                                    radius: 4
                                    visible: parent.children[0].status !== Image.Ready
                                    Text {
                                        anchors.centerIn: parent
                                        text: "▼"
                                        color: "white"
                                    }
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

            // 3. Table Rows
            ListView {
                id: tableList
                width: parent.width - 40
                height: parent.height - 150
                clip: true
                model: viewModel
                boundsBehavior: Flickable.StopAtBounds

                property int rowHeightPx: 62
                property int spacingPx: 0
                property real manualContentHeight: (count * rowHeightPx)
                                                   + ((count > 0 ? count - 1 : 0) * spacingPx)

                spacing: spacingPx
                flickDeceleration: 1500
                maximumFlickVelocity: 2500

                onCountChanged: {
                    var maxScroll = manualContentHeight - height
                    if (manualContentHeight <= height) {
                        contentY = 0
                    } else if (contentY > maxScroll) {
                        contentY = maxScroll
                    }
                }

                delegate: Rectangle {
                    width: tableList.width
                    height: tableList.rowHeightPx
                    color: index % 2 === 0 ? "#10FFFFFF" : "transparent"

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 0
                        spacing: 0

                        component CellText: Text {
                            font.family: "Roboto"
                            font.pixelSize: 32
                            font.weight: Font.Normal
                            lineHeight: 1.0
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

                        // Date Column
                        Item {
                            width: parent.width * 0.25
                            height: parent.height

                            // --- CHANGE 2: Removed Image, centered Text directly ---
                            Text {
                                text: model.date
                                anchors.centerIn: parent
                                color: "white"
                                font.family: "Roboto"
                                font.weight: Font.Normal
                                font.pixelSize: 32
                                lineHeight: 1.0
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }

                        // Time Column
                        Item {
                            width: parent.width * 0.15
                            height: parent.height
                            Text {
                                text: model.time
                                anchors.centerIn: parent
                                color: "white"
                                font.family: "Roboto"
                                font.weight: Font.Normal
                                font.pixelSize: 32
                                lineHeight: 1.0
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }

                        CellText {
                            text: model.changes
                            width: parent.width * 0.30
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    onWheel: {
                        if (tableList.manualContentHeight > tableList.height) {
                            var speedFactor = 2.5
                            var currentPos = tableList.contentY
                            var delta = wheel.angleDelta.y * speedFactor
                            var newPos = currentPos - delta
                            var maxScroll = tableList.manualContentHeight - tableList.height
                            if (newPos < 0)
                                newPos = 0
                            if (newPos > maxScroll)
                                newPos = maxScroll
                            tableList.contentY = newPos
                        }
                    }
                }
            }
        }

        // ... [Filter Popup Code] ...
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

            function pad(n) {
                return n < 10 ? "0" + n : n
            }

            Component {
                id: colonSeparator
                Text {
                    text: ":"
                    color: "white"
                    font.family: "Roboto Condensed"
                    font.weight: Font.Bold
                    font.pixelSize: 50
                    lineHeight: 1.0
                    height: 47
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Component {
                id: tumblerBackground
                Rectangle {
                    anchors.fill: parent
                    color: "#15000000"
                    border.color: "#AACCFF"
                    border.width: 1
                    radius: 4
                }
            }

            Component {
                id: wheelDelegate
                Text {
                    text: {
                        if (typeof modelData === "number")
                            return filterPopup.pad(modelData + 1)
                        return modelData
                    }
                    color: "white"
                    font.bold: true
                    font.pixelSize: 32
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            ColumnLayout {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.topMargin: 66
                spacing: 66

                Item {
                    id: dateSelectionContainer
                    Layout.preferredWidth: filterPopup.width
                    Layout.preferredHeight: 47

                    Rectangle {
                        id: verticalSeparator
                        width: 2
                        height: 47
                        color: Qt.rgba(1, 1, 1, 0.2)
                        visible: false
                        anchors.centerIn: parent
                    }

                    RowLayout {
                        spacing: 25
                        anchors.right: verticalSeparator.left
                        anchors.rightMargin: 30
                        anchors.verticalCenter: verticalSeparator.verticalCenter
                        Text {
                            text: "From"
                            color: "#0FE6EF"
                            font.family: "Roboto"
                            font.weight: Font.Medium
                            font.pixelSize: 40
                            lineHeight: 1.0
                            Layout.alignment: Qt.AlignVCenter
                        }
                        Row {
                            spacing: 10
                            Tumbler {
                                id: startDay
                                model: 31
                                visibleItemCount: 1
                                width: 73
                                height: 47
                                delegate: wheelDelegate
                                background: Loader {
                                    sourceComponent: tumblerBackground
                                }
                                Component.onCompleted: currentIndex = new Date().getDate(
                                                           ) - 1
                            }
                            Loader {
                                sourceComponent: colonSeparator
                            }
                            Tumbler {
                                id: startMonth
                                model: 12
                                visibleItemCount: 1
                                width: 90
                                height: 47
                                delegate: wheelDelegate
                                background: Loader {
                                    sourceComponent: tumblerBackground
                                }
                                Component.onCompleted: currentIndex = new Date().getMonth()
                            }
                            Loader {
                                sourceComponent: colonSeparator
                            }
                            Tumbler {
                                id: startYear
                                model: 20
                                property int baseYear: 2020
                                visibleItemCount: 1
                                width: 89
                                height: 47
                                background: Loader {
                                    sourceComponent: tumblerBackground
                                }
                                contentItem: ListView {
                                    model: startYear.model
                                    delegate: Text {
                                        text: startYear.baseYear + index
                                        color: "white"
                                        font.bold: true
                                        font.pixelSize: 32
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        height: startYear.availableHeight
                                                / startYear.visibleItemCount
                                    }
                                    snapMode: ListView.SnapToItem
                                    clip: true
                                }
                                Component.onCompleted: currentIndex = new Date().getFullYear(
                                                           ) - baseYear
                            }
                        }
                    }

                    RowLayout {
                        spacing: 25
                        anchors.left: verticalSeparator.right
                        anchors.leftMargin: 30
                        anchors.verticalCenter: verticalSeparator.verticalCenter
                        Text {
                            text: "To"
                            color: "#0FE6EF"
                            font.family: "Roboto"
                            font.weight: Font.Medium
                            font.pixelSize: 40
                            lineHeight: 1.0
                            Layout.alignment: Qt.AlignVCenter
                        }
                        Row {
                            spacing: 10
                            Tumbler {
                                id: endDay
                                model: 31
                                visibleItemCount: 1
                                width: 73
                                height: 47
                                delegate: wheelDelegate
                                background: Loader {
                                    sourceComponent: tumblerBackground
                                }
                                Component.onCompleted: currentIndex = new Date().getDate(
                                                           ) - 1
                            }
                            Loader {
                                sourceComponent: colonSeparator
                            }
                            Tumbler {
                                id: endMonth
                                model: 12
                                visibleItemCount: 1
                                width: 90
                                height: 47
                                delegate: wheelDelegate
                                background: Loader {
                                    sourceComponent: tumblerBackground
                                }
                                Component.onCompleted: currentIndex = new Date().getMonth()
                            }
                            Loader {
                                sourceComponent: colonSeparator
                            }
                            Tumbler {
                                id: endYear
                                model: 20
                                property int baseYear: 2020
                                visibleItemCount: 1
                                width: 89
                                height: 47
                                background: Loader {
                                    sourceComponent: tumblerBackground
                                }
                                contentItem: ListView {
                                    model: endYear.model
                                    delegate: Text {
                                        text: endYear.baseYear + index
                                        color: "white"
                                        font.family: "Roboto"
                                        font.bold: true
                                        font.pixelSize: 32
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        height: endYear.availableHeight / endYear.visibleItemCount
                                    }
                                    snapMode: ListView.SnapToItem
                                    clip: true
                                }
                                Component.onCompleted: currentIndex = new Date().getFullYear(
                                                           ) - baseYear
                            }
                        }
                    }
                }

                Row {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 20
                    Button {
                        text: "Cancel"
                        width: 478.89
                        height: 74
                        background: Rectangle {
                            color: "transparent"
                            border.color: "white"
                            border.width: 0.82
                            opacity: 0.8
                            radius: 9.87
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            opacity: 0.8
                            font.family: "Roboto"
                            font.weight: Font.Medium
                            font.pixelSize: 26
                            lineHeight: 1.5
                            font.letterSpacing: 0.52
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: filterPopup.visible = false
                    }
                    Button {
                        text: "Submit"
                        width: 478.89
                        height: 74
                        background: Rectangle {
                            color: "white"
                            radius: 9.87
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "#007D99"
                            opacity: 0.8
                            font.family: "Roboto"
                            font.weight: Font.Medium
                            font.pixelSize: 26
                            lineHeight: 1.5
                            font.letterSpacing: 0.52
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: {
                            var sDayStr = filterPopup.pad(
                                        startDay.currentIndex + 1)
                            var sMonthStr = filterPopup.pad(
                                        startMonth.currentIndex + 1)
                            var sYearStr = startYear.baseYear + startYear.currentIndex

                            var eDayStr = filterPopup.pad(
                                        endDay.currentIndex + 1)
                            var eMonthStr = filterPopup.pad(
                                        endMonth.currentIndex + 1)
                            var eYearStr = endYear.baseYear + endYear.currentIndex

                            // --- CHANGE 3: Used / instead of - for filter string ---
                            filterByDateRange(
                                        sDayStr + "/" + sMonthStr + "/" + sYearStr,
                                        eDayStr + "/" + eMonthStr + "/" + eYearStr)
                            isFiltered = true
                            filterPopup.visible = false
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
    }
}
