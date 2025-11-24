import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

Item {
    id: root
    width: 850
    height: 720
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.left: parent.left
    property bool capsLock: false
    property string buffer: ""
    signal goClicked(string text)
    signal keyPressed(string text)

    // --- Keyboard Container (Below Text Box) ---
    Rectangle {
        id: keyboardContainer
        width: 850
        height: 720
        anchors.left: parent.left
        color: "transparent"
        z: 1 // Ensure it stays below the test text box

        // --- Rest of your original keyboard layout remains unchanged ---
        Rectangle {
            id: textBox
            width: 850
            height: 60
            anchors.top: parent.top
            anchors.topMargin: 20
            anchors.left: parent.left
            color: "#010217"
            border.color: "#3478F6"
            border.width: 2

            Text {
                id: displayText
                anchors.centerIn: parent
                text: root.buffer
                color: "white"
                font.pixelSize: 36
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                leftPadding: 12
            }
        }

        Rectangle {
            id: keyboardBackground1
            x: 0
            y: textBox.height + 40
            width: lettersLayer.width
            height: parent.height - (textBox.height + 40)
            color: "#010217"
            z: 0
        }

        Rectangle {
            id: keyboardBackground2
            x: 0
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 0
            width: lettersLayer.width
            height: 720
            color: "#010217"
            z: 0
        }

        Item {
            id: lettersLayer
            width: 850
            height: 456.95
            x: 0
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 20
            z: 1

            // --- Your existing keyboard rows and buttons remain exactly the same ---
            // Top row: q w e r t y u i o p
            Repeater {
                model: [{
                        "x": 16.1836,
                        "y": 24.4275,
                        "w": 70.6336,
                        "h": 86.5649,
                        "label": "q"
                    }, {
                        "x": 99.1836,
                        "y": 24.4275,
                        "w": 70.6336,
                        "h": 86.5649,
                        "label": "w"
                    }, {
                        "x": 182.184,
                        "y": 24.4275,
                        "w": 70.6336,
                        "h": 86.5649,
                        "label": "e"
                    }, {
                        "x": 265.184,
                        "y": 24.4275,
                        "w": 70.6336,
                        "h": 86.5649,
                        "label": "r"
                    }, {
                        "x": 348.184,
                        "y": 24.4275,
                        "w": 70.6336,
                        "h": 86.5649,
                        "label": "t"
                    }, {
                        "x": 431.184,
                        "y": 24.4275,
                        "w": 70.6336,
                        "h": 86.5649,
                        "label": "y"
                    }, {
                        "x": 514.184,
                        "y": 24.4275,
                        "w": 70.6336,
                        "h": 86.5649,
                        "label": "u"
                    }, {
                        "x": 597.184,
                        "y": 24.4275,
                        "w": 70.6336,
                        "h": 86.5649,
                        "label": "i"
                    }, {
                        "x": 680.184,
                        "y": 24.4275,
                        "w": 70.6336,
                        "h": 86.5649,
                        "label": "o"
                    }, {
                        "x": 763.184,
                        "y": 24.4275,
                        "w": 70.6336,
                        "h": 86.5649,
                        "label": "p"
                    }]
                delegate: Item {
                    x: modelData.x
                    y: modelData.y
                    width: modelData.w
                    height: modelData.h
                    Rectangle {
                        anchors.fill: parent
                        radius: 9.48092
                        color: Qt.rgba(1, 1, 1, 0.3)
                        border.color: "transparent"
                        Text {
                            anchors.centerIn: parent
                            text: root.capsLock ? modelData.label.toUpperCase(
                                                      ) : modelData.label
                            color: "white"
                            font.pixelSize: 33
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                root.buffer += root.capsLock ? modelData.label.toUpperCase(
                                                                   ) : modelData.label
                                root.keyPressed(modelData.label)
                            }
                        }
                    }
                }
            }

            // --- Home row: a s d f g h j k l ---
            Repeater {
                model: [{
                        "x": 49.1611,
                        "y": 135.725,
                        "w": 72.5276,
                        "h": 86.5649,
                        "label": "a"
                    }, {
                        "x": 134.055,
                        "y": 135.725,
                        "w": 72.5276,
                        "h": 86.5649,
                        "label": "s"
                    }, {
                        "x": 218.948,
                        "y": 135.725,
                        "w": 72.5276,
                        "h": 86.5649,
                        "label": "d"
                    }, {
                        "x": 303.843,
                        "y": 135.725,
                        "w": 72.5276,
                        "h": 86.5649,
                        "label": "f"
                    }, {
                        "x": 388.736,
                        "y": 135.725,
                        "w": 72.5276,
                        "h": 86.5649,
                        "label": "g"
                    }, {
                        "x": 473.631,
                        "y": 135.725,
                        "w": 72.5276,
                        "h": 86.5649,
                        "label": "h"
                    }, {
                        "x": 558.524,
                        "y": 135.725,
                        "w": 72.5276,
                        "h": 86.5649,
                        "label": "j"
                    }, {
                        "x": 643.419,
                        "y": 135.725,
                        "w": 72.5276,
                        "h": 86.5649,
                        "label": "k"
                    }, {
                        "x": 728.312,
                        "y": 135.725,
                        "w": 72.5276,
                        "h": 86.5649,
                        "label": "l"
                    }]
                delegate: Item {
                    x: modelData.x
                    y: modelData.y
                    width: modelData.w
                    height: modelData.h
                    Rectangle {
                        anchors.fill: parent
                        radius: 9.48092
                        color: Qt.rgba(1, 1, 1, 0.3)
                        Text {
                            anchors.centerIn: parent
                            text: root.capsLock ? modelData.label.toUpperCase(
                                                      ) : modelData.label
                            color: "white"
                            font.pixelSize: 33
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                root.buffer += root.capsLock ? modelData.label.toUpperCase(
                                                                   ) : modelData.label
                                root.keyPressed(modelData.label)
                            }
                        }
                    }
                }
            }

            // --- Third row: Shift, z x c v b n m, Backspace ---
            Repeater {
                model: [{
                        "x": 16.1836,
                        "y": 247.023,
                        "w": 86.5649,
                        "h": 86.5649,
                        "label": "⇧",
                        "special": false
                    }, {
                        "x": 131.604,
                        "y": 247.023,
                        "w": 73.2279,
                        "h": 86.5649,
                        "label": "z"
                    }, {
                        "x": 217.198,
                        "y": 247.023,
                        "w": 73.2279,
                        "h": 86.5649,
                        "label": "x"
                    }, {
                        "x": 302.792,
                        "y": 247.023,
                        "w": 73.2279,
                        "h": 86.5649,
                        "label": "c"
                    }, {
                        "x": 388.387,
                        "y": 247.023,
                        "w": 73.2279,
                        "h": 86.5649,
                        "label": "v"
                    }, {
                        "x": 473.98,
                        "y": 247.023,
                        "w": 73.2279,
                        "h": 86.5649,
                        "label": "b"
                    }, {
                        "x": 559.575,
                        "y": 247.023,
                        "w": 73.2279,
                        "h": 86.5649,
                        "label": "n"
                    }, {
                        "x": 645.17,
                        "y": 247.023,
                        "w": 73.2279,
                        "h": 86.5649,
                        "label": "m"
                    }, {
                        "x": 747.252,
                        "y": 247.023,
                        "w": 86.5649,
                        "h": 86.5649,
                        "label": "⌫",
                        "special": false
                    }]
                delegate: Item {
                    x: modelData.x
                    y: modelData.y
                    width: modelData.w
                    height: modelData.h
                    Rectangle {
                        anchors.fill: parent
                        radius: 9.48092
                        color: modelData.label === "⌫" ? Qt.rgba(1, 1, 1,
                                                                 0.1) : Qt.rgba(
                                                             1, 1, 1, 0.3)
                        Text {
                            anchors.centerIn: parent
                            text: (modelData.label === "⇧" ? (root.capsLock ? "⇧" : "⇧") : (root.capsLock ? modelData.label.toUpperCase() : modelData.label))
                            color: "white"
                            font.pixelSize: 33
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (modelData.label === "⇧") {
                                    root.capsLock = !root.capsLock
                                    root.keyPressed("CAPS")
                                } else if (modelData.label === "⌫") {
                                    if (root.buffer.length > 0)
                                        root.buffer = root.buffer.slice(0, -1)
                                    root.keyPressed("BACKSPACE")
                                } else {
                                    root.buffer += root.capsLock ? modelData.label.toUpperCase(
                                                                       ) : modelData.label
                                    root.keyPressed(modelData.label)
                                }
                            }
                        }
                    }
                }
            }

            // --- Bottom row ---
            Rectangle {
                x: 627
                y: 360.382
                width: 65.85
                height: 86.5649
                radius: 9.48092
                color: Qt.rgba(1, 1, 1, 0.2)
                Text {
                    anchors.centerIn: parent
                    text: "."
                    color: "white"
                    font.pixelSize: 33
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        root.buffer += "."
                        root.keyPressed(".")
                    }
                }
            }

            Rectangle {
                id: toggleButton
                x: 16
                y: 360.382
                width: 187
                height: 86
                radius: 9
                color: Qt.rgba(1, 1, 1, 0.1)

                Text {
                    id: toggleText
                    anchors.centerIn: parent
                    text: "123"
                    color: "white"
                    font.pixelSize: 33
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        lettersLayer.visible = false
                        numbersLayer.visible = true
                        toggleText.text = "ABC"
                    }
                }
            }

            Rectangle {
                x: 703.97
                y: 360.382
                width: 129.847
                height: 86.5649
                radius: 9.48092
                color: "#3478F6"
                Text {
                    anchors.centerIn: parent
                    text: "go"
                    color: "white"
                    font.pixelSize: 33
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        root.goClicked(root.buffer)
                        root.keyPressed("ENTER")
                    }
                }
            }

            Rectangle {
                x: 217.198
                y: 360.382
                width: 397.18
                height: 86.56
                radius: 8
                color: Qt.rgba(1, 1, 1, 0.2)
                Text {
                    anchors.centerIn: parent
                    text: "Space"
                    color: "white"
                    font.pixelSize: 33
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        root.buffer += " "
                        root.keyPressed(" ")
                    }
                }
            }
        }

        // --- NUMBERS LAYER ---
        Item {
            id: numbersLayer
            anchors.fill: parent
            visible: false

            // Your existing numbers layer remains exactly the same
            Row {
                spacing: 12
                x: 302.792
                y: 152
                Repeater {
                    model: ["1", "2", "3"]
                    delegate: Rectangle {
                        width: 70
                        height: 86
                        radius: 9
                        color: Qt.rgba(1, 1, 1, 0.3)
                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            color: "white"
                            font.pixelSize: 33
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                root.buffer += modelData
                                root.keyPressed(modelData)
                            }
                        }
                    }
                }
            }

            Row {
                spacing: 12
                x: 302.792
                y: 263
                Repeater {
                    model: ["4", "5", "6"]
                    delegate: Rectangle {
                        width: 70
                        height: 86
                        radius: 9
                        color: Qt.rgba(1, 1, 1, 0.3)
                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            color: "white"
                            font.pixelSize: 33
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                root.buffer += modelData
                                root.keyPressed(modelData)
                            }
                        }
                    }
                }
            }

            Row {
                spacing: 12
                x: 302.792
                y: 375
                Repeater {
                    model: ["7", "8", "9"]
                    delegate: Rectangle {
                        width: 70
                        height: 86
                        radius: 9
                        color: Qt.rgba(1, 1, 1, 0.3)
                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            color: "white"
                            font.pixelSize: 33
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                root.buffer += modelData
                                root.keyPressed(modelData)
                            }
                        }
                    }
                }
            }

            // Bottom row: toggle, 0, backspace
            Rectangle {
                id: toggleButton2
                x: 16
                y: 496.382
                width: 187
                height: 86
                radius: 9
                color: Qt.rgba(1, 1, 1, 0.1)

                Text {
                    anchors.centerIn: parent
                    text: "ABC"
                    color: "white"
                    font.pixelSize: 33
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        lettersLayer.visible = true
                        numbersLayer.visible = false
                        toggleText.text = "123"
                    }
                }
            }

            Rectangle {
                x: 302.792
                y: 496.382
                width: 157
                height: 86
                radius: 8
                color: Qt.rgba(1, 1, 1, 0.2)
                Text {
                    anchors.centerIn: parent
                    text: "0"
                    color: "white"
                    font.pixelSize: 33
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        root.buffer += "0"
                        root.keyPressed("0")
                    }
                }
            }

            Rectangle {
                x: 703
                y: 496.382
                width: 130
                height: 86
                radius: 9
                color: "#3478F6"
                Text {
                    anchors.centerIn: parent
                    text: "go"
                    color: "white"
                    font.pixelSize: 33
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        root.goClicked(root.buffer)
                        root.keyPressed("ENTER")
                    }
                }
            }

            Rectangle {
                x: 471.792
                y: 496.382
                width: 70
                height: 86.5649
                radius: 9.48092
                color: Qt.rgba(1, 1, 1, 0.2)
                Text {
                    anchors.centerIn: parent
                    text: "."
                    color: "white"
                    font.pixelSize: 33
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        root.buffer += "."
                        root.keyPressed(".")
                    }
                }
            }

            Rectangle {
                x: 747.252
                y: 378.023
                width: 86.5649
                height: 86.5649
                radius: 9.48092
                color: Qt.rgba(1, 1, 1, 0.2)
                Text {
                    anchors.centerIn: parent
                    text: "⌫"
                    color: "white"
                    font.pixelSize: 33
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (root.buffer.length > 0)
                            root.buffer = root.buffer.slice(0, -1)
                        root.keyPressed("BACKSPACE")
                    }
                }
            }
        }
    }
}
