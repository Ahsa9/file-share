import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: driverInfoWrapper
    width: parent ? parent.width : 2560
    height: parent ? parent.height : 720
    z: 999

    // Set the initial visible state to false so the subsequent change triggers the fade-in.
    visible: false

    // --- INITIALIZATION FIX ---
    Component.onCompleted: {
        // Immediately set visible to true when the component is ready.
        // This triggers the 'onVisibleChanged' handler and the 'Behavior' for a smooth fade-in.
        driverInfoWrapper.visible = true
    }
    // --------------------------

    // The key change: We use a separate property (actualOpacity) for the animation,
    // and bind the item's opacity to it. We control 'visible' manually.
    property real actualOpacity: visible ? 1 : 0
    opacity: actualOpacity

    // --- FADE-OUT ANIMATION ---
    PropertyAnimation {
        id: fadeOutAnimation
        target: driverInfoWrapper
        property: "actualOpacity"
        to: 0
        duration: 400
        easing.type: Easing.InCubic

        // After the fade is complete, set visible to false to truly hide the Item
        onStopped: {
            if (driverInfoWrapper.actualOpacity === 0) {
                driverInfoWrapper.visible = false
            }
        }
    }

    // --- FADE-IN ANIMATION (uses Behavior) ---
    // The fade-in will still use the Behavior for convenience when 'visible' changes to true
    // This is because when 'visible' is set to true, 'actualOpacity' becomes 1, and the behavior catches it.
    Behavior on actualOpacity {
        NumberAnimation {
            duration: 400
            easing.type: Easing.InCubic
        }
    }

    // Function to initiate the animated closing
    function closeDriverInfo() {
        if (driverInfoWrapper.visible && fadeOutAnimation.running === false) {
            // Start fade-out animation by setting the target opacity
            fadeOutAnimation.start()
        }
    }

    // === AUTOCLOSE LOGIC ===
    property real progressValue: 0 // 0 → 1
    property bool progressActive: false
    property real speedValue: 0 // from appCore.speed
    property bool progressFinished: false

    onVisibleChanged: {
        if (visible) {
            // Fade-in is achieved immediately by the opacity: actualOpacity binding
            progressValue = 0
            progressActive = true
            progressFinished = false
            progressTimer.start()

            // read initial speed
            speedValue = Number(appCore.speed)
        } else {
            // Note: visible: false is only set AFTER the fade-out animation completes (see onStopped above)
            progressActive = false
            progressTimer.stop()
        }
    }

    Connections {
        target: appCore

        function onSpeedChanged() {
            if (!driverInfoWrapper.visible)
                return

            // only auto-hide after progress completed
            if (!driverInfoWrapper.progressFinished)
                return

            var v = Number(appCore.speed)
            driverInfoWrapper.speedValue = v // for debug if you like

            if (v > 0) {
                console.log("Auto-hide driver info (speed became > 0 after progress finished)")
                // MODIFIED: Call the closing function for animated fade-out
                driverInfoWrapper.closeDriverInfo()
            }
        }
    }

    Timer {
        id: progressTimer
        // Keeps the original 10-second total duration (100 intervals * 100ms)
        interval: 100 // update every 100ms
        repeat: true

        onTriggered: {
            if (!driverInfoWrapper.progressActive)
                return

            // increase progress (10s total => 0.01 every 100ms)
            driverInfoWrapper.progressValue += 0.01

            // clamp
            if (driverInfoWrapper.progressValue > 1.0)
                driverInfoWrapper.progressValue = 1.0

            // update canvas
            holdProgress.progress = driverInfoWrapper.progressValue
            holdProgress.requestPaint()

            if (driverInfoWrapper.progressValue >= 1.0) {
                driverInfoWrapper.progressActive = false
                driverInfoWrapper.progressFinished = true
                progressTimer.stop()

                // first immediate check
                driverInfoWrapper.speedValue = Number(appCore.speed)
                if (driverInfoWrapper.speedValue > 0) {
                    console.log("Auto-hide driver info (speed > 0 & progress 100%)")
                    // MODIFIED: Call the closing function for animated fade-out
                    driverInfoWrapper.closeDriverInfo()
                }
            }
        }
    }

    // --- LOGOUT COOLDOWN (local to this popup) ---
    property bool logoutLocked: false

    Timer {
        id: logoutCooldown
        interval: 3000 // 3 seconds
        repeat: false
        onTriggered: driverInfoWrapper.logoutLocked = false
    }

    // CLICK OUTSIDE TO CLOSE
    MouseArea {
        anchors.fill: parent
        z: 1
        // MODIFIED: Call the closing function for animated fade-out
        onClicked: driverInfoWrapper.closeDriverInfo()
    }

    // POPUP CARD
    Rectangle {
        id: warningwindow
        z: 2
        width: 808
        height: 154
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 430

        MouseArea {
            anchors.fill: parent
        }

        color: "#0027889e"
        radius: 20
        border.width: 0

        // Properties
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
                    anchors.centerIn: parent
                    source: warningwindow.driverImagePath
                    width: parent.width
                    height: parent.height
                    fillMode: Image.PreserveAspectCrop
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

        // -----------------------------
        // DRIVER NAME + ID
        // -----------------------------
        Row {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 32 + 26 + 92
            spacing: 26

            Item {
                width: 260
                height: parent.height

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 6

                    Text {
                        id: driverNameText
                        color: "#ffffff"
                        text: warningwindow.driverName
                        font.pixelSize: 32
                        font.family: "Encode Sans"
                        font.weight: Font.DemiBold
                    }

                    Item {
                        width: parent.width
                        height: driverNameText.height

                        Row {
                            spacing: 5

                            Text {
                                text: "ID:"
                                color: "#8C9BB3"
                                font.pixelSize: 28
                                font.family: "Encode Sans"
                            }

                            Text {
                                text: warningwindow.driverIdNNumber
                                color: "#ffffff"
                                font.pixelSize: 28
                                font.family: "Encode Sans"
                                font.weight: Font.Medium
                            }
                        }
                    }
                }
            }
        }

        // -----------------------------
        // SMALL PROGRESS CIRCLE
        // -----------------------------
        Canvas {
            id: holdProgress
            width: 36
            height: 36
            z: 10

            anchors.top: parent.top
            anchors.topMargin: 20
            anchors.right: parent.right
            anchors.rightMargin: 20

            property real progress: driverInfoWrapper.progressValue

            Component.onCompleted: requestPaint()

            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                ctx.clearRect(0, 0, width, height)

                var center = width / 2
                var radius = width / 2 - 3
                var start = -Math.PI / 2
                var end = start + Math.PI * 2 * progress

                // background circle
                ctx.lineWidth = 5
                ctx.strokeStyle = "#66A9B7"
                ctx.beginPath()
                ctx.arc(center, center, radius, 0, Math.PI * 2, false)
                ctx.stroke()

                // progress arc
                ctx.strokeStyle = "#00E5FF"
                ctx.beginPath()
                ctx.arc(center, center, radius, start, end, false)
                ctx.stroke()
            }
        }

        // -----------------------------
        // LOGOUT BUTTON (ICON + TEXT)
        // -----------------------------
        Item {
            id: logoutWrapper

            anchors.bottom: parent.bottom
            anchors.bottomMargin: 28
            anchors.right: parent.right
            anchors.rightMargin: 0

            width: logoutRow.width + 20
            height: 60

            Row {
                id: logoutRow
                spacing: 10
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter

                Image {
                    id: logoutIcon
                    source: "qrc:/images/driver_logout.png"
                    width: 48
                    height: 48
                    fillMode: Image.PreserveAspectFit
                }

                Text {
                    id: logoutText
                    text: "Logout"
                    color: "white"
                    font.pixelSize: 32
                    font.family: "Encode Sans"
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    console.log("LOG: Logout clicked")

                    // 3-second cooldown
                    if (driverInfoWrapper.logoutLocked) {
                        console.log("LOGOUT BLOCKED → wait 3 seconds")
                        return
                    }

                    driverInfoWrapper.logoutLocked = true
                    logoutCooldown.start()

                    appCore.logoutNow()
                }
            }
        }
    }
}
