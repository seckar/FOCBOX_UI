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

#ifndef DATATYPES_H
#define DATATYPES_H

#include <QObject>
#include <QString>
#include <QStringList>
#include <QVector>
#include <stdint.h>

typedef struct {
    QString name;
    QString systemPath;
    bool isVesc;
} VSerialInfo_t;

typedef enum {
    CFG_T_UNDEFINED = 0,
    CFG_T_DOUBLE,
    CFG_T_INT,
    CFG_T_QSTRING,
    CFG_T_ENUM,
    CFG_T_BOOL
} CFG_T;

typedef enum {
    VESC_TX_UNDEFINED = 0,
    VESC_TX_UINT8,
    VESC_TX_INT8,
    VESC_TX_UINT16,
    VESC_TX_INT16,
    VESC_TX_UINT32,
    VESC_TX_INT32,
    VESC_TX_DOUBLE16,
    VESC_TX_DOUBLE32,
    VESC_TX_DOUBLE32_AUTO
} VESC_TX_T;

typedef enum {
    FAULT_CODE_NONE = 0,
    FAULT_CODE_OVER_VOLTAGE = 1,
    FAULT_CODE_UNDER_VOLTAGE = 2,
    FAULT_CODE_DRV = 3,
    FAULT_CODE_ABS_OVER_CURRENT = 4,
    FAULT_CODE_OVER_TEMP_FET = 5,
    FAULT_CODE_OVER_TEMP_MOTOR = 6,
    FAULT_CODE_DRV2 = 7,
    FAULT_CODE_ABS_OVER_CURRENT2 = 8,
    FAULT_CODE_OVER_TEMP_FET2 = 9,
    FAULT_CODE_OVER_TEMP_MOTOR2 = 10
} mc_fault_code;

typedef enum {
    DISP_POS_MODE_NONE = 0,
    DISP_POS_MODE_INDUCTANCE,
    DISP_POS_MODE_OBSERVER,
    DISP_POS_MODE_ENCODER,
    DISP_POS_MODE_PID_POS,
    DISP_POS_MODE_PID_POS_ERROR,
    DISP_POS_MODE_ENCODER_OBSERVER_ERROR
} disp_pos_mode;

struct MC_VALUES {
    Q_GADGET

    Q_PROPERTY(double v_in MEMBER v_in)
    Q_PROPERTY(double temp_mos MEMBER temp_mos)
    Q_PROPERTY(double temp_mos2 MEMBER temp_mos2)
    Q_PROPERTY(double temp_motor MEMBER temp_motor)
    Q_PROPERTY(double temp_motor2 MEMBER temp_motor2)
    Q_PROPERTY(double current_motor MEMBER current_motor)
    Q_PROPERTY(double current_motor2 MEMBER current_motor2)
    Q_PROPERTY(double current_in MEMBER current_in)
    Q_PROPERTY(double id MEMBER id)
    Q_PROPERTY(double id2 MEMBER id2)
    Q_PROPERTY(double iq MEMBER iq)
    Q_PROPERTY(double iq2 MEMBER iq2)
    Q_PROPERTY(double rpm MEMBER rpm)
    Q_PROPERTY(double rpm2 MEMBER rpm2)
    Q_PROPERTY(double duty_now MEMBER duty_now)
    Q_PROPERTY(double duty_now2 MEMBER duty_now2)
    Q_PROPERTY(double amp_hours MEMBER amp_hours)
    Q_PROPERTY(double amp_hours_charged MEMBER amp_hours_charged)
    Q_PROPERTY(double watt_hours MEMBER watt_hours)
    Q_PROPERTY(double watt_hours_charged MEMBER watt_hours_charged)
    Q_PROPERTY(int tachometer MEMBER tachometer)
    Q_PROPERTY(int tachometer2 MEMBER tachometer2)
    Q_PROPERTY(int tachometer_abs MEMBER tachometer_abs)
    Q_PROPERTY(int tachometer_abs2 MEMBER tachometer_abs2)
    Q_PROPERTY(double position MEMBER position)
    Q_PROPERTY(double position2 MEMBER position2)
    Q_PROPERTY(mc_fault_code fault_code MEMBER fault_code)
    Q_PROPERTY(QString fault_str MEMBER fault_str)

public:
    double v_in;
    double temp_mos;
    double temp_mos2;
    double temp_motor;
    double temp_motor2;
    double current_motor;
    double current_motor2;
    double current_in;
    double id;
    double id2;
    double iq;
    double iq2;
    double rpm;
    double rpm2;
    double duty_now;
    double duty_now2;
    double amp_hours;
    double amp_hours_charged;
    double watt_hours;
    double watt_hours_charged;
    int tachometer;
    int tachometer2;
    int tachometer_abs;
    int tachometer_abs2;
    double position;
    double position2;
    mc_fault_code fault_code;
    QString fault_str;
};

Q_DECLARE_METATYPE(MC_VALUES)

typedef enum {
    DEBUG_SAMPLING_OFF = 0,
    DEBUG_SAMPLING_NOW,
    DEBUG_SAMPLING_START,
    DEBUG_SAMPLING_TRIGGER_START,
    DEBUG_SAMPLING_TRIGGER_FAULT,
    DEBUG_SAMPLING_TRIGGER_START_NOSEND,
    DEBUG_SAMPLING_TRIGGER_FAULT_NOSEND,
    DEBUG_SAMPLING_SEND_LAST_SAMPLES
} debug_sampling_mode;

typedef enum {
    COMM_FW_VERSION = 0,
    COMM_JUMP_TO_BOOTLOADER = 1,
    COMM_ERASE_NEW_APP = 2,
    COMM_WRITE_NEW_APP_DATA = 3,
    COMM_GET_VALUES = 4,
    COMM_SET_DUTY = 5,
    COMM_SET_CURRENT = 6,
    COMM_SET_CURRENT_BRAKE = 7,
    COMM_SET_RPM = 8,
    COMM_SET_POS = 9,
    COMM_SET_HANDBRAKE = 10,
    COMM_SET_DETECT = 11,
    COMM_SET_SERVO_POS = 12,
    COMM_SET_MCCONF = 13,
    COMM_GET_MCCONF = 14,
    COMM_GET_MCCONF_DEFAULT = 15,
    COMM_SET_APPCONF = 16,
    COMM_GET_APPCONF = 17,
    COMM_GET_APPCONF_DEFAULT = 18,
    COMM_SAMPLE_PRINT = 19,
    COMM_TERMINAL_CMD = 20,
    COMM_PRINT = 21,
    COMM_ROTOR_POSITION = 22,
    COMM_EXPERIMENT_SAMPLE = 23,
    COMM_DETECT_MOTOR_PARAM = 24,
    COMM_DETECT_MOTOR_R_L = 25,
    COMM_DETECT_MOTOR_FLUX_LINKAGE = 26,
    COMM_DETECT_ENCODER = 27,
    COMM_DETECT_HALL_FOC = 28,
    COMM_REBOOT = 29,
    COMM_ALIVE = 30,
    COMM_GET_DECODED_PPM = 31,
    COMM_GET_DECODED_ADC = 32,
    COMM_GET_DECODED_CHUK = 33,
    COMM_FORWARD_CAN = 34,
    COMM_SET_CHUCK_DATA = 35,
    COMM_CUSTOM_APP_DATA = 36,
    COMM_NRF_START_PAIRING = 37,
    COMM_GET_UNITY_VALUES = 38
} COMM_PACKET_ID;

typedef struct {
    int js_x;
    int js_y;
    int acc_x;
    int acc_y;
    int acc_z;
    bool bt_c;
    bool bt_z;
} chuck_data;

struct bldc_detect {
    Q_GADGET

    Q_PROPERTY(double cycle_int_limit MEMBER cycle_int_limit)
    Q_PROPERTY(double bemf_coupling_k MEMBER bemf_coupling_k)
    Q_PROPERTY(QVector<int> hall_table MEMBER hall_table)
    Q_PROPERTY(int hall_res MEMBER hall_res)

public:
    double cycle_int_limit;
    double bemf_coupling_k;
    QVector<int> hall_table;
    int hall_res;
};

Q_DECLARE_METATYPE(bldc_detect)

typedef enum {
    NRF_PAIR_STARTED = 0,
    NRF_PAIR_OK = 1,
    NRF_PAIR_FAIL = 2
} NRF_PAIR_RES;

#endif // DATATYPES_H
