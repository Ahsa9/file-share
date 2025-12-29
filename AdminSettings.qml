import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

Rectangle {
    id: adminRoot
    width: 2560
    height: 720
    color: "white"

    signal requestClose

    // ==========================================================
    // === SUB-PAGES DECLARATION ===
    // ==========================================================

    // 1. AUDIT PAGE
    AuditTrailPage {
        id: auditPage
        anchors.fill: parent
        z: 100
        visible: false
        onClosePage: console.log("Audit page closed")
    }

    // 2. TOTALIZERS PAGE
    TotalizersPage {
        id: totalizersPage
        anchors.fill: parent
        z: 100
        visible: false
        onClosePage: console.log("Totalizers page closed")
    }

    // 3. TARRIF PAGE (NEW ADDITION)
    // Ensure the filename matches (e.g., TarrifPage.qml)
    TarrifPage {
        id: tarrifPage
        anchors.fill: parent
        z: 100
        visible: false
        onClosePage: console.log("Tarrif page closed")
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        preventStealing: true
    }

    TopBar {
        id: headerBar
        anchors.top: parent.top
        width: parent.width
        z: 4
    }

    RowLayout {
        anchors.centerIn: parent
        spacing: 32

        Repeater {
            model: [{
                    "name": "CONFIGURATION",
                    "icon": "qrc:/images/c_Config.png",
                    "w": 154.47,
                    "h": 192.70
                }, {
                    "name": "TARRIF",
                    "icon"// This key matches the logic below
                    : "qrc:/images/c_Tarrif.png",
                    "w": 146.34,
                    "h": 167.57
                }, {
                    "name": "TOTALIZERS",
                    "icon": "qrc:/images/c_Totalizers.png",
                    "w": 119.44,
                    "h": 164.42
                }, {
                    "name": "AUDIT TRAILS",
                    "icon": "qrc:/images/c_Audit Trail.png",
                    "w": 144.71,
                    "h": 163.48
                }]

            delegate: Rectangle {
                width: 582.5
                height: 368
                color: "transparent"
                border.color: "#117BB1"
                border.width: 2
                radius: 24

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 56

                    Image {
                        source: modelData.icon
                        Layout.preferredWidth: modelData.w
                        Layout.preferredHeight: modelData.h
                        Layout.alignment: Qt.AlignHCenter
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        mipmap: true
                    }

                    Text {
                        text: modelData.name
                        color: "#007D99"
                        Layout.alignment: Qt.AlignHCenter
                        font.family: "Roboto Condensed"
                        font.pixelSize: 40
                        font.weight: Font.Bold
                        font.letterSpacing: 0
                        lineHeight: 1.0
                        lineHeightMode: Text.ProportionalHeight
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onPressed: parent.opacity = 0.7
                    onReleased: parent.opacity = 1.0

                    // === UPDATED ONCLICKED LOGIC ===
                    onClicked: {
                        if (modelData.name === "AUDIT TRAILS") {
                            auditPage.show()
                        } else if (modelData.name === "TOTALIZERS") {
                            totalizersPage.show()
                        } else if (modelData.name === "TARRIF") {
                            tarrifPage.show() // Opens the newly created page
                        } else {
                            console.log("Clicked " + modelData.name)
                        }
                    }
                }
            }
        }
    }

    // Bottom Bar (Exit Button)
    Rectangle {
        id: bottomBar
        width: parent.width
        height: 138
        anchors.bottom: parent.bottom
        color: "#007D99"
        opacity: 0.8

        Rectangle {
            width: 582
            height: 90
            anchors.left: parent.left
            anchors.leftMargin: 72
            anchors.top: parent.top
            anchors.topMargin: 24
            color: "transparent"
            border.color: "#FFFFFF"
            border.width: 1
            radius: 12

            Text {
                text: "EXIT"
                anchors.centerIn: parent
                font.pixelSize: 32
                font.bold: true
                color: Qt.rgba(255, 255, 255, 0.8)
            }

            MouseArea {
                anchors.fill: parent
                onClicked: adminRoot.requestClose()
            }
        }
    }
}
