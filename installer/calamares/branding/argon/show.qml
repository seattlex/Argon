/* Argon OS — installer slideshow (text-only, no image assets) */
import QtQuick 2.0;
import calamares.slideshow 1.0;

Presentation
{
    id: presentation

    Timer {
        interval: 12000
        running: presentation.activatedInCalamares
        repeat: true
        onTriggered: presentation.goToNextSlide()
    }

    function onActivate() { }
    function onLeave() { }

    Rectangle {
        anchors.fill: parent
        color: "#101A2C"
        z: -1
    }

    Slide {
        Text {
            anchors.centerIn: parent
            width: parent.width * 0.75
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            color: "#ECEFF4"
            font.pixelSize: 22
            text: "<h1>Welcome to Argon OS</h1><br/>" +
                  "A privacy-first operating system built on Kali Linux.<br/>" +
                  "No telemetry. No tracking. Ever."
        }
    }

    Slide {
        Text {
            anchors.centerIn: parent
            width: parent.width * 0.75
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            color: "#ECEFF4"
            font.pixelSize: 22
            text: "<h1>Secure by default</h1><br/>" +
                  "Firewall enabled, AppArmor enforced, automatic security " +
                  "updates, and encrypted DNS — all configured before your " +
                  "first login."
        }
    }

    Slide {
        Text {
            anchors.centerIn: parent
            width: parent.width * 0.75
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            color: "#ECEFF4"
            font.pixelSize: 22
            text: "<h1>Yours to inspect</h1><br/>" +
                  "Argon is free software. Every build script, every " +
                  "configuration file and every default is public:<br/>" +
                  "github.com/seattlex/argon"
        }
    }
}
