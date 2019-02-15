/*
    Copyright 2018 Benjamin Vedder	benjamin@vedder.se



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
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import QtCharts 2.2
import QtQuick.Window 2.11


import Vedder.vesc.vescinterface 1.0
import Vedder.vesc.commands 1.0
import Vedder.vesc.configparams 1.0
import Vedder.vesc.utility 1.0
import Vedder.vesc.bleuart 1.0

Item{
    anchors.fill: parent
    anchors.topMargin: uibox.spaceVertical
    anchors.bottomMargin: uibox.spaceVertical
    anchors.rightMargin:uibox.spaceVertical
    anchors.leftMargin: uibox.spaceVertical
    id: item1

    //width:5000
    //height: 2000
    property alias confPageBattery: item1
    property alias  batterySettingsButton: batterySettingsButton
    property alias  motorSettingsButton: motorSettingsButton
    property alias  appSettingsButton: appSettingsButton

    property alias  batterySettingsWindow: batterySettingsWindow
    property alias  motorSettingsWindow: motorSettingsWindow
    property alias  appSettingsWindow: appSettingsWindow

    property alias  columnLayoutProps: columnLayoutProps
    property bool configNotUpdating: true
    property bool motorConfUpdated: false
    property bool appConfUpdated: false
    property bool motorConfWritten: false
    property bool appConfWritten: false
    property double durAnim: 250
    property double maxBattcurrent: 120.0
    property double battCurrent: 0.0
    property double battCharge: 0.0

    property double battMinCutoff: 0
    property double battMaxCutoff: 0


    property double res: 0.0
    property double ind: 0.0
    property double lambda: 0.0
    property double kp: 0.0
    property double ki: 0.0
    property double gain: 0.0

    property double res2: 0.0
    property double ind2: 0.0
    property double lambda2: 0.0
    property double kp2: 0.0
    property double ki2: 0.0
    property double gain2: 0.0

    property var table: []
    property bool useHallSenors1:false
    property bool useHallSenors2:false

    property bool inv1: false
    property bool inv2: false

    property bool writeBothConfig: true

    property double maxHWcurrent: 100.0

    property double maxCurrent1: 0.0
    property double maxCurrent2: 0.0

    property double maxBrakeCurrent1: 0.0
    property double maxBrakeCurrent2: 0.0

    property double msMin: 1.0
    property double msMax: 1.5
    property double msCenter: 2.0

    property double msMinTest: 1.0
    property double msMaxTest: 1.5
    property double msCenterTest: 2.0

    property double msNow: 1.5

    property double valueNow: 0.5
    property bool resetDone: true
    property bool sendCanStatus: false
    property double previousAppToUse
    property double previousRemoteMode

    property double torqueCurveMode: 2 //0 power 1 expo 2 poly
    property double torqueCurveAccel: 0
    property double torqueCurveBrake: 0
    property double deadZone:0.15

    property double secondsToOff: 1.5
    property double minutesToOff: 10
    property bool pushToStart: true

    property double motorTemp: 135
    property bool motorTempEnable: true
    property double motorBeta: 4100

    property Commands mCommands: VescIf.commands()
    property ConfigParams mAppConf: VescIf.appConfig()
    property ConfigParams mInfoConf: VescIf.infoConfig()
    property alias roundButton: roundButton
    property ConfigParams mMcConf: VescIf.mcConfig()
    property BleUart mBle: VescIf.bleDevice()




    function calcKpKi() {
        if (res < 1e-10) {
            VescIf.emitMessageDialog("Calculate Error",
                                     "R is 0. Please measure it first.",
                                     false, false)
            return;
        }

        if (ind < 1e-10) {
            VescIf.emitMessageDialog("Calculate Error",
                                     "L is 0. Please measure it first.",
                                     false, false)
            return;
        }

        // https://e2e.ti.com/blogs_/b/motordrivecontrol/archive/2015/07/20/teaching-your-pi-controller-to-behave-part-ii

        kp = ind / (1000.0* 1e-6)
        console.log("kp is ", kp)


        ki = res / (1000.0* 1e-6)
    }
    function calcKpKi2() {
        if (res2 < 1e-10) {
            VescIf.emitMessageDialog("Calculate Error",
                                     "R2 is 0. Please measure it first.",
                                     false, false)
            return;
        }

        if (ind2 < 1e-10) {
            VescIf.emitMessageDialog("Calculate Error",
                                     "L2 is 0. Please measure it first.",
                                     false, false)
            return;
        }

        // https://e2e.ti.com/blogs_/b/motordrivecontrol/archive/2015/07/20/teaching-your-pi-controller-to-behave-part-ii
        var tc = 1000.0* 1e-6
        var bw = 1.0 / tc
        kp2 = ind2 * bw;
        ki2 = res2 * bw;
    }
    function calcGain() {
        if (lambda < 1e-10) {
            VescIf.emitMessageDialog("Calculate Error",
                                     "\u03BB1 is 0. Please measure it first.",
                                     false, false)
            return;
        }
        gain = 0.001 / (lambda * lambda)*1e6
    }
    function calcGain2() {
        if (lambda2 < 1e-10) {
            VescIf.emitMessageDialog("Calculate Error",
                                     "\u03BB2 is 0. Please measure it first.",
                                     false, false)
            return;
        }
        gain2 = 0.001 / (lambda2 * lambda2)*1e6
    }
    function updateDisplay() {
        txtMinTest.text = "Min: " + parseFloat(msMinTest).toFixed(2) + " ms"
        txtNowTest.text = "Now: " + parseFloat(msNow).toFixed(2) + " ms"
        txtMaxTest.text = "Max: " + parseFloat(msMaxTest).toFixed(2) + " ms"
        txtNow.text = parseFloat(valueBar.value*100).toFixed(0) + "%"
        valueBar.value = (msNow - (msMax + msMin)/2.0)/((msMax + msMin)/2.0 - msMin)
        valueBarTest.value = (msNow - (msMaxTest + msMinTest)/2.0)/((msMaxTest + msMinTest)/2.0 - msMinTest)
    }
    function updateGraphics() {

        resistanceText1.text = parseFloat(res*1000).toFixed(0) + " mΩ"
        resistanceText2.text = parseFloat(res2*1000).toFixed(0) + " mΩ"
        inductorText1.text = parseFloat(ind*1e6).toFixed(0) + " uH"
        inductorText2.text = parseFloat(ind2*1e6).toFixed(0) + " uH"

        thermalSwitch.checked = motorTempEnable
        slider9.value =  (motorBeta -2600.0)/3000.0
        slider8.value = (motorTemp - 75.0)/60.0

        rectangle1.rotation = (table[1]<201.0) ? table[1]*360.0/200.0 : 180.0
        rectangle2.rotation = (table[2]<201.0) ? table[2]*360.0/200.0 : 180.0
        rectangle3.rotation = (table[3]<201.0) ? table[3]*360.0/200.0 : 180.0
        rectangle4.rotation = (table[4]<201) ? table[4]*360.0/200.0 : 180.0
        rectangle5.rotation = (table[5]<201) ? table[5]*360.0/200.0 : 180.0
        rectangle6.rotation = (table[6]<201) ? table[6]*360.0/200.0 : 180.0

        rectangle7.rotation = (table[9]<201.0) ? table[9]*360.0/200.0 : 0.0
        rectangle8.rotation = (table[10]<201.0) ? table[10]*360.0/200.0 : 0.0
        rectangle9.rotation = (table[11]<201.0) ? table[11]*360.0/200.0 : 0.0
        rectangle10.rotation = (table[12]<201.0) ? table[12]*360.0/200.0 : 0.0
        rectangle11.rotation = (table[13]<201.0) ? table[13]*360.0/200.0 : 0.0
        rectangle12.rotation = (table[14]<201.0) ? table[14]*360.0/200.0 : 0.0




        fluxLinkageText1.text = parseFloat(lambda*1000).toFixed(1) + " mWb"
        fluxLinkageText2.text = parseFloat(lambda2*1000).toFixed(1) + " mWb"

        currText1.text = parseFloat(maxCurrent1).toFixed(0) + " A"
        currText2.text = parseFloat(maxCurrent2).toFixed(0) + " A"
        slider.value = maxCurrent1/maxHWcurrent

        currBrakeText1.text = parseFloat(maxBrakeCurrent1).toFixed(0) + " A"
        currBrakeText2.text = parseFloat(maxBrakeCurrent2).toFixed(0) + " A"
        slider2.value = -maxBrakeCurrent1/maxHWcurrent

        image7.mirror = inv1
        image8.mirror = inv2
        roundButton.checked = inv1
        roundButton2.checked = inv2


        startVoltCutoff.value = Math.round(battMaxCutoff*10.0);
        endVoltCutoff.value = Math.round(battMinCutoff*10.0);

        batteryCurrentText.text = parseFloat(battCurrent).toFixed(0) + " A"
        battCurrentSlider.value = battCurrent/maxBattcurrent

        batteryDischargeText.text = parseFloat(battCharge).toFixed(0) + " A"
        battChargeSlider.value = -battCharge/(maxBattcurrent)

        torqueCurveModeComboBox.currentIndex = torqueCurveMode
        slider7.value = (torqueCurveAccel + 5.0)*0.1
        slider10.value = (torqueCurveBrake + 5.0)*0.1

        pushToStartSwitch.checked = pushToStart
        
        slider5.value = minutesToOff/60.0
        slider6.value = (secondsToOff - 1.5)*2/17.0
        
        drawTorqueCurve()
    }
    function applyMotorConfig() {
        mMcConf.updateParamEnum("motor_type",2,item1)
        mMcConf.updateParamEnum("m_sensor_port_mode",0,item1)
        mMcConf.updateParamEnum("m_sensor_port_mode2",0,item1)

        if(useHallSenors1)
            mMcConf.updateParamEnum("foc_sensor_mode",2)
        else
            mMcConf.updateParamEnum("foc_sensor_mode",0)

        if(useHallSenors2)
            mMcConf.updateParamEnum("foc_sensor_mode2",2)
        else
            mMcConf.updateParamEnum("foc_sensor_mode2",0)

        calcKpKi()
        calcKpKi2()
        calcGain()
        calcGain2()

        mMcConf.updateParamDouble("foc_motor_r", res, item1);
        mMcConf.updateParamDouble("foc_motor_r2", res2, item1);
        mMcConf.updateParamDouble("foc_motor_l", ind, item1);
        mMcConf.updateParamDouble("foc_motor_l2", ind2, item1);
        console.log("kp is right before", kp)
        mMcConf.updateParamDouble("foc_current_kp", kp);
        mMcConf.updateParamDouble("foc_current_ki", ki);
        mMcConf.updateParamDouble("foc_current_kp2", kp2, item1);
        mMcConf.updateParamDouble("foc_current_ki2", ki2, item1);
        for(var i = 0;i < 7;i++) {
            mMcConf.updateParamInt("foc_hall_table_" + i, table[i],item1)
            mMcConf.updateParamInt("foc_hall2_table_" + i,table[i+8],item1)
        }
        mMcConf.updateParamBool("m_invert_direction",inv1,item1)
        mMcConf.updateParamBool("m_invert_direction2",inv2,item1)

        mMcConf.updateParamDouble("foc_motor_flux_linkage",lambda,item1)
        mMcConf.updateParamDouble("foc_motor_flux_linkage2",lambda2,item1)
        mMcConf.updateParamDouble("foc_observer_gain",gain,item1)
        mMcConf.updateParamDouble("foc_observer_gain2",gain2,item1)

        mMcConf.updateParamDouble("l_current_max",maxCurrent1,item1)
        mMcConf.updateParamDouble("l_current_min",maxBrakeCurrent1,item1)


        mMcConf.updateParamDouble("l_battery_cut_start",battMaxCutoff,item1)
        mMcConf.updateParamDouble("l_battery_cut_end", battMinCutoff,item1)

        mMcConf.updateParamDouble("l_in_current_min",battCharge,item1)
        mMcConf.updateParamDouble("l_in_current_max",battCurrent,item1)

        mMcConf.updateParamDouble("l_temp_motor_end", (motorTemp + 35), item1);
        mMcConf.updateParamDouble("l_temp_motor_start", (motorTemp-35), item1);
        mMcConf.updateParamDouble("m_ntc_motor_beta", motorBeta, item1);
        mMcConf.updateParamBool("m_motor_temp_throttle_enable",motorTempEnable,item1)

        mCommands.setMcconf(true)
    }
    function applyAppConfig() {
        mAppConf.updateParamDouble("app_ppm_conf.pulse_start", msMin)
        mAppConf.updateParamDouble("app_ppm_conf.pulse_end", msMax)
        mAppConf.updateParamDouble("app_ppm_conf.pulse_center", msCenter)


        if(ppmModeComboBox.currentIndex !== 0 && uartBaudComboBox.currentIndex !== 0)
        {
            mAppConf.updateParamEnum("app_to_use", 4);
        }else if(ppmModeComboBox.currentIndex !== 0)
        {
            mAppConf.updateParamEnum("app_to_use", 1);
        }else if(uartBaudComboBox.currentIndex !== 0)
        {
            mAppConf.updateParamEnum("app_to_use", 4);
        }else{
            mAppConf.updateParamEnum("app_to_use", 1);
        }

        switch(ppmModeComboBox.currentIndex)
        {
        case 0:
            mAppConf.updateParamEnum("app_ppm_conf.ctrl_type", 0);
            break;
        case 1:
            mAppConf.updateParamEnum("app_ppm_conf.ctrl_type", 1);
            break;
        case 2:
            mAppConf.updateParamEnum("app_ppm_conf.ctrl_type", 3);
            break;
        }

        switch(uartBaudComboBox.currentIndex)
        {
        case 0:
        case 1:
            mAppConf.updateParamInt("app_uart_baudrate", 9600);
            break;
        case 2:
            mAppConf.updateParamInt("app_uart_baudrate", 115200);
            break;
        }

        mAppConf.updateParamBool("app_ppm_conf.tc", false);
        mAppConf.updateParamBool("app_ppm_conf.median_filter", true);
        mAppConf.updateParamBool("app_ppm_conf.safe_start", true);
        mAppConf.updateParamEnum("can_baud_rate", 2);

        mAppConf.updateParamEnum("app_ppm_conf.throttle_exp_mode", torqueCurveMode);
        mAppConf.updateParamDouble("app_ppm_conf.throttle_exp", torqueCurveAccel)
        mAppConf.updateParamDouble("app_ppm_conf.throttle_exp_brake", torqueCurveBrake)
        mAppConf.updateParamDouble("app_ppm_conf.hyst", deadZone)

        mAppConf.updateParamInt("app_smart_switch_conf.msec_pressed_for_off", Math.round(1000*secondsToOff))
        mAppConf.updateParamInt("app_smart_switch_conf.sec_inactive_for_off", Math.round(60*minutesToOff))
        mAppConf.updateParamBool("app_smart_switch_conf.push_to_start_enabled", pushToStart)



        switch(canModeComboBox.currentIndex)
        {
        case 0:
            mAppConf.updateParamBool("app_ppm_conf.multi_esc", false);
            mAppConf.updateParamBool("send_can_status", false);
            break;
        case 1:
            mAppConf.updateParamBool("app_ppm_conf.multi_esc", true);
            mAppConf.updateParamBool("send_can_status", false);
            mAppConf.updateParamInt("controller_id", 0);
            break;
        case 2:
            mAppConf.updateParamBool("app_ppm_conf.multi_esc", false);
            mAppConf.updateParamBool("send_can_status", true);
            mAppConf.updateParamInt("send_can_status_rate_hz", 500);
            mAppConf.updateParamInt("controller_id", 1);
            break;
        }

        mCommands.setAppConf()
    }
    function setPPMTestAppConfig() {
        writeBothConfig = false
        item1.configNotUpdating = false
        previousAppToUse = mAppConf.getParamEnum("app_to_use");
        previousRemoteMode = mAppConf.getParamEnum("app_ppm_conf.ctrl_type");
        mAppConf.updateParamEnum("app_to_use", 4);
        mAppConf.updateParamEnum("app_ppm_conf.ctrl_type", 0);
        mCommands.setAppConf();

    }
    function revertAppConfig() {
        writeBothConfig = false
        item1.configNotUpdating = false
        mAppConf.updateParamEnum("app_to_use", previousAppToUse);
        mAppConf.updateParamEnum("app_ppm_conf.ctrl_type", previousRemoteMode);
        mCommands.setAppConf();

    }
    function drawTorqueCurve() {
        throttleCurve.removePoints(0,41)
        for(var i = -20; i<21; i++){
            var throt = 100.0*Utility.throttle_curve(i/20.0,torqueCurveAccel,torqueCurveBrake,torqueCurveMode)
            throttleCurve.append(5.0*i,throt)
        }
    }

    ColumnLayout{
        clip: true
        id: uibox
        anchors.topMargin: spaceVertical
        anchors.bottomMargin: spaceVertical
        anchors.rightMargin: spaceVertical
        anchors.leftMargin: spaceVertical
        anchors.centerIn: parent
        spacing: spaceVertical
        RowLayout {
            id: rowLayout11
            // spacing: 0.035*uibox.widthIcon
            spacing: uibox.spaceVertical
            Button {
                id: buttonReadCurrent
                text: qsTr("Read Current Config")
                Layout.fillWidth:true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                font.pixelSize: uibox.textSize1
                enabled: false
                onClicked: {
                    mCommands.getMcconf()
                    mCommands.getAppConf()
                    buttonReadCurrent.enabled = false
                }
            }
            Button {
                id: buttonApplyValues
                text: qsTr("Apply Updated Config")
                font.pixelSize: uibox.textSize1
                Layout.fillWidth: true
                //    Layout.preferredHeight: 0.6*uibox.middleColumnWidth1
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                enabled: false

                onClicked: {
                    item1.configNotUpdating = false
                    applyAppConfig()
                    buttonApplyValues.enabled = false
                    calibrationButton.enabled = false
                }
            }
        }


        property double widthIcon: buttonReadCurrent.height/0.12//Math.min(parent.width,parent.height)
        //width:Math.min(parent.width,parent.height)
        width: parent.width
        height:parent.height
        // contentWidth: width
        // height: Math.max(1.5*widthIcon,parent.height)
        //height:Math.max(5.0/2.0*uibox.widthIcon,parent.height)
        //anchors.centerIn: parent
        property double textSize1: 0.035*uibox.widthIcon
        property double textSize2: 0.035*uibox.widthIcon
        property color accent1: "#AA00CCA3"
        property double symbolWidth1: 0.18*uibox.widthIcon
        property double imageFade1: 0.3
        property double middleColumnWidth1: 0.2*uibox.widthIcon
        property double hallDotSize1: 0.025*uibox.widthIcon
        property double hallDotBorderSize1: 0.005*uibox.widthIcon
        property double spaceVertical: buttonReadCurrent.height/8.0
        //bottomPadding: 10
        Flickable {
            Layout.fillHeight: true
            Layout.fillWidth: true
            //ScrollBar.vertical.interactive: false
            //Flickable.interactive: false
            //Flickable.onContentYChanged: Flickable.contentY = 0
            boundsBehavior: Flickable.DragAndOvershootBounds
            contentHeight: contentItem.childrenRect.height
            contentWidth: width


            id: columnLayoutProps
            anchors.rightMargin: 0
            anchors.topMargin: 0
            anchors.bottomMargin: 0
            anchors.leftMargin: 0
            clip:true

            //spacing: 0.035*uibox.widthIcon
            //anchors.topMargin: 10
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            ColumnLayout{
                spacing: uibox.spaceVertical
                anchors.top: parent.top
                width: parent.width
                anchors.rightMargin: 0
                anchors.bottomMargin: 0
                anchors.leftMargin: 0
                onImplicitHeightChanged: columnLayoutProps.contentHeight = implicitHeight
                ColumnLayout{
                    spacing: uibox.spaceVertical
                    id:batterySettingsWindow
                    Layout.fillWidth: true
                    clip: true
                    Layout.preferredHeight: batterySettingsButton.height
                    //  spacing: 0.035*uibox.widthIcon
                    Behavior on Layout.preferredHeight {
                        NumberAnimation {
                            id: battAnim
                            easing.type: Easing.OutCirc
                            duration: item1.durAnim
                            onRunningChanged: {
                                if(batterySettingsWindow.Layout.preferredHeight === batterySettingsWindow.implicitHeight && running === false && battAnim.duration === item1.durAnim)
                                {
                                    battAnim.duration = 0
                                    batterySettingsWindow.Layout.preferredHeight = -1;
                                }
                            }
                        }
                    }

                    Button{
                        id:batterySettingsButton
                        //horizontalAlignment: Text.AlignHCenter
                        Layout.fillWidth: true
                        text: "BATTERY LIMITS"
                        font.bold: true
                        font.pixelSize: uibox.textSize1
                        //Layout.fillWidth: true
                        //bottomPadding: 10
                        //leftPadding: 5
                        //rightPadding: 5
                        //topPadding:2*uibox.textSize2
                        Rectangle{
                            id:arrowBatt
                            color:"#00000000"
                            Rectangle{
                                width:parent.width
                                color:"black"
                                height:0.2*parent.height
                                anchors.top:parent.top
                                radius:height/2
                            }
                            Rectangle{
                                height:parent.height
                                color:"black"
                                width:0.2*parent.width
                                anchors.right:parent.right
                                radius:width/2
                            }

                            anchors.centerIn: parent
                            height:parent.height*0.4
                            width: height
                            anchors.horizontalCenterOffset: 0.5*parent.width - 1.4*width
                            rotation: 45
                            Behavior on rotation {
                                NumberAnimation {
                                    duration: item1.durAnim
                                    easing.type: Easing.OutCirc
                                }
                            }
                        }

                        onClicked: {

                            if(batterySettingsWindow.Layout.preferredHeight === batterySettingsButton.height){
                                battAnim.duration = item1.durAnim
                                arrowBatt.rotation = 135
                                batterySettingsWindow.Layout.preferredHeight = batterySettingsWindow.implicitHeight
                                //battTim.start()
                            }
                            else{
                                arrowBatt.rotation = 45
                                battAnim.duration = 0
                                batterySettingsWindow.Layout.preferredHeight = batterySettingsWindow.implicitHeight
                                battAnim.duration = item1.durAnim
                                batterySettingsWindow.Layout.preferredHeight = batterySettingsButton.height
                            }
                        }
                    }

                    RowLayout{
                        Text {
                            Layout.fillHeight: false
                            Layout.fillWidth:  true
                            text: qsTr("SERIES CELLS\r\n(LI-ION)")
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.pixelSize: uibox.textSize1
                        }
                        Text {
                            Layout.fillHeight: false
                            Layout.fillWidth:  true
                            text: qsTr("CUTOFF START\r\n(VOLTS)")
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.pixelSize: uibox.textSize1
                        }
                        Text {
                            Layout.fillHeight: false
                            Layout.fillWidth:  true
                            text: qsTr("CUTOFF END\r\n(VOLTS)")
                            horizontalAlignment: Text.AlignHCenter
                            font.bold: true
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.pixelSize: uibox.textSize1
                        }

                    }

                    RowLayout {
                        //spacing: 0.035*uibox.widthIcon
                        ComboBox {
                            id: seriesCells
                            //Layout.fillHeight: true
                            Layout.fillWidth:  true
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                            transformOrigin: Item.Center
                            font.pixelSize: uibox.textSize1
                            // Layout.preferredHeight: 0.6*uibox.middleColumnWidth1

                            model: [
                                "3 cells",
                                "4 cells",
                                "5 cells",
                                "6 cells",
                                "7 cells",
                                "8 cells",
                                "9 cells",
                                "10 cells",
                                "11 cells",
                                "12 cells",
                                "Custom Voltages"
                            ]

                            onCurrentTextChanged: {
                                if(currentText === "Custom Voltages"){
                                    // item1.battMaxCutoff = 11.0
                                    // item1.battMinCutoff = 9.0
                                    startVoltCutoff.enabled = true
                                    endVoltCutoff.enabled = true
                                    updateGraphics()
                                }else{
                                    var numcells = parseInt(currentText)
                                    item1.battMaxCutoff = numcells*3.4
                                    item1.battMinCutoff = numcells*3.1
                                    startVoltCutoff.enabled = false
                                    endVoltCutoff.enabled = false
                                    updateGraphics()
                                }
                            }
                        }

                        SpinBox {
                            id: startVoltCutoff
                            //Layout.preferredWidth: uibox.symbolWidth1*2
                            Layout.fillWidth:  true
                            // Layout.preferredHeight: 0.6*uibox.middleColumnWidth1
                            from: 0
                            value: 110
                            to: 100 * 10
                            stepSize: 2
                            font.pixelSize: uibox.textSize1

                            property int decimals: 1
                            property double doubleValue: value / 10

                            validator: DoubleValidator {
                                bottom: Math.min(startVoltCutoff.from, startVoltCutoff.to)
                                top:  Math.max(startVoltCutoff.from, startVoltCutoff.to)
                            }
                            onValueChanged: {
                                item1.battMaxCutoff = startVoltCutoff.value/10
                            }

                            textFromValue: function(value, locale) {
                                return Number(value / 10).toLocaleString(locale, 'f', startVoltCutoff.decimals)
                            }

                            valueFromText: function(text, locale) {
                                return Number.fromLocaleString(locale, text) * 10
                            }
                        }

                        SpinBox {
                            id: endVoltCutoff
                            //Layout.preferredWidth: uibox.symbolWidth1*2
                            Layout.fillWidth:  true
                            // Layout.preferredHeight: 0.6*uibox.middleColumnWidth1
                            from: 0
                            value: 110
                            to: 100 * 10
                            stepSize: 2
                            font.pixelSize: uibox.textSize1

                            property int decimals: 1
                            property double doubleValue: value / 10

                            validator: DoubleValidator {
                                bottom: Math.min(endVoltCutoff.from, endVoltCutoff.to)
                                top:  Math.max(endVoltCutoff.from, endVoltCutoff.to)
                            }
                            onValueChanged: {
                                item1.battMinCutoff = endVoltCutoff.value/10
                            }

                            textFromValue: function(value, locale) {
                                return Number(value / 10).toLocaleString(locale, 'f', endVoltCutoff.decimals)
                            }

                            valueFromText: function(text, locale) {
                                return Number.fromLocaleString(locale, text) * 10
                            }
                        }

                    }

                    RowLayout {
                        Layout.fillHeight: false
                        Text {
                            text: qsTr(" ")
                            Layout.preferredWidth: uibox.symbolWidth1*1.6
                            horizontalAlignment: Text.AlignHCenter
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.pixelSize: uibox.textSize1
                        }
                        Text {
                            id: labelTxt
                            text: qsTr("MAX BATTERY\r\nDISCHARGE CURRENT")
                            Layout.preferredHeight: buttonReadCurrent.height
                            Layout.fillHeight: false
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.pixelSize: uibox.textSize1
                            font.bold: true
                        }
                        Text {
                            id: batteryCurrentText
                            text: qsTr("0 A")

                            Layout.preferredWidth: uibox.symbolWidth1*1.6
                            horizontalAlignment: Text.AlignHCenter
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.pixelSize: 2*labelTxt.font.pixelSize
                        }

                    }

                    RowLayout {
                        Slider {
                            id: battCurrentSlider
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            Layout.fillWidth: true
                            value: 0
                            Layout.preferredHeight: buttonReadCurrent.height*2/3

                            onValueChanged:  {
                                item1.battCurrent = Math.round(value*item1.maxBattcurrent)
                                updateGraphics()
                            }
                        }
                    }


                    RowLayout {
                        Layout.fillHeight: false
                        Text {
                            text: qsTr(" ")
                            Layout.preferredWidth: uibox.symbolWidth1*1.6
                            horizontalAlignment: Text.AlignHCenter
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.pixelSize: uibox.textSize1
                        }
                        Text {
                            text: qsTr("MAX BRAKING\r\nREGEN CURRENT")
                            Layout.fillHeight: false
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            Layout.preferredHeight: buttonReadCurrent.height
                            font.pixelSize: uibox.textSize1
                            font.bold: true
                        }
                        Text {
                            id: batteryDischargeText
                            text: qsTr("0 A")
                            Layout.preferredWidth: uibox.symbolWidth1*1.6
                            horizontalAlignment: Text.AlignHCenter
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.pixelSize: 2*labelTxt.font.pixelSize
                        }
                    }


                    RowLayout {
                        Slider {
                            id: battChargeSlider
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            Layout.fillWidth: true
                            Layout.preferredHeight: buttonReadCurrent.height*2/3
                            value: 0

                            onValueChanged:  {
                                item1.battCharge = Math.round(-value*item1.maxBattcurrent)
                                updateGraphics()
                            }
                        }
                    }





                }
                ColumnLayout{
                    id:motorSettingsWindow
                    Layout.fillWidth: true
                    clip: true
                    spacing: uibox.spaceVertical
                    Layout.preferredHeight: motorSettingsButton.height
                    //   spacing: 0.035*uibox.widthIcon
                    Behavior on Layout.preferredHeight {
                        NumberAnimation {
                            id: motorAnim
                            easing.type: Easing.OutCirc
                            duration: item1.durAnim
                            onRunningChanged: {
                                if(motorSettingsWindow.Layout.preferredHeight === motorSettingsWindow.implicitHeight && motorAnim.running === false && motorAnim.duration === item1.durAnim)
                                {
                                    motorAnim.duration = 0
                                    motorSettingsWindow.Layout.preferredHeight = -1;
                                }
                            }
                        }
                    }

                    Button{
                        id:motorSettingsButton
                        Layout.fillWidth: true
                        text: "MOTOR CALIBRATION"
                        font.bold: true
                        font.pixelSize: uibox.textSize1
                        Rectangle{
                            id:arrowMotor
                            color:"#00000000"
                            Rectangle{
                                width:parent.width
                                color:"black"
                                height:0.2*parent.height
                                anchors.top:parent.top
                                radius:height/2
                            }
                            Rectangle{
                                height:parent.height
                                color:"black"
                                width:0.2*parent.width
                                anchors.right:parent.right
                                radius:width/2
                            }

                            anchors.centerIn: parent
                            height:parent.height*0.4
                            width: height
                            anchors.horizontalCenterOffset: 0.5*parent.width - 1.4*width
                            rotation: 45
                            Behavior on rotation {
                                NumberAnimation {
                                    duration: item1.durAnim
                                    easing.type: Easing.OutCirc
                                }
                            }
                        }
                        onClicked: {
                            if(motorSettingsWindow.Layout.preferredHeight === motorSettingsButton.height){
                                motorAnim.duration = item1.durAnim
                                arrowMotor.rotation = 135
                                motorSettingsWindow.Layout.preferredHeight = motorSettingsWindow.implicitHeight
                            }
                            else{
                                motorAnim.duration = 0
                                motorSettingsWindow.Layout.preferredHeight = motorSettingsWindow.implicitHeight
                                arrowMotor.rotation = 45
                                motorAnim.duration = item1.durAnim
                                motorSettingsWindow.Layout.preferredHeight = motorSettingsButton.height
                            }
                        }
                    }

                    RowLayout {
                        spacing: 0
                        id: rowLayout1
                        Layout.fillHeight: false
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        height: 0.4*uibox.middleColumnWidth1
                        focus: true

                        Text {
                            id: text2
                            text: qsTr("MOTOR 1")
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            Layout.fillHeight: false
                            Layout.preferredWidth: uibox.symbolWidth1*1.75
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.pixelSize: uibox.textSize1
                        }

                        Button {
                            id: button
                            text: qsTr("Start Test")
                            font.pixelSize: uibox.textSize1
                            Layout.fillWidth: true
                            //Layout.preferredHeight: 0.6*uibox.middleColumnWidth1
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            enabled:false
                            onClicked: {
                                mCommands.measureRL()
                                button.enabled = false
                            }
                        }

                        Text {
                            id: text1
                            text: qsTr("MOTOR 2")
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            Layout.fillHeight: false
                            Layout.preferredWidth: uibox.symbolWidth1*1.75
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.pixelSize: uibox.textSize1

                        }

                    }

                    RowLayout {
                        spacing: 0
                        id: rowLayout2
                        Layout.fillHeight: false
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                        //height: 0.6*uibox.symbolWidth1
                        Rectangle{
                            Layout.preferredWidth: 2*uibox.symbolWidth1
                            Layout.preferredHeight:  0.6*uibox.symbolWidth1
                            color:"#00000000"
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            Rectangle{
                                id:bgres1
                                anchors.fill:parent
                                radius:height/10
                                color: uibox.accent1
                                opacity: 0

                                Behavior on opacity {
                                    NumberAnimation {
                                        easing.type: Easing.OutCirc
                                        duration: 1000
                                    }
                                }
                            }


                            RowLayout{
                                spacing: -0.5
                                anchors.fill:parent

                                ColumnLayout{
                                    width:uibox.symbolWidth1
                                    height: 0.6*uibox.symbolWidth1

                                    Image {
                                        id: image1
                                        sourceSize.height: 623
                                        sourceSize.width: 212
                                        Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                                        opacity: uibox.imageFade1
                                        Layout.preferredHeight: 0.35*uibox.symbolWidth1
                                        Layout.preferredWidth: uibox.symbolWidth1
                                        fillMode: Image.PreserveAspectFit
                                        mirror:true
                                        source: "qrc:/res/resistor.png"
                                    }
                                    Text {
                                        id: resistanceText1
                                        opacity: 1
                                        text: qsTr("0 mΩ")
                                        verticalAlignment: Text.AlignVCenter
                                        horizontalAlignment: Text.AlignHCenter
                                        Layout.preferredWidth: uibox.symbolWidth1
                                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                                        font.pixelSize: labelTxt.font.pixelSize * 0.75
                                    }
                                }


                                ColumnLayout{
                                    width:uibox.symbolWidth1
                                    height: 0.6*uibox.symbolWidth1

                                    Image {
                                        id: image3
                                        Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                                        sourceSize.height: 623
                                        sourceSize.width: 212
                                        opacity: uibox.imageFade1
                                        Layout.preferredHeight: 0.35*uibox.symbolWidth1
                                        Layout.preferredWidth: uibox.symbolWidth1
                                        fillMode: Image.PreserveAspectFit
                                        source: "qrc:/res/inductor.png"
                                    }
                                    Text {
                                        id: inductorText1
                                        opacity: 1
                                        text: qsTr("0 uH")
                                        Layout.columnSpan: 0
                                        Layout.rowSpan: 0
                                        verticalAlignment: Text.AlignVCenter
                                        horizontalAlignment: Text.AlignHCenter
                                        Layout.preferredWidth: uibox.symbolWidth1
                                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                                        font.pixelSize: labelTxt.font.pixelSize * 0.75
                                    }
                                }
                            }
                        }



                        Text {

                            id: text4
                            text: qsTr("R/L")
                            verticalAlignment: Text.AlignVCenter
                            Layout.columnSpan: 1
                            Layout.fillWidth: true
                            Layout.preferredWidth: uibox.middleColumnWidth1
                            height: 0.4*uibox.middleColumnWidth1
                            horizontalAlignment: Text.AlignHCenter
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.pixelSize:  labelTxt.font.pixelSize * 2
                            font.bold: true
                        }

                        Rectangle{
                            Layout.preferredWidth: 2*uibox.symbolWidth1
                            Layout.preferredHeight:  0.6*uibox.symbolWidth1
                            color:"#00000000"
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            Rectangle{
                                id:bgres2
                                anchors.fill:parent
                                radius:height/10
                                color: uibox.accent1
                                opacity: 0

                                Behavior on opacity {
                                    NumberAnimation {
                                        easing.type: Easing.OutCirc
                                        duration: 1000
                                    }
                                }
                            }


                            RowLayout{
                                spacing: -0.5
                                anchors.fill:parent
                                ColumnLayout{
                                    width:uibox.symbolWidth1
                                    height: 0.6*uibox.symbolWidth1
                                    Image {
                                        id: image4
                                        Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                                        sourceSize.height: 623
                                        sourceSize.width: 212
                                        opacity: uibox.imageFade1
                                        Layout.preferredHeight: 0.35*uibox.symbolWidth1
                                        Layout.preferredWidth: uibox.symbolWidth1
                                        fillMode: Image.PreserveAspectFit
                                        source: "qrc:/res/inductor.png"
                                    }
                                    Text {
                                        id: inductorText2
                                        opacity: 1
                                        text: qsTr("0 uH")
                                        Layout.columnSpan: 0
                                        Layout.rowSpan: 0
                                        verticalAlignment: Text.AlignVCenter
                                        horizontalAlignment: Text.AlignHCenter
                                        Layout.preferredWidth: uibox.symbolWidth1
                                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                                        font.pixelSize: labelTxt.font.pixelSize * 0.75
                                    }
                                }

                                ColumnLayout{

                                    width:uibox.symbolWidth1
                                    height: 0.6*uibox.symbolWidth1

                                    Image {
                                        id: image2
                                        sourceSize.height: 623
                                        sourceSize.width: 212
                                        Layout.alignment: Qt.AlignLeft | Qt.AlignTop


                                        opacity: uibox.imageFade1
                                        Layout.preferredHeight: 0.35*uibox.symbolWidth1
                                        Layout.preferredWidth: uibox.symbolWidth1
                                        fillMode: Image.PreserveAspectFit
                                        source: "qrc:/res/resistor.png"
                                    }
                                    Text {
                                        id: resistanceText2
                                        opacity: 1
                                        text: qsTr("0 mΩ")
                                        //anchors.centerIn: parent
                                        Layout.columnSpan: 0
                                        Layout.rowSpan: 0
                                        verticalAlignment: Text.AlignVCenter
                                        horizontalAlignment: Text.AlignHCenter
                                        Layout.preferredWidth: uibox.symbolWidth1
                                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                                        font.pixelSize: labelTxt.font.pixelSize * 0.75
                                    }
                                }
                            }
                        }
                    }
                    RowLayout {
                        id: rowLayout4
                        Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                        spacing: 0
                        Item {
                            id: spacer1
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            Layout.preferredWidth: 2*uibox.symbolWidth1
                            Layout.preferredHeight: uibox.symbolWidth1
                            Rectangle {
                                id: circle1
                                height:  0.75*uibox.symbolWidth1
                                width: height
                                anchors.centerIn: parent
                                color: "#00000000"
                                border.color: "black"
                                opacity: uibox.imageFade1
                                border.width: 0.08*uibox.symbolWidth1
                                radius: width*0.5
                            }

                            Rectangle{
                                id: rectangle1
                                anchors.centerIn: parent
                                width: circle1.width -3.5*uibox.hallDotSize1
                                height:uibox.hallDotSize1
                                rotation: 180
                                color:"#00000000"
                                Rectangle {
                                    anchors.left: parent.right
                                    width: uibox.hallDotSize1
                                    height:uibox.hallDotSize1
                                    radius: uibox.hallDotSize1*0.5
                                    border.width:  uibox.hallDotBorderSize1
                                    color: uibox.accent1
                                    border.color: "black"
                                    Rectangle {
                                        anchors.left: parent.right
                                        width:parent.width
                                        height:parent.height
                                        radius:parent.radius
                                        border.width:  parent.border.width
                                        color: "#ffffff"
                                        border.color: "black"
                                        Rectangle {
                                            anchors.left: parent.right
                                            width:parent.width
                                            height:parent.height
                                            radius:parent.radius
                                            border.width:   parent.border.width
                                            color: "#ffffff"
                                            border.color: "black"
                                        }
                                    }
                                }
                                Behavior on rotation {
                                    NumberAnimation {
                                        easing.type: Easing.OutCirc
                                        duration: 2000
                                    }
                                }
                            }
                            Rectangle{
                                id: rectangle2
                                anchors.centerIn: parent
                                width: circle1.width -3.5*uibox.hallDotSize1
                                height:uibox.hallDotSize1
                                rotation: 180
                                color:"#00000000"
                                Rectangle {
                                    anchors.left: parent.right
                                    width: uibox.hallDotSize1
                                    height:uibox.hallDotSize1
                                    radius: uibox.hallDotSize1*0.5
                                    border.width: uibox.hallDotBorderSize1
                                    color: uibox.accent1
                                    border.color: "black"
                                    Rectangle {
                                        anchors.left: parent.right
                                        width:parent.width
                                        height:parent.height
                                        radius:parent.radius
                                        border.width:  parent.border.width
                                        color: uibox.accent1
                                        border.color: "black"
                                        Rectangle {
                                            anchors.left: parent.right
                                            width:parent.width
                                            height:parent.height
                                            radius:parent.radius
                                            border.width:  parent.border.width
                                            color: "#ffffff"
                                            border.color: "black"
                                        }
                                    }
                                }
                                Behavior on rotation {
                                    NumberAnimation {
                                        easing.type: Easing.OutCirc
                                        duration: 2000
                                    }
                                }
                            }
                            Rectangle{
                                id: rectangle3
                                anchors.centerIn: parent
                                width: circle1.width -3.5*uibox.hallDotSize1
                                height:uibox.hallDotSize1
                                rotation: 180
                                color:"#00000000"
                                Rectangle {
                                    anchors.left: parent.right
                                    width: uibox.hallDotSize1
                                    height:width
                                    radius: width*0.5
                                    border.width: uibox.hallDotBorderSize1
                                    color: "#ffffff"
                                    border.color: "black"
                                    Rectangle {
                                        anchors.left: parent.right
                                        width:parent.width
                                        height:parent.height
                                        radius:parent.radius
                                        border.width:  parent.border.width
                                        color: uibox.accent1
                                        border.color: "black"
                                        Rectangle {
                                            anchors.left: parent.right
                                            width:parent.width
                                            height:parent.height
                                            radius:parent.radius
                                            border.width:  parent.border.width
                                            color: "#ffffff"
                                            border.color: "black"
                                        }
                                    }
                                }
                                Behavior on rotation {
                                    NumberAnimation {
                                        easing.type: Easing.OutCirc
                                        duration: 2000
                                    }
                                }
                            }
                            Rectangle{
                                id: rectangle4
                                anchors.centerIn: parent
                                width: circle1.width -3.5*uibox.hallDotSize1
                                height:uibox.hallDotSize1
                                rotation: 180
                                color:"#00000000"
                                Rectangle {
                                    anchors.left: parent.right
                                    width: uibox.hallDotSize1
                                    height:width
                                    radius: width*0.5
                                    border.width: uibox.hallDotBorderSize1
                                    color:  "#ffffff"
                                    border.color: "black"
                                    Rectangle {
                                        anchors.left: parent.right
                                        width:parent.width
                                        height:parent.height
                                        radius:parent.radius
                                        border.width:  parent.border.width
                                        color: uibox.accent1
                                        border.color: "black"
                                        Rectangle {
                                            anchors.left: parent.right
                                            width:parent.width
                                            height:parent.height
                                            radius:parent.radius
                                            border.width:  parent.border.width
                                            color: uibox.accent1
                                            border.color: "black"
                                        }
                                    }
                                }
                                Behavior on rotation {
                                    NumberAnimation {
                                        easing.type: Easing.OutCirc
                                        duration: 2000
                                    }
                                }
                            }
                            Rectangle{
                                id: rectangle5
                                anchors.centerIn: parent
                                width: circle1.width -3.5*uibox.hallDotSize1
                                height:uibox.hallDotSize1
                                rotation: 180
                                color:"#00000000"
                                Rectangle {
                                    anchors.left: parent.right
                                    width: uibox.hallDotSize1
                                    height:width
                                    radius: width*0.5
                                    border.width: uibox.hallDotBorderSize1
                                    color:  "#ffffff"
                                    border.color: "black"
                                    Rectangle {
                                        anchors.left: parent.right
                                        width:parent.width
                                        height:parent.height
                                        radius:parent.radius
                                        border.width:  parent.border.width
                                        color:  "#ffffff"
                                        border.color: "black"
                                        Rectangle {
                                            anchors.left: parent.right
                                            width:parent.width
                                            height:parent.height
                                            radius:parent.radius
                                            border.width:  parent.border.width
                                            color: uibox.accent1
                                            border.color: "black"
                                        }
                                    }
                                }
                                Behavior on rotation {
                                    NumberAnimation {
                                        easing.type: Easing.OutCirc
                                        duration: 2000
                                    }
                                }
                            }
                            Rectangle{
                                id: rectangle6
                                anchors.centerIn: parent
                                width: circle1.width -3.5*uibox.hallDotSize1
                                height:uibox.hallDotSize1
                                rotation: 180
                                color:"#00000000"
                                Rectangle {
                                    anchors.left: parent.right
                                    width: uibox.hallDotSize1
                                    height:width
                                    radius: width*0.5
                                    border.width: uibox.hallDotBorderSize1
                                    color: uibox.accent1
                                    border.color: "black"
                                    Rectangle {
                                        anchors.left: parent.right
                                        width:parent.width
                                        height:parent.height
                                        radius:parent.radius
                                        border.width:  parent.border.width
                                        color: "#ffffff"
                                        border.color: "black"
                                        Rectangle {
                                            anchors.left: parent.right
                                            width:parent.width
                                            height:parent.height
                                            radius:parent.radius
                                            border.width:  parent.border.width
                                            color: uibox.accent1
                                            border.color: "black"
                                        }
                                    }
                                }
                                Behavior on rotation {
                                    NumberAnimation {
                                        easing.type: Easing.OutCirc
                                        duration: 2000
                                    }
                                }
                            }

                        }

                        Text {
                            id: text6
                            text: qsTr("HALL")
                            verticalAlignment: Text.AlignVCenter
                            Layout.fillWidth: true
                            Layout.preferredWidth: uibox.middleColumnWidth1
                            //Layout.preferredHeight: 0.25*item1.width
                            horizontalAlignment: Text.AlignHCenter
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.pixelSize:  labelTxt.font.pixelSize * 2
                            font.bold: true
                        }
                        Rectangle {
                            id:spacer2
                            Layout.preferredWidth: 2*uibox.symbolWidth1
                            Layout.preferredHeight: uibox.symbolWidth1
                            color: "#00000000"
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            Rectangle {
                                id: circle2
                                width: height
                                height: circle1.width
                                anchors.centerIn: parent
                                color: "#00000000"
                                border.color: "black"
                                opacity: uibox.imageFade1
                                border.width: 0.08*uibox.symbolWidth1
                                radius: width*0.5
                            }

                            Rectangle{
                                id: rectangle7
                                anchors.centerIn: parent
                                width: circle1.width -3.5*uibox.hallDotSize1
                                height:uibox.hallDotSize1
                                rotation: 0
                                color:"#00000000"
                                Rectangle {
                                    anchors.left: parent.right
                                    width: uibox.hallDotSize1
                                    height:width
                                    radius: width*0.5
                                    border.width: uibox.hallDotBorderSize1
                                    color: uibox.accent1
                                    border.color: "black"
                                    Rectangle {
                                        anchors.left: parent.right
                                        width:parent.width
                                        height:parent.height
                                        radius:parent.radius
                                        border.width:  parent.border.width
                                        color: "#ffffff"
                                        border.color: "black"
                                        Rectangle {
                                            anchors.left: parent.right
                                            width:parent.width
                                            height:parent.height
                                            radius:parent.radius
                                            border.width:  parent.border.width
                                            color: "#ffffff"
                                            border.color: "black"
                                        }
                                    }
                                }
                                Behavior on rotation {
                                    NumberAnimation {
                                        easing.type: Easing.OutCirc
                                        duration: 2000
                                    }
                                }
                            }
                            Rectangle{
                                id: rectangle8
                                anchors.centerIn: parent
                                width: circle1.width -3.5*uibox.hallDotSize1
                                height:uibox.hallDotSize1
                                rotation: 0
                                color:"#00000000"
                                Rectangle {
                                    anchors.left: parent.right
                                    width: uibox.hallDotSize1
                                    height:width
                                    radius: width*0.5
                                    border.width: uibox.hallDotBorderSize1
                                    color: uibox.accent1
                                    border.color: "black"
                                    Rectangle {
                                        anchors.left: parent.right
                                        width:parent.width
                                        height:parent.height
                                        radius:parent.radius
                                        border.width:  parent.border.width
                                        color: uibox.accent1
                                        border.color: "black"
                                        Rectangle {
                                            anchors.left: parent.right
                                            width:parent.width
                                            height:parent.height
                                            radius:parent.radius
                                            border.width:  parent.border.width
                                            color: "#ffffff"
                                            border.color: "black"
                                        }
                                    }
                                }
                                Behavior on rotation {
                                    NumberAnimation {
                                        easing.type: Easing.OutCirc
                                        duration: 2000
                                    }
                                }
                            }
                            Rectangle{
                                id: rectangle9
                                anchors.centerIn: parent
                                width: circle1.width -3.5*uibox.hallDotSize1
                                height:uibox.hallDotSize1
                                rotation: 0
                                color:"#00000000"
                                Rectangle {
                                    anchors.left: parent.right
                                    width: uibox.hallDotSize1
                                    height:width
                                    radius: width*0.5
                                    border.width: uibox.hallDotBorderSize1
                                    color: "#ffffff"
                                    border.color: "black"
                                    Rectangle {
                                        anchors.left: parent.right
                                        width:parent.width
                                        height:parent.height
                                        radius:parent.radius
                                        border.width:  parent.border.width
                                        color: uibox.accent1
                                        border.color: "black"
                                        Rectangle {
                                            anchors.left: parent.right
                                            width:parent.width
                                            height:parent.height
                                            radius:parent.radius
                                            border.width:  parent.border.width
                                            color: "#ffffff"
                                            border.color: "black"
                                        }
                                    }
                                }
                                Behavior on rotation {
                                    NumberAnimation {
                                        easing.type: Easing.OutCirc
                                        duration: 2000
                                    }
                                }
                            }
                            Rectangle{
                                id: rectangle10
                                anchors.centerIn: parent
                                width: circle1.width -3.5*uibox.hallDotSize1
                                height:uibox.hallDotSize1
                                rotation: 0
                                color:"#00000000"
                                Rectangle {
                                    anchors.left: parent.right
                                    width: uibox.hallDotSize1
                                    height:width
                                    radius: width*0.5
                                    border.width: uibox.hallDotBorderSize1
                                    color:  "#ffffff"
                                    border.color: "black"
                                    Rectangle {
                                        anchors.left: parent.right
                                        width:parent.width
                                        height:parent.height
                                        radius:parent.radius
                                        border.width:  parent.border.width
                                        color: uibox.accent1
                                        border.color: "black"
                                        Rectangle {
                                            anchors.left: parent.right
                                            width:parent.width
                                            height:parent.height
                                            radius:parent.radius
                                            border.width:  parent.border.width
                                            color: uibox.accent1
                                            border.color: "black"
                                        }
                                    }
                                }
                                Behavior on rotation {
                                    NumberAnimation {
                                        easing.type: Easing.OutCirc
                                        duration: 2000
                                    }
                                }
                            }
                            Rectangle{
                                id: rectangle11
                                anchors.centerIn: parent
                                width: circle1.width -3.5*uibox.hallDotSize1
                                height:uibox.hallDotSize1
                                rotation: 0
                                color:"#00000000"
                                Rectangle {
                                    anchors.left: parent.right
                                    width: uibox.hallDotSize1
                                    height:width
                                    radius: width*0.5
                                    border.width: uibox.hallDotBorderSize1
                                    color:  "#ffffff"
                                    border.color: "black"
                                    Rectangle {
                                        anchors.left: parent.right
                                        width:parent.width
                                        height:parent.height
                                        radius:parent.radius
                                        border.width:  parent.border.width
                                        color:  "#ffffff"
                                        border.color: "black"
                                        Rectangle {
                                            anchors.left: parent.right
                                            width:parent.width
                                            height:parent.height
                                            radius:parent.radius
                                            border.width:  parent.border.width
                                            color: uibox.accent1
                                            border.color: "black"
                                        }
                                    }
                                }
                                Behavior on rotation {
                                    NumberAnimation {
                                        easing.type: Easing.OutCirc
                                        duration: 2000
                                    }
                                }
                            }
                            Rectangle{
                                id: rectangle12
                                anchors.centerIn: parent
                                width: circle1.width -3.5*uibox.hallDotSize1
                                height:uibox.hallDotSize1
                                rotation: 0
                                color:"#00000000"
                                Rectangle {
                                    anchors.left: parent.right
                                    width: uibox.hallDotSize1
                                    height:width
                                    radius: width*0.5
                                    border.width: uibox.hallDotBorderSize1
                                    color: uibox.accent1
                                    border.color: "black"
                                    Rectangle {
                                        anchors.left: parent.right
                                        width:parent.width
                                        height:parent.height
                                        radius:parent.radius
                                        border.width:  parent.border.width
                                        color: "#ffffff"
                                        border.color: "black"
                                        Rectangle {
                                            anchors.left: parent.right
                                            width:parent.width
                                            height:parent.height
                                            radius:parent.radius
                                            border.width:  parent.border.width
                                            color: uibox.accent1
                                            border.color: "black"
                                        }
                                    }
                                }
                                Behavior on rotation {
                                    NumberAnimation {
                                        easing.type: Easing.OutCirc
                                        duration: 2000
                                    }
                                }
                            }
                        }
                    }
                    RowLayout {
                        spacing: 0
                        id: rowLayout5
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                        height: 0.85*uibox.symbolWidth1
                        Rectangle{
                            Layout.preferredWidth: 2*uibox.symbolWidth1
                            Layout.preferredHeight:  0.85*uibox.symbolWidth1
                            color:"#00000000"
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            Rectangle{
                                id:bgFL1
                                anchors.fill:parent
                                radius:height/10
                                color: uibox.accent1
                                opacity: 0

                                Behavior on opacity {
                                    NumberAnimation {
                                        easing.type: Easing.OutCirc
                                        duration: 1000
                                    }
                                }
                            }


                            RowLayout{
                                spacing: -0.1
                                anchors.fill:parent
                                Item{
                                    Layout.preferredWidth: uibox.symbolWidth1
                                    Layout.preferredHeight: 0.85*uibox.symbolWidth1
                                    Image {
                                        sourceSize.height: 300
                                        sourceSize.width: 300
                                        id: image7
                                        opacity: uibox.imageFade1
                                        anchors.fill: parent
                                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                        fillMode: Image.PreserveAspectFit
                                        source: "qrc:/res/spinIcon.png"
                                        mirror: false
                                    }
                                    RoundButton {
                                        anchors.centerIn: parent
                                        width: uibox.symbolWidth1*0.23
                                        height: width
                                        id: roundButton
                                        checked: false
                                        checkable: true
                                        text: ""
                                        highlighted: false
                                        onCheckedChanged: {
                                            item1.inv1 = roundButton.checked
                                            updateGraphics()
                                        }
                                    }
                                }
                                ColumnLayout{
                                    width:uibox.symbolWidth1
                                    height: 0.8*uibox.symbolWidth1
                                    Image {
                                        sourceSize.width: 623
                                        sourceSize.height: 300
                                        id: image5
                                        opacity: uibox.imageFade1
                                        Layout.preferredWidth: uibox.symbolWidth1
                                        Layout.preferredHeight: 0.6*uibox.symbolWidth1
                                        //Layout.fillHeight: false
                                        //Layout.fillWidth: false
                                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                        fillMode: Image.PreserveAspectFit
                                        source: "qrc:/res/flux linkage.png"
                                    }
                                    Text {
                                        id: fluxLinkageText1
                                        opacity: 1
                                        text: qsTr("0.0 mWb")
                                        //anchors.centerIn: parent
                                        verticalAlignment: Text.AlignVCenter
                                        horizontalAlignment: Text.AlignHCenter
                                        Layout.preferredWidth: uibox.symbolWidth1
                                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                                        font.pixelSize: labelTxt.font.pixelSize * 0.75
                                    }
                                }

                            }
                        }
                        Text {
                            id: text7
                            text: qsTr("λ")
                            Layout.fillWidth: true
                            Layout.preferredWidth: uibox.middleColumnWidth1
                            horizontalAlignment: Text.AlignHCenter
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.pixelSize: labelTxt.font.pixelSize * 2
                            font.bold: true
                        }
                        Rectangle{
                            Layout.preferredWidth: 2*uibox.symbolWidth1
                            Layout.preferredHeight:  0.85*uibox.symbolWidth1
                            color:"#00000000"
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            Rectangle{
                                id:bgFL2
                                anchors.fill:parent
                                radius:height/10
                                color: uibox.accent1
                                opacity: 0
                                Behavior on opacity {
                                    NumberAnimation {
                                        easing.type: Easing.OutCirc
                                        duration: 1000
                                    }
                                }
                            }

                            RowLayout{
                                spacing: -0.1
                                anchors.fill:parent
                                ColumnLayout{
                                    width:uibox.symbolWidth1
                                    height: 0.85*uibox.symbolWidth1
                                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                    Image {
                                        sourceSize.width: 623
                                        sourceSize.height: 300
                                        id: image6
                                        opacity: uibox.imageFade1
                                        Layout.preferredWidth: uibox.symbolWidth1
                                        Layout.preferredHeight: 0.6*uibox.symbolWidth1
                                        //Layout.fillHeight: false
                                        //Layout.fillWidth: false
                                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                        fillMode: Image.PreserveAspectFit
                                        source: "qrc:/res/flux linkage.png"
                                    }
                                    Text {
                                        id: fluxLinkageText2
                                        opacity: 1
                                        text: qsTr("0.0 mWb")
                                        //anchors.centerIn: parent
                                        verticalAlignment: Text.AlignVCenter
                                        horizontalAlignment: Text.AlignHCenter
                                        Layout.preferredWidth: uibox.symbolWidth1
                                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                                        font.pixelSize: labelTxt.font.pixelSize * 0.75
                                    }
                                }
                                Item{
                                    Layout.preferredWidth: uibox.symbolWidth1
                                    Layout.preferredHeight: 0.8*uibox.symbolWidth1
                                    Image {
                                        sourceSize.height: 300
                                        sourceSize.width: 300
                                        id: image8
                                        opacity: uibox.imageFade1
                                        anchors.fill: parent
                                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                                        fillMode: Image.PreserveAspectFit
                                        source: "qrc:/res/spinIcon.png"
                                        mirror: false


                                    }
                                    RoundButton {
                                        anchors.centerIn: parent
                                        width: uibox.symbolWidth1*0.23
                                        height: width
                                        id: roundButton2
                                        checked: false
                                        checkable: true
                                        text: ""
                                        highlighted: false
                                        onCheckedChanged: {
                                            item1.inv2 = roundButton2.checked
                                            updateGraphics()
                                        }
                                    }
                                }
                            }
                        }

                    }
                    /* RowLayout {
                        spacing: 0
                        id: rowLayout12
                        Layout.fillHeight: false
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        height: 0.4*uibox.middleColumnWidth1
                        focus: true

                        Text {
                            id: text10
                            text: qsTr("14")
                            Layout.preferredWidth: uibox.symbolWidth1*2
                            horizontalAlignment: Text.AlignHCenter
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.pixelSize: labelTxt.font.pixelSize * 2

                            //font.pixelSize: uibox.textSize1
                        }

                        Text {
                            id: text13
                            text: qsTr("POLES")
                            Layout.fillWidth: true
                            Layout.preferredWidth: uibox.middleColumnWidth1
                            horizontalAlignment: Text.AlignHCenter
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.pixelSize: labelTxt.font.pixelSize * 2
                            font.bold: true
                        }

                        Text {
                            id: text11
                            text: qsTr("14")
                            Layout.preferredWidth: uibox.symbolWidth1*2
                            horizontalAlignment: Text.AlignHCenter
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.pixelSize: labelTxt.font.pixelSize * 2
                            //font.pixelSize: uibox.textSize1

                        }

                    }*/
                    RowLayout {
                        id: rowLayout8
                        Layout.fillHeight: false
                        Text {
                            id: currText1
                            text: qsTr("0 A")
                            Layout.preferredWidth: uibox.symbolWidth1*1.6
                            Layout.preferredHeight: buttonReadCurrent.height*0.8
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.pixelSize: labelTxt.font.pixelSize * 2
                        }
                        Text {
                            id: text9
                            text: qsTr("MAX MOTOR CURRENT")
                            Layout.fillHeight: false
                            Layout.fillWidth: true
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.pixelSize: uibox.textSize1
                            font.bold: true
                        }
                        Text {
                            id: currText2
                            text: qsTr("0 A")
                            Layout.preferredWidth: uibox.symbolWidth1*1.6
                            Layout.preferredHeight: buttonReadCurrent.height*0.8
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.pixelSize: labelTxt.font.pixelSize * 2
                        }
                    }
                    RowLayout {
                        id: rowLayout7
                        Layout.fillHeight: true

                        Slider {
                            id: slider
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            Layout.fillWidth: true
                            value: 0
                            Layout.preferredHeight: buttonReadCurrent.height*2/3
                            onValueChanged:  {
                                item1.maxCurrent1 = Math.round(value*item1.maxHWcurrent)
                                item1.maxCurrent2 = Math.round(value*item1.maxHWcurrent)
                                updateGraphics()
                            }
                        }
                    }

                    RowLayout {
                        id: rowLayout10
                        Layout.fillHeight: false
                        Text {
                            id: currBrakeText1
                            text: qsTr("0 A")
                            Layout.preferredHeight: buttonReadCurrent.height*0.8
                            Layout.preferredWidth: uibox.symbolWidth1*1.6
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.pixelSize: labelTxt.font.pixelSize * 2
                        }
                        Text {
                            id: text12
                            text: qsTr("MAX BRAKE CURRENT")
                            Layout.fillHeight: false
                            Layout.fillWidth: true
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.pixelSize: uibox.textSize1
                            font.bold: true
                        }
                        Text {
                            id: currBrakeText2
                            text: qsTr("0 A")
                            Layout.preferredHeight: buttonReadCurrent.height*0.8
                            Layout.preferredWidth: uibox.symbolWidth1*1.6
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.pixelSize: labelTxt.font.pixelSize * 2
                        }
                    }
                    RowLayout {
                        id: rowLayout9
                        Layout.fillHeight: true

                        Slider {
                            id: slider2
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            Layout.fillWidth: true
                            Layout.preferredHeight: buttonReadCurrent.height*2/3
                            value: 0
                            onValueChanged:  {
                                item1.maxBrakeCurrent1 = -Math.round(value*item1.maxHWcurrent)
                                item1.maxBrakeCurrent2 = -Math.round(value*item1.maxHWcurrent)
                                updateGraphics()
                            }
                        }
                    }

                }
                ColumnLayout{
                    spacing: uibox.spaceVertical
                    id:appSettingsWindow
                    Layout.fillWidth: true
                    clip: true
                    Layout.preferredHeight: appSettingsButton.height
                    // spacing: 0.035*uibox.widthIcon
                    Behavior on Layout.preferredHeight {
                        NumberAnimation {
                            id: appAnim
                            easing.type: Easing.OutCirc
                            duration: item1.durAnim
                            onRunningChanged: {
                                if(appSettingsWindow.Layout.preferredHeight === appSettingsWindow.implicitHeight && appAnim.running === false && appAnim.duration === item1.durAnim)
                                {
                                    appAnim.duration = 0
                                    appSettingsWindow.Layout.preferredHeight = -1;
                                }
                            }
                        }
                    }

                    Button{
                        id:appSettingsButton
                        //horizontalAlignment: Text.AlignHCenter
                        Layout.fillWidth: true
                        text: "REMOTE CONFIG"
                        font.bold: true
                        font.pixelSize: uibox.textSize1
                        //Layout.fillWidth: true
                        //bottomPadding: 10
                        //leftPadding: 5
                        //rightPadding: 5
                        //topPadding:2*uibox.textSize2

                        Rectangle{
                            id:arrowApp
                            color:"#00000000"
                            Rectangle{
                                width:parent.width
                                color:"black"
                                height:0.2*parent.height
                                anchors.top:parent.top
                                radius:height/2
                            }
                            Rectangle{
                                height:parent.height
                                color:"black"
                                width:0.2*parent.width
                                anchors.right:parent.right
                                radius:width/2
                            }

                            anchors.centerIn: parent
                            height:parent.height*0.4
                            width: height
                            anchors.horizontalCenterOffset: 0.5*parent.width - 1.4*width
                            rotation: 45
                            Behavior on rotation {
                                NumberAnimation {
                                    duration: item1.durAnim
                                    easing.type: Easing.OutCirc
                                }
                            }
                        }
                        onClicked: {
                            if(appSettingsWindow.Layout.preferredHeight === appSettingsButton.height){
                                appAnim.duration = item1.durAnim
                                arrowApp.rotation = 135
                                appSettingsWindow.Layout.preferredHeight = appSettingsWindow.implicitHeight
                            }
                            else{
                                appAnim.duration = 0
                                appSettingsWindow.Layout.preferredHeight = appSettingsWindow.implicitHeight
                                arrowApp.rotation = 45
                                appAnim.duration = item1.durAnim
                                appSettingsWindow.Layout.preferredHeight = appSettingsButton.height
                            }
                        }
                    }
                    RowLayout{
                        //   spacing:parent.width/20
                        Layout.fillWidth: true
                        //   Layout.topMargin: parent.parent.width/30
                        Rectangle{
                            color: "#00000000"
                            //Layout.preferredWidth: uibox.symbolWidth1
                            Layout.preferredWidth: parent.width/4
                            Layout.preferredHeight: 10
                            Rectangle{
                                property double numPos: 3
                                property var wireColors:  ["#777777", "#ff7777","#dddddd"]
                                property var wireNames:   ["GND","5V","SIG"]
                                width:uibox.widthIcon/30*numPos
                                height:uibox.widthIcon/12
                                color:"#00000000"
                                anchors.centerIn: parent
                                Rectangle{
                                    width:parent.width
                                    height:parent.height/8
                                    color:"lightgrey"
                                    anchors.centerIn: parent
                                    anchors.verticalCenterOffset: -parent.height/20

                                }
                                Rectangle{
                                    width:0.95*parent.width
                                    height:0.5*parent.height
                                    color:"lightgrey"
                                    anchors.centerIn: parent
                                    anchors.verticalCenterOffset: 0.25*parent.height
                                }
                                /* Row {
                                width: parent.width*(2*parent.numPos-1)/(2*parent.numPos + 1)
                                spacing: parent.width*1/(2*parent.numPos + 1)  // a simple layout do avoid overlapping
                                anchors.centerIn: parent
                                height:parent.height/2
                                z: 2
                                anchors.verticalCenterOffset:-parent.height/3
                                Repeater {
                                    model: parent.parent.wireNames
                                    delegate: Rectangle {
                                        width:parent.spacing
                                        height: parent.height
                                        color: "#00000000";
                                        Text{
                                            anchors.centerIn: parent
                                            text: modelData
                                            rotation: 90
                                            font.pixelSize: parent.width
                                        }
                                    }
                                }
                            }*/
                                Row {
                                    width: parent.width*(2*parent.numPos-1)/(2*parent.numPos + 1)
                                    spacing: parent.width*1/(2*parent.numPos + 1)  // a simple layout do avoid overlapping
                                    anchors.centerIn: parent
                                    height:parent.height*2/3
                                    z: -1
                                    anchors.verticalCenterOffset: -parent.height/3
                                    Repeater {
                                        model: parent.parent.wireColors
                                        delegate: Rectangle {
                                            width:parent.spacing
                                            height: parent.height
                                            color: modelData;
                                            //border { width: 1; color: "black" }
                                        }
                                    }
                                }
                                Row {
                                    z: 1
                                    width: parent.width*(2*parent.numPos-1)/(2*parent.numPos + 1)
                                    spacing: parent.width*1/(2*parent.numPos + 1)  // a simple layout do avoid overlapping
                                    anchors.centerIn: parent
                                    height:parent.height/3
                                    anchors.verticalCenterOffset: parent.height/4

                                    Repeater {
                                        z: 1
                                        model: parent.parent.numPos; // just define the number you want, can be a variable too
                                        delegate: Rectangle {
                                            width:parent.spacing
                                            height: parent.height
                                            color: "darkgrey";
                                        }
                                    }
                                }
                            }
                        }
                        Text{
                            id:ppmTxt
                            text:"PPM MODE"
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: uibox.textSize2
                            // Layout.alignment: Qt.AlignRight
                            Layout.fillWidth: true
                        }
                        ComboBox {
                            id: ppmModeComboBox
                            // Layout.preferredHeight:  0.6*uibox.middleColumnWidth1
                            Layout.preferredWidth: parent.width/2
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            transformOrigin: Item.Center
                            font.pixelSize: uibox.textSize1
                            model: [
                                "Disabled",
                                "Forward/Reverse",
                                "Forward/Brake",
                            ]

                            onCurrentTextChanged: {
                                item1.updateGraphics()
                                //createEditorApp("app_ppm_conf.ctrl_type")

                            }
                        }

                    }

                    RowLayout{
                        Layout.fillWidth: true
                        ColumnLayout{
                            ProgressBar {
                                id: valueBar
                                Layout.fillWidth: true
                                from: -1.0
                                to: 1.0
                                value: 0.0

                                Behavior on value {
                                    NumberAnimation {
                                        easing.type: Easing.OutCirc
                                        duration: 100
                                    }
                                }
                            }
                            RowLayout{
                                Text{
                                    id: txtMin
                                    text: "-100%"
                                    Layout.alignment: Qt.AlignLeft
                                    font.pixelSize: uibox.textSize1
                                }
                                Text{
                                    id: txtNow
                                    text: "0%"
                                    Layout.alignment: Qt.AlignCenter
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignHCenter
                                    font.pixelSize: uibox.textSize1
                                }
                                Text{
                                    id: txtMax
                                    text: "100%"
                                    Layout.alignment: Qt.AlignRight
                                    font.pixelSize: uibox.textSize1
                                }
                            }
                        }
                        Button {
                            id: calibrationButton
                            enabled: true
                            text: "Calibrate"
                            font.pixelSize: uibox.textSize1
                            //Layout.preferredWidth: parent.width/3
                            //Image{
                            // source: "qrc:/res/icons/Refresh-96.png"
                            // anchors.fill: parent
                            //}

                            //Layout.preferredWidth: height
                            //Layout.fillHeight: true
                            onClicked: {
                                remoteDialogBody.visible = false
                                remoteDialog.title = "Please Wait..."
                                calibrationButton.enabled = false
                                setPPMTestAppConfig()
                                remoteDialog.open()
                                // resetDone = true
                                // updateDisplay()
                            }
                        }
                    }
                    RowLayout{
                        Layout.fillWidth: true
                        Rectangle{
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            opacity:0
                        }

                        Button{
                            Layout.preferredWidth: uartBaudComboBox.width
                            text: "Tune Throttle Curves"
                            //font.bold: true
                            font.pixelSize: uibox.textSize1
                            onClicked: {
                                remoteDialog2.open()
                            }
                        }
                    }


                    RowLayout{
                        Layout.fillWidth: true
                        Rectangle{
                            color: "#00000000"
                            //Layout.preferredWidth: uibox.symbolWidth1
                            Layout.preferredWidth: parent.width/4
                            Layout.preferredHeight: 10
                            Rectangle{
                                property double numPos: 7
                                property var wireColors:  ["#00000000", "#ff7777", "#777777","#00000000","#dddddd",uibox.accent1]
                                property var wireNames:  ["", "3v3", "GND","","RX","TX"]
                                anchors.centerIn: parent
                                width:uibox.widthIcon/30*numPos
                                height:uibox.widthIcon/12
                                color:"#00000000"
                                Rectangle{
                                    width:parent.width
                                    height:parent.height/8
                                    color:"lightgrey"
                                    anchors.centerIn: parent
                                    anchors.verticalCenterOffset: -parent.height/20

                                }
                                Rectangle{
                                    width:0.95*parent.width
                                    height:0.5*parent.height
                                    color:"lightgrey"
                                    anchors.centerIn: parent
                                    anchors.verticalCenterOffset: 0.25*parent.height
                                }
                                /*Row {
                                width: parent.width*(2*parent.numPos-1)/(2*parent.numPos + 1)
                                spacing: parent.width*1/(2*parent.numPos + 1)  // a simple layout do avoid overlapping
                                anchors.centerIn: parent
                                height:parent.height/2
                                z: 2
                                anchors.verticalCenterOffset:-parent.height/3
                                Repeater {
                                    model: parent.parent.wireNames
                                    delegate: Rectangle {
                                        width:parent.spacing
                                        height: parent.height
                                        color: "#00000000";
                                        Text{
                                            anchors.centerIn: parent
                                            text: modelData
                                            rotation: 90
                                            font.pixelSize: parent.width
                                        }
                                    }
                                }
                            }*/
                                Row {
                                    width: parent.width*(2*parent.numPos-1)/(2*parent.numPos + 1)
                                    spacing: parent.width*1/(2*parent.numPos + 1)  // a simple layout do avoid overlapping
                                    anchors.centerIn: parent
                                    height:parent.height*2/3
                                    z: -1
                                    anchors.verticalCenterOffset: -parent.height/3
                                    Repeater {
                                        model: parent.parent.wireColors
                                        delegate: Rectangle {
                                            width:parent.spacing
                                            height: parent.height
                                            color: modelData;
                                            //border { width: 1; color: "black" }
                                        }
                                    }
                                }
                                Row {
                                    z: 1
                                    width: parent.width*(2*parent.numPos-1)/(2*parent.numPos + 1)
                                    spacing: parent.width*1/(2*parent.numPos + 1)  // a simple layout do avoid overlapping
                                    anchors.centerIn: parent
                                    height:parent.height/3
                                    anchors.verticalCenterOffset: parent.height/4

                                    Repeater {
                                        z: 1
                                        model: parent.parent.numPos; // just define the number you want, can be a variable too
                                        delegate: Rectangle {
                                            width:parent.spacing
                                            height: parent.height
                                            color: "darkgrey";
                                        }
                                    }
                                }
                            }
                        }
                        Text{
                            id:uartTxt
                            text:"UART MODE"
                            font.bold: true
                            font.pixelSize: uibox.textSize2
                            //Layout.preferredWidth: uibox.symbolWidth1
                            Layout.fillWidth:  true
                            //Layout.alignment: Qt.AlignBottom
                            horizontalAlignment: Text.AlignHCenter
                        }
                        ComboBox {
                            id: uartBaudComboBox
                            //  Layout.preferredHeight:  0.6*uibox.middleColumnWidth1
                            Layout.preferredWidth: parent.width/2
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            transformOrigin: Item.Center
                            font.pixelSize: uibox.textSize1

                            model: [
                                "Disabled",
                                "9600 Baud",
                                "115200 Baud",
                                "Custom"
                            ]

                            onCurrentTextChanged: {


                            }
                        }
                    }
                    RowLayout{
                        Layout.fillWidth: true
                        Rectangle{
                            color: "#00000000"
                            //Layout.preferredWidth: uibox.symbolWidth1
                            Layout.preferredWidth: parent.width/4
                            Layout.preferredHeight: 10
                            Rectangle{
                                property double numPos: 4
                                property var wireColors: ["#00000000","#dddddd",uibox.accent1, "#00000000"]
                                property var wireNames: ["", "CANH", "CANL",""]
                                anchors.centerIn: parent

                                width:uibox.widthIcon/30*numPos
                                height:uibox.widthIcon/12
                                color:"#00000000"
                                Rectangle{
                                    width:parent.width
                                    height:parent.height/8
                                    color:"lightgrey"
                                    anchors.centerIn: parent
                                    anchors.verticalCenterOffset: -parent.height/20

                                }
                                Rectangle{
                                    width:0.95*parent.width
                                    height:0.5*parent.height
                                    color:"lightgrey"
                                    anchors.centerIn: parent
                                    anchors.verticalCenterOffset: 0.25*parent.height
                                }
                                /*Row {
                                width: parent.width*(2*parent.numPos-1)/(2*parent.numPos + 1)
                                spacing: parent.width*1/(2*parent.numPos + 1)  // a simple layout do avoid overlapping
                                anchors.centerIn: parent
                                height:parent.height/2
                                z: 2
                                anchors.verticalCenterOffset:-parent.height/3
                                Repeater {
                                    model: parent.parent.wireNames
                                    delegate: Rectangle {
                                        width:parent.spacing
                                        height: parent.height
                                        color: "#00000000";
                                        Text{
                                            anchors.centerIn: parent
                                            text: modelData
                                            rotation: 90
                                            font.pixelSize: parent.width
                                        }
                                    }
                                }
                            }*/
                                Row {
                                    width: parent.width*(2*parent.numPos-1)/(2*parent.numPos + 1)
                                    spacing: parent.width*1/(2*parent.numPos + 1)  // a simple layout do avoid overlapping
                                    anchors.centerIn: parent
                                    height:parent.height*2/3
                                    z: -1
                                    anchors.verticalCenterOffset: -parent.height/3
                                    Repeater {
                                        model: parent.parent.wireColors
                                        delegate: Rectangle {
                                            width:parent.spacing
                                            height: parent.height
                                            color: modelData;
                                            //   border { width: 1; color: "black" }
                                        }
                                    }
                                }
                                Row {
                                    z: 1
                                    width: parent.width*(2*parent.numPos-1)/(2*parent.numPos + 1)
                                    spacing: parent.width*1/(2*parent.numPos + 1)  // a simple layout do avoid overlapping
                                    anchors.centerIn: parent
                                    height:parent.height/3
                                    anchors.verticalCenterOffset: parent.height/4

                                    Repeater {
                                        z: 1
                                        model: parent.parent.numPos; // just define the number you want, can be a variable too
                                        delegate: Rectangle {
                                            width:parent.spacing
                                            height: parent.height
                                            color: "darkgrey";
                                        }
                                    }
                                }
                            }
                        }
                        Text{
                            id:canTxt
                            text:"CAN MODE"
                            font.bold: true
                            Layout.fillWidth: true
                            font.pixelSize: uibox.textSize2
                            //Layout.preferredWidth: uibox.symbolWidth1
                            // Layout.alignment: Qt.AlignBottom
                            horizontalAlignment: Text.AlignHCenter

                        }

                        ComboBox {
                            id: canModeComboBox
                            //  Layout.preferredHeight:  0.6*uibox.middleColumnWidth1
                            Layout.preferredWidth: parent.width/2
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            transformOrigin: Item.Center
                            font.pixelSize: uibox.textSize1

                            model: [
                                "Disabled",
                                "Master (id:0)",
                                "Slave  (id:1)"
                            ]

                            onCurrentTextChanged: {
                                //createEditorApp("app_ppm_conf.ctrl_type")

                            }
                        }


                    }



                }
                ColumnLayout{
                    spacing: uibox.spaceVertical
                    id:buttonSettingsWindow
                    Layout.fillWidth: true
                    clip: true
                    Layout.preferredHeight: buttonSettingsButton.height
                    // spacing: 0.035*uibox.widthIcon
                    Behavior on Layout.preferredHeight {
                        NumberAnimation {
                            id: buttonAnim
                            easing.type: Easing.OutCirc
                            duration: item1.durAnim
                            onRunningChanged: {
                                if(buttonSettingsWindow.Layout.preferredHeight === buttonSettingsWindow.implicitHeight && buttonAnim.running === false && buttonAnim.duration === item1.durAnim)
                                {
                                    buttonAnim.duration = 0
                                    buttonSettingsWindow.Layout.preferredHeight = -1;
                                }
                            }
                        }
                    }

                    Button{
                        id:buttonSettingsButton
                        //horizontalAlignment: Text.AlignHCenter
                        Layout.fillWidth: true
                        text: "SMART SWITCH SETTINGS"
                        font.bold: true
                        font.pixelSize: uibox.textSize1
                        //Layout.fillWidth: true
                        //bottomPadding: 10
                        //leftPadding: 5
                        //rightPadding: 5
                        //topPadding:2*uibox.textSize2

                        Rectangle{
                            id:arrowButton
                            color:"#00000000"
                            Rectangle{
                                width:parent.width
                                color:"black"
                                height:0.2*parent.height
                                anchors.top:parent.top
                                radius:height/2
                            }
                            Rectangle{
                                height:parent.height
                                color:"black"
                                width:0.2*parent.width
                                anchors.right:parent.right
                                radius:width/2
                            }

                            anchors.centerIn: parent
                            height:parent.height*0.4
                            width: height
                            anchors.horizontalCenterOffset: 0.5*parent.width - 1.4*width
                            rotation: 45
                            Behavior on rotation {
                                NumberAnimation {
                                    duration: item1.durAnim
                                    easing.type: Easing.OutCirc
                                }
                            }
                        }
                        onClicked: {
                            if(buttonSettingsWindow.Layout.preferredHeight === buttonSettingsButton.height){
                                buttonAnim.duration = item1.durAnim
                                arrowButton.rotation = 135
                                buttonSettingsWindow.Layout.preferredHeight = buttonSettingsWindow.implicitHeight
                            }
                            else{
                                buttonAnim.duration = 0
                                buttonSettingsWindow.Layout.preferredHeight = buttonSettingsWindow.implicitHeight
                                arrowButton.rotation = 45
                                buttonAnim.duration = item1.durAnim
                                buttonSettingsWindow.Layout.preferredHeight = buttonSettingsButton.height
                            }
                        }
                    }

                    RowLayout{
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Text{
                            id:pushtostartText
                            Layout.fillWidth: true
                            text: "ENABLED"

                            font.pixelSize: uibox.textSize1
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Text{
                            Layout.preferredWidth: parent.width/3
                            text: "KICK PUSH TO START"
                            font.bold: true
                            font.pixelSize: uibox.textSize1
                            horizontalAlignment: Text.AlignHCenter
                        }


                        Switch{
                            id: pushToStartSwitch
                            checked: true
                            //Layout.fillWidth: true

                            Layout.preferredWidth: parent.width/3
                            onCheckedChanged: {
                                pushToStart = checked
                                if(checked){
                                    pushtostartText.text = "ENABLED"
                                }else{
                                    pushtostartText.text = "DISABLED"
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: false
                        Text {
                            text: qsTr("")
                            Layout.preferredWidth: uibox.symbolWidth1*1.6
                            Layout.preferredHeight: buttonReadCurrent.height*0.8
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.pixelSize: uibox.textSize1
                        }
                        Text {
                            id: smartSwitchMinutesTitle
                            text: qsTr("MIN INACTIVE UNTIL SHUTDOWN")
                            Layout.fillHeight: false
                            Layout.fillWidth: true
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.pixelSize: uibox.textSize1
                            font.bold: true
                        }
                        Text {
                            id: ssMinutesText
                            text: qsTr("5 min")
                            Layout.preferredWidth: uibox.symbolWidth1*1.6
                            Layout.preferredHeight: buttonReadCurrent.height*0.8
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.pixelSize:uibox.textSize1
                        }
                    }
                    RowLayout {
                        Layout.fillHeight: true

                        Slider {
                            id: slider5
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            Layout.fillWidth: true
                            value: 5/60

                            Layout.preferredHeight: buttonReadCurrent.height*2/3
                            onValueChanged:  {
                                minutesToOff = Math.round(value*60)
                                if(minutesToOff == 0)
                                    ssMinutesText.text = "DISABLED"
                                else
                                    ssMinutesText.text = parseFloat(minutesToOff).toFixed(0) + " min"

                            }
                        }
                    }

                    RowLayout {
                        Layout.fillHeight: false
                        Text {
                            text: qsTr("")
                            Layout.preferredWidth: uibox.symbolWidth1*1.6
                            Layout.preferredHeight: buttonReadCurrent.height*0.8
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.pixelSize: uibox.textSize1
                        }
                        Text {
                            id: ssSecondsTitle
                            text: qsTr("PWR PRESS FOR SHUTDOWN")
                            Layout.fillHeight: false
                            Layout.fillWidth: true
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.pixelSize: uibox.textSize1
                            font.bold: true
                        }
                        Text {
                            id: ssSecondsText
                            text: qsTr("1.5 sec")
                            Layout.preferredWidth: uibox.symbolWidth1*1.6
                            Layout.preferredHeight: buttonReadCurrent.height*0.8
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.pixelSize: uibox.textSize1
                        }
                    }
                    RowLayout {
                        Layout.fillHeight: true

                        Slider {
                            id: slider6
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            Layout.fillWidth: true
                            value: 0
                            Layout.preferredHeight: buttonReadCurrent.height*2/3
                            onValueChanged:  {
                                secondsToOff = Math.round(value*17)/2 + 1.5
                                ssSecondsText.text = parseFloat(secondsToOff).toFixed(1) +" sec"
                            }
                        }
                    }

                }
                ColumnLayout{
                    spacing: uibox.spaceVertical
                    id:thermalSettingsWindow
                    Layout.fillWidth: true
                    clip: true
                    Layout.preferredHeight: thermalSettingsButton.height
                    // spacing: 0.035*uibox.widthIcon
                    Behavior on Layout.preferredHeight {
                        NumberAnimation {
                            id: thermalAnim
                            easing.type: Easing.OutCirc
                            duration: item1.durAnim
                            onRunningChanged: {
                                if(thermalSettingsWindow.Layout.preferredHeight === thermalSettingsWindow.implicitHeight && thermalAnim.running === false && thermalAnim.duration === item1.durAnim)
                                {
                                    thermalAnim.duration = 0
                                    thermalSettingsWindow.Layout.preferredHeight = -1;
                                }
                            }
                        }
                    }

                    Button{
                        id:thermalSettingsButton
                        //horizontalAlignment: Text.AlignHCenter
                        Layout.fillWidth: true
                        text: "MOTOR TEMP LIMITS"
                        font.bold: true
                        font.pixelSize: uibox.textSize1
                        //Layout.fillWidth: true
                        //bottomPadding: 10
                        //leftPadding: 5
                        //rightPadding: 5
                        //topPadding:2*uibox.textSize2

                        Rectangle{
                            id:arrowthermal
                            color:"#00000000"
                            Rectangle{
                                width:parent.width
                                color:"black"
                                height:0.2*parent.height
                                anchors.top:parent.top
                                radius:height/2
                            }
                            Rectangle{
                                height:parent.height
                                color:"black"
                                width:0.2*parent.width
                                anchors.right:parent.right
                                radius:width/2
                            }

                            anchors.centerIn: parent
                            height:parent.height*0.4
                            width: height
                            anchors.horizontalCenterOffset: 0.5*parent.width - 1.4*width
                            rotation: 45
                            Behavior on rotation {
                                NumberAnimation {
                                    duration: item1.durAnim
                                    easing.type: Easing.OutCirc
                                }
                            }
                        }
                        onClicked: {
                            if(thermalSettingsWindow.Layout.preferredHeight === thermalSettingsButton.height){
                                thermalAnim.duration = item1.durAnim
                                arrowthermal.rotation = 135
                                thermalSettingsWindow.Layout.preferredHeight = thermalSettingsWindow.implicitHeight
                            }
                            else{
                                thermalAnim.duration = 0
                                thermalSettingsWindow.Layout.preferredHeight = thermalSettingsWindow.implicitHeight
                                arrowthermal.rotation = 45
                                thermalAnim.duration = item1.durAnim
                                thermalSettingsWindow.Layout.preferredHeight = thermalSettingsButton.height
                            }
                        }
                    }

                    RowLayout{
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Text{
                            id:thermalEnText
                            Layout.fillWidth: true
                            text: "ENABLED"

                            font.pixelSize: uibox.textSize1
                            horizontalAlignment: Text.AlignLeft
                        }

                        Text{
                            Layout.preferredWidth: parent.width/3
                            text: "MOTOR THERMAL THROTTLING"
                            font.bold: true
                            font.pixelSize: uibox.textSize1
                            horizontalAlignment: Text.AlignHCenter
                        }


                        Switch{
                            id: thermalSwitch
                            checked: true
                            //Layout.fillWidth: true

                            Layout.preferredWidth: parent.width/3
                            onCheckedChanged: {
                                motorTempEnable = checked
                                if(checked){
                                    thermalEnText.text = "ENABLED"
                                    slider8.enabled = true
                                    slider9.enabled = true
                                    motorTempTitle.color = "black"
                                    motorTempText.color = "black"
                                    motorBetaTitle.color = "black"
                                    motorBetaText.color = "black"
                                }else{
                                    thermalEnText.text = "DISABLED"
                                    slider8.enabled = false
                                    slider9.enabled = false
                                    motorTempTitle.color = "grey"
                                    motorTempText.color = "grey"
                                    motorBetaTitle.color = "grey"
                                    motorBetaText.color = "grey"
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: false
                        Text {
                            text: qsTr("")
                            Layout.preferredWidth: uibox.symbolWidth1*1.6
                            Layout.preferredHeight: buttonReadCurrent.height*0.8
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.pixelSize: uibox.textSize1
                        }
                        Text {
                            id: motorTempTitle
                            text: qsTr("MAX ALLOWED MOTOR TEMP")
                            Layout.fillHeight: false
                            Layout.fillWidth: true
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.pixelSize: uibox.textSize1
                            font.bold: true
                        }
                        Text {
                            id: motorTempText
                            text: qsTr("100 \xB0 C")
                            Layout.preferredWidth: uibox.symbolWidth1*1.6
                            Layout.preferredHeight: buttonReadCurrent.height*0.8
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.pixelSize:labelTxt.font.pixelSize * 1.5
                        }
                    }
                    RowLayout {
                        Layout.fillHeight: true

                        Slider {
                            id: slider8
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            Layout.fillWidth: true
                            value: 0.5

                            Layout.preferredHeight: buttonReadCurrent.height*2/3
                            onValueChanged:  {
                                motorTemp = Math.round(value * 60.0) + 75.0

                                motorTempText.text = parseFloat(motorTemp).toFixed(0) + " \xB0 C"

                            }
                        }
                    }

                    RowLayout {
                        Layout.fillHeight: false
                        Text {
                            text: qsTr("")
                            Layout.preferredWidth: uibox.symbolWidth1*1.6
                            Layout.preferredHeight: buttonReadCurrent.height*0.8
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.pixelSize: uibox.textSize1
                        }
                        Text {
                            id: motorBetaTitle
                            text: qsTr("MOTOR BETA")
                            Layout.fillHeight: false
                            Layout.fillWidth: true
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.pixelSize: uibox.textSize1
                            font.bold: true
                        }
                        Text {
                            id: motorBetaText
                            text: qsTr("4100")
                            Layout.preferredWidth: uibox.symbolWidth1*1.6
                            Layout.preferredHeight: buttonReadCurrent.height*0.8
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.pixelSize: labelTxt.font.pixelSize * 1.5
                        }
                    }
                    RowLayout {
                        Layout.fillHeight: true

                        Slider {
                            id: slider9
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            Layout.fillWidth: true
                            value: 0.5
                            Layout.preferredHeight: buttonReadCurrent.height*2/3
                            onValueChanged:  {
                                motorBeta = Math.round(value*3000) +2600
                                motorBetaText.text = parseFloat(motorBeta).toFixed(0)
                            }
                        }
                    }
                }
            }
        }
    }


    Connections {
        target: mAppConf

        onUpdated: {
            appConfUpdated = true
            if( motorConfUpdated == true){
                motorConfUpdated = false
                appConfUpdated = false
                button.enabled = true
                buttonApplyValues.enabled = true
                calibrationButton.enabled = true
                buttonReadCurrent.enabled = true
            }

            msMin = mAppConf.getParamDouble("app_ppm_conf.pulse_start")
            msMax = mAppConf.getParamDouble("app_ppm_conf.pulse_end")
            msCenter = mAppConf.getParamDouble("app_ppm_conf.pulse_center")

            torqueCurveMode = mAppConf.getParamEnum("app_ppm_conf.throttle_exp_mode")
            torqueCurveAccel = mAppConf.getParamDouble("app_ppm_conf.throttle_exp")
            torqueCurveBrake = mAppConf.getParamDouble("app_ppm_conf.throttle_exp_brake")
            deadZone = mAppConf.getParamDouble("app_ppm_conf.hyst")

            secondsToOff = mAppConf.getParamInt("app_smart_switch_conf.msec_pressed_for_off")/1000.0
            minutesToOff = Math.round(mAppConf.getParamInt("app_smart_switch_conf.sec_inactive_for_off")/60.0)
            pushToStart = mAppConf.getParamBool("app_smart_switch_conf.push_to_start_enabled")

            var appToUse =  mAppConf.getParamEnum("app_to_use")
            var PPMcontrolType =  mAppConf.getParamEnum("app_ppm_conf.ctrl_type");
            var PPMUartBaud =  mAppConf.getParamInt("app_uart_baudrate");
            var ppmMultiESC =  mAppConf.getParamBool("app_ppm_conf.multi_esc");
            var sendCanStatus =  mAppConf.getParamBool("send_can_status");
            if(appToUse > 2 && appToUse < 6 ){
                if(PPMUartBaud === 9600){
                    uartBaudComboBox.currentIndex = 1
                }else if(PPMUartBaud ===115200){
                    uartBaudComboBox.currentIndex = 2
                }else {
                    uartBaudComboBox.currentIndex = 3
                }
            }

            if(PPMcontrolType === 0 ){
                ppmModeComboBox.currentIndex = 0
            }else if(PPMcontrolType === 1 ){
                ppmModeComboBox.currentIndex =  1
            }else if(PPMcontrolType === 3 ){
                ppmModeComboBox.currentIndex = 2
            }

            if(ppmMultiESC === true){
                canModeComboBox.currentIndex = 1
            }else if(sendCanStatus === true){
                canModeComboBox.currentIndex = 2
            }else{
                canModeComboBox.currentIndex = 0
            }

            updateGraphics()


        }
    }

    /* Timer {
        id: rtTimer
        interval: 50
        running: true
        repeat: true

        onTriggered: {
            if (VescIf.isPortConnected() && configNotUpdating) {
                mCommands.getDecodedPpm()
            }
        }
    }*/
    Timer {
        id: reconnecctTimer
        interval: 3000
        running: false
        repeat: false

        onTriggered: {
            //if(mBle.isConnected())
            //    VescIf.reconnectLastPort()
            item1.configNotUpdating = true
            remoteDialogBody.visible = true
            remoteDialog.title = "REMOTE CALIBRATION"
            msMinTest = msNow
            msMaxTest = msNow
            msCenterTest = msNow
        }
    }

    Connections {
        target: mMcConf

        onUpdated: {


            motorConfUpdated = true
            if( appConfUpdated == true){
                motorConfUpdated = false
                appConfUpdated = false
                button.enabled = true
                buttonApplyValues.enabled = true
                buttonReadCurrent.enabled = true
            }

            bgres1.opacity = 0
            bgres2.opacity = 0
            bgFL1.opacity = 0
            bgFL2.opacity = 0
            circle1.color = "#00000000"
            circle2.color = "#00000000"

            useHallSenors1 = (mMcConf.getParamEnum("foc_sensor_mode")===2)
            useHallSenors2 = (mMcConf.getParamEnum("foc_sensor_mode2")===2)


            res = mMcConf.getParamDouble("foc_motor_r")
            res2 = mMcConf.getParamDouble("foc_motor_r2")
            ind = mMcConf.getParamDouble("foc_motor_l")
            ind2 = mMcConf.getParamDouble("foc_motor_l2")
            calcKpKi()
            calcKpKi2()

            for(var i = 0;i < 7;i++) {
                table[i] = mMcConf.getParamInt("foc_hall_table_" + i)
                table[i+8] = mMcConf.getParamInt("foc_hall2_table_" + i)
            }

            inv1 = mMcConf.getParamBool("m_invert_direction")
            inv2 = mMcConf.getParamBool("m_invert_direction2")

            lambda = mMcConf.getParamDouble("foc_motor_flux_linkage")
            lambda2 = mMcConf.getParamDouble("foc_motor_flux_linkage2")


            motorTemp = mMcConf.getParamDouble("l_temp_motor_end") - 35
            motorBeta = mMcConf.getParamDouble("m_ntc_motor_beta")
            motorTempEnable = mMcConf.getParamBool("m_motor_temp_throttle_enable")




            calcGain()
            calcGain2()

            maxCurrent1 = mMcConf.getParamDouble("l_current_max")
            maxCurrent2 = mMcConf.getParamDouble("l_current_max")

            maxBrakeCurrent1 = mMcConf.getParamDouble("l_current_min")
            maxBrakeCurrent2 = mMcConf.getParamDouble("l_current_min")


            battMaxCutoff = mMcConf.getParamDouble("l_battery_cut_start")
            battMinCutoff = mMcConf.getParamDouble("l_battery_cut_end")

            var cellNum = Math.round(battMaxCutoff/3.4)
            seriesCells.currentIndex = (cellNum - 3)


            battCharge = mMcConf.getParamDouble("l_in_current_min")
            battCurrent = mMcConf.getParamDouble("l_in_current_max")

            updateGraphics()

        }
    }

    Dialog {
        id: motorConfigDialog
        modal: true
        focus: true
        width: 0.8*uibox.width
        height: Math.min(implicitHeight, parent.height - 40)
        closePolicy: Popup.CloseOnEscape

        //font.pixelSize: uibox.width*0.03
        font.bold: true

        x: (parent.width - width) / 2
        y: (parent.height - height) / 2

        ScrollView {
            anchors.fill: parent
            clip: true
            contentWidth: parent.width - 20

            Text {
                id: motorConfigDialogLabel
                verticalAlignment: Text.AlignVCenter
                anchors.fill: parent
                wrapMode: Text.WordWrap
                textFormat: Text.RichText
                //font.pixelSize: parent.width*0.04
            }
        }
    }


    Connections {
        target: mCommands

        onDecodedPpmReceived: {
            valueNow = value
            msNow = last_len

            if (msNow < msMinTest) {
                msMinTest = msNow
            }

            if (msNow > msMaxTest) {
                msMaxTest = msNow
            }

            var range = msMaxTest - msMinTest
            var pos = msNow - msMinTest

            if (pos > (range / 4.0) && pos < ((3.0 * range) / 4.0)) {
                msCenterTest = msNow
            } else {
                msCenterTest = range / 2.0 + msMin
            }

            updateDisplay()
        }

        onMotorRLReceived: {
            if (r < 1e-9 && l < 1e-9) {
                VescIf.emitStatusMessage("Bad FOC Detection Result Received", false)
                bgres1.opacity = uibox.imageFade1
                bgres1.color = "red"

            } else {
                res = r
                ind = l * 1e-6
                calcKpKi()
                bgres1.opacity = uibox.imageFade1
                bgres1.color = uibox.accent1
            }
            if (r2 < 1e-9 && l2 < 1e-9) {
                bgres2.opacity = uibox.imageFade1
                bgres2.color = "red"
            } else {
                res2 = r2
                ind2= l2 * 1e-6
                calcKpKi2()
                bgres2.opacity = uibox.imageFade1
                bgres2.color = uibox.accent1
            }
            if (r < 1e-9 && l < 1e-9 && r2 < 1e-9 && l2 < 1e-9) {
                VescIf.emitStatusMessage("Bad FOC Detection Result Received", false)
                VescIf.emitMessageDialog("Bad Detection Result",
                                         "Could not measure the motor resistance and inductance.",
                                         false, false)
            }else{
                VescIf.emitStatusMessage("FOC Detection Result Received", true)
                updateGraphics()
            }
            mCommands.measureHallFoc(12.0)
        }
        onFocHallTableReceived: {
            var numInvalid1 = 0
            var numInvalid2 = 0
            table = hall_table
            updateGraphics()
            for(var i = 1;i < 6;i++) {
                if(table[i] > 200){
                    numInvalid1 = numInvalid1 + 1
                }
                if(table[i+8] > 200){
                    numInvalid2 = numInvalid2 + 1
                }
            }

            if(numInvalid1 > 0){
                circle1.color = "orange"
                useHallSenors1 = false
            }else{
                circle1.color = uibox.accent1
                useHallSenors1 = true
            }

            if(numInvalid2 >0){
                circle2.color = "orange"
                useHallSenors2 = false
            }else{
                circle2.color = uibox.accent1
                useHallSenors2 = true
            }

            if(numInvalid1 < 1  && numInvalid2 < 1 ){
                VescIf.emitStatusMessage("Hall Sensors Detected Succesfully For Both Motors", true)
            }else if(numInvalid1 < 1  && numInvalid2 > 0){
                VescIf.emitStatusMessage("Motor 1 Hall Sensors, Motor 2 Sensorless", true)
            }else if(numInvalid1 > 0  && numInvalid2 <1){
                VescIf.emitStatusMessage("Motor 1 Sensorless, Motor 2 Hall Sensors", true)
            }else{
                VescIf.emitStatusMessage("Both Motors Sensorless", true)
            }
            mCommands.measureLinkage()
            motorConfigDialog.open()
            motorConfigDialog.title = "Flux Linkage Measurement In Progress"
            motorConfigDialogLabel.text = "Hand spin each wheel in the forward direction of your board to set motor direction. This process will time out in 15 seconds or when adequate velocity spins are applied."

        }

        onMotorLinkageReceived: {
            motorConfigDialog.close()
            if (flux_linkage < 1e-9 && flux_linkage2 <1e-9) {
                VescIf.emitStatusMessage("Flux Linkage Measurement Failed", false)
            }else{
                VescIf.emitStatusMessage("Flux Linkage Detection Recieved", true)
            }
            if(flux_linkage>1e-9){
                lambda = flux_linkage
                inv1 = !dir1
                calcGain()
                bgFL1.opacity = uibox.imageFade1
                bgFL1.color = uibox.accent1
            }else{
                bgFL1.opacity = uibox.imageFade1
                bgFL1.color = "red"
            }
            if(flux_linkage2>1e-9){
                lambda2 = flux_linkage2
                inv2 = !dir2
                calcGain2()
                bgFL2.opacity = uibox.imageFade1
                bgFL2.color = uibox.accent1
            }else{
                bgFL2.opacity = uibox.imageFade1
                bgFL2.color = "red"
            }
            updateGraphics()
            button.enabled = true
        }
        onAckReceived: {
            if(ackType == "APPCONF Write OK"){
                if(writeBothConfig){
                    mCommands.setCurrent(0,0)
                    applyMotorConfig()
                }else{

                    writeBothConfig = true
                    reconnecctTimer.running = true
                    mCommands.setCurrent(0,0)
                }
            }
            if(ackType == "MCCONF Write OK"){
                reconnecctTimer.running = true
                buttonApplyValues.enabled = true
                calibrationButton.enabled = true
            }
        }

        onMcConfigCheckResult: {

            if (paramsNotSet.length > 0) {
                var notUpdated = "The following parameters were truncated because " +
                        "they were beyond the hardware limits:\n"

                for (var i = 0;i < paramsNotSet.length;i++) {
                    notUpdated += mMcConf.getLongName(paramsNotSet[i]) + "\n"
                }

                VescIf.emitMessageDialog("Parameters truncated", notUpdated, false, false)
            }
        }
    }

    Dialog{
        id: remoteDialog
        modal: true
        focus: true
        width: parent.width - 20
        closePolicy: Popup.CloseOnEscape
        title:"REMOTE CALIBRATION"

        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        ColumnLayout{
            id:remoteDialogBody
            anchors.fill:parent
            spacing: 10
            Text{
                id: instructions
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: "Press the throttle of your remote fully forward and backward to calibrate the maximum limits then hit APPLY."
            }
            RowLayout{
                Layout.fillWidth:  true
                ColumnLayout{
                    ProgressBar {
                        id: valueBarTest
                        Layout.fillWidth: true
                        from: -1.0
                        to: 1.0
                        value: 0.0
                        Behavior on value {
                            NumberAnimation {
                                easing.type: Easing.OutCirc
                                duration: 100
                            }
                        }
                    }
                    RowLayout{
                        Text{
                            id: txtMinTest
                            text: "1.0 ms"
                            Layout.alignment: Qt.AlignLeft
                            font.pixelSize: uibox.textSize1
                        }
                        Text{
                            id: txtNowTest
                            text: "1.5 ms"
                            Layout.alignment: Qt.AlignCenter
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: uibox.textSize1
                        }
                        Text{
                            id: txtMaxTest
                            text: "2.0 ms"
                            Layout.alignment: Qt.AlignRight
                            font.pixelSize: uibox.textSize1
                        }
                    }
                }
                Button {
                    Image{
                        source: "qrc:/res/icons/Refresh-96.png"
                        anchors.fill: parent
                    }
                    Layout.preferredWidth: height
                    onClicked: {
                        msMinTest = msNow
                        msMaxTest = msNow
                        msCenterTest = msNow
                    }
                }
            }
            /*Text{
                id: note
                font.italic:  true
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font.pixelSize: instructions.font.pixelSize*0.75
                horizontalAlignment: Text.AlignHCenter
                text: "This test should be run AFTER motor calibration"
            }*/
            RowLayout{
                Button {
                    //standardButtons: DialogButtonBox.Ok
                    Layout.fillWidth: true
                    text:"CANCEL"
                    Layout.alignment: Qt.AlignRight
                    onPressed: {
                        revertAppConfig()
                        remoteDialog.close()
                    }
                }
                Button {
                    //standardButtons: DialogButtonBox.Ok
                    Layout.fillWidth: true
                    text:"APPLY"
                    Layout.alignment: Qt.AlignRight
                    onPressed: {
                        msMin = msMinTest
                        msMax = msMaxTest
                        msCenter = msCenterTest
                        //rpmconv.value = 10*Math.max(Math.abs(startTac1 - tac1)/60.0, Math.abs(startTac2 - tac2)/60.0)
                        revertAppConfig()
                        remoteDialog.close()
                    }
                }
            }
        }

    }

    Dialog{
        id: remoteDialog2
        modal: true
        focus: true
        width: parent.width - 8
        closePolicy: Popup.CloseOnEscape
        //  title:"Throttle Curve Setup"


        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        ColumnLayout{
            id:remoteDialogBody2
            anchors.fill:parent
            spacing: 10

            RowLayout{
                Layout.fillWidth: true
                spacing: 0
                Slider {
                    id: slider10
                    orientation: Qt.Vertical
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Layout.fillHeight: true
                    value: 0.5
                    z:2
                    stepSize: 0.025
                    Layout.preferredWidth: buttonReadCurrent.height*1/3

                    // Layout.preferredHeight: buttonReadCurrent.height*2/3
                    onValueChanged:  {
                        torqueCurveBrake = value*10 - 5
                        torqueBrakeText.text = parseFloat(20*torqueCurveBrake).toFixed(0)+ " %"
                        drawTorqueCurve()
                    }
                }
                Rectangle{
                    Layout.fillWidth: true
                    Layout.preferredHeight: 0.7*width
                    z:1

                    ChartView {
                        title: "THROTTLE CURVE"
                        titleFont.pixelSize: uibox.textSize1*Screen.devicePixelRatio
                        titleFont.bold: true
                        anchors.centerIn: parent
                        scale: 1/(Screen.devicePixelRatio)
                        width: parent.width*Screen.devicePixelRatio
                        height: parent.height*Screen.devicePixelRatio

                        legend.visible: false
                        id: chartView2
                        animationOptions: ChartView.NoAnimation
                        theme: ChartView.ChartThemeLight
                        antialiasing: false

                        //property bool openGL: true
                        //property bool openGLSupported: true
                        ValueAxis {
                            id: axisY2
                            min: -100
                            labelFormat: "%.0f\%"
                            labelsFont.pixelSize: uibox.textSize1*Screen.devicePixelRatio
                            max: 100
                            // titleText: "Motor Command"
                        }


                        ValueAxis {
                            id: axisX2
                            min: -100
                            max: 100
                            labelFormat: "%.0f\%"
                            labelsFont.pixelSize: uibox.textSize1*Screen.devicePixelRatio
                            // titleText: "Remote Input"
                            //  labelsColor: "#00000000"
                        }


                        LineSeries {

                            id: throttleCurve
                            //name: "Motor 1 Voltage"
                            axisX: axisX2
                            axisYRight: axisY2
                            //useOpenGL: true
                            width: 3*Screen.devicePixelRatio
                            color: uibox.accent1


                            Component.onCompleted: {
                                drawTorqueCurve()
                            }

                        }
                    }
                }

                Slider {
                    id: slider7
                    orientation: Qt.Vertical
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Layout.fillHeight: true
                    value: 0.5
                    z:2
                    stepSize: 0.025
                    Layout.preferredWidth: buttonReadCurrent.height*1/3

                    // Layout.preferredHeight: buttonReadCurrent.height*2/3
                    onValueChanged:  {
                        torqueCurveAccel = value*10 - 5
                        torqueAccelText.text = parseFloat(20*torqueCurveAccel).toFixed(0)+ " %"
                        drawTorqueCurve()

                    }
                }
            }
            RowLayout{
                Layout.fillWidth: true
                Text{
                    id:torqueBrakeText
                    text:"0 %"
                    font.bold: true
                    horizontalAlignment: Text.AlignLeft
                    font.pixelSize: uibox.textSize2
                    // Layout.alignment: Qt.AlignRight
                    Layout.preferredWidth: parent.width/5
                }

                ComboBox {
                    id: torqueCurveModeComboBox
                    Layout.fillWidth: true
                    //  Layout.preferredHeight:  0.6*uibox.middleColumnWidth1
                    // Layout.preferredWidth: parent.width/2
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    transformOrigin: Item.Center
                    font.pixelSize: uibox.textSize1
                    currentIndex: 2

                    model: [
                        "Power Function",
                        "Exponential Function",
                        "Polynomial Function"
                    ]

                    onCurrentIndexChanged: {
                        torqueCurveMode = currentIndex
                        drawTorqueCurve()
                    }
                }
                Text{
                    id:torqueAccelText
                    text:"0 %"
                    font.bold: true
                    horizontalAlignment: Text.AlignRight
                    font.pixelSize: uibox.textSize2
                    // Layout.alignment: Qt.AlignRight
                    Layout.preferredWidth: parent.width/5
                }
            }

            RowLayout{
                Button {
                    //standardButtons: DialogButtonBox.Ok
                    Layout.fillWidth: true
                    text:"OK"
                    Layout.alignment: Qt.AlignRight
                    onPressed: {
                        remoteDialog2.close()
                    }
                }
            }
        }

    }
}

