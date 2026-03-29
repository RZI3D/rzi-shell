import Quickshell
import Quickshell.Services.UPower
import QtQuick
import QtQuick.Effects
import QtQuick.Controls
import QtQuick.Controls.Material
import Quickshell.Io
import "../theme" as Theme
import "../widgets" as Widgets

Item {
    id: root
    implicitWidth: batteryRow.implicitWidth + 20
    implicitHeight: Theme.Catppuccin.barHeight

    property var battery: UPower.displayDevice
    property bool isCritical: battery.percentage <= 0.05 && battery.state !== UPowerDeviceState.Charging 
    property bool isWarning: battery.percentage <= 0.20 && battery.state !== UPowerDeviceState.Charging


    Process {
        id: notifySender
    }

    // 2. The notify function using the .exec() method from your docs
    function notify(title, message, urgency, icon) {
        let cmdString = `notify-send -a "System" -u ${urgency} -i ${icon} "${title}" "${message}"`;
    
        notifySender.exec({
            command: ["sh", "-c", cmdString]
        });
    }

    property real animatedProgress: 0.0

    NumberAnimation {
        id: fillAnimation
        target: root
        property: "animatedProgress"
        from: 0.0
        to: battery.percentage
        duration: 800
        easing.type: Easing.OutCubic
        onFinished:  batToast.show();
    }

    function showToast() {
        batToast.show();
        fillAnimation.restart();    
    }

    Widgets.ToastSlider {
        id: batToast
        icon: "image://icon/" + battery.iconName
        // Use the animated property here instead of battery.percentage
        progress: animatedProgress
        text: Math.round(animatedProgress * 100) + "%"
        disableAnimation: true
        openHeight: 1800
        closeHeight: 2200
    }

    // --- Logic Triggers ---
    onIsCriticalChanged: {
        if (isCritical && battery.state !== UPowerDeviceState.Charging) {
            notify("Battery CRITICAL!", "Battery is 5%. Plug in NOW!", "high", "battery-low");
            showToast()
        }
    }

    Connections {
        target: root.battery
        function onStateChanged() {
            if (root.battery.state === UPowerDeviceState.Charging) {
                console.log(batToast.progress)
                notify("Charging", "Power source connected.", "low", "battery-charging");
                showToast()
            } else if (root.battery.state === UPowerDeviceState.Discharging) {
                notify("Discharging", "Power source disconnected.", "low", "battery");
                showToast()                
            }
        }
    }

    Rectangle {
        id: bgRect
        anchors.centerIn: parent
        height: Theme.Catppuccin.barHeight - 10
        width: parent.width
        radius: 9
        
        // Base color logic
        color: {
            if (root.isCritical) {
                return Theme.Catppuccin.red; // 5% or less - Breathing Red
            } else if (root.isWarning) {
                return Theme.Catppuccin.maroon; // 20% or less - Solid Warning
            } else {
                return Theme.Catppuccin.surface1; // Normal state
            }
        }

        Behavior on color { ColorAnimation { duration: 300 } }

        // --- Breathing Animation ---
        SequentialAnimation {
            id: breatheAnim
            running: root.isCritical
            loops: Animation.Infinite
            
            NumberAnimation { target: bgRect; property: "opacity"; from: 1.0; to: 0.4; duration: 1200; easing.type: Easing.InOutSine }
            NumberAnimation { target: bgRect; property: "opacity"; from: 0.4; to: 1.0; duration: 1200; easing.type: Easing.InOutSine }
            
            // When the animation stops (isCritical becomes false), ensure opacity is 1
            onRunningChanged: {
                if (!running) bgRect.opacity = 1.0
            }
        }

        Row {
            id: batteryRow
            anchors.centerIn: parent
            spacing: 5
            Item {
                width: 14
                height: 14
                anchors.verticalCenter: parent.verticalCenter
                Image {
                    id: batteryIcon
                    anchors.verticalCenter: parent.verticalCenter
                    source: "image://icon/" + battery.iconName
                    height: 14; width: height
                }
                MultiEffect {
                    source: batteryIcon
                    anchors.fill: batteryIcon
                    
                    // Color Tinting logic
                    colorization: (root.isWarning || root.isCritical) ? 1.0 : 0.0
                    colorizationColor: Theme.Catppuccin.bg
                    
                    // Keep the icon sharp
                    brightness: 0.0
                    contrast: 0.0
                }
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: Math.round(battery.percentage * 100) + "%"
                color: (root.isCritical || root.isWarning) ? Theme.Catppuccin.surface2 : Theme.Catppuccin.text
                font.family:    Theme.Catppuccin.font
                font.pixelSize: Theme.Catppuccin.fontSm
                font.bold:      root.isCritical
            }
        }
    }
}