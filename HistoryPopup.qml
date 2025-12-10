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

    // === C++ INTERFACE ===
    function refreshData() {
        if (typeof auditModel !== "undefined") {
            auditModel.refresh()
        }
    }

    function filterByDateRange(startDateStr, endDateStr) {
        if (typeof auditModel !== "undefined") {
            auditModel.applyFilter(startDateStr, endDateStr)
            tableList.contentY = 0
            isFiltered = true
        }
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

    // === MAIN BOX ===
    Rectangle {
        id: popupRect
        width: 1859
        height: 550
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height
        radius: 40
        color: Qt.rgba(0, 0.49, 0.60, 0.8) // Adjusted to match your theme
        border.color: "#FFFFFF"
        border.width: 1

        Behavior on y {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutCubic
            }
        }

        // === SCROLLBAR ===
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
                // Math fix: ensure logic handles empty lists safely
                height: {
                    var contentH = tableList.manualContentHeight
                    var viewH = tableList.height
                    if (contentH <= viewH || contentH === 0)
                        return parent.height - 4
                    var ratio = viewH / contentH
                    return Math.max(30, parent.height * ratio)
                }
                Connections {
                    target: tableList
                    function onContentYChanged() {
                        if (!dragArea.drag.active) {
                            var listRange = tableList.manualContentHeight - tableList.height
                            var trackRange = sideBar.height - scrollHandle.height
                            if (listRange > 0) {
                                var calcY = (tableList.contentY / listRange) * trackRange
                                scrollHandle.y = Math.max(0,
                                                          Math.min(trackRange,
                                                                   calcY))
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
                                tableList.contentY = (scrollHandle.y / trackAvailable)
                                        * listAvailable
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
                    font.family: "EncodeSans"
                    font.pixelSize: 40
                    color: "white"
                    font.weight: Font.Medium
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Columns
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
                            // Filter Icon
                            Rectangle {
                                width: 30
                                height: 30
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

                model: auditModel // Links to C++

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

                        // Roles from AuditModel.cpp
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
                    font.bold: true
                    font.pixelSize: 50
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
                    text: (typeof modelData === "number") ? filterPopup.pad(
                                                                modelData + 1) : modelData
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
                    Layout.preferredWidth: filterPopup.width
                    Layout.preferredHeight: 47
                    Rectangle {
                        id: vSep
                        width: 2
                        height: 47
                        color: Qt.rgba(1, 1, 1, 0.2)
                        visible: false
                        anchors.centerIn: parent
                    }

                    // Start Date
                    RowLayout {
                        spacing: 25
                        anchors.right: vSep.left
                        anchors.rightMargin: 30
                        anchors.verticalCenter: vSep.verticalCenter
                        Text {
                            text: "From"
                            color: "#0FE6EF"
                            font.family: "Roboto"
                            font.pixelSize: 40
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
                                    snapMode: ListView.SnapToItem
                                    clip: true
                                    delegate: Text {
                                        text: startYear.baseYear + index
                                        color: "white"
                                        font.bold: true
                                        font.pixelSize: 32
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        // FIXED SYNTAX HERE:
                                        height: startYear.availableHeight
                                                / startYear.visibleItemCount
                                    }
                                }
                            }
                        }
                    }

                    // End Date
                    RowLayout {
                        spacing: 25
                        anchors.left: vSep.right
                        anchors.leftMargin: 30
                        anchors.verticalCenter: vSep.verticalCenter
                        Text {
                            text: "To"
                            color: "#0FE6EF"
                            font.family: "Roboto"
                            font.pixelSize: 40
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
                                    snapMode: ListView.SnapToItem
                                    clip: true
                                    delegate: Text {
                                        text: endYear.baseYear + index
                                        color: "white"
                                        font.bold: true
                                        font.pixelSize: 32
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        // FIXED SYNTAX HERE:
                                        height: endYear.availableHeight / endYear.visibleItemCount
                                    }
                                }
                            }
                        }
                    }
                }

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
                            var sD = filterPopup.pad(startDay.currentIndex + 1)
                            var sM = filterPopup.pad(
                                        startMonth.currentIndex + 1)
                            var sY = startYear.baseYear + startYear.currentIndex
                            var eD = filterPopup.pad(endDay.currentIndex + 1)
                            var eM = filterPopup.pad(endMonth.currentIndex + 1)
                            var eY = endYear.baseYear + endYear.currentIndex
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
