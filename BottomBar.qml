import QtQuick 2.15
import QtGraphicalEffects 1.15

Item {
    id: bottomBarContainer
    width: 372
    height: 108
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    clip: true

    property QtObject windowRef
    // Needed for totalizer popup reference

    // Property to track which popup is currently open
    property string activePopup: ""

    // Function to handle popup state changes
    function setPopupState(popupName, isOpen) {
        if (isOpen) {
            activePopup = popupName
        } else if (activePopup === popupName) {
            activePopup = ""
        }
        updateIconStates()
    }

    // Function to update all icon states
    function updateIconStates() {
        for (var i = 0; i < iconRow.children.length; i++) {
            var loader = iconRow.children[i]
            if (loader && loader.item) {
                loader.item.updateState()
            }
        }
    }

    // === Draw a top-curved, bottom-flat bar ===
    Rectangle {
        id: bottomBar
        width: parent.width
        height: parent.height + radius
        y: 0
        radius: 40
        color: Qt.rgba(0, 0.49, 0.60, 0.68)
        border.width: 0
        layer.enabled: true

        // Mask the lower curve so only the top remains curved
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: radius
            color: parent.color
            radius: 0
        }
    }

    // === ICON ROW ===
    Row {
        id: iconRow
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 21
        anchors.right: parent.right
        anchors.rightMargin: 32
        z: 3
        spacing: 69

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
                        // No popup open - normal hover behavior
                        if (isHovered) {
                            // This icon is hovered - show normal+shade
                            normal.visible = true
                            active.visible = false
                            hoverShade.opacity = 1.0
                            isActive = true
                        } else {
                            // Check if any other icon is hovered
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
                                // Another icon is hovered - show active image
                                normal.visible = false
                                active.visible = true
                                hoverShade.opacity = 0.0
                                isActive = true
                            } else {
                                // No hover anywhere - show normal state
                                normal.visible = true
                                active.visible = false
                                hoverShade.opacity = 0.0
                                isActive = false
                            }
                        }
                    } else {
                        // Popup open - special behavior
                        if (activePopup === popupName) {
                            // This is the icon that opened the popup
                            // Show normal image with shade (always)
                            normal.visible = true
                            active.visible = false
                            hoverShade.opacity = 1.0
                            isActive = false
                        } else {
                            // Other icons show active image with no shade
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
                    z: 0
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
                    z: 1
                }

                Image {
                    id: active
                    anchors.centerIn: parent
                    width: 44
                    height: 44
                    smooth: true
                    z: 2
                }

                MouseArea {
                    id: area
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        isHovered = true
                        updateState()
                        // Update all other icons too
                        bottomBarContainer.updateIconStates()
                    }
                    onExited: {
                        isHovered = false
                        updateState()
                        // Update all other icons too
                        bottomBarContainer.updateIconStates()
                    }
                    onClicked: {
                        parent.clicked()
                    }
                }

                Component.onCompleted: {
                    updateState()
                }
            }
        }

        Loader {
            id: infoIcon
            sourceComponent: hoverIcon
            onLoaded: {
                item.normalSource = "qrc:/images/info.png"
                item.activeSource = "qrc:/images/info_active(light).png"
                item.popupName = "info"

                item.clicked.connect(function () {
                    console.log("Info icon clicked")
                    // Add your info popup logic here
                })
            }
        }

        Loader {
            id: billIcon
            sourceComponent: hoverIcon
            onLoaded: {
                item.normalSource = "qrc:/images/bill.png"
                item.activeSource = "qrc:/images/bill_active(light).png"
                item.popupName = "bill"

                item.clicked.connect(function () {
                    console.log("Bill icon clicked")
                    // Add your bill popup logic here
                })
            }
        }

        Loader {
            id: trendIcon
            sourceComponent: hoverIcon
            onLoaded: {
                item.normalSource = "qrc:/images/trend.png"
                item.activeSource = "qrc:/images/trend_active(light).png"
                item.popupName = "trend"

                item.clicked.connect(function () {
                    console.log("Trend icon clicked")

                    // Create the popup if it doesn't exist
                    if (!windowRef.totalizerPopup) {
                        console.log("Creating totalizer popup...")
                        var component = Qt.createComponent(
                                    "qrc:/components/Totalizers.qml")
                        if (component.status === Component.Ready) {
                            windowRef.totalizerPopup = component.createObject(
                                        windowRef)
                            if (windowRef.totalizerPopup) {
                                console.log("Totalizer popup created successfully")
                                windowRef.totalizerPopup.visible = false
                                windowRef.totalizerPopup.z = 100 // Ensure it's on top

                                // Connect to the popup's visibility changes
                                windowRef.totalizerPopup.visibleChanged.connect(
                                            function () {
                                                bottomBarContainer.setPopupState(
                                                            "trend",
                                                            windowRef.totalizerPopup.visible)
                                            })
                            } else {
                                console.error(
                                            "Failed to create totalizer popup object")
                            }
                        } else {
                            console.error("Error loading Totalizers.qml:",
                                          component.errorString())
                        }
                    }

                    // Toggle visibility
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
    }
}
