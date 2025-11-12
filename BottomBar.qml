import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import QtGraphicalEffects 1.15

Item {
    id: barContainer
    width: 632
    height: 108
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    clip: true
    z: 2

    // --- Window reference passed from main.qml ---
    property Window windowRef

    Rectangle {
        id: bottomBar
        anchors.fill: parent
        color: Qt.rgba(1 / 255, 2 / 255, 25 / 255, 0.6)
        radius: 40
        border.width: 0
        z: 2

        Item {
            id: iconLayer
            anchors.fill: parent
            property int startX: 33
            property int spacingX: 130
            property int topY: 34

            ListModel {
                id: iconModel
                ListElement {
                    normal: "qrc:/images/info.png"
                    hover: "qrc:/images/info_active.png"
                }
                ListElement {
                    normal: "qrc:/images/bill.png"
                    hover: "qrc:/images/bill_active.png"
                }
                ListElement {
                    normal: "qrc:/images/trend.png"
                    hover: "qrc:/images/trend_active.png"
                }
                ListElement {
                    normal: "qrc:/images/radio.png"
                    hover: "qrc:/images/radio_active.png"
                }
                ListElement {
                    normal: "qrc:/images/setting.png"
                    hover: "qrc:/images/setting_active.png"
                }
            }

            Repeater {
                model: iconModel
                delegate: Item {
                    width: 40
                    height: 40
                    x: iconLayer.startX + index * iconLayer.spacingX
                    y: iconLayer.topY

                    Image {
                        id: normal
                        anchors.fill: parent
                        source: model.normal
                        z: 2
                        opacity: 1
                    }
                    Image {
                        id: hover
                        anchors.fill: parent
                        source: model.hover
                        z: 2
                        opacity: 0
                    }

                    Image {
                        id: bg
                        width: 64
                        height: 88
                        x: -10
                        y: -10
                        source: "qrc:/images/blur_rectangle.png"
                        z: 0
                        smooth: true
                        opacity: 0
                        Behavior on opacity {
                            NumberAnimation {
                                duration: 200
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: hoverIcon(true)
                        onExited: hoverIcon(false)
                        onClicked: {
                            console.log("Icon", index + 1, "clicked")

                            // --- Only trigger the 3rd button (index 2) ---
                            if (index === 2 && windowRef) {
                                // Create the popup if it doesn't exist
                                if (!windowRef.totalizerPopup) {
                                    let component = Qt.createComponent(
                                                      "qrc:/Totalizer.qml")
                                    if (component.status === Component.Ready) {
                                        windowRef.totalizerPopup = component.createObject(
                                                    windowRef, {
                                                        "anchors": {
                                                            "fill": windowRef
                                                        },
                                                        "visible": false
                                                    })
                                    } else {
                                        console.error(
                                                    "Failed to load Totalizer.qml")
                                    }
                                }

                                // Toggle visibility
                                if (windowRef.totalizerPopup) {
                                    windowRef.totalizerPopup.visible
                                            = !windowRef.totalizerPopup.visible
                                    if (windowRef.totalizerPopup.visible)
                                        windowRef.totalizerPopup.show()
                                }
                            }
                        }
                    }

                    function hoverIcon(active) {
                        bg.opacity = active ? 1 : 0
                        normal.opacity = active ? 0 : 1
                        hover.opacity = active ? 1 : 0
                    }
                }
            }
        }
    }
}
