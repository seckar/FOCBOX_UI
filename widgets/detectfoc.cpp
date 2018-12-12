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

#include "detectfoc.h"
#include "ui_detectfoc.h"
#include "helpdialog.h"
#include <QMessageBox>

DetectFoc::DetectFoc(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::DetectFoc)
{
    ui->setupUi(this);
    layout()->setContentsMargins(0, 0, 0, 0);
    mVesc = 0;
    mLastCalcOk = false;
    mAllValuesOk = false;
    mLastOkValuesApplied = false;
    mRunning = false;
    updateColors();
}

DetectFoc::~DetectFoc()
{
    delete ui;
}

void DetectFoc::on_rlButton_clicked()
{
    if (mVesc) {
        if (!mVesc->isPortConnected()) {
            QMessageBox::critical(this,
                                  tr("Connection Error"),
                                  tr("The FOCBOX is not connected. Please connect it."));
            return;
        }

        QMessageBox::information(this,
                              tr("Measure R & L"),
                              tr("When measuring R & L the motor is going to make some noises, but "
                                 "not rotate. These noises are completely normal, so don't unplug "
                                 "anything unless you see smoke."));

        mVesc->commands()->measureRL();
        mRunning = true;
    }
}

void DetectFoc::on_lambdaButton_clicked()
{
    if (mVesc) {
        if (!mVesc->isPortConnected()) {
            QMessageBox::critical(this,
                                  tr("Connection Error"),
                                  tr("The FOCBOX is not connected. Please connect it."));
            return;
        }

        if (ui->resistanceBox->value() < 1e-10 || ui->resistanceBox_2->value() < 1e-10 ) {
            QMessageBox::critical(this,
                                  tr("Measure Error"),
                                  tr("R is 0. Please measure it first."));
            return;
        }

        QMessageBox::StandardButton reply;
        reply = QMessageBox::warning(this,
                                     tr("ATTENTION"),
                                     tr("Please hand spin each motor to detect"
                                        "flux linkage."),
                                     QMessageBox::Ok | QMessageBox::Cancel);

        if (reply == QMessageBox::Ok) {
            mVesc->commands()->measureLinkage();

            mRunning = true;
        }
    }
}

void DetectFoc::on_helpButton_clicked()
{
    if (mVesc) {
        HelpDialog::showHelp(this, mVesc->infoConfig(), "help_foc_detect", false);
    }
}

VescInterface *DetectFoc::vesc() const
{
    return mVesc;
}

void DetectFoc::setVesc(VescInterface *vesc)
{
    mVesc = vesc;

    if (mVesc) {
        connect(mVesc->commands(), SIGNAL(motorRLReceived(double,double,double,double)),
                this, SLOT(motorRLReceived(double,double,double,double)));
        connect(mVesc->commands(), SIGNAL(motorLinkageReceived(double,double,bool,bool)),
                this, SLOT(motorLinkageReceived(double,double)));
    }
}

void DetectFoc::motorRLReceived(double r, double l, double r2, double l2)
{
    if (!mRunning) {
        return;
    }

    mRunning = false;

    if (r < 1e-9 && l < 1e-9) {
        mVesc->emitStatusMessage(tr("Bad FOC Detection Result Received"), false);
        QMessageBox::critical(this,
                              tr("Bad Detection Result"),
                              tr("Could not measure the motor resistance and inductance."));
    } else {
        mVesc->emitStatusMessage(tr("FOC Detection Result Received"), true);
        ui->resistanceBox->setValue(r * 1e3);
        ui->resistanceBox_2->setValue(r2 * 1e3);
        ui->inductanceBox->setValue(l);
        ui->inductanceBox_2->setValue(l2);
        ui->kpBox->setValue(0.0);
        ui->kiBox->setValue(0.0);
        ui->kpBox_2->setValue(0.0);
        ui->kiBox_2->setValue(0.0);
        on_calcKpKiButton_clicked();

        // TODO: Use some rule to calculate time constant?
//        if (l > 50.0) {
//            ui->tcBox->setValue(2000);
//        } else {
//            ui->tcBox->setValue(1000);
//        }
    }

    mLastOkValuesApplied = false;
    updateColors();
}

void DetectFoc::motorLinkageReceived(double flux_linkage,double flux_linkage2)
{
    if (!mRunning) {
        return;
    }

    mRunning = false;

    if (flux_linkage < 1e-9) {
        mVesc->emitStatusMessage(tr("Bad FOC Detection Result Received"), false);
        QMessageBox::critical(this,
                              tr("Bad Detection Result"),
                              tr("Could not measure the flux linkage properly. Adjust the start parameters "
                                 "according to the help text and try again."));
    } else {
        mVesc->emitStatusMessage(tr("FOC Detection Result Received"), true);
        ui->lambdaBox->setValue(flux_linkage * 1e3);
        ui->obsGainBox->setValue(0.0);
    }

    if (flux_linkage2 < 1e-9) {
        mVesc->emitStatusMessage(tr("Bad FOC Detection Result Received"), false);
        QMessageBox::critical(this,
                              tr("Bad Detection Result"),
                              tr("Could not measure the flux linkage 2 properly. Adjust the start parameters "
                                 "according to the help text and try again."));
    } else {
        mVesc->emitStatusMessage(tr("FOC Detection Result Received"), true);
        ui->lambdaBox_2->setValue(flux_linkage2 * 1e3);
        ui->obsGainBox_2->setValue(0.0);
    }
    if(flux_linkage > 1e-9 && flux_linkage2 > 1e-9){
        on_calcGainButton_clicked();
    }

    mLastOkValuesApplied = false;
    updateColors();
}

void DetectFoc::on_applyAllButton_clicked()
{
    if (mVesc) {
        double r = ui->resistanceBox->value() / 1e3;
        double l = ui->inductanceBox->value();
        double lambda = ui->lambdaBox->value() / 1e3;
        double r2 = ui->resistanceBox_2->value() / 1e3;
        double l2 = ui->inductanceBox_2->value();
        double lambda2 = ui->lambdaBox_2->value() / 1e3;

        if (r < 1e-10) {
            QMessageBox::critical(this,
                                  tr("Apply Error"),
                                  tr("R1 is 0. Please measure it first."));
            return;
        }

        if (l < 1e-10) {
            QMessageBox::critical(this,
                                  tr("Apply Error"),
                                  tr("L1 is 0. Please measure it first."));
            return;
        }

        if (lambda < 1e-10) {
            QMessageBox::critical(this,
                                  tr("Apply Error"),
                                  tr("\u03BB1 is 0. Please measure it first."));
            return;
        }
        if (r2 < 1e-10) {
            QMessageBox::critical(this,
                                  tr("Apply Error"),
                                  tr("R2 is 0. Please measure it first."));
            return;
        }

        if (l2 < 1e-10) {
            QMessageBox::critical(this,
                                  tr("Apply Error"),
                                  tr("L2 is 0. Please measure it first."));
            return;
        }

        if (lambda2 < 1e-10) {
            QMessageBox::critical(this,
                                  tr("Apply Error"),
                                  tr("\u03BB2 is 0. Please measure it first."));
            return;
        }

        mVesc->mcConfig()->updateParamDouble("foc_motor_r", r);
        mVesc->mcConfig()->updateParamDouble("foc_motor_l", l / 1e6);
        mVesc->mcConfig()->updateParamDouble("foc_motor_flux_linkage", lambda);
        mVesc->mcConfig()->updateParamDouble("foc_motor_r2", r2);
        mVesc->mcConfig()->updateParamDouble("foc_motor_l2", l2 / 1e6);
        mVesc->mcConfig()->updateParamDouble("foc_motor_flux_linkage2", lambda2);

        mVesc->emitStatusMessage(tr("R, L and \u03BB Applied"), true);

        on_calcKpKiButton_clicked();
        on_calcGainButton_clicked();

        if (mLastCalcOk) {
            mVesc->mcConfig()->updateParamDouble("foc_current_kp", ui->kpBox->value());
            mVesc->mcConfig()->updateParamDouble("foc_current_ki", ui->kiBox->value());
            mVesc->mcConfig()->updateParamDouble("foc_observer_gain", ui->obsGainBox->value() * 1e6);
            mVesc->mcConfig()->updateParamDouble("foc_current_kp2", ui->kpBox_2->value());
            mVesc->mcConfig()->updateParamDouble("foc_current_ki2", ui->kiBox_2->value());
            mVesc->mcConfig()->updateParamDouble("foc_observer_gain2", ui->obsGainBox_2->value() * 1e6);
            mVesc->emitStatusMessage(tr("KP, KI and Observer Gain Applied"), true);
            mLastOkValuesApplied = true;
        } else {
            mVesc->emitStatusMessage(tr("Apply Parameters Failed"), false);
        }
    }
}

bool DetectFoc::lastOkValuesApplied() const
{
    return mLastOkValuesApplied;
}

bool DetectFoc::allValuesOk() const
{
    return mAllValuesOk;
}

void DetectFoc::updateColors()
{
    bool r_ok = ui->resistanceBox->value() > 1e-10;
    bool l_ok = ui->inductanceBox->value() > 1e-10;
    bool r_ok2 = ui->resistanceBox_2->value() > 1e-10;
    bool l_ok2 = ui->inductanceBox_2->value() > 1e-10;
    bool lambda_ok = ui->lambdaBox->value() > 1e-10;
    bool lambda_ok2 = ui->lambdaBox_2->value() > 1e-10;
    bool gain_ok = ui->obsGainBox->value() > 1e-10;
    bool kp_ok = ui->kpBox->value() > 1e-10;
    bool ki_ok = ui->kiBox->value() > 1e-10;
    bool gain_ok2 = ui->obsGainBox_2->value() > 1e-10;
    bool kp_ok2 = ui->kpBox_2->value() > 1e-10;
    bool ki_ok2 = ui->kiBox_2->value() > 1e-10;

    QString style_red = "color: rgb(255, 255, 255);"
                        "background-color: rgb(150, 0, 0);";

    QString style_green = "color: rgb(255, 255, 255);"
                          "background-color: rgb(0, 150, 150);";

    ui->resistanceBox->setStyleSheet(QString("#resistanceBox {%1}").
                                     arg(r_ok ? style_green : style_red));
    ui->inductanceBox->setStyleSheet(QString("#inductanceBox {%1}").
                                     arg(l_ok ? style_green : style_red));
    ui->lambdaBox->setStyleSheet(QString("#lambdaBox {%1}").
                                 arg(lambda_ok ? style_green : style_red));
    ui->obsGainBox->setStyleSheet(QString("#obsGainBox {%1}").
                                  arg(gain_ok ? style_green : style_red));
    ui->kpBox->setStyleSheet(QString("#kpBox {%1}").
                             arg(kp_ok ? style_green : style_red));
    ui->kiBox->setStyleSheet(QString("#kiBox {%1}").
                             arg(ki_ok ? style_green : style_red));
    ui->resistanceBox_2->setStyleSheet(QString("#resistanceBox_2 {%1}").
                                     arg(r_ok2 ? style_green : style_red));
    ui->inductanceBox_2->setStyleSheet(QString("#inductanceBox_2 {%1}").
                                     arg(l_ok2 ? style_green : style_red));
    ui->lambdaBox_2->setStyleSheet(QString("#lambdaBox_2 {%1}").
                                 arg(lambda_ok2 ? style_green : style_red));
    ui->obsGainBox_2->setStyleSheet(QString("#obsGainBox_2 {%1}").
                                  arg(gain_ok2 ? style_green : style_red));
    ui->kpBox_2->setStyleSheet(QString("#kpBox_2 {%1}").
                             arg(kp_ok2 ? style_green : style_red));
    ui->kiBox_2->setStyleSheet(QString("#kiBox_2 {%1}").
                             arg(ki_ok2 ? style_green : style_red));

    mAllValuesOk = r_ok && l_ok && lambda_ok && gain_ok && kp_ok && ki_ok;
}

void DetectFoc::on_calcKpKiButton_clicked()
{
    double r = ui->resistanceBox->value() / 1e3;
    double l = ui->inductanceBox->value();
    double r2 = ui->resistanceBox_2->value() / 1e3;
    double l2 = ui->inductanceBox_2->value();

    mLastCalcOk = false;

    if (r < 1e-10) {
        QMessageBox::critical(this,
                              tr("Calculate Error"),
                              tr("R is 0. Please measure it first."));
    }
    if (r2 < 1e-10) {
        QMessageBox::critical(this,
                              tr("Calculate Error"),
                              tr("R2 is 0. Please measure it first."));
    }

    if (l < 1e-10) {
        QMessageBox::critical(this,
                              tr("Calculate Error"),
                              tr("L is 0. Please measure it first."));
    }
    if (l2 < 1e-10) {
        QMessageBox::critical(this,
                              tr("Calculate Error"),
                              tr("L is 0. Please measure it first."));
    }

    l /= 1e6;
    l2 /= 1e6;

    // https://e2e.ti.com/blogs_/b/motordrivecontrol/archive/2015/07/20/teaching-your-pi-controller-to-behave-part-ii
    double tc = ui->tcBox->value();
    double tc2 = ui->tcBox_2->value();
    double bw = 1.0 / (tc * 1e-6);
    double bw2 = 1.0 / (tc2 * 1e-6);
    double kp = l * bw;
    double ki = r * bw;
    double kp2 = l2 * bw2;
    double ki2 = r2 * bw2;
    if(l > 1e-10 && r > 1e-10){
    ui->kpBox->setValue(kp);
    ui->kiBox->setValue(ki);
    }
    if(l2 > 1e-10 && r2 > 1e-10){
    ui->kpBox_2->setValue(kp2);
    ui->kiBox_2->setValue(ki2);
    }
    mLastOkValuesApplied = false;
    mLastCalcOk = true;
    updateColors();
}

void DetectFoc::on_calcGainButton_clicked()
{
    double lambda = ui->lambdaBox->value() / 1e3;
    double lambda2 = ui->lambdaBox_2->value() / 1e3;
    mLastCalcOk = false;

    if (lambda < 1e-10) {
        QMessageBox::critical(this,
                              tr("Calculate Error"),
                              tr("\u03BB is 0. Please measure it first."));
    }
    if (lambda2 < 1e-10) {
        QMessageBox::critical(this,
                              tr("Calculate Error"),
                              tr("\u03BB 2 is 0. Please measure it first."));
    }
    if (lambda > 1e-10) {
    ui->obsGainBox->setValue((0.001 / (lambda * lambda)));
    mLastOkValuesApplied = false;
    mLastCalcOk = true;
    updateColors();
    }
    if (lambda2 > 1e-10) {
    ui->obsGainBox_2->setValue((0.001 / (lambda2 * lambda2)));
    mLastOkValuesApplied = false;
    mLastCalcOk = true;
    updateColors();
    }
}
