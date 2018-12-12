/****************************************************************************
**
** Copyright (C) 2016 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
** This file is part of the Qt Charts module of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:GPL$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see https://www.qt.io/terms-conditions. For further
** information use the contact form at https://www.qt.io/contact-us.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 3 or (at your option) any later version
** approved by the KDE Free Qt Foundation. The licenses are as published by
** the Free Software Foundation and appearing in the file LICENSE.GPL3
** included in the packaging of this file. Please review the following
** information to ensure the GNU General Public License requirements will
** be met: https://www.gnu.org/licenses/gpl-3.0.html.
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick 2.0
import QtCharts 2.2
import QtQuick.Window 2.11
//import QuickPlot 1.0


//![1]
Item {
    id: logging
    anchors.fill:parent
    property real chart1CurrentMin: 0
    property real chart1CurrentMax: 0
    property real chart2CurrentMin: 0
    property real chart2CurrentMax: 0
    property real iii: 0
    property real numSamples:100
    // width: 600
    //  height: 400

    /* ControlPanel {
        id: controlPanel
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.leftMargin: 10
//![1]

        onSignalSourceChanged: {
            if (source == "sin")
                dataSource.generateData(0, signalCount, sampleCount);
            else
                dataSource.generateData(1, signalCount, sampleCount);
            scopeView.axisX().max = sampleCount;
        }
        onSeriesTypeChanged: scopeView.changeSeriesType(type);
        onRefreshRateChanged: scopeView.changeRefreshRate(rate);
        onAntialiasingEnabled: scopeView.antialiasing = enabled;
        onOpenGlChanged: {
            scopeView.openGL = enabled;
        }
    }*/

    //![2]

    Flickable {
        anchors.centerIn:parent
        scale:1///Screen.devicePixelRatio
        width: parent.width
        height: parent.height

        boundsBehavior: Flickable.DragAndOvershootBounds
        contentHeight: contentItem.childrenRect.height
        contentWidth: width


        id: columnLayoutProps
        anchors.rightMargin: 0
        anchors.topMargin: 0
        anchors.bottomMargin: 0
        anchors.leftMargin: 0
        clip:true
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        ColumnLayout{
            spacing: 10
            anchors.top: parent.top
            width: parent.width
            anchors.rightMargin: 0
            anchors.bottomMargin: 0
            anchors.leftMargin: 0
            onImplicitHeightChanged: columnLayoutProps.contentHeight = implicitHeight
            /*
            PlotArea {
                id: plotArea
                Layout.fillWidth: true
                Layout.preferredHeight: 0.6*width
                antialiasing: true

                yScaleEngine: TightScaleEngine {
                    max: 1.5
                    min: -1.5
                }

                items: [
                    ScrollingCurve {
                        antialiasing: true
                        id: meter;
                        numPoints: 100
                        color: 'red'

                    },

                    ScrollingCurve {
                        id: meter2;
                        numPoints: 100
                        color: 'blue'

                    }
                ]
            }
            */


            /*
            ChartView {
                Layout.fillWidth: true
                Layout.preferredHeight: 0.6*width
                id: chartView
                animationOptions: ChartView.SeriesAnimations
                theme: ChartView.ChartThemeDark
                antialiasing: enabled
                property bool openGL: true
                property bool openGLSupported: true

                ValueAxis {
                    id: axisY1
                    min: -80
                    max: 80
                    titleText: "Amps"
                }


                ValueAxis {
                    id: axisX1
                    min: 0
                    max: logging.numSamples
                    labelsColor: "#00000000"
                }

                LineSeries {
                    id: mot1Current
                    name: "Motor 1 Current"
                    axisX: axisX1
                    axisY: axisY1
                    useOpenGL: chartView.openGL
                }
                LineSeries {
                    id: mot2Current
                    name: "Motor 2 Current"
                    axisX: axisX1
                    axisY: axisY1
                    useOpenGL: chartView.openGL
                }
            }*/

            ChartView {
                Layout.fillWidth: true
                Layout.preferredHeight: 0.6*width
                id: chartView2
                animationOptions: ChartView.NoAnimation
                theme: ChartView.ChartThemeDark
                antialiasing: true
                property bool openGL: true
                property bool openGLSupported: true

                ValueAxis {
                    id: axisY2
                    min: -25
                    max: 25
                    titleText: "Volts"
                }


                ValueAxis {
                    id: axisX2
                    min: 0
                    max: logging.numSamples
                    labelsColor: "#00000000"
                }


                LineSeries {
                    id: mot1Volt
                    name: "Motor 1 Voltage"
                    axisX: axisX2
                    axisYRight: axisY2
                    useOpenGL: chartView2.openGL
                }
                LineSeries {
                    id: mot2Volt
                    name: "Motor 2 Voltage"
                    axisX: axisX2
                    axisYRight: axisY2
                    useOpenGL: chartView2.openGL
                }
            }
            /*



            ChartView {
                Layout.fillWidth: true
                Layout.preferredHeight: 0.6*width
                id: chartView3
                animationOptions: ChartView.SeriesAnimations
                theme: ChartView.ChartThemeDark
                antialiasing: enabled
                property bool openGL: true
                property bool openGLSupported: true

                ValueAxis {
                    id: axisY3
                    min: 0
                    max: 25
                    titleText: "Temperature(Celcius)"
                }


                ValueAxis {
                    id: axisX3
                    min: 0
                    max: logging.numSamples
                    labelsColor: "#00000000"
                }

                LineSeries {
                    id: mot1Temp
                    name: "Motor 1 Temp"
                    axisX: axisX3
                    axisY: axisY3
                    useOpenGL: chartView.openGL
                }
                LineSeries {
                    id: mot2Temp
                    name: "Motor 2 Temp"
                    axisX: axisX3
                    axisY: axisY3
                    useOpenGL: chartView.openGL
                }
                LineSeries {
                    id: fet1Temp
                    name: "MOSFET Temp 2"
                    axisX: axisX3
                    axisY: axisY3
                    useOpenGL: chartView.openGL
                }
                LineSeries {
                    id: fet2Temp
                    name: "MOSFET Temp 2"
                    axisX: axisX3
                    axisY: axisY3
                    useOpenGL: chartView.openGL
                }


            }

            ChartView {
                Layout.fillWidth: true
                Layout.preferredHeight: 0.6*width
                id: chartView4
                animationOptions: ChartView.SeriesAnimations
                theme: ChartView.ChartThemeDark
                antialiasing: enabled
                property bool openGL: true
                property bool openGLSupported: true

                ValueAxis {
                    id: axisY4
                    min: -80
                    max: 80
                    titleText: "Amps"
                }

                ValueAxis {
                    id: axisY5
                    min: -80
                    max: 80
                    titleText: "Volts"
                }


                ValueAxis {
                    id: axisX4
                    min: 0
                    max: logging.numSamples
                    labelsColor: "#00000000"
                }

                LineSeries {
                    id: battCurrent
                    name: "Battery Current"
                    axisX: axisX4
                    axisY: axisY4
                    useOpenGL: chartView.openGL
                }

                LineSeries {
                    id: battVolt
                    name: "Battery Voltage"
                    axisX: axisX4
                    axisYRight: axisY5
                    useOpenGL: chartView.openGL
                }

            }*/
        }
    }



    Connections {
        target: mCommands
        onValuesReceived: {

           // meter.appendDataPoint( values.v_in*values.duty_now );
            //meter2.appendDataPoint( values.v_in*values.duty_now2);


            var i
            iii++
            /*
            if(iii>battCurrent.count/2){
                iii = 0;
                chart1CurrentMax = 0;
                chart1CurrentMin = 0;
                chart2CurrentMax = 0;
                chart2CurrentMin = 0;
                for(i =0; i<battCurrent.count; i++){

                    chart1CurrentMax = (chart1CurrentMax<mot1Current.at(i).y)?mot1Current.at(i).y:chart1CurrentMax
                    chart1CurrentMin = (chart1CurrentMin>mot1Current.at(i).y )?mot1Current.at(i).y:chart1CurrentMin
                    chart1CurrentMax = (chart1CurrentMax<mot2Current.at(i).y)?mot2Current.at(i).y:chart1CurrentMax
                    chart1CurrentMin = (chart1CurrentMin>mot2Current.at(i).y )?mot2Current.at(i).y:chart1CurrentMin

                    chart2CurrentMax = (chart2CurrentMax<mot1Volt.at(i).y)?mot1Volt.at(i).y:chart2CurrentMax
                    chart2CurrentMin = (chart2CurrentMin>mot1Volt.at(i).y )?mot1Volt.at(i).y:chart2CurrentMin
                    chart2CurrentMax = (chart2CurrentMax<mot2Volt.at(i).y)?mot2Volt.at(i).y:chart2CurrentMax
                    chart2CurrentMin = (chart2CurrentMin>mot2Volt.at(i).y )?mot2Volt.at(i).y:chart2CurrentMin
                }
            }else{
                i = battCurrent.count - 1;
                chart1CurrentMax = (chart1CurrentMax<mot1Current.at(i).y)?mot1Current.at(i).y:chart1CurrentMax
                chart1CurrentMin = (chart1CurrentMin>mot1Current.at(i).y )?mot1Current.at(i).y:chart1CurrentMin
                chart1CurrentMax = (chart1CurrentMax<mot2Current.at(i).y)?mot2Current.at(i).y:chart1CurrentMax
                chart1CurrentMin = (chart1CurrentMin>mot2Current.at(i).y )?mot2Current.at(i).y:chart1CurrentMin

                chart2CurrentMax = (chart2CurrentMax<mot1Volt.at(i).y)?mot1Volt.at(i).y:chart2CurrentMax
                chart2CurrentMin = (chart2CurrentMin>mot1Volt.at(i).y )?mot1Volt.at(i).y:chart2CurrentMin
                chart2CurrentMax = (chart2CurrentMax<mot2Volt.at(i).y)?mot2Volt.at(i).y:chart2CurrentMax
                chart2CurrentMin = (chart2CurrentMin>mot2Volt.at(i).y )?mot2Volt.at(i).y:chart2CurrentMin
            }

            axisY1.min = (chart1CurrentMin<0)*Math.floor(chart1CurrentMin)
            axisY1.max = Math.ceil(chart1CurrentMax+0.1)

            axisY2.min = (chart2CurrentMin<0)*Math.floor(chart2CurrentMin)
            axisY2.max = Math.ceil(chart2CurrentMax)+1
             */
            if(mot1Volt.count<numSamples){
                /*battCurrent.append(battCurrent.count,values.current_in)
                mot1Current.append(mot1Current.count,values.current_motor)
                mot2Current.append(mot2Current.count,values.current_motor2)

                battVolt.append(battVolt.count,values.v_in)*/
                mot1Volt.append(mot1Volt.count,values.v_in*values.duty_now)
                mot2Volt.append(mot2Volt.count,values.v_in*values.duty_now2)

            }else{
                /*
                battCurrent.append(battCurrent.at(numSamples-1).x+1,values.current_in);
                mot1Current.append(mot1Current.at(numSamples-1).x+1,values.current_motor);
                mot2Current.append(mot2Current.at(numSamples-1).x+1,values.current_motor2);
                battCurrent.remove(0);
                mot1Current.remove(0);
                mot2Current.remove(0);
                axisX1.min = battCurrent.at(0).x
                axisX1.max = battCurrent.at(numSamples-1).x*/

                //battVolt.append(battVolt.at(numSamples-1).x+1,values.v_in);
                mot1Volt.append(mot1Volt.at(numSamples-1).x+1,values.v_in*values.duty_now);
                mot2Volt.append(mot2Volt.at(numSamples-1).x+1,values.v_in*values.duty_now2);
                //battVolt.remove(0);
                mot1Volt.remove(0);
                mot2Volt.remove(0);
                axisX2.min = mot1Volt.at(0).x
                axisX2.max = mot1Volt.at(numSamples-1).x
            }

            /*currentGauge.value = Math.abs(values.current_motor)
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
    //![2]
}
