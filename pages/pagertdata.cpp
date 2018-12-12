/*
    Copyright 2016 - 2017 Benjamin Vedder	benjamin@vedder.se

    

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

#include "pagertdata.h"
#include "ui_pagertdata.h"

PageRtData::PageRtData(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::PageRtData)
{
    ui->setupUi(this);
    layout()->setContentsMargins(0, 0, 0, 0);
    mVesc = 0;

    mTimer = new QTimer(this);
    mTimer->start(20);

    mSecondCounter = 0.0;
    mLastUpdateTime = 0;

    mUpdateValPlot = false;
    mUpdatePosPlot = false;

    ui->currentPlot->setInteractions(QCP::iRangeDrag | QCP::iRangeZoom);
    ui->tempPlot->setInteractions(QCP::iRangeDrag | QCP::iRangeZoom);
    ui->rpmPlot->setInteractions(QCP::iRangeDrag | QCP::iRangeZoom);
    ui->focPlot->setInteractions(QCP::iRangeDrag | QCP::iRangeZoom);
    ui->posPlot->setInteractions(QCP::iRangeDrag | QCP::iRangeZoom);

    // Current and duty
    int graphIndex = 0;
    ui->currentPlot->addGraph();
    ui->currentPlot->graph(graphIndex)->setPen(QPen(Qt::blue));
    ui->currentPlot->graph(graphIndex)->setName("Current in");
    graphIndex++;

    ui->currentPlot->addGraph();
    ui->currentPlot->graph(graphIndex)->setPen(QPen(Qt::red));
    ui->currentPlot->graph(graphIndex)->setName("Current motor 1");
    graphIndex++;

    ui->currentPlot->addGraph();
    ui->currentPlot->graph(graphIndex)->setPen(QPen(Qt::darkRed));
    ui->currentPlot->graph(graphIndex)->setName("Current motor 2");
    graphIndex++;

    ui->currentPlot->addGraph(ui->currentPlot->xAxis, ui->currentPlot->yAxis2);
    ui->currentPlot->graph(graphIndex)->setPen(QPen(Qt::cyan));
    ui->currentPlot->graph(graphIndex)->setName("Duty cycle 1");
    graphIndex++;

    ui->currentPlot->addGraph(ui->currentPlot->xAxis, ui->currentPlot->yAxis2);
    ui->currentPlot->graph(graphIndex)->setPen(QPen(Qt::darkCyan));
    ui->currentPlot->graph(graphIndex)->setName("Duty cycle 2");
    graphIndex++;

    // Temperatures
    graphIndex = 0;
    ui->tempPlot->addGraph();
    ui->tempPlot->graph(graphIndex)->setPen(QPen(Qt::blue));
    ui->tempPlot->graph(graphIndex)->setName("Temperature MOSFET 1");
    graphIndex++;

    ui->tempPlot->addGraph();
    ui->tempPlot->graph(graphIndex)->setPen(QPen(Qt::green));
    ui->tempPlot->graph(graphIndex)->setName("Temperature MOSFET 2");
    graphIndex++;

    ui->tempPlot->addGraph(ui->tempPlot->xAxis, ui->tempPlot->yAxis2);
    ui->tempPlot->graph(graphIndex)->setPen(QPen(Qt::magenta));
    ui->tempPlot->graph(graphIndex)->setName("Temperature Motor 1");
    graphIndex++;

    ui->tempPlot->addGraph(ui->tempPlot->xAxis, ui->tempPlot->yAxis2);
    ui->tempPlot->graph(graphIndex)->setPen(QPen(Qt::cyan));
    ui->tempPlot->graph(graphIndex)->setName("Temperature Motor 2");
    graphIndex++;

    // RPM
    graphIndex = 0;
    ui->rpmPlot->addGraph();
    ui->rpmPlot->graph(graphIndex)->setPen(QPen(Qt::blue));
    ui->rpmPlot->graph(graphIndex)->setName("ERPM 1");
    graphIndex++;

    ui->rpmPlot->addGraph();
    ui->rpmPlot->graph(graphIndex)->setPen(QPen(Qt::red));
    ui->rpmPlot->graph(graphIndex)->setName("ERPM 2");
    graphIndex++;

    // FOC
    graphIndex = 0;
    ui->focPlot->addGraph();
    ui->focPlot->graph(graphIndex)->setPen(QPen(Qt::blue));
    ui->focPlot->graph(graphIndex)->setName("D Current 1");
    graphIndex++;

    ui->focPlot->addGraph();
    ui->focPlot->graph(graphIndex)->setPen(QPen(Qt::darkBlue));
    ui->focPlot->graph(graphIndex)->setName("D Current 2");
    graphIndex++;

    ui->focPlot->addGraph();
    ui->focPlot->graph(graphIndex)->setPen(QPen(Qt::red));
    ui->focPlot->graph(graphIndex)->setName("Q Current 1");
    graphIndex++;

    ui->focPlot->addGraph();
    ui->focPlot->graph(graphIndex)->setPen(QPen(Qt::darkRed));
    ui->focPlot->graph(graphIndex)->setName("Q Current 2");
    graphIndex++;

    QFont legendFont = font();
    legendFont.setPointSize(9);

    ui->currentPlot->legend->setVisible(true);
    ui->currentPlot->legend->setFont(legendFont);
    ui->currentPlot->axisRect()->insetLayout()->setInsetAlignment(0, Qt::AlignRight|Qt::AlignBottom);
    ui->currentPlot->legend->setBrush(QBrush(QColor(255,255,255,230)));
    ui->currentPlot->xAxis->setLabel("Seconds (s)");
    ui->currentPlot->yAxis->setLabel("Ampere (A)");
    ui->currentPlot->yAxis2->setLabel("Duty Cycle");

    ui->tempPlot->legend->setVisible(true);
    ui->tempPlot->legend->setFont(legendFont);
    ui->tempPlot->axisRect()->insetLayout()->setInsetAlignment(0, Qt::AlignRight|Qt::AlignBottom);
    ui->tempPlot->legend->setBrush(QBrush(QColor(255,255,255,230)));
    ui->tempPlot->xAxis->setLabel("Seconds (s)");
    ui->tempPlot->yAxis->setLabel("Temperature MOSFET (\u00B0C)");
    ui->tempPlot->yAxis2->setLabel("Temperature Motor (\u00B0C)");

    ui->rpmPlot->legend->setVisible(true);
    ui->rpmPlot->legend->setFont(legendFont);
    ui->rpmPlot->axisRect()->insetLayout()->setInsetAlignment(0, Qt::AlignRight|Qt::AlignBottom);
    ui->rpmPlot->legend->setBrush(QBrush(QColor(255,255,255,230)));
    ui->rpmPlot->xAxis->setLabel("Seconds (s)");
    ui->rpmPlot->yAxis->setLabel("ERPM");

    ui->focPlot->legend->setVisible(true);
    ui->focPlot->legend->setFont(legendFont);
    ui->focPlot->axisRect()->insetLayout()->setInsetAlignment(0, Qt::AlignRight|Qt::AlignBottom);
    ui->focPlot->legend->setBrush(QBrush(QColor(255,255,255,230)));
    ui->focPlot->xAxis->setLabel("Seconds (s)");
    ui->focPlot->yAxis->setLabel("Current");

    ui->currentPlot->yAxis->setRange(-20, 130);
    ui->currentPlot->yAxis2->setRange(-0.2, 1.3);
    ui->currentPlot->yAxis2->setVisible(true);
    ui->tempPlot->yAxis->setRange(0, 120);
    ui->tempPlot->yAxis2->setRange(0, 120);
    ui->tempPlot->yAxis2->setVisible(true);
    ui->rpmPlot->yAxis->setRange(0, 120);
    ui->focPlot->yAxis->setRange(0, 120);

    ui->posPlot->addGraph();
    ui->posPlot->graph(0)->setPen(QPen(Qt::blue));
    ui->posPlot->graph(0)->setName("Position");
    ui->posPlot->legend->setVisible(true);
    ui->posPlot->legend->setFont(legendFont);
    ui->posPlot->axisRect()->insetLayout()->setInsetAlignment(0, Qt::AlignRight|Qt::AlignBottom);
    ui->posPlot->legend->setBrush(QBrush(QColor(255,255,255,230)));
    ui->posPlot->xAxis->setLabel("Sample");
    ui->posPlot->yAxis->setLabel("Degrees");

    connect(mTimer, SIGNAL(timeout()),
            this, SLOT(timerSlot()));
}

PageRtData::~PageRtData()
{
    delete ui;
}

VescInterface *PageRtData::vesc() const
{
    return mVesc;
}

void PageRtData::setVesc(VescInterface *vesc)
{
    mVesc = vesc;

    if (mVesc) {
        connect(mVesc->commands(), SIGNAL(valuesReceived(MC_VALUES)),
                this, SLOT(valuesReceived(MC_VALUES)));
        connect(mVesc->commands(), SIGNAL(rotorPosReceived(double)),
                this, SLOT(rotorPosReceived(double)));
    }
}

void PageRtData::timerSlot()
{
    if (mUpdateValPlot) {
        int dataSize = mTempMosVec.size();

        QVector<double> xAxis(dataSize);
        for (int i = 0;i < mSeconds.size();i++) {
            xAxis[i] = mSeconds[i];
        }

        // Current and duty-plot
        int graphIndex = 0;
        ui->currentPlot->graph(graphIndex++)->setData(xAxis, mCurrInVec);
        ui->currentPlot->graph(graphIndex++)->setData(xAxis, mCurrMotorVec);
        ui->currentPlot->graph(graphIndex++)->setData(xAxis, mCurrMotorVec2);
        ui->currentPlot->graph(graphIndex++)->setData(xAxis, mDutyVec);
        ui->currentPlot->graph(graphIndex++)->setData(xAxis, mDutyVec2);

        // Temperature plot
        graphIndex = 0;
        ui->tempPlot->graph(graphIndex++)->setData(xAxis, mTempMosVec);
        ui->tempPlot->graph(graphIndex++)->setData(xAxis, mTempMosVec2);
        ui->tempPlot->graph(graphIndex++)->setData(xAxis, mTempMotorVec);
        ui->tempPlot->graph(graphIndex++)->setData(xAxis, mTempMotorVec2);

        // RPM plot
        graphIndex = 0;
        ui->rpmPlot->graph(graphIndex++)->setData(xAxis, mRpmVec);
        ui->rpmPlot->graph(graphIndex++)->setData(xAxis, mRpmVec2);

        // FOC plot
        graphIndex = 0;
        ui->focPlot->graph(graphIndex++)->setData(xAxis, mIdVec);
        ui->focPlot->graph(graphIndex++)->setData(xAxis, mIdVec2);
        ui->focPlot->graph(graphIndex++)->setData(xAxis, mIqVec);
        ui->focPlot->graph(graphIndex++)->setData(xAxis, mIqVec2);

        if (ui->autoscaleButton->isChecked()) {
            ui->currentPlot->rescaleAxes();
            ui->tempPlot->rescaleAxes();
            ui->rpmPlot->rescaleAxes();
            ui->focPlot->rescaleAxes();
        }

        ui->currentPlot->replot();
        ui->tempPlot->replot();
        ui->rpmPlot->replot();
        ui->focPlot->replot();

        mUpdateValPlot = false;
    }

    if (mUpdatePosPlot) {
        QVector<double> xAxis(mPositionVec.size());
        for (int i = 0;i < mPositionVec.size();i++) {
            xAxis[i] = (double)i;
        }

        ui->posBar->setValue((int)fabs(mPositionVec.last()));
        ui->posPlot->graph(0)->setData(xAxis, mPositionVec);

        if (ui->autoscaleButton->isChecked()) {
            ui->posPlot->rescaleAxes();
        }

        ui->posPlot->replot();

        mUpdatePosPlot = false;
    }
}

void PageRtData::valuesReceived(MC_VALUES values)
{
    ui->rtText->setValues(values);

    const int maxS = 500;

    appendDoubleAndTrunc(&mTempMosVec, values.temp_mos, maxS);
    appendDoubleAndTrunc(&mTempMosVec2, values.temp_mos2, maxS);
    appendDoubleAndTrunc(&mTempMotorVec, values.temp_motor, maxS);
    appendDoubleAndTrunc(&mTempMotorVec2, values.temp_motor2, maxS);
    appendDoubleAndTrunc(&mCurrInVec, values.current_in, maxS);
    appendDoubleAndTrunc(&mCurrMotorVec, values.current_motor, maxS);
    appendDoubleAndTrunc(&mCurrMotorVec2, values.current_motor2, maxS);
    appendDoubleAndTrunc(&mIdVec, values.id, maxS);
    appendDoubleAndTrunc(&mIdVec2, values.id2, maxS);
    appendDoubleAndTrunc(&mIqVec, values.iq, maxS);
    appendDoubleAndTrunc(&mIqVec2, values.iq2, maxS);
    appendDoubleAndTrunc(&mDutyVec, values.duty_now, maxS);
    appendDoubleAndTrunc(&mDutyVec2, values.duty_now2, maxS);
    appendDoubleAndTrunc(&mRpmVec, values.rpm, maxS);
    appendDoubleAndTrunc(&mRpmVec2, values.rpm2, maxS);

    qint64 tNow = QDateTime::currentMSecsSinceEpoch();

    double elapsed = (double)(tNow - mLastUpdateTime) / 1000.0;
    if (elapsed > 1.0) {
        elapsed = 1.0;
    }

    mSecondCounter += elapsed;

    appendDoubleAndTrunc(&mSeconds, mSecondCounter, maxS);

    mLastUpdateTime = tNow;

    mUpdateValPlot = true;
}

void PageRtData::rotorPosReceived(double pos)
{
    appendDoubleAndTrunc(&mPositionVec, pos, 1500);
    mUpdatePosPlot = true;
}

void PageRtData::appendDoubleAndTrunc(QVector<double> *vec, double num, int maxSize)
{
    vec->append(num);

    if(vec->size() > maxSize) {
        vec->remove(0, vec->size() - maxSize);
    }
}

void PageRtData::updateZoom()
{
    Qt::Orientations plotOrientations = (Qt::Orientations)
            ((ui->zoomHButton->isChecked() ? Qt::Horizontal : 0) |
             (ui->zoomVButton->isChecked() ? Qt::Vertical : 0));

    ui->currentPlot->axisRect()->setRangeZoom(plotOrientations);
    ui->tempPlot->axisRect()->setRangeZoom(plotOrientations);
    ui->rpmPlot->axisRect()->setRangeZoom(plotOrientations);
    ui->focPlot->axisRect()->setRangeZoom(plotOrientations);
    ui->posPlot->axisRect()->setRangeZoom(plotOrientations);
}

void PageRtData::on_zoomHButton_toggled(bool checked)
{
    (void)checked;
    updateZoom();
}

void PageRtData::on_zoomVButton_toggled(bool checked)
{
    (void)checked;
    updateZoom();
}

void PageRtData::on_rescaleButton_clicked()
{
    ui->currentPlot->rescaleAxes();
    ui->tempPlot->rescaleAxes();
    ui->rpmPlot->rescaleAxes();
    ui->focPlot->rescaleAxes();
    ui->posPlot->rescaleAxes();

    ui->currentPlot->replot();
    ui->tempPlot->replot();
    ui->rpmPlot->replot();
    ui->focPlot->replot();
    ui->posPlot->replot();
}

void PageRtData::on_posInductanceButton_clicked()
{
    if (mVesc) {
        mVesc->commands()->setDetect(DISP_POS_MODE_INDUCTANCE);
    }
}

void PageRtData::on_posObserverButton_clicked()
{
    if (mVesc) {
        mVesc->commands()->setDetect(DISP_POS_MODE_OBSERVER);
    }
}

void PageRtData::on_posEncoderButton_clicked()
{
    if (mVesc) {
        mVesc->commands()->setDetect(DISP_POS_MODE_ENCODER);
    }
}

void PageRtData::on_posPidButton_clicked()
{
    if (mVesc) {
        mVesc->commands()->setDetect(DISP_POS_MODE_PID_POS);
    }
}

void PageRtData::on_posPidErrorButton_clicked()
{
    if (mVesc) {
        mVesc->commands()->setDetect(DISP_POS_MODE_PID_POS_ERROR);
    }
}

void PageRtData::on_posEncoderObserverErrorButton_clicked()
{
    if (mVesc) {
        mVesc->commands()->setDetect(DISP_POS_MODE_ENCODER_OBSERVER_ERROR);
    }
}

void PageRtData::on_posStopButton_clicked()
{
    if (mVesc) {
        mVesc->commands()->setDetect(DISP_POS_MODE_NONE);
    }
}

void PageRtData::on_tempShowMosfetBox_toggled(bool checked)
{
    ui->tempPlot->graph(0)->setVisible(checked);
}

void PageRtData::on_tempShowMotorBox_toggled(bool checked)
{
    ui->tempPlot->graph(1)->setVisible(checked);
}
