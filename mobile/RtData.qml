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

import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Extras 1.4
import QtQuick.Controls.Styles 1.4
import Qt.labs.settings 1.0

import Vedder.vesc.vescinterface 1.0
import Vedder.vesc.commands 1.0
import Vedder.vesc.configparams 1.0

Item {
    id: daddy
    property Commands mCommands: VescIf.commands()
    property ConfigParams mMcConf: VescIf.mcConfig()
    property int gaugeSize: 0.9*width / 2
    property int gaugeHeight:  100
    property alias image: imageBoard
    property real fillet: 0.005*imageBoard.width
    property real tac1: 0
    property real tac2: 0
    property real startTac1: 0
    property real startTac2: 0

    anchors.fill:parent
    Button {
        z: 5
        anchors.right: imageBoard.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset:  -0.15*imageBoard.width
        height: 0.125*imageBoard.width
        width: 0.125*imageBoard.width

        flat: true
        onClicked: {
            settingsDialog.open()
        }
        Image {
            source: "qrc:/res/icons/Settings-96.png"
            anchors.fill: parent
            opacity: 0.5
        }

        /*Column {
            spacing: parent.height/15 // a simple layout do avoid overlapping
            anchors.centerIn: parent
            Repeater {
                model: 3
                delegate: Rectangle {
                    width: 3*parent.spacing
                    height: width
                    radius:width/2
                    color: "#444444"
                }
            }*/
        //}

    }


    Image {
        id: imageBoard
        width: Math.min(parent.width,parent.height)
        height: 2*imageBoard.width
        //width: 400
        // height: 2*imageBoard.width

        sourceSize.width: 1000
        sourceSize.height: 2000
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        anchors.centerIn: parent
        //Layout.fillHeight: false
        //height: 620
        Layout.columnSpan: 1
        //Layout.fillHeight: true
        //Layout.fillWidth: false
        antialiasing: false
        // scale: 1
        // sourceSize.width: 0
        //fillMode: Image.Stretch
        transformOrigin: Item.Center
        z: 0
        source: "../res/skate_deck.png"
        Text {
            id: motorTempText
            anchors.centerIn:  parent
            anchors.verticalCenterOffset: 0.175*imageBoard.width
            anchors.horizontalCenterOffset: -0.425*imageBoard.width
            font.pixelSize: 0.04*imageBoard.width
            text: qsTr("")
            //Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        }
        Text {
            id: motorTempText2
            anchors.centerIn:  parent
            anchors.verticalCenterOffset: 0.175*imageBoard.width
            anchors.horizontalCenterOffset: 0.425*imageBoard.width
            font.pixelSize: 0.04*imageBoard.width
            text: qsTr("")
            //Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        }

        ColumnLayout {
            spacing: 0.015*imageBoard.width
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 0.325*imageBoard.width
            anchors.horizontalCenterOffset: -0.32*imageBoard.width
            width: 0.31*imageBoard.width

            RowLayout{
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.fillHeight: false
                Layout.fillWidth: true
                Rectangle {
                    // anchors.centerIn:parent
                    //anchors.verticalCenterOffset : 0.075*imageBoard.width
                    Layout.preferredHeight: 0.11*imageBoard.width
                    // Layout.preferredWidth: 0.315*imageBoard.width

                    id: currentGauge
                    color: "#00000000"
                    property real actualVal: 0
                    property string positive: "#00CCA3"
                    property string negative: "orange"
                    z: 1

                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Rectangle{
                        radius:daddy.fillet
                        anchors.right: parent.right
                        height: currentGauge.height
                        width: currentGauge.width*currentGauge.value/currentGauge.maximumValue
                        color:  (currentGauge.actualVal >= 0) ? currentGauge.positive : currentGauge.negative
                    }
                    Text {
                        anchors.centerIn: parent
                        id: currentText
                        text: qsTr("0 A")
                        z: 3
                        transformOrigin: Item.Top
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: 0.075*imageBoard.width
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                        Layout.fillWidth: true
                    }

                    antialiasing: false
                    Layout.fillHeight: false
                    Layout.fillWidth: true
                    property real minimumValue: 0
                    property real maximumValue: 60
                    property real value: 0



                    Behavior on value {
                        NumberAnimation {
                            easing.type: Easing.OutCirc
                            duration: 100
                        }
                    }
                }
            }
            RowLayout{
                Layout.fillHeight: false
                Layout.fillWidth: true
                Rectangle {
                    // anchors.centerIn:parent
                    id: voltageGauge
                    property real actualVal: 0
                    color: "#00000000"
                    property string positive: "#00CCA3"
                    property string negative: "orange"
                    z: 2
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Rectangle{
                        radius:daddy.fillet
                        anchors.right: parent.right
                        height:parent.height
                        width: voltageGauge.width*voltageGauge.value/voltageGauge.maximumValue
                        color:  (voltageGauge.actualVal >= 0) ? voltageGauge.positive : voltageGauge.negative
                    }
                    Text {
                        anchors.centerIn: voltageGauge
                        id: powerText
                        text: qsTr("0 V")
                        z: 4
                        transformOrigin: Item.Top
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: 0.075*imageBoard.width
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                        Layout.fillWidth: true
                    }
                    antialiasing: false
                    Layout.fillHeight: false
                    Layout.fillWidth: true
                    property real minimumValue: 0
                    property real maximumValue: 100
                    property real value: 0
                    Layout.preferredHeight: 0.11*imageBoard.width
                    Behavior on value {
                        NumberAnimation {
                            easing.type: Easing.OutCirc
                            duration: 100
                        }
                    }
                }
            }
        }

        ColumnLayout {
            spacing: 0.015*imageBoard.width
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 0.325*imageBoard.width
            anchors.horizontalCenterOffset: 0.32*imageBoard.width
            width: 0.31*imageBoard.width

            RowLayout{
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.fillHeight: false
                Layout.fillWidth: true
                Rectangle {
                    //  anchors.centerIn:parent
                    //anchors.verticalCenterOffset : 0.075*imageBoard.width
                    Layout.preferredHeight: 0.11*imageBoard.width
                    // Layout.preferredWidth: 0.315*imageBoard.width

                    id: currentGauge2
                    color: "#00000000"
                    property real actualVal: 0
                    property string positive: "#00CCA3"
                    property string negative: "orange"
                    z: 1

                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Rectangle{
                        radius: daddy.fillet
                        anchors.left: parent.left
                        height: currentGauge2.height
                        width: currentGauge2.width*currentGauge2.value/currentGauge2.maximumValue
                        color:  (currentGauge2.actualVal >= 0) ? currentGauge2.positive : currentGauge2.negative
                    }
                    Text {
                        anchors.centerIn: parent
                        id: currentText2
                        text: qsTr("0 A")
                        z: 3
                        transformOrigin: Item.Top
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: 0.075*imageBoard.width
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                        Layout.fillWidth: true
                    }

                    antialiasing: false
                    Layout.fillHeight: false
                    Layout.fillWidth: true
                    property real minimumValue: 0
                    property real maximumValue: 60
                    property real value: 0


                    Behavior on value {
                        NumberAnimation {
                            easing.type: Easing.OutCirc
                            duration: 100
                        }
                    }
                }
            }
            RowLayout{
                Layout.fillHeight: false
                Layout.fillWidth: true
                Rectangle {
                    //  anchors.centerIn:parent
                    id: voltageGauge2
                    property real actualVal: 0
                    color: "#00000000"
                    property string positive: "#00CCA3"
                    property string negative: "orange"
                    z: 2
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Rectangle{
                        radius: daddy.fillet
                        anchors.left: parent.left
                        height:parent.height
                        width: voltageGauge2.width*voltageGauge2.value/voltageGauge2.maximumValue
                        color:  (voltageGauge2.actualVal >= 0) ? voltageGauge2.positive : voltageGauge2.negative
                    }
                    Text {
                        anchors.centerIn: voltageGauge2
                        id: powerText2
                        text: qsTr("0 V")
                        z: 4
                        transformOrigin: Item.Top
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: 0.075*imageBoard.width
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                        Layout.fillWidth: true
                    }
                    antialiasing: false
                    Layout.fillHeight: false
                    Layout.fillWidth: true
                    property real minimumValue: 0
                    property real maximumValue: 100
                    property real value: 0
                    Layout.preferredHeight: 0.11*imageBoard.width
                    Behavior on value {
                        NumberAnimation {
                            easing.type: Easing.OutCirc
                            duration: 100
                        }
                    }
                }
            }
        }



        ColumnLayout {
            anchors.centerIn: parent
            Layout.preferredWidth: 0.4*imageBoard.width
            Layout.preferredHeight:  0.6*imageBoard.width
            anchors.verticalCenterOffset: -0.2*imageBoard.width
            spacing: 10

            RowLayout{
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                Rectangle {
                    // anchors.centerIn:parent
                    Rectangle {
                        color: "#000000"
                        anchors.horizontalCenter: batteryGauge.horizontalCenter
                        anchors.verticalCenter: batteryGauge.verticalCenter
                        anchors.horizontalCenterOffset: batteryGauge.width/2.0
                        radius: daddy.fillet
                        width: 0.015*imageBoard.width
                        height: 0.05*imageBoard.width
                    }
                    id: batteryGauge
                    color: "#00000000"
                    radius: daddy.fillet
                    border.width:  0.0075*imageBoard.width
                    transformOrigin: Item.Center


                    property string full: "#00CCA3"
                    property string low: "red"

                    property real minimumValue: 0
                    property real maximumValue: 100
                    property real value: 100
                    z: 2
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Rectangle{
                        anchors.left: parent.left
                        height:parent.height
                        width: batteryGauge.width*batteryGauge.value/batteryGauge.maximumValue
                        color:  (batteryGauge.value >= 20) ? batteryGauge.full : batteryGauge.low
                        radius: 0.0075*imageBoard.width
                        z: -1
                    }


                    Text {
                        anchors.centerIn: parent
                        id: batteryText
                        text: qsTr("100%")
                        z: 4
                        transformOrigin: Item.Top
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: 0.075*imageBoard.width
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                        Layout.fillWidth: true
                    }
                    antialiasing: false
                    Layout.fillHeight: false
                    Layout.preferredWidth: 0.3*imageBoard.width
                    Layout.preferredHeight: 0.11*imageBoard.width
                    Behavior on value {
                        NumberAnimation {
                            easing.type: Easing.OutCirc
                            duration: 100
                        }
                    }
                }
            }
            RowLayout{
                Layout.fillWidth: true
                // spacing: 10
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                //anchors.centerIn: parent
                CircularGauge {
                    id: rpmGauge
                    z: 2
                    Layout.preferredWidth: 0.4*imageBoard.width
                    Layout.preferredHeight: 0.4*imageBoard.width
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    minimumValue: 0

                    maximumValue: 35
                    value: 0
                    style: CircularGaugeStyle {
                        tickmarkStepSize: 5
                        maximumValueAngle: 90
                        minimumValueAngle: -90
                        needle: Rectangle {
                            y: outerRadius * 0.15
                            implicitWidth: outerRadius * 0.03
                            implicitHeight: outerRadius * 0.9
                            antialiasing: true
                            color: "#00CCA3"
                        }
                    }

                    Behavior on value {
                        NumberAnimation {
                            easing.type: Easing.OutCirc
                            duration: 100
                        }
                    }
                    Text {
                        id: rpmText
                        text: qsTr("0 MPH")
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: 0.06*imageBoard.width
                        font.pixelSize: 0.075*imageBoard.width
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        Layout.fillWidth: true
                        Text {
                            id: tempText
                            anchors.centerIn:  parent
                            anchors.verticalCenterOffset: parent.height
                            anchors.horizontalCenterOffset: -parent.height*0.8
                            font.pixelSize: 0.04*imageBoard.width
                            text: qsTr("0 \u00B0C")
                            //Layout.fillWidth: true
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        }
                        Text {
                            id: tempText2
                            anchors.centerIn:  parent
                            anchors.verticalCenterOffset: parent.height
                            anchors.horizontalCenterOffset: parent.height*1.2
                            font.pixelSize: 0.04*imageBoard.width
                            text: qsTr("0 \u00B0C")
                            //Layout.fillWidth: true
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        }
                        Text {
                            id: faultText
                            z:5
                            anchors.centerIn:  parent
                            font.bold: true
                            anchors.verticalCenterOffset: -2*parent.height
                            color: "red"
                            //anchors.horizontalCenterOffset: parent.height*1.2
                            font.pixelSize: 0.025*imageBoard.width
                            text: qsTr("")
                            //Layout.fillWidth: true
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        }
                    }
                }
            }
        }
    }


    Connections {
        target: mMcConf

        onUpdated: {
            currentGauge.minimumValue = 0//-mMcConf.getParamDouble("l_current_max")
            currentGauge.maximumValue = mMcConf.getParamDouble("l_current_max")
            currentGauge2.minimumValue = 0//-mMcConf.getParamDouble("l_current_max")
            currentGauge2.maximumValue = mMcConf.getParamDouble("l_current_max")
        }
    }
    Connections {
        target: VescIf
        onPortConnectedChanged: {
            rpmTestButton.enabled = VescIf.isPortConnected()
        }
    }

    Connections {
        target: mCommands

        onValuesReceived: {

            currentGauge.actualVal = values.current_motor
            currentGauge.value = Math.abs(values.current_motor)
            currentGauge2.value = Math.abs(values.current_motor2)
            currentGauge2.actualVal = values.current_motor2
            currentText.text = parseFloat(values.current_motor).toFixed(0) + " A"
            currentText2.text = parseFloat(values.current_motor2).toFixed(0) + " A"
            voltageGauge.value = Math.abs(values.duty_now * values.v_in)
            voltageGauge2.value = Math.abs(values.duty_now2 * values.v_in)
            voltageGauge.actualVal = values.duty_now * values.v_in
            voltageGauge2.actualVal = values.duty_now2 * values.v_in
            voltageGauge.maximumValue = values.v_in
            voltageGauge2.maximumValue = voltageGauge.maximumValue
            powerText.text = parseFloat(values.duty_now * values.v_in).toFixed(0) + " V"
            powerText2.text = parseFloat(values.duty_now2 * values.v_in).toFixed(0) + " V"
            var v_min = mMcConf.getParamDouble("l_battery_cut_end")
            var v_max = v_min*4.2/3.1
            var battValue
            if(batteryGauge.value>0){
                battValue = 10*(values.v_in - v_min)/(v_max - v_min)+0.9*batteryGauge.value;
            }else{
                battValue = (values.v_in - v_min)/(v_max - v_min)*100;
            }
            if(battValue>100)
                battValue = 100
            if(battValue<0)
                battValue = 0
            batteryGauge.value = battValue
            var fl = mMcConf.getParamDouble("foc_motor_flux_linkage")
            var rpmMax = (values.v_in * 60.0) / (Math.sqrt(3.0) * 2.0 * Math.PI * fl)
            var rpmMaxRound = (Math.ceil(rpmMax / 5000.0) * 5000.0) / 1000.0
            rpmText.text = parseFloat(rpmGauge.value).toFixed(0) + " MPH"
            tac1 = values.tachometer
            tac2 = values.tachometer2

            rpmGauge.minimumValue = 0
            if(batterySwitch.checked)
                batteryText.text = parseFloat(batteryGauge.value).toFixed(0) + " %"
            else
                batteryText.text = parseFloat(values.v_in).toFixed(0) + " V"

            if(speedSwitch.checked){
                rpmGauge.value = Math.min(values.rpm,values.rpm2)/rpmconv.realValue*60*mmDiameter.value/1000.0*3.14*0.000621371 //to mph
                rpmGauge.maximumValue = 35
                rpmText.text = parseFloat(Math.round(rpmGauge.value,1)) + " MPH"
            }else{
                rpmGauge.value = Math.min(values.rpm,values.rpm2)/rpmconv.realValue*60*mmDiameter.value/1000.0*3.14*0.000621371*1.609//to kph
                rpmText.text = parseFloat(Math.round(rpmGauge.value,1)) + " KM/H"
                rpmGauge.maximumValue = 55
            }
            tempText.text = parseFloat(values.temp_mos).toFixed(0) + " \u00B0C"
            tempText2.text = parseFloat(values.temp_mos2).toFixed(0) + " \u00B0C"
            if(values.fault_str === "FAULT_CODE_NONE")
                faultText.text = ""
            else
                faultText.text = values.fault_str

            motorTempText.text = parseFloat(values.temp_motor).toFixed(0) + " \u00B0C"
            motorTempText2.text = parseFloat(values.temp_motor2).toFixed(0) + " \u00B0C"
            motorTempText.visible = values.temp_motor > 0;
            motorTempText2.visible = values.temp_motor2 > 0;
            var erpmToRpm = Math.max(Math.abs(startTac1 - tac1)/60.0, Math.abs(startTac2 - tac2)/60.0 )
            tacDifferential.text = "Current Measured Ratio: " + parseFloat(erpmToRpm).toFixed(1)

            /*valText.text =
                    "Battery    : " + parseFloat(values.v_in).toFixed(2) + " V\n" +
                    "I Battery  : " + parseFloat(values.current_in).toFixed(2) + " A\n" +
                    "Temp MOS   : " + parseFloat(values.temp_mos).toFixed(2) + " \u00B0C\n" +
                    "Temp Motor : " + parseFloat(values.temp_motor).toFixed(2) + " \u00B0C\n" +
                    "Ah Draw    : " + parseFloat(values.amp_hours * 1000.0).toFixed(1) + " mAh\n" +
                    "Ah Charge  : " + parseFloat(values.amp_hours_charged * 1000.0).toFixed(1) + " mAh\n" +
                    "Wh Draw    : " + parseFloat(values.watt_hours).toFixed(2) + " Wh\n" +
                    "Wh Charge  : " + parseFloat(values.watt_hours_charged).toFixed(2) + " Wh\n" +
                    "ABS Tacho  : " + values.tachometer_abs + " Counts\n" +
                    "Fault      : " + values.fault_str*/
        }
    }
    Dialog{
        id: testDialog
        modal: true
        focus: true
        width: parent.width - 20
        closePolicy: Popup.CloseOnEscape
        title:"ERPM TO RPM TEST"

        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        ColumnLayout{
            anchors.fill:parent
            spacing: 10
            Text{
                id: instructions
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: "Spin either skate wheel exctly 10 times in one direction, then press the APPLY button. It is reccomended to place a colored marker on the wheel to make full rotations easier to see."
            }
            RowLayout{
                Layout.fillWidth:  true
                Text{
                    id: tacDifferential
                    font.bold:  true
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    text: ""
                }
                Button {
                    Image{
                        source: "qrc:/res/icons/Refresh-96.png"
                        anchors.fill: parent
                    }
                    Layout.preferredWidth: height
                    onClicked: {
                        daddy.startTac1 = daddy.tac1
                        daddy.startTac2 = daddy.tac2
                    }
                }
            }
            Text{
                id: note
                font.italic:  true
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font.pixelSize: instructions.font.pixelSize*0.75
                horizontalAlignment: Text.AlignHCenter
                text: "This test should be run AFTER motor calibration"
            }
            RowLayout{
                Button {
                    //standardButtons: DialogButtonBox.Ok
                    Layout.fillWidth: true
                    text:"CANCEL"
                    Layout.alignment: Qt.AlignRight
                    onPressed: testDialog.close()
                }
                Button {
                    //standardButtons: DialogButtonBox.Ok
                    Layout.fillWidth: true
                    text:"APPLY"
                    Layout.alignment: Qt.AlignRight
                    onPressed: {
                        rpmconv.value = 10*Math.max(Math.abs(startTac1 - tac1)/60.0, Math.abs(startTac2 - tac2)/60.0)
                        testDialog.close()
                    }
                }
            }
        }

    }
    Dialog {
        id: settingsDialog
        title:"HUD CONFIG"
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

                ColumnLayout{
                    anchors.fill: parent
                    RowLayout{
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Text{
                            Layout.fillWidth: true
                            text: "Battery (V - %):"
                            horizontalAlignment: Text.AlignRight
                        }

                        Switch{
                            id: batterySwitch
                            Layout.preferredWidth: parent.width/2
                        }
                    }
                    RowLayout{
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Text{
                            Layout.fillWidth: true
                            text: "Speed (KM/H - MPH):"
                            horizontalAlignment: Text.AlignRight
                        }
                        Switch{
                            id: speedSwitch
                            Layout.preferredWidth: parent.width/2
                        }
                    }
                    RowLayout{
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Button{
                            id: rpmTestButton
                            Layout.fillWidth: true
                            enabled: false
                            text: "TEST ERPM -> RPM"

                            onPressed: {
                                if(VescIf.isPortConnected())
                                {
                                    daddy.startTac1 = daddy.tac1
                                    daddy.startTac2 = daddy.tac2
                                    testDialog.open()
                                }
                            }
                        }
                        SpinBox {
                            id: rpmconv
                            Layout.preferredWidth: parent.width/2
                            //Layout.fillWidth: true
                            // Layout.preferredHeight: 0.6*uibox.middleColumnWidth1
                            from: 0
                            value: 100
                            to: 100 * 10
                            stepSize: 2
                            // font.pixelSize: uibox.textSize1

                            property int decimals: 1
                            property real realValue: value / 10

                            validator: DoubleValidator {
                                bottom: Math.min(rpmconv.from, rpmconv.to)
                                top:  Math.max(rpmconv.from, rpmconv.to)
                            }
                            textFromValue: function(value, locale) {
                                return Number(value / 10).toLocaleString(locale, 'f', rpmconv.decimals)
                            }

                            valueFromText: function(text, locale) {
                                return Number.fromLocaleString(locale, text) * 10
                            }
                        }

                    }


                    RowLayout{
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Text{
                            Layout.fillWidth: true
                            text: "Wheel Diameter (mm):"
                            horizontalAlignment: Text.AlignRight
                        }
                        SpinBox {
                            id: mmDiameter
                            Layout.preferredWidth: parent.width/2
                            from: 0
                            value: 90
                            to: 500
                            stepSize: 1
                            editable:  true
                            // font.pixelSize: uibox.textSize1
                            textFromValue: function(value, locale) {
                                return Number(value).toLocaleString(locale, 'i', 0)
                            }
                        }
                    }
                }
            }
            DialogButtonBox {
                standardButtons: DialogButtonBox.Ok
                Layout.alignment: Qt.AlignRight

                onAccepted: settingsDialog.close()
            }
        }
    }

    Settings {
        id: settings
            property alias  mphOrKmh: batterySwitch.checked
            property alias  vOrPercent: speedSwitch.checked
            property alias  erpmToRpm: rpmconv.value
            property alias  wheelDiamter: mmDiameter.value
        }

}
