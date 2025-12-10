import QtQuick 2.15
import QtGraphicalEffects 1.15

Item {
    id: bottomBarContainer
    width: 440
    height: 108
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    clip: true

    property QtObject windowRef
    property string activePopup: ""
    property var driverInfoPopup: null

    property bool logoutLocked: false

    Timer {
        id: logoutCooldown
        interval: 3000
        repeat: false
        onTriggered: logoutLocked = false
    }

    function setPopupState(popupName, isOpen) {
        if (isOpen)
            activePopup = popupName
        else if (activePopup === popupName)
            activePopup = ""
        updateIconStates()
    }

    function updateIconStates() {
        for (var i = 0; i < iconRow.children.length; i++) {
            var loader = iconRow.children[i]
            if (loader && loader.item)
                loader.item.updateState()
        }
    }

    Rectangle {
        id: bottomBar
        width: parent.width
        height: parent.height + radius
        y: 0
        radius: 40
        color: Qt.rgba(0, 0.49, 0.60, 0.68)

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: radius
            color: parent.color
        }
    }

    Row {
        id: iconRow
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 21
        anchors.right: parent.right
        anchors.rightMargin: 32
        z: 3

        // Auto spacing for FOUR icons
        spacing: (bottomBarContainer.width - anchors.leftMargin
                  - anchors.rightMargin - (4 * 64)) / 3

        Component {
            id: hoverIcon

            Item {
                width: 64
                height: 64
                anchors.verticalCenter: parent.verticalCenter

                property alias normalSource: normal.source
                property alias activeSource: active.source
                property string popupName: ""
                property bool isHovered: false
                property bool isActive: false
                signal clicked

                function updateState() {
                    if (activePopup === "") {
                        if (isHovered) {
                            normal.visible = true
                            active.visible = false
                            hoverShade.opacity = 1.0
                            isActive = true
                        } else {
                            var anyHovered = false
                            for (var i = 0; i < iconRow.children.length; i++) {
                                var loader = iconRow.children[i]
                                if (loader && loader.item && loader !== parent
                                        && loader.item.isHovered) {
                                    anyHovered = true
                                    break
                                }
                            }

                            if (anyHovered) {
                                normal.visible = false
                                active.visible = true
                                hoverShade.opacity = 0.0
                                isActive = true
                            } else {
                                normal.visible = true
                                active.visible = false
                                hoverShade.opacity = 0.0
                                isActive = false
                            }
                        }
                    } else {
                        if (activePopup === popupName) {
                            normal.visible = true
                            active.visible = false
                            hoverShade.opacity = 1.0
                            isActive = false
                        } else {
                            normal.visible = false
                            active.visible = true
                            hoverShade.opacity = 0.0
                            isActive = true
                        }
                    }
                }

                Image {
                    id: hoverShade
                    source: "qrc:/images/hovor_shade.png"
                    anchors.centerIn: parent
                    width: 80
                    height: 80
                    opacity: 0.0
                    smooth: true
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 150
                            easing.type: Easing.InOutQuad
                        }
                    }
                }

                Image {
                    id: normal
                    anchors.centerIn: parent
                    width: 44
                    height: 44
                    smooth: true
                }

                Image {
                    id: active
                    anchors.centerIn: parent
                    width: 44
                    height: 44
                    smooth: true
                }

                MouseArea {
                    id: area
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        isHovered = true
                        updateState()
                        bottomBarContainer.updateIconStates()
                    }
                    onExited: {
                        isHovered = false
                        updateState()
                        bottomBarContainer.updateIconStates()
                    }
                    onClicked: parent.clicked()
                }

                Component.onCompleted: updateState()
            }
        }

        // --- NEW ICON 3: DRIVER INFO ---
        Loader {
            id: driverInfoIcon
            sourceComponent: hoverIcon
            onLoaded: {
                item.normalSource = "qrc:/images/driver_info.png"
                item.activeSource = "qrc:/images/driver_info_active(light).png"
                item.popupName = "driver_info"

                item.clicked.connect(function () {
                    console.log("Driver Info clicked")

                    if (!windowRef) {
                        console.log("Driver Info: windowRef is null")
                        return
                    }

                    // Create popup instance if not created yet
                    if (!windowRef.driverInfoPopup) {
                        var component = Qt.createComponent(
                                    "qrc:/components/DriverInfo.qml")
                        if (component.status === Component.Ready) {
                            windowRef.driverInfoPopup = component.createObject(
                                        windowRef)
                            if (!windowRef.driverInfoPopup) {
                                console.log("Driver Info: createObject FAILED")
                                return
                            }

                            windowRef.driverInfoPopup.visible = false
                            windowRef.driverInfoPopup.z = 200

                            // Sync bottom bar highlight state with popup visibility
                            windowRef.driverInfoPopup.visibleChanged.connect(
                                        function () {
                                            bottomBarContainer.setPopupState(
                                                        "driver_info",
                                                        windowRef.driverInfoPopup.visible)
                                        })
                        } else {
                            console.log("Driver Info: component error →",
                                        component.errorString())
                            return
                        }
                    }

                    // Toggle popup
                    windowRef.driverInfoPopup.visible = !windowRef.driverInfoPopup.visible
                    bottomBarContainer.setPopupState(
                                "driver_info",
                                windowRef.driverInfoPopup.visible)
                })
            }
        }

        // BILL ---
        // BILL / HISTORY ICON
        Loader {
            id: billIcon
            sourceComponent: hoverIcon
            onLoaded: {
                item.normalSource = "qrc:/images/bill.png"
                item.activeSource = "qrc:/images/bill_active(light).png"
                item.popupName = "bill"

                item.clicked.connect(function () {
                    console.log("Bill/History Icon Clicked")

                    // 1. Create the popup if it doesn't exist
                    if (!windowRef.historyPopup) {
                        console.log("Attempting to load: qrc:/components/HistoryPopup.qml")

                        var component = Qt.createComponent(
                                    "qrc:/components/HistoryPopup.qml")

                        if (component.status === Component.Ready) {
                            windowRef.historyPopup = component.createObject(
                                        windowRef)

                            if (windowRef.historyPopup) {
                                windowRef.historyPopup.visible = false
                                windowRef.historyPopup.z = 100

                                // Connect visibility change to icon state
                                windowRef.historyPopup.visibleChanged.connect(
                                            function () {
                                                bottomBarContainer.setPopupState(
                                                            "bill",
                                                            windowRef.historyPopup.visible)
                                            })
                                console.log("History Popup created successfully")
                            } else {
                                console.error(
                                            "Error: Component Ready, but createObject returned null.")
                            }
                        } else {
                            // === THIS IS THE IMPORTANT PART ===
                            // If the popup fails to open, this will tell you WHY.
                            console.error("Error loading HistoryPopup.qml:",
                                          component.errorString())
                        }
                    }

                    // 2. Toggle Visibility
                    if (windowRef.historyPopup) {
                        if (windowRef.historyPopup.visible) {
                            windowRef.historyPopup.hide()
                            bottomBarContainer.setPopupState("bill", false)
                        } else {
                            windowRef.historyPopup.show()
                            bottomBarContainer.setPopupState("bill", true)
                        }
                    }
                })
            }
        }
        //TREND / TOTALIZER ---
        Loader {
            id: trendIcon
            sourceComponent: hoverIcon
            onLoaded: {
                item.normalSource = "qrc:/images/trend.png"
                item.activeSource = "qrc:/images/trend_active(light).png"
                item.popupName = "trend"

                item.clicked.connect(function () {
                    console.log("trend clicked")

                    if (!windowRef.totalizerPopup) {
                        var component = Qt.createComponent(
                                    "qrc:/components/Totalizers.qml")
                        if (component.status === Component.Ready) {
                            windowRef.totalizerPopup = component.createObject(
                                        windowRef)
                            windowRef.totalizerPopup.visible = false
                            windowRef.totalizerPopup.z = 100

                            windowRef.totalizerPopup.visibleChanged.connect(
                                        function () {
                                            bottomBarContainer.setPopupState(
                                                        "trend",
                                                        windowRef.totalizerPopup.visible)
                                        })
                        }
                    }

                    if (windowRef.totalizerPopup) {
                        if (windowRef.totalizerPopup.visible) {
                            windowRef.totalizerPopup.hide()
                            bottomBarContainer.setPopupState("trend", false)
                        } else {
                            windowRef.totalizerPopup.show()
                            bottomBarContainer.setPopupState("trend", true)
                        }
                    }
                })
            }
        }

        // INFO ---
        Loader {
            id: infoIcon
            sourceComponent: hoverIcon
            onLoaded: {
                item.normalSource = "qrc:/images/info.png"
                item.activeSource = "qrc:/images/info_active(light).png"
                item.popupName = "info"

                item.clicked.connect(function () {
                    console.log("info clicked")

                    if (!windowRef.infoPopup) {
                        var component = Qt.createComponent(
                                    "qrc:/components/Info.qml")
                        if (component.status === Component.Ready) {
                            windowRef.infoPopup = component.createObject(
                                        windowRef)
                            windowRef.infoPopup.visible = false
                            windowRef.infoPopup.z = 100

                            windowRef.infoPopup.visibleChanged.connect(
                                        function () {
                                            bottomBarContainer.setPopupState(
                                                        "info",
                                                        windowRef.infoPopup.visible)
                                        })
                        }
                    }

                    if (windowRef.infoPopup) {
                        if (windowRef.infoPopup.visible) {
                            windowRef.infoPopup.hide()
                            bottomBarContainer.setPopupState("info", false)
                        } else {
                            windowRef.infoPopup.show()
                            bottomBarContainer.setPopupState("info", true)
                        }
                    }
                })
            }
        }
    }
}
