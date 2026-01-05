import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    width: parent ? parent.width : 2560
    height: parent ? parent.height : 720
    visible: false
    opacity: 0

    // === PROPERTIES ===
    property bool isFiltered: false
    property int startDayIndex: 0
    property int startMonthIndex: 0
    property int startYearIndex: 0
    property int endDayIndex: 0
    property int endMonthIndex: 0
    property int endYearIndex: 0
    property int baseYear: 2020

    // === AUTOCLOSE LOGIC ===
    property real progressValue: 0
    property bool progressActive: false
    property bool progressFinished: false
    property real speedValue: 0

    Timer {
        id: speedCloseTimer
        interval: 10000
        onTriggered: root.hide()
    }

    Timer {
        id: autoCloseTimer
        interval: 100
        repeat: true
        onTriggered: {
            if (!progressActive)
                return
            progressValue += 0.01
            if (progressValue >= 1.0) {
                progressActive = false
                progressFinished = true
                stop()
                if (Number(appCore.speed) > 0)
                    speedCloseTimer.start()
            }
        }
    }

    Connections {
        target: appCore
        function onSpeedChanged() {
            if (!visible || !progressFinished)
                return
            var v = Number(appCore.speed)
            if (v > 0) {
                if (!speedCloseTimer.running)
                    speedCloseTimer.start()
            } else {
                speedCloseTimer.stop()
            }
        }
    }

    // === INTERFACE FUNCTIONS ===
    function refreshData() {
        if (typeof auditModel !== "undefined")
            auditModel.refresh()
    }

    function filterByDateRange(s, e) {
        if (typeof auditModel !== "undefined") {
            auditModel.applyFilter(s, e)
            tableList.contentY = 0
            isFiltered = true
        }
    }

    function pad(n) {
        return n < 10 ? "0" + n : n
    }

    onVisibleChanged: {
        if (visible) {
            refreshData()
            progressValue = 0
            progressActive = true
            progressFinished = false
            autoCloseTimer.start()
        } else {
            progressActive = false
            autoCloseTimer.stop()
            speedCloseTimer.stop()
        }
    }

    function show() {
        visible = true
        opacity = 1
    }

    function hide() {
        opacity = 0
        hideTimer.start()
    }

    Timer {
        id: hideTimer
        interval: 400
        repeat: false
        onTriggered: {
            root.visible = false
            filterPopup.visible = false
            detailsPopup.visible = false
            tableList.contentY = 0
            startDayIndex = 0
            startMonthIndex = 0
            startYearIndex = 0
            endDayIndex = 0
            endMonthIndex = 0
            endYearIndex = 0

            if (isFiltered && typeof auditModel !== "undefined") {
                auditModel.clearFilter()
                isFiltered = false
            }
        }
    }

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

    // === REUSABLE: 3-VALUE SELECTION WHEEL ===
    Rectangle {
        id: bigSlotPopup
        anchors.fill: parent
        color: "#AA000000"
        z: 1000
        visible: false
        opacity: visible ? 1 : 0
        property var currentModel: []
        property var updateCallback: null

        Behavior on opacity {
            NumberAnimation {
                duration: 200
            }
        }

        function open(dataModel, initialIndex, callback) {
            currentModel = dataModel
            bigTumbler.currentIndex = initialIndex
            updateCallback = callback
            visible = true
        }
        function close() {
            visible = false
        }

        MouseArea {
            anchors.fill: parent
            onClicked: bigSlotPopup.close()
        }

        Rectangle {
            width: 320
            height: 480
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
                Tumbler {
                    id: bigTumbler
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: bigSlotPopup.currentModel
                    visibleItemCount: 3
                    clip: true
                    delegate: Text {
                        text: (typeof modelData
                               === "number") ? (modelData > 100 ? modelData : root.pad(
                                                                      modelData + 1)) : modelData
                        color: "white"
                        font.family: "Roboto Condensed"
                        font.styleName: "Bold"
                        font.pixelSize: 55
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        scale: 1.0 - Math.abs(Tumbler.displacement) * 0.4
                        opacity: 1.0 - Math.abs(Tumbler.displacement) * 0.5
                    }
                }
                Button {
                    text: "OK"
                    font.family: "Roboto"
                    font.styleName: "Medium"
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 60
                    Layout.alignment: Qt.AlignHCenter
                    background: Rectangle {
                        color: parent.down ? "white" : "transparent"
                        border.color: "white"
                        radius: 10
                    }
                    contentItem: Text {
                        text: "OK"
                        color: parent.down ? "#007D99" : "white"
                        font.family: "Roboto"
                        font.styleName: "Medium"
                        font.pixelSize: 28
                        horizontalAlignment: Text.AlignHCenter
                    }
                    onClicked: {
                        if (typeof bigSlotPopup.updateCallback === "function") {
                            bigSlotPopup.updateCallback(bigTumbler.currentIndex)
                        }
                        bigSlotPopup.close()
                    }
                }
            }
        }
    }

    // === CONFIG DETAILS POPUP (JSON VIEWER) ===
    Rectangle {
        id: detailsPopup
        anchors.fill: parent
        color: "#AA000000"
        visible: false
        z: 600
        property string detailContent: ""
        function open(content) {
            detailContent = content
            visible = true
        }

        Rectangle {
            id: detailsInnerBox
            width: 1859
            height: 550
            radius: 40
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -45
            color: Qt.rgba(0, 0.49, 0.60, 0.8)
            border.color: "white"
            border.width: 1
            clip: true

            MouseArea {
                anchors.fill: parent
            }

            Item {
                id: detailsHeaderArea
                width: parent.width - 80
                height: 60
                anchors.top: parent.top
                anchors.topMargin: 40
                anchors.horizontalCenter: parent.horizontalCenter
                Row {
                    spacing: 20
                    anchors.left: parent.left
                    Image {
                        width: 50
                        height: 50
                        source: "qrc:/images/audit_trail.png"
                        fillMode: Image.PreserveAspectFit
                    }
                    Text {
                        text: "AUDIT TRAIL"
                        font.family: "Roboto"
                        font.styleName: "Regular"
                        font.pixelSize: 40
                        color: "white"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                Button {
                    id: closeBtn
                    text: "CLOSE"
                    width: 200
                    height: 55
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    background: Rectangle {
                        color: closeBtn.down ? "white" : "transparent"
                        border.color: "white"
                        border.width: 2
                        radius: 12
                    }
                    contentItem: Text {
                        text: closeBtn.text
                        color: closeBtn.down ? "#007D99" : "white"
                        font.family: "Roboto"
                        font.styleName: "Regular"
                        font.pixelSize: 28
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: detailsPopup.visible = false
                }
            }

            Rectangle {
                id: detailsLine
                width: parent.width - 80
                height: 2
                color: "white"
                anchors.top: detailsHeaderArea.bottom
                anchors.topMargin: 20
                anchors.horizontalCenter: parent.horizontalCenter
            }

            ScrollView {
                id: detailsScroll
                anchors.top: detailsLine.bottom
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottomMargin: 20
                clip: true

                ScrollBar.vertical: ScrollBar {
                    id: vBar
                    parent: detailsScroll
                    x: detailsScroll.width - width - 10
                    active: vBar.active || vBar.pressed
                    contentItem: Rectangle {
                        implicitWidth: 6
                        radius: 3
                        color: "white"
                        opacity: vBar.active ? 0.5 : 0.0
                        Behavior on opacity {
                            NumberAnimation {
                                duration: 200
                            }
                        }
                    }
                }
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                TextArea {
                    text: detailsPopup.detailContent
                    color: "white"
                    font.family: "Roboto"
                    font.styleName: "Regular"
                    font.pixelSize: 30
                    readOnly: true
                    wrapMode: Text.WordWrap
                    leftPadding: 40
                    rightPadding: 40
                    topPadding: 15
                    bottomPadding: 15
                    background: null
                }
            }
        }
    }

    // === MAIN POPUP BOX ===
    Rectangle {
        id: popupRect
        width: 1859
        height: 550
        radius: 40
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -45
        color: Qt.rgba(0, 0.49, 0.60, 0.8)
        border.color: "white"
        border.width: 1
        MouseArea {
            anchors.fill: parent
        }

        Column {
            anchors.fill: parent
            anchors.margins: 40
            spacing: 20
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
                    font.family: "Roboto"
                    font.styleName: "Regular"
                    font.pixelSize: 40
                    color: "white"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Rectangle {
                width: parent.width - 40
                height: 50
                color: "transparent"
                Row {
                    anchors.fill: parent
                    component HeaderText: Text {
                        font.family: "Roboto"
                        font.styleName: "Medium" // Maps to Weight 500
                        font.pixelSize: 40
                        lineHeight: 1.0 // Maps to 100%
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        height: parent.height
                        // leading-trim is not a standard QML property,
                        // but lineHeight 1.0 covers the 100% requirement.
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
                                font.styleName: "Medium"
                                font.pixelSize: 40
                                color: "white"
                            }
                            Image {
                                source: "qrc:/images/filter_icon.png"
                                width: 40
                                height: 40
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
                        width: parent.width * 0.3
                    }
                }
                Rectangle {
                    width: parent.width
                    height: 2
                    color: "white"
                    anchors.bottom: parent.bottom
                }
            }

            ListView {
                id: tableList
                width: parent.width - 40
                height: parent.height - 150
                clip: true
                model: auditModel
                delegate: Rectangle {
                    width: tableList.width
                    height: 62
                    color: index % 2 === 0 ? "#10FFFFFF" : "transparent"
                    Row {
                        anchors.fill: parent
                        component CellText: Text {
                            font.family: "Roboto"
                            font.styleName: "Medium"
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
                        Item {
                            width: parent.width * 0.3
                            height: parent.height
                            Button {
                                text: "Show Config"
                                anchors.centerIn: parent
                                width: parent.width * 0.8
                                height: 45
                                background: Rectangle {
                                    color: parent.down ? "white" : "transparent"
                                    border.color: "white"
                                    radius: 10
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: parent.down ? "#007D99" : "white"
                                    font.family: "Roboto"
                                    font.styleName: "medium"
                                    font.pixelSize: 22
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onClicked: detailsPopup.open(model.changes)
                            }
                        }
                    }
                }
            }
        }

        DateFilter {
            id: filterPopup
            visible: false
            anchors.centerIn: parent
            onCancelClicked: filterPopup.visible = false
            onSubmitClicked: function (start, end) {
                filterByDateRange(start, end)
                filterPopup.visible = false
            }
        }
    }
}
