// Copyright 2022 Alexey Varfolomeev <varlesh@gmail.com>
// Used sources & ideas:
// - Joshua Krämer from https://github.com/joshuakraemer/sddm-theme-dialog
// - Suraj Mandal from https://github.com/surajmandalcell/Elegant-sddm
// - Breeze theme by KDE Visual Design Group
// - SDDM Team https://github.com/sddm/sddm
import QtQuick 2.8
import QtQuick.Controls 2.1
import Qt5Compat.GraphicalEffects 1.0
import QtQuick.Layouts 1.2
import "components"

Rectangle {
    width: 640
    height: 480
    LayoutMirroring.enabled: Qt.locale().textDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    TextConstants {
        id: textConstants
    }

    // hack for disable autostart QtQuick.VirtualKeyboard
    Loader {
        id: inputPanel
        property bool keyboardActive: false
        source: "components/VirtualKeyboard.qml"
    }

    Connections {
        target: sddm
        onLoginSucceeded: {}
        onLoginFailed: {
            password.placeholderText = textConstants.loginFailed;
            password.placeholderTextColor = "white";
            password.text = "";
            password.focus = true;
            errorMsgContainer.visible = true;
        }
    }

    Image {
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop

        Binding on source {
            when: config.background !== undefined
            value: config.background
        }
    }

    DropShadow {
        anchors.fill: panel
        horizontalOffset: 0
        verticalOffset: 0
        radius: 0
        samples: 17
        color: "#70000000"
        source: panel
    }

    Row {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.rightMargin: 40
        anchors.topMargin: 15

        Item {

            Image {
                id: shutdown
                height: 22
                width: 22
                source: "images/system-shutdown.svg"
                fillMode: Image.PreserveAspectFit

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        shutdown.source = "images/system-shutdown-hover.svg";
                        var component = Qt.createComponent("components/ShutdownToolTip.qml");
                        if (component.status === Component.Ready) {
                            var tooltip = component.createObject(shutdown);
                            tooltip.x = -100;
                            tooltip.y = 40;
                            tooltip.destroy(600);
                        }
                    }
                    onExited: {
                        shutdown.source = "images/system-shutdown.svg";
                    }
                    onClicked: {
                        shutdown.source = "images/system-shutdown-pressed.svg";
                        sddm.powerOff();
                    }
                }
            }
        }
    }

    Row {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.rightMargin: 70
        anchors.topMargin: 15

        Item {

            Image {
                id: reboot
                height: 22
                width: 22
                source: "images/system-reboot.svg"
                fillMode: Image.PreserveAspectFit

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        reboot.source = "images/system-reboot-hover.svg";
                        var component = Qt.createComponent("components/RebootToolTip.qml");
                        if (component.status === Component.Ready) {
                            var tooltip = component.createObject(reboot);
                            tooltip.x = -100;
                            tooltip.y = 40;
                            tooltip.destroy(600);
                        }
                    }
                    onExited: {
                        reboot.source = "images/system-reboot.svg";
                    }
                    onClicked: {
                        reboot.source = "images/system-reboot-pressed.svg";
                        sddm.reboot();
                    }
                }
            }
        }
    }

    Item {
        width: parent.width
        Rectangle {
            height: 300
            width: 400
            anchors.horizontalCenter: parent.horizontalCenter
            color: "transparent"
            Clock {
                id: clock
                visible: true
                anchors.topMargin: 100
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
            }
        }
    }

    Item {
        width: dialog.width
        height: dialog.height
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        Rectangle {
            id: dialog
            color: "transparent"
            height: 100
            width: 400
        }
        Grid {
            columns: 1
            spacing: 8
            verticalItemAlignment: Grid.AlignVCenter
            horizontalItemAlignment: Grid.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter

            TextField {
                id: password
                height: 48
                width: 365
                color: "#fff"
                echoMode: TextInput.Password
                focus: true
                placeholderText: textConstants.password
                onAccepted: sddm.login(user.currentText, password.text, session.currentIndex)

                background: Rectangle {
                    implicitWidth: parent.width
                    implicitHeight: parent.height
                    color: "#fff"
                    opacity: 0.2
                    radius: 21
                }

                Image {
                    id: caps
                    width: 24
                    height: 24
                    opacity: 0
                    state: keyboard.capsLock ? "activated" : ""
                    anchors.right: password.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: 10
                    fillMode: Image.PreserveAspectFit
                    source: "images/capslock.svg"
                    sourceSize.width: 24
                    sourceSize.height: 24

                    states: [
                        State {
                            name: "activated"
                            PropertyChanges {
                                target: caps
                                opacity: 1
                            }
                        },
                        State {
                            name: ""
                            PropertyChanges {
                                target: caps
                                opacity: 0
                            }
                        }
                    ]

                    transitions: [
                        Transition {
                            to: "activated"
                            NumberAnimation {
                                target: caps
                                property: "opacity"
                                from: 0
                                to: 1
                                duration: imageFadeIn
                            }
                        },
                        Transition {
                            to: ""
                            NumberAnimation {
                                target: caps
                                property: "opacity"
                                from: 1
                                to: 0
                                duration: imageFadeOut
                            }
                        }
                    ]
                }
            }
            Keys.onPressed: {
                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    sddm.login(user.currentText, password.text, session.currentIndex);
                    event.accepted = true;
                }
            }
        }
    }
}
