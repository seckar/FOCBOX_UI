/*
    This file is part of FOCBOX Tool.

    FOCBOX Tool is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FOCBOX Tool is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program .  If not, see <http://www.gnu.org/licenses/>.
    */

import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import Vedder.vesc.vescinterface 1.0
import Vedder.vesc.commands 1.0
import Vedder.vesc.configparams 1.0
import Vedder.vesc.fwhelper 1.0
import Vedder.vesc.utility 1.0

import QtQuick.Dialogs 1.0

Item {
    id: item1
    property Commands mCommands: VescIf.commands()
    property ConfigParams mInfoConf: VescIf.infoConfig()
    property real durAnim: 250

    FwHelper {
        id: fwHelper
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10
        anchors.rightMargin: 10
        anchors.leftMargin: 10
        anchors.topMargin: 10

        ComboBox {
            spacing: 10
            id: uploadSelect
            //Layout.fillHeight: true
            Layout.fillWidth:  true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
            transformOrigin: Item.Center
            font.bold: true
            //Text.horizontalAlignment:  Text.AlignHCenter
            // font.pixelSize: uibox.textSize1
            // Layout.preferredHeight: 0.6*uibox.middleColumnWidth1

            model: [
                "Included Firmware",
                "Custom Firmware",
                "Bootloader"
            ]

            onCurrentTextChanged: {
                switch(uploadSelect.currentIndex)
                {
                case 0:
                    includedFWWindow.visible = true
                    customFWWindow.visible = false
                    bootloaderWindow.visible = false
                    break;
                case 1:
                    includedFWWindow.visible = false
                    customFWWindow.visible = true
                    bootloaderWindow.visible = false
                    break;
                case 2:
                    includedFWWindow.visible = false
                    customFWWindow.visible = false
                    bootloaderWindow.visible = true
                    break;
                }
            }
        }


        ScrollView {
            Layout.fillHeight: true
            Layout.fillWidth: true
            contentWidth: width
            spacing: 10
            id: columnLayout
            clip: true
            //spacing: 0.035*uibox.widthIcon
            //anchors.topMargin: 10
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            ColumnLayout{
                anchors.fill:parent
                spacing: 10
                ColumnLayout{
                    spacing: 10
                    id:includedFWWindow
                    Layout.fillWidth: true
                    clip: true
                    // Layout.preferredHeight: includedFirmwareButton.height
                    //  spacing: 0.035*uibox.widthIcon

                    Text {
                        Layout.fillWidth: true
                        height: 30;
                        text: "Hardware"
                        horizontalAlignment: Text.AlignHCenter
                    }

                    ComboBox {
                        id: hwBox
                        Layout.preferredHeight: 48
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                        textRole: "key"
                        model: ListModel {
                            id: hwItems
                        }

                        Component.onCompleted: {
                            updateHw("")
                        }

                        onCurrentIndexChanged: {
                            if (hwItems.rowCount() === 0) {
                                return
                            }

                            var fws = fwHelper.getFirmwares(hwItems.get(hwBox.currentIndex).value)

                            fwItems.clear()

                            for (var name in fws) {
                                if (name.toLowerCase().indexOf("UNITY.bin") !== -1) {
                                    fwItems.insert(0, { key: name, value: fws[name] })
                                } else {
                                    fwItems.append({ key: name, value: fws[name] })
                                }
                            }

                            fwBox.currentIndex = 0
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        height: 30;
                        text: "Firmware"
                        horizontalAlignment: Text.AlignHCenter
                    }

                    ComboBox {
                        id: fwBox
                        spacing: 10
                        Layout.preferredHeight: 48
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                        textRole: "key"
                        model: ListModel {
                            id: fwItems
                        }
                    }

                    Button {
                        text: "Show Changelog"
                        padding: 10
                        spacing: 10
                        Layout.fillWidth: true

                        onClicked: {
                            VescIf.emitMessageDialog(
                                        "Firmware Changelog",
                                        Utility.fwChangeLog(),
                                        true)
                        }
                    }


                }
                ColumnLayout{
                    id:customFWWindow
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    visible: false
                    //   spacing: 0.035*uibox.widthIcon


                    TextInput {
                        id: customFwText
                        wrapMode: TextInput.Wrap
                        Layout.fillWidth: true

                    }

                    Button {
                        text: "Choose File..."
                        Layout.fillWidth: true

                        onClicked: {
                            if (Utility.requestFilePermission()) {
                                if(Qt.platform.os === "android"){
                                    filePicker.visible = true
                                    filePicker.enabled = true
                                }else{
                                    fileDialog.open()
                                }
                            } else {
                                VescIf.emitMessageDialog(
                                            "File Permissions",
                                            "Unable to request file system permission.",
                                            false, false)
                            }
                        }
                    }

                    FilePicker {
                        id: filePicker
                        Layout.preferredHeight: 250
                        //Layout.fillHeight: true
                        Layout.fillWidth: true
                        showDotAndDotDot: true
                        nameFilters: "*.bin"
                        visible: false
                        enabled: false

                        onFileSelected: {
                            customFwText.text = currentFolder() + "/" + fileName
                            visible = false
                            enabled = false
                        }
                    }


                }
                ColumnLayout{
                    id:bootloaderWindow
                    Layout.fillWidth: true
                    clip: true
                    visible: false
                    //Layout.preferredHeight: bootloaderButton.height
                    // spacing: 0.035*uibox.widthIco


                    Text {
                        Layout.fillWidth: true
                        height: 30;
                        text: "Hardware"
                        horizontalAlignment: Text.AlignHCenter
                    }

                    ComboBox {
                        id: blBox
                        Layout.preferredHeight: 48
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                        textRole: "key"
                        model: ListModel {
                            id: blItems
                        }

                        Component.onCompleted: {
                            updateBl("")
                        }
                    }
                }
            }
        }


        Rectangle {
            Layout.fillWidth: true
            height: asd.implicitHeight + 20
            color: "#00000000"

            ColumnLayout {
                id: asd
                // spacing: 10
                anchors.fill: parent
                anchors.margins: 10

                Text {
                    Layout.fillWidth: true
                    id: uploadText
                    text: qsTr("Not Uploading")
                    horizontalAlignment: Text.AlignHCenter
                }

                ProgressBar {
                    id: uploadProgress
                    Layout.fillWidth: true
                }

                RowLayout {
                    spacing: 10
                    Layout.fillWidth: true

                    Button {
                        id: uploadButton
                        text: qsTr("Upload")
                        Layout.fillWidth: true

                        onClicked: {
                            if (!VescIf.isPortConnected()) {
                                VescIf.emitMessageDialog(
                                            "Connection Error",
                                            "The FOCBOX is not connected. Please open a connection.",
                                            false)
                                return
                            }


                            if (uploadSelect.currentIndex == 0) {
                                if (fwItems.rowCount() === 0) {
                                    VescIf.emitMessageDialog(
                                                "Upload Error",
                                                "This version of FOCBOX Tool does not include any firmware " +
                                                "for your hardware version. You can either " +
                                                "upload a custom file or look for a later version of FOCBOX " +
                                                "Tool that might support your hardware.",
                                                false)
                                    return;
                                }

                                if (hwItems.rowCount() === 1) {
                                    uploadDialog.title = "Warning"
                                    uploadDialogLabel.text =
                                            "Uploading new firmware will clear all settings on your FOCBOX " +
                                            "and you have to do the configuration again. Do you want to " +
                                            "continue?"
                                    uploadDialog.open()
                                } else {
                                    uploadDialog.title = "Warning"
                                    uploadDialogLabel.text =
                                            "Uploading firmware for the wrong hardware version " +
                                            "WILL damage the FOCBOX for sure. Are you sure that you have " +
                                            "chosen the correct hardware version?"
                                    uploadDialog.open()
                                }
                            } else if (uploadSelect.currentIndex == 1) {
                                if (customFwText.text.length > 0) {
                                    uploadDialog.title = "Warning"
                                    uploadDialogLabel.text =
                                            "Uploading firmware for the wrong hardware version " +
                                            "WILL damage the FOCBOX for sure. Are you sure that you have " +
                                            "chosen the correct hardware version?"
                                    uploadDialog.open()
                                } else {
                                    VescIf.emitMessageDialog(
                                                "Error",
                                                "Please select a file",
                                                false, false)
                                }
                            } else if (uploadSelect.currentIndex == 2) {
                                if (blItems.rowCount() === 0) {
                                    VescIf.emitMessageDialog(
                                                "Upload Error",
                                                "This version of FOCBOX Tool does not include any bootloader " +
                                                "for your hardware version.",
                                                false)
                                    return;
                                }

                                uploadDialog.title = "Warning"
                                uploadDialogLabel.text =
                                        "This will attempt to upload a bootloader to the connected FOCBOX. " +
                                        "If the connected FOCBOX already has a bootloader this will destroy " +
                                        "the bootloader and firmware updates cannot be done anymore. Do " +
                                        "you want to continue?"
                                uploadDialog.open()
                            }
                        }
                    }

                    Button {
                        id: cancelButton
                        text: qsTr("Cancel")
                        Layout.fillWidth: true
                        enabled: false

                        onClicked: {
                            mCommands.cancelFirmwareUpload()
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    id: versionText
                    color: "#606060"
                    text:
                        "FW   : \n" +
                        "HW   : \n" +
                        "UUID : "
                    font.family: "DejaVu Sans Mono"
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

    }


    FileDialog {
        id: fileDialog
        title: "Please choose a file"
        nameFilters: [ "Firmware files (*.bin)" ]
        folder: shortcuts.home
        onAccepted: {
            customFwText.text = fileDialog.fileUrl;
            var path = customFwText.text;
            if(Qt.platform.os === "linux")
                path = path.replace(/^(file:\/{2})/,""); // unescape html codes like '%23' for '#'
            if(Qt.platform.os === "windows")
                path = path.replace(/^(file:\/{3})/,""); // unescape html codes like '%23' for '#'
            customFwText.text = decodeURIComponent(path);
            //console.log("You chose: " + fileDialog.fileUrls)
            fileDialog.close()
        }
        onRejected: {
            console.log("Canceled")
            fileDialog.close()
        }
        // Component.onCompleted: visible = true
    }

    Dialog {
        id: uploadDialog
        standardButtons: Dialog.Ok | Dialog.Cancel
        modal: true
        focus: true
        width: parent.width - 20
        closePolicy: Popup.CloseOnEscape

        x: (parent.width - width) / 2
        y: (parent.height - height) / 2

        Text {
            id: uploadDialogLabel
            verticalAlignment: Text.AlignVCenter
            anchors.fill: parent
            wrapMode: Text.WordWrap
        }

        onAccepted: {
            if (uploadSelect.currentIndex == 0) {
                fwHelper.uploadFirmware(fwItems.get(fwBox.currentIndex).value, VescIf, false, false)
            } else if (uploadSelect.currentIndex == 1) {
                fwHelper.uploadFirmware(customFwText.text, VescIf, false, true)
            } else if (uploadSelect.currentIndex == 2) {
                fwHelper.uploadFirmware(blItems.get(blBox.currentIndex).value, VescIf, true, false)
            }
        }
    }

    function updateHw(hw) {
        var hws = fwHelper.getHardwares(hw)

        hwItems.clear()

        for (var name in hws) {
            if (name.indexOf("412") !== -1) {
                hwItems.insert(0, { key: name, value: hws[name] })
            } else {
                hwItems.append({ key: name, value: hws[name] })
            }
        }

        hwBox.currentIndex = 0
    }

    function updateBl(hw) {
        var bls = fwHelper.getBootloaders(hw)

        blItems.clear()

        for (var name in bls) {
            if (name.indexOf("412") !== -1) {
                blItems.insert(0, { key: name, value: bls[name] })
            } else {
                blItems.append({ key: name, value: bls[name] })
            }
        }

        blBox.currentIndex = 0
    }

    Connections {
        target: VescIf

        onFwUploadStatus: {
            if (isOngoing) {
                uploadText.text = status + " (" + parseFloat(progress * 100.0).toFixed(2) + " %)"
            } else {
                uploadText.text = status
            }

            uploadProgress.value = progress
            uploadButton.enabled = !isOngoing
            cancelButton.enabled = isOngoing
        }
    }

    Connections {
        target: mCommands

        onFwVersionReceived: {
            updateHw(hw)
            updateBl(hw)

            versionText.text =
                    "FW   : " + major + "." + minor + "\n" +
                    "HW   : " + hw + "\n" +
                    "UUID : " + Utility.uuid2Str(uuid, false)
        }
    }
}
