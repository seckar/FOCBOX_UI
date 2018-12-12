/*
    Copyright 2017 Benjamin Vedder	benjamin@vedder.se



    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program .  If not, see <http://www.gnu.org/licenses/>.
    */

import QtQuick 2.7
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3

import Vedder.vesc.vescinterface 1.0
import Vedder.vesc.commands 1.0
import Vedder.vesc.configparams 1.0
import Vedder.vesc.utility 1.0

ApplicationWindow {
    id: appWindow
    property Commands mCommands: VescIf.commands()
    property ConfigParams mMcConf: VescIf.mcConfig()
    property ConfigParams mAppConf: VescIf.appConfig()
    property ConfigParams mInfoConf: VescIf.infoConfig()
    property real currentSetupStep: 0
    visible: true
    width: 600
    height: 1000
    title: qsTr("FOCBOX UI")

    Component.onCompleted: {
        Utility.checkVersion(VescIf)
        //        swipeView.currentIndex = 3
    }


    Drawer {
        id: drawer
        width: 0.5 * appWindow.width
        height: appWindow.height - footer.height - tabBar.height
        y: tabBar.height
        dragMargin: 20

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 0

            Image {
                id: image
                Layout.preferredWidth: Math.min(parent.width, parent.height)
                Layout.preferredHeight: Math.min(Layout.preferredWidth, 150)
                fillMode: Image.PreserveAspectFit
                Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                source: "qrc:/res/logo_enertion.png"
            }

            Button {
                id: reconnectButton

                Layout.fillWidth: true
                text: "Reconnect"
                enabled: false
                flat: true

                onClicked: {
                    VescIf.reconnectLastPort()
                }
            }


            Button {
                Layout.fillWidth: true
                text: "Disconnect"
                enabled: connBle.disconnectButton.enabled
                flat: true

                onClicked: {
                    VescIf.disconnectPort()

                }
            }

            Item {
                // Spacer
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            Button {
                Layout.fillWidth: true
                text: "About"
                flat: true

                onClicked: {
                    VescIf.emitMessageDialog(
                                "About",
                                Utility.aboutText(),
                                true, true)
                }
            }

            Button {
                Layout.fillWidth: true
                text: "Changelog"
                flat: true

                onClicked: {
                    VescIf.emitMessageDialog(
                                "FOCBOX UI Changelog",
                                Utility.vescToolChangeLog(),
                                true, false)
                }
            }

            Button {
                Layout.fillWidth: true
                text: "License"
                flat: true

                onClicked: {
                    VescIf.emitMessageDialog(
                                mInfoConf.getLongName("gpl_text"),
                                mInfoConf.getDescription("gpl_text"),
                                true, true)
                }
            }
        }
    }



    SwipeView {
        id: swipeView
        currentIndex: tabBar.currentIndex
        anchors.fill: parent
        onCurrentIndexChanged: tabBar.currentIndex = currentIndex



        Page {
            ConnectBle {
                id: connBle
                anchors.fill: parent
                anchors.margins: 10
                guidedSetupButton.onClicked: {              //////////////////////////////
                    guidedSetupIntro.open()
                }
            }
        }

        Page {

            RtData {
                anchors.fill: parent
            }
        }

        Page {
            ConfigPage{
                id: confPageBattery
                anchors.fill: parent
                anchors.centerIn: parent
                anchors.margins: 10
            }
        }

        Page {
            FwUpdate {
                anchors.fill: parent
            }
        }
        Page {
            Terminal {
                id: terminalPage
                anchors.fill: parent
                anchors.margins: 10
            }


        }
        Page {
            Flickable {
                anchors.fill: parent
                //ScrollBar.vertical.interactive: false
                //Flickable.interactive: false
                //Flickable.onContentYChanged: Flickable.contentY = 0
                boundsBehavior: Flickable.DragAndOvershootBounds
                contentHeight: contentItem.childrenRect.height
                contentWidth: width
                id: pinoutScroll
                anchors.rightMargin: 0
                anchors.topMargin: 0
                anchors.bottomMargin: 0
                anchors.leftMargin: 0
                clip:true


                Image {
                    id: pinoutPage
                    width:parent.width
                    source: "qrc:/res/images/pinout.png"
                    fillMode: Image.PreserveAspectFit
                }
            }

            /*Logging {
                id: loggingPage
                anchors.fill: parent
                anchors.margins: 10
            }*/


        }

    }

    header: Rectangle {
        color: "#dbdbdb"
        height: tabBar.height

        RowLayout {
            anchors.fill: parent
            spacing: 0

            ToolButton {
                Layout.preferredHeight: tabBar.height
                Layout.preferredWidth: tabBar.height - 10

                Image {
                    id: manuButton
                    anchors.centerIn: parent
                    width: tabBar.height * 0.5
                    height: tabBar.height * 0.5
                    opacity: 0.5
                    source: "qrc:/res/icons/Settings-96.png"
                }

                onClicked: {
                    if (drawer.visible) {
                        drawer.close()
                    } else {
                        drawer.open()
                    }
                }
            }

            TabBar {
                id: tabBar
                currentIndex: swipeView.currentIndex
                Layout.fillWidth: true
                implicitWidth: 0
                clip: true

                background: Rectangle {
                    opacity: 1
                    color: "#e8e8e8"
                }

                property int buttons: 5
                property int buttonWidth: 120

                TabButton {
                    text: qsTr("Connect")

                    font.pointSize: 12
                    width: Math.max(tabBar.buttonWidth, tabBar.width / tabBar.buttons)
                }
                TabButton {
                    text: qsTr("HUD")
                    font.pointSize: 12
                    width: Math.max(tabBar.buttonWidth, tabBar.width / tabBar.buttons)
                }
                TabButton {
                    text: qsTr("Config")
                    width: Math.max(tabBar.buttonWidth, tabBar.width / tabBar.buttons)
                }
                TabButton {
                    text: qsTr("Firmware")
                    width: Math.max(tabBar.buttonWidth, tabBar.width / tabBar.buttons)
                }
                TabButton {
                    text: qsTr("Terminal")
                    width: Math.max(tabBar.buttonWidth, tabBar.width / tabBar.buttons)
                }
                TabButton {
                    text: qsTr("Pinout")
                    width: Math.max(tabBar.buttonWidth, tabBar.width / tabBar.buttons)
                }
            }
        }
    }

    footer: Rectangle {
        id: connectedRect
        color: "lightgray"

        Text {
            id: connectedText
            color: "black"
            text: VescIf.getConnectedPortName()
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            anchors.fill: parent
        }

        width: parent.width
        height: 20
    }



    ColumnLayout{
        id: guideOverlay
        anchors.fill:parent
        z:5
        spacing: 0
        visible:false

        Rectangle{
            z:5
            id:rec1
            Layout.preferredHeight: 0
            Layout.fillWidth: true
            color: "black"
            opacity:0.7
            MouseArea {
                anchors.fill: parent

            }

            Behavior on Layout.preferredHeight {
                NumberAnimation {
                    easing.type: Easing.OutCirc
                    duration: 500
                }
            }
        }
        Rectangle{
            id:rec2
            Layout.preferredHeight: 0
            Layout.fillWidth: true
            color: "black"
            opacity:0


            Behavior on Layout.preferredHeight {
                NumberAnimation {
                    easing.type: Easing.OutCirc
                    duration: 500
                }
            }

        }
        Rectangle{
            z:5
            id:rec3
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: "black"
            opacity:0.7
            onHeightChanged:{
                if( (guidedSetupIntro.height + 10) < height)
                    guidedSetupIntro.y = y + 10
                else
                    guidedSetupIntro.y = rec2.y - guidedSetupIntro.height - 10
            }
            MouseArea {
                anchors.fill: parent

            }


        }
    }

    Timer {
        id: statusTimer
        interval: 4000
        running: false
        repeat: false
        onTriggered: {
            connectedText.text = VescIf.getConnectedPortName()
            connectedRect.color = "lightgray"
        }
    }

    Timer {
        id: uiTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            if (!statusTimer.running && connectedText.text !== VescIf.getConnectedPortName()) {
                connectedText.text = VescIf.getConnectedPortName()
            }
        }
    }

    Timer {
        id: confTimer
        interval: 1000
        running: true
        repeat: true

        property bool mcConfRx: false
        property bool appConfRx: false

        onTriggered: {
            if (VescIf.isPortConnected()) {
                if (!mcConfRx) {
                    mCommands.getMcconf()
                }

                if (!appConfRx) {
                    mCommands.getAppConf()
                }
            }
        }
    }

    Timer {
        id: rtTimer
        interval: 50
        running: true
        repeat: true

        onTriggered: {
            if (VescIf.isPortConnected() && (tabBar.currentIndex == 1 ) && confPageBattery.configNotUpdating) {
                // Sample RT data when the RT page is selected
                mCommands.getValues()
            }
            if (VescIf.isPortConnected() && tabBar.currentIndex == 2 && confPageBattery.configNotUpdating) {
                mCommands.getDecodedPpm()
            }
        }
    }

    Timer {
        id: sendAliveTimer
        interval: 100
        running: true
        repeat: true

        onTriggered: {
            if (VescIf.isPortConnected() && tabBar.currentIndex == 4 && confPageBattery.configNotUpdating) {
                mCommands.sendAlive()
            }
        }
    }

    Dialog {
        id: vescDialog
        modal: true
        focus: true
        width: parent.width - 20
        height: Math.min(implicitHeight, parent.height - 40)
        closePolicy: Popup.CloseOnEscape

        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        ColumnLayout{
            anchors.fill:parent
            ScrollView {
                Layout.fillHeight: true
                Layout.fillWidth: true
                clip: true
                contentWidth: parent.width - 20

                Text {
                    id: vescDialogLabel
                    verticalAlignment: Text.AlignVCenter
                    anchors.fill: parent
                    wrapMode: Text.WordWrap
                    textFormat: Text.RichText
                    //font.pixelSize: parent.width*0.04
                    onLinkActivated: {
                        Qt.openUrlExternally(link)
                    }
                }

            }
            DialogButtonBox {
                standardButtons: DialogButtonBox.Ok
                Layout.alignment: Qt.AlignRight

                onAccepted: vescDialog.close()
            }
        }
    }


    Dialog {
        id: guidedSetupIntro
        modal: false
        focus: false
        width: parent.width - 20
        height: implicitHeight
        closePolicy: Popup.CloseOnEscape
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        onOpened: {
            guideOverlay.visible = true
            tabBar.enabled = false
            swipeView.interactive = false
            guidedSetupLabel.text = "Welcome to guided board setup! Please place your board deck down and wheels up within easy reach and press OK to continue with guided setup"
            confPageBattery.columnLayoutProps.interactive = false

            if(confPageBattery.batterySettingsWindow.height > confPageBattery.batterySettingsButton.height){
                confPageBattery.batterySettingsButton.clicked()
            }
            if(confPageBattery.motorSettingsWindow.height > confPageBattery.motorSettingsButton.height){
                confPageBattery.motorSettingsButton.clicked()
            }
            if(confPageBattery.appSettingsWindow.height > confPageBattery.appSettingsButton.height){
                confPageBattery.appSettingsButton.clicked()
            }
        }

        onClosed: {
            currentSetupStep = 0
            setupGuideOK.enabled = true
            rec1.Layout.preferredHeight = 0
            rec2.Layout.preferredHeight = 0
            guideOverlay.visible = false
            tabBar.enabled = true
            swipeView.interactive = true
            confPageBattery.columnLayoutProps.interactive = true
        }
        ColumnLayout{
            anchors.fill:parent
            ScrollView {
                Layout.fillHeight: true
                Layout.fillWidth: true
                clip: true
                contentWidth: parent.width - 20

                Text {
                    id: guidedSetupLabel
                    verticalAlignment: Text.AlignVCenter
                    anchors.fill: parent
                    wrapMode: Text.WordWrap
                    textFormat: Text.RichText
                }

            }
            DialogButtonBox {
                id: setupGuideOK
                standardButtons: DialogButtonBox.Ok | DialogButtonBox.Cancel
                Layout.alignment: Qt.AlignRight
                spacing: 10
                Layout.fillWidth: true
                onRejected: {
                    guidedSetupIntro.close()
                }

                onAccepted: {
                    switch(currentSetupStep)
                    {
                    case 0:
                        if(VescIf.isPortConnected()){
                            currentSetupStep++
                        }else{
                            guidedSetupLabel.text = "Please connect your FOCBOX Unity over USB or Bluetooth and press OK"
                            rec1.Layout.preferredHeight = connBle.titleImage.height + connBle.bleBox.y -15 //- connBle.bleBox.height
                            rec2.Layout.preferredHeight = connBle.guidedSetupButton.height * 5 + 15
                            break;
                        }
                    case 1:
                        confPageBattery.batterySettingsButton.clicked()
                        rec1.Layout.preferredHeight = confPageBattery.batterySettingsButton.height * 2.3
                        rec2.Layout.preferredHeight = confPageBattery.batterySettingsButton.height * 2
                        currentSetupStep++
                        tabBar.currentIndex = 2
                        guidedSetupLabel.text = "Select the number of Lithium-Ion/Lithium-Polymer cells in your battery pack or choose custom voltage to select appropriate voltage cutoffs if your pack is non-standard"
                        break;
                    case 2:
                        currentSetupStep++
                        rec1.Layout.preferredHeight = confPageBattery.batterySettingsButton.height * 4.3
                        rec2.Layout.preferredHeight = confPageBattery.batterySettingsButton.height * 1.9
                        guidedSetupLabel.text = "Select the maximum discharge current for your battery. This will impact acceleration at higher speeds but should not be set higher than the rated discharge current of your battery to avoid damaging the pack."
                        break;
                    case 3:
                        currentSetupStep++
                        rec1.Layout.preferredHeight = confPageBattery.batterySettingsButton.height * 6.2
                        rec2.Layout.preferredHeight = confPageBattery.batterySettingsButton.height * 1.9
                        guidedSetupLabel.text = "Select the maximum regen current for your battery. This will impact braking strength at higher speeds but should not be set beyond maximum rated charging current of your battery to avoid damaging the pack."
                        break;
                    case 4:
                        currentSetupStep++
                        confPageBattery.batterySettingsButton.clicked()
                        confPageBattery.motorSettingsButton.clicked()
                        enabled = false
                        rec1.Layout.preferredHeight = confPageBattery.batterySettingsButton.height * 3.4
                        rec2.Layout.preferredHeight = confPageBattery.batterySettingsButton.height * 5.4
                        guidedSetupLabel.text = "We will now begin the calibration routine for motors. Ensure both motors and hall sensors (if available) are plugged in correctly and that the wheels and motors are free of interference then press \"Start Test\" to begin. Once completed succesfully press OK to continue "
                        break;
                    case 5:
                        currentSetupStep++
                        rec1.Layout.preferredHeight = confPageBattery.batterySettingsButton.height * 8.7
                        rec2.Layout.preferredHeight = confPageBattery.batterySettingsButton.height * 1.8
                        guidedSetupLabel.text = "Select the maximum motor current, do not exceed the maximum continuous rated current of your motors. Increasing maximum motor current will increase available low-speed torque at the cost of efficiency."
                        break;
                    case 6:
                        currentSetupStep++
                        rec1.Layout.preferredHeight = confPageBattery.batterySettingsButton.height * 10.4
                        rec2.Layout.preferredHeight = confPageBattery.batterySettingsButton.height * 1.8
                        guidedSetupLabel.text = "Select the maximum braking motor current, do not exceed the maximum continuous rated current of your motors. Increasing maximum braking motor current will increase available braking force at low-speed."
                        break;
                    case 7:
                        confPageBattery.motorSettingsButton.clicked()
                        //confPageBattery.appSettingsButton.clicked()
                        currentSetupStep++
                        enabled = false
                        rec1.Layout.preferredHeight = confPageBattery.batterySettingsButton.height * 0
                        rec2.Layout.preferredHeight = confPageBattery.batterySettingsButton.height * 1.2
                        guidedSetupLabel.text = "Now we will apply these motor and battery settings before continuing on to setup the remote, hit the \"Apply Updated Config\" button above to continue."
                        break;
                    case 8:
                        confPageBattery.appSettingsButton.clicked()
                        currentSetupStep++
                        rec1.Layout.preferredHeight = confPageBattery.batterySettingsButton.height * 3.4
                        rec2.Layout.preferredHeight = confPageBattery.batterySettingsButton.height * 1.2
                        guidedSetupLabel.text = "We will now begin the Remote Config, ensure your remote reciever is plugged in and your remote is connected and turned on."
                        break;
                    case 9:
                        currentSetupStep++
                        rec1.Layout.preferredHeight = confPageBattery.batterySettingsButton.height * 4.5
                        rec2.Layout.preferredHeight = confPageBattery.batterySettingsButton.height * 1.2
                        guidedSetupLabel.text = "Select the preferred behaviour for your remote throtte. Forward/Brake is the recommended setting if you are unsure."
                        break;
                    case 10:
                        currentSetupStep++
                        rec1.Layout.preferredHeight = confPageBattery.batterySettingsButton.height * 5.625
                        rec2.Layout.preferredHeight = confPageBattery.batterySettingsButton.height * 1.2
                        guidedSetupLabel.text = "In order to correctly configure the range of your remote hit the \"Calibrate\" button above and follow the instructions before continuing. If the gauge to the left already appears accurate then it is acceptable to skip calibration"
                        break;/*
                    case 11:
                        currentSetupStep++
                        rec1.Layout.preferredHeight = confPageBattery.batterySettingsButton.height * 6.75
                        rec2.Layout.preferredHeight = confPageBattery.batterySettingsButton.height * 1.2
                        guidedSetupLabel.text = "Select the Correct Baud Rate for any accesory you have plugged in to the FOCBOX Unity."
                        break;*/
                     case 11:
                        currentSetupStep++
                        rec1.Layout.preferredHeight = confPageBattery.batterySettingsButton.height * 9
                        rec2.Layout.preferredHeight = confPageBattery.batterySettingsButton.height * 1.2
                        guidedSetupLabel.text = "If using only one Unity this setting should be left Disabled. This configures the CAN bus if using two FOCBOX Unities for 4WD. The Unity with your remote reciever plugged in should be set as master and the peripheral Unity set as Slave."
                        break;
                    case 12:
                        confPageBattery.appSettingsButton.clicked()
                        currentSetupStep++
                        enabled = false
                        rec1.Layout.preferredHeight = confPageBattery.batterySettingsButton.height * 0
                        rec2.Layout.preferredHeight = confPageBattery.batterySettingsButton.height * 1.2
                        guidedSetupLabel.text = "Now we will apply the app settings to finalize the configuration of the unity, hit the \"Apply Updated Config\" button above to continue."
                        break;
                    case 13:
                        currentSetupStep++
                        rec1.Layout.preferredHeight = confPageBattery.batterySettingsButton.height * 0
                        rec2.Layout.preferredHeight = confPageBattery.batterySettingsButton.height * 0
                        tabBar.currentIndex = 1
                        guidedSetupLabel.text = "Thanks for following along with our guide! If everything went smoothly your board should be all setup. We've taken you the HUD page now, hit the gear to setup the HUD interface to your liking and make sure to bench test your board a bit before giving it a ride!"
                        break;
                    case 14:
                        currentSetupStep++
                        guidedSetupIntro.close()
                        break;
                    }
                }

            }
        }
    }




    Connections {
        target: mCommands
        onMotorLinkageReceived: {
            setupGuideOK.enabled = true
        }

        onAckReceived: {
            if(ackType == "MCCONF Write OK"){
                setupGuideOK.enabled = true
            }
        }
    }
    Connections {
        target: VescIf
        onPortConnectedChanged: {
            connectedText.text = VescIf.getConnectedPortName()
            if (VescIf.isPortConnected()) {
                reconnectButton.enabled = true
            }
        }

        onStatusMessage: {
            connectedText.text = msg
            connectedRect.color = isGood ? "#00CCA3" : "red"
            statusTimer.restart()
        }

        onMessageDialog: {
            vescDialog.title = title
            vescDialogLabel.text = msg
            vescDialogLabel.textFormat = richText ? Text.RichText : Text.AutoText
            vescDialog.open()
        }

        onFwRxChanged: {
            if (rx && !limited) {
                mCommands.getMcconf()
                mCommands.getAppConf()
            }
        }
    }

    Connections {
        target: mMcConf

        onUpdated: {
            confTimer.mcConfRx = true
        }
    }

    Connections {
        target: mAppConf

        onUpdated: {
            confTimer.appConfRx = true
        }
    }
}
