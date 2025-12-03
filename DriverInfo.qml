import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: driverInfoWrapper
    width: parent ? parent.width : 2560
    height: parent ? parent.height : 720
    z: 999
    visible: true

    // CLICK OUTSIDE TO CLOSE
    MouseArea {
        anchors.fill: parent
        z: 1
        onClicked: driverInfoWrapper.visible = false
    }

    // POPUP CARD
    Rectangle {
        id: warningwindow
        z: 2
        width: 808
        height: 154
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 120

        color: "#0027889e"
        radius: 20
        border.width: 0

        // Correct property definitions
        property string driverImagePath: "file:///taximeter-config/" + appCore.driverImage
        property string driverName: appCore.driverName
        property string driverIdNNumber: appCore.driverId

        Rectangle {
            id: rectangle
            width: parent.width
            height: parent.height
            color: "#00ffffff"

            Rectangle {
                width: 92
                height: 92
                radius: 46
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 30
                clip: true

                Image {
                    //width: 92
                    //height: 92
                    anchors.centerIn: parent
                    source: warningwindow.driverImagePath   // FIXED
                    fillMode: Image.PreserveAspectFit
                }
            }

            Canvas {
                id: canvas
                anchors.fill: parent
                clip: true
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    ctx.clearRect(0, 0, width, height)

                    ctx.fillStyle = "#007d99"
                    var radius = 20
                    ctx.beginPath()
                    ctx.moveTo(radius, 0)
                    ctx.lineTo(width - radius, 0)
                    ctx.quadraticCurveTo(width, 0, width, radius)
                    ctx.lineTo(width, height - radius)
                    ctx.quadraticCurveTo(width, height, width - radius, height)
                    ctx.lineTo(radius, height)
                    ctx.quadraticCurveTo(0, height, 0, height - radius)
                    ctx.lineTo(0, radius)
                    ctx.quadraticCurveTo(0, 0, radius, 0)
                    ctx.closePath()
                    ctx.fill()

                    var circleX = 50 + 26
                    var circleY = parent.height / 2
                    var circleRadius = 46
                    ctx.globalCompositeOperation = "destination-out"
                    ctx.beginPath()
                    ctx.arc(circleX, circleY, circleRadius, 0, 2 * Math.PI)
                    ctx.fill()
                    ctx.globalCompositeOperation = "source-over"
                }
            }
        }

        Row {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 32 + 26 + 92
            spacing: 26

            Column {
                Text {
                    color: "#ffffff"
                    text: warningwindow.driverName     // FIXED
                    font.pixelSize: 32
                    font.family: "Encode Sans"
                }

                Row {
                    spacing: 5
                    Text {
                        text: "ID:"
                        color: "#8C9BB3"
                        font.pixelSize: 32
                        font.family: "Encode Sans"
                    }
                    Text {
                        text: warningwindow.driverIdNNumber    // FIXED
                        color: "#ffffff"
                        font.pixelSize: 32
                        font.family: "Encode Sans"
                    }
                }
            }
        }
    }
}
