/***************************************************************************
* Copyright (c) 2013 Abdurrahman AVCI <abdurrahmanavci@gmail.com>
* Copyright (c) 2024 Aleksei Bavshin <alebastr@fedoraproject.org>
* Modified for Modern Glassmorphism
***************************************************************************/

import QtQuick 2.0
import SddmComponents 2.0

Rectangle {
    id: container
    width: 380
    height: 440
    color: "#99000000"          // تفعيل الشفافية الداكنة العصرية (زجاجي)
    radius: 20                  // حواف دائرية ناعمة وكبيرة
    border.color: "#66ffffff"   // إطار زجاجي مضيء خفيف
    border.width: 1

    LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    property int sessionIndex: session.index

    TextConstants { id: textConstants }

    Connections {
        target: sddm

        function onLoginSucceeded() {
            errorMessage.color = "steelblue"
            errorMessage.text = textConstants.loginSucceeded
        }
        function onLoginFailed() {
            password.text = ""
            errorMessage.color = "#ff6b6b"
            errorMessage.text = textConstants.loginFailed
        }
        function onInformationMessage(message) {
            errorMessage.color = "#ff6b6b"
            errorMessage.text = message
        }
    }

    Background {
        anchors.fill: parent
        source: Qt.resolvedUrl(config.background)
        fillMode: Image.PreserveAspectCrop
        onStatusChanged: {
            var defaultBackground = Qt.resolvedUrl(config.defaultBackground)
            if (status == Image.Error && source != defaultBackground) {
                source = defaultBackground
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"

        Clock {
            id: clock
            anchors.margins: 15
            anchors.top: parent.top; anchors.right: parent.right
            color: "white"
            timeFont.family: "Oxygen"
        }

        Item {
            id: rectangle
            anchors.centerIn: parent
            width: Math.max(340, mainColumn.implicitWidth + 40)
            height: Math.max(380, mainColumn.implicitHeight + 40)

            Column {
                id: mainColumn
                anchors.centerIn: parent
                spacing: 14
                
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "white"
                    verticalAlignment: Text.AlignVCenter
                    height: implicitHeight
                    width: parent.width
                    text: textConstants.welcomeText.arg(sddm.hostName)
                    wrapMode: Text.WordWrap
                    font.pixelSize: 22
                    font.bold: true
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                }

                Column {
                    width: parent.width
                    spacing: 4
                    Text {
                        id: lblName
                        width: parent.width
                        text: textConstants.userName
                        color: "#dddddd"
                        font.bold: true
                        font.pixelSize: 12
                    }

                    TextBox {
                        id: name
                        width: parent.width; height: 35
                        text: userModel.lastUser
                        font.pixelSize: 14

                        color: "#1Affffff"
                        borderColor: "#4Dffffff"
                        textColor: "white"
                        radius: 8

                        KeyNavigation.backtab: rebootButton; KeyNavigation.tab: password

                        Keys.onPressed: function (event) {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                sddm.login(name.text, password.text, sessionIndex)
                                event.accepted = true
                            }
                        }
                    }
                }

                Column {
                    width: parent.width
                    spacing: 4
                    Text {
                        id: lblPassword
                        width: parent.width
                        text: textConstants.password
                        color: "#dddddd"
                        font.bold: true
                        font.pixelSize: 12
                    }

                    PasswordBox {
                        id: password
                        width: parent.width; height: 35
                        font.pixelSize: 14

                        color: "#1Affffff"
                        borderColor: "#4Dffffff"
                        textColor: "white"
                        radius: 8

                        KeyNavigation.backtab: name; KeyNavigation.tab: session

                        Keys.onPressed: function (event) {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                sddm.login(name.text, password.text, sessionIndex)
                                event.accepted = true
                            }
                        }
                    }
                }

                Row {
                    spacing: 6
                    width: parent.width / 2
                    z: 100

                    Column {
                        z: 100
                        width: parent.width * (layoutBox.visible ? 1.3 : 2)
                        spacing: 4
                        anchors.bottom: parent.bottom

                        Text {
                            id: lblSession
                            width: parent.width
                            text: textConstants.session
                            color: "#dddddd"
                            wrapMode: TextEdit.WordWrap
                            font.bold: true
                            font.pixelSize: 12
                        }

                        ComboBox {
                            id: session
                            width: parent.width; height: 32
                            font.pixelSize: 14
                            arrowIcon: Qt.resolvedUrl("angle-down.png")
                            model: sessionModel
                            index: sessionModel.lastIndex

                            color: "#1Affffff"
                            borderColor: "#4Dffffff"
                            textColor: "white"

                            KeyNavigation.backtab: password; KeyNavigation.tab: layoutBox
                        }
                    }

                    Column {
                        z: 101
                        width: parent.width * 0.7
                        spacing: 4
                        anchors.bottom: parent.bottom
                        visible: keyboard.enabled && keyboard.layouts.length > 0

                        Text {
                            id: lblLayout
                            width: parent.width
                            text: textConstants.layout
                            color: "#dddddd"
                            wrapMode: TextEdit.WordWrap
                            font.bold: true
                            font.pixelSize: 12
                        }

                        LayoutBox {
                            id: layoutBox
                            width: parent.width; height: 32
                            font.pixelSize: 14
                            arrowIcon: Qt.resolvedUrl("angle-down.png")

                            color: "#1Affffff"
                            borderColor: "#4Dffffff"
                            textColor: "white"

                            KeyNavigation.backtab: session; KeyNavigation.tab: loginButton
                        }
                    }
                }

                Column {
                    width: parent.width
                    Text {
                        id: errorMessage
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: textConstants.prompt
                        color: "white"
                        font.pixelSize: 11
                    }
                }

                Row {
                    spacing: 6
                    anchors.horizontalCenter: parent.horizontalCenter
                    property int btnWidth: Math.max(loginButton.implicitWidth,
                                                    shutdownButton.implicitWidth,
                                                    rebootButton.implicitWidth, 75) + 6
                    Button {
                        id: loginButton
                        text: textConstants.login
                        width: parent.btnWidth

                        color: "#1Affffff"
                        borderColor: "#4Dffffff"
                        textColor: "white"
                        activeColor: "#33ffffff"
                        pressedColor: "#66ffffff"
                        radius: 8

                        onClicked: sddm.login(name.text, password.text, sessionIndex)
                        KeyNavigation.backtab: layoutBox; KeyNavigation.tab: shutdownButton
                    }

                    Button {
                        id: shutdownButton
                        text: textConstants.shutdown
                        width: parent.btnWidth

                        color: "#1Affffff"
                        borderColor: "#4Dffffff"
                        textColor: "white"
                        activeColor: "#33ffffff"
                        pressedColor: "#66ffffff"
                        radius: 8

                        onClicked: sddm.powerOff()
                        KeyNavigation.backtab: loginButton; KeyNavigation.tab: rebootButton
                    }

                    Button {
                        id: rebootButton
                        text: textConstants.reboot
                        width: parent.btnWidth

                        color: "#1Affffff"
                        borderColor: "#4Dffffff"
                        textColor: "white"
                        activeColor: "#33ffffff"
                        pressedColor: "#66ffffff"
                        radius: 8

                        onClicked: sddm.reboot()
                        KeyNavigation.backtab: shutdownButton; KeyNavigation.tab: name
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        if (name.text == "")
            name.focus = true
        else
            password.focus = true
    }
}
