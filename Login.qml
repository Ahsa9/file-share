import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root
    width: 2560
    height: 720

    property string username: ""
    property string password: ""
    property string activeField: "username"
    property bool keyboardVisible: false
    signal fieldSelected(string fieldType)
    signal submitClicked(string username, string password)

    Image {
        id: loginbackground
        anchors.fill: parent
        source: "qrc:/images/Splash Screen.png"
        fillMode: Image.PreserveAspectCrop
        z: 0
    }

    // ===== LOGIN BOX =====
    Rectangle {
        id: loginBox
        width: 840
        height: 392
        y: 174
        color: "transparent"
        opacity: 1
        rotation: 0
        property int sectionGap: 32

        // Center login box or shift when keyboard is visible
        x: root.keyboardVisible ? 860 : (parent.width - width) / 2

        // Animate x whenever it changes
        Behavior on x {
            NumberAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }

        // Automatically move when keyboard visibility changes

        // ===== USERNAME SECTION =====
        Rectangle {
            id: usernameBg
            anchors.top: parent.top
            width: parent.width
            height: 115
            color: "#15151D"
            opacity: 0.6

            Rectangle {
                anchors.fill: parent
                color: "transparent"

                Image {
                    anchors.right: parent.right
                    anchors.rightMargin: 30
                    anchors.verticalCenter: parent.verticalCenter
                    width: 54
                    height: 54
                    source: "qrc:/images/group211.png"
                    fillMode: Image.PreserveAspectFit
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.leftMargin: 32
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 100
                    height: 30
                    color: "transparent"

                    Text {
                        id: usernameDisplay
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignLeft
                        text: {
                            if (root.username === "")
                                return (root.keyboardVisible
                                        && root.activeField === "username") ? "" : "USERNAME"
                            else
                                return root.username
                        }
                        color: "white"
                        opacity: root.username === "" ? 0.8 : 1.0
                        font.pixelSize: 27
                        font.bold: root.username === ""
                        clip: true
                    }

                    Rectangle {
                        id: usernameCursor
                        x: usernameDisplay.contentWidth + 8
                        y: 5
                        width: 2
                        height: 20
                        color: "#029BBE"
                        visible: root.activeField === "username"
                                 && root.username !== "" && root.keyboardVisible

                        SequentialAnimation on opacity {
                            running: visible
                            loops: Animation.Infinite
                            NumberAnimation {
                                to: 0
                                duration: 500
                            }
                            NumberAnimation {
                                to: 1
                                duration: 500
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root.activeField = "username"
                            root.fieldSelected("username")
                            root.keyboardVisible = true
                        }
                    }
                }
            }
        }

        // ===== PASSWORD SECTION =====
        Rectangle {
            id: passwordBg
            anchors.top: usernameBg.bottom
            anchors.topMargin: loginBox.sectionGap
            width: parent.width
            height: 115
            color: "#15151D"
            opacity: 0.6

            Rectangle {
                anchors.fill: parent
                color: "transparent"

                Image {
                    anchors.right: parent.right
                    anchors.rightMargin: 30
                    anchors.verticalCenter: parent.verticalCenter
                    width: 54
                    height: 54
                    source: "qrc:/images/group210.png"
                    fillMode: Image.PreserveAspectFit
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.leftMargin: 32
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 100
                    height: 30
                    color: "transparent"

                    Text {
                        id: passwordDisplay
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignLeft
                        text: {
                            if (root.password === "")
                                return (root.keyboardVisible
                                        && root.activeField === "password") ? "" : "PASSWORD"
                            else
                                return "*".repeat(root.password.length)
                        }
                        color: "white"
                        opacity: root.password === "" ? 0.8 : 1.0
                        font.pixelSize: 27
                        font.bold: root.password === ""
                        clip: true
                    }

                    Rectangle {
                        id: passwordCursor
                        x: passwordDisplay.contentWidth + 8
                        y: 5
                        width: 2
                        height: 20
                        color: "#029BBE"
                        visible: root.activeField === "password"
                                 && root.password !== "" && root.keyboardVisible

                        SequentialAnimation on opacity {
                            running: visible
                            loops: Animation.Infinite
                            NumberAnimation {
                                to: 0
                                duration: 500
                            }
                            NumberAnimation {
                                to: 1
                                duration: 500
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root.activeField = "password"
                            root.fieldSelected("password")
                            root.keyboardVisible = true
                        }
                    }
                }
            }
        }

        // ===== SEND BUTTON =====
        Rectangle {
            id: sendButton
            anchors.top: passwordBg.bottom
            anchors.topMargin: loginBox.sectionGap
            width: parent.width
            height: 98
            color: "transparent"
            border.color: "#029BBE"
            border.width: 3

            Text {
                id: sendButtonText // <-- add this
                anchors.centerIn: parent
                text: "SEND"
                color: "white"
                opacity: 0.9
                font.pixelSize: 27
                font.bold: true
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    root.submitClicked(root.username, root.password)
                    root.keyboardVisible = false
                }
                onEntered: sendButtonText.opacity = 1.0
                onExited: sendButtonText.opacity = 0.8
            }
        }
    }

    // ==== FUNCTIONS ====
    function handleKeyInput(key) {
        if (root.activeField === "username") {
            if (key === "BACKSPACE")
                root.username = root.username.slice(0, -1)
            else if (key === "ENTER") {
                root.activeField = "password"
                root.fieldSelected("password")
            } else if (key.length === 1)
                root.username += key
        } else if (root.activeField === "password") {
            if (key === "BACKSPACE")
                root.password = root.password.slice(0, -1)
            else if (key === "ENTER") {
                root.submitClicked(root.username, root.password)
                root.keyboardVisible = false
            } else if (key.length === 1)
                root.password += key
        }
    }

    function setTextFromKeyboard(text) {
        if (root.activeField === "username")
            root.username = text
        else if (root.activeField === "password")
            root.password = text
    }

    function getCurrentText() {
        return root.activeField === "username" ? root.username : root.activeField
                                                 === "password" ? root.password : ""
    }

    function clearFields() {
        username = ""
        password = ""
        activeField = "username"
        keyboardVisible = false
    }

    function setActiveField(fieldType) {
        activeField = fieldType
    }

    function hideKeyboard() {
        keyboardVisible = false
    }
}
