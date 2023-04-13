import 'dart:developer';
import 'dart:io';

import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pos_printer_platform/flutter_pos_printer_platform.dart';
import 'package:get/get.dart';
import 'package:resturantapp/constant/all_controller.dart';
import 'package:resturantapp/data/local_hive_database.dart';
import 'package:resturantapp/model/printer_type_hive.dart';
import 'package:resturantapp/utils/shared_pref.dart';
import 'package:resturantapp/views/widgets/simple_appBar.dart';
import 'package:toggle_switch/toggle_switch.dart';

class PrinterAttach extends StatefulWidget {
  final BuildContext homeContext;

  const PrinterAttach({Key? key, required this.homeContext}) : super(key: key);

  @override
  State<PrinterAttach> createState() => _PrinterAttachState();
}

class _PrinterAttachState extends State<PrinterAttach> {
  // Printer Type [bluetooth, usb, network]

  // late PrinterProvider printerController;

  @override
  void initState() {
    int paperSize = LocalHiveDatabase.getPaperSize();
    // int paperSize = 80;
    if (paperSize == 80) {
      printerController.paperSize = PaperSize.mm80;
    } else {
      printerController.paperSize = PaperSize.mm58;
    }
    super.initState();
    printerController.scan();
    // subscription to listen change status of bluetooth connection
    printerController.bluetoothStreamInitializer();
    printerController.usbStreamInitializer();
  }

  @override
  void dispose() {
    printerController.subscription?.cancel();
    printerController.subscriptionBtStatus?.cancel();
    printerController.subscriptionUsbStatus?.cancel();
    // printerController.portController.dispose();
    // printerController.ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(title: "Printer Settings".tr, haveIcon: true),
      body: Center(
        child: Container(
          height: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: Row(
                //     children: [
                //       Expanded(
                //         child: ElevatedButton(
                //           onPressed: printerController.selectedPrinter == null || printerController.isConnected
                //               ? null
                //               : () {
                //             printerController.connectDevice(context);
                //           },
                //           style: ElevatedButton.styleFrom(backgroundColor: printerController.isConnected ? Colors.white : ConstantColors().primaryColor),
                //           child: const Text("Connect", textAlign: TextAlign.center),
                //         ),
                //       ),
                //       const SizedBox(width: 8),
                //       Expanded(
                //         child: ElevatedButton(
                //           onPressed: printerController.selectedPrinter == null || !printerController.isConnected
                //               ? null
                //               : () {
                //             if (printerController.selectedPrinter != null)
                //               printerController.printerManager
                //                   .disconnect(type: printerController.selectedPrinter!.typePrinter);
                //             setState(() {
                //               printerController.isConnected = false;
                //             });
                //           },
                //           style: ElevatedButton.styleFrom(backgroundColor: printerController.isConnected ? Colors.white : ConstantColors().primaryColor),
                //           child: const Text("Disconnect", textAlign: TextAlign.center),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text("${"Paper size".tr}: "),
                    ToggleSwitch(
                      initialLabelIndex: printerController.paperSize == PaperSize.mm80 ? 1 : 0,
                      totalSwitches: 2,
                      labels: const ['58mm', '80mm'],
                      activeBgColor: const [Colors.orange],
                      onToggle: (index) {
                        log('switched to: $index');
                        if (index == 0) {
                          printerController.paperSize = PaperSize.mm58;
                          LocalHiveDatabase.savePaperSize(58);
                        } else {
                          printerController.paperSize = PaperSize.mm80;
                          LocalHiveDatabase.savePaperSize(80);
                        }
                      },
                    ),
                  ]),
                ),
                DropdownButtonFormField<MyPrinterType>(
                  value: printerController.defaultPrinterType,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.print,
                      size: 24,
                    ),
                    labelText: "Type Printer Device".tr,
                    labelStyle: const TextStyle(fontSize: 18.0),
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                  ),
                  items: <DropdownMenuItem<MyPrinterType>>[
                    if (Platform.isAndroid || Platform.isIOS)
                      const DropdownMenuItem(
                        value: MyPrinterType.bluetooth,
                        child: Text("Bluetooth"),
                      ),
                    if (Platform.isAndroid || Platform.isWindows)
                      const DropdownMenuItem(
                        value: MyPrinterType.usb,
                        child: Text("USB"),
                      ),
                    const DropdownMenuItem(
                      value: MyPrinterType.network,
                      child: Text("Wifi"),
                    ),
                  ],
                  onChanged: (MyPrinterType? value) {
                    setState(() {
                      if (value != null) {
                        setState(() {
                          printerController.defaultPrinterType = value;
                          printerController.selectedPrinter = null;
                          printerController.isBle.value = false;
                          printerController.isConnected.value = false;
                          printerController.scan();
                        });
                      }
                    });
                  },
                ),
                Visibility(
                  visible: printerController.defaultPrinterType == MyPrinterType.bluetooth && Platform.isAndroid,
                  child: SwitchListTile.adaptive(
                    contentPadding: const EdgeInsets.only(bottom: 20.0, left: 20),
                    title: Text(
                      "This device supports ble (low energy)".tr,
                      textAlign: TextAlign.start,
                      style: const TextStyle(fontSize: 19.0),
                    ),
                    value: printerController.isBle.value,
                    onChanged: (bool? value) {
                      setState(() {
                        printerController.isBle.value = value ?? false;
                        printerController.isConnected.value = false;
                        printerController.selectedPrinter = null;
                        printerController.scan();
                      });
                    },
                  ),
                ),
                Visibility(
                  visible: printerController.defaultPrinterType == MyPrinterType.bluetooth && Platform.isAndroid,
                  child: SwitchListTile.adaptive(
                    contentPadding: const EdgeInsets.only(bottom: 20.0, left: 20),
                    title: Text(
                      "Reconnect".tr,
                      textAlign: TextAlign.start,
                      style: const TextStyle(fontSize: 19.0),
                    ),
                    value: printerController.reconnect.value,
                    onChanged: (bool? value) {
                      setState(() {
                        printerController.reconnect.value = value ?? false;
                      });
                    },
                  ),
                ),
                Obx(() {
                  return Column(
                      children: printerController.devices
                          .map(
                            (device) => Obx(() {
                              String email = LocalSharedPrefDatabase.getUserEmail() ?? "";
                              bool isSaved = LocalHiveDatabase.checkIfADeviceIsSaved(email, device);
                              log("isSaved: $isSaved");
                              return ListTile(
                                title: Text('${device.deviceName}'),
                                subtitle: Platform.isAndroid && printerController.defaultPrinterType == MyPrinterType.usb
                                    ? null
                                    : Visibility(visible: !Platform.isWindows, child: Text("${device.address}")),
                                // onLongPress: () {
                                //   if (isSaved) {
                                //     LocalHiveDatabase.deleteASpecificPrinterForASpecificUser(
                                //       email,
                                //       device.productId ?? "",
                                //       device.vendorId ?? "",
                                //       device.address ?? "",
                                //       device.typePrinter,
                                //     );
                                //     setState(() {});
                                //   }
                                // },
                                onTap: () {
                                  // do something
                                  printerController.selectDevice(device);
                                  // setState(() {});
                                },
                                leading: printerController.selectedPrinterAddress.value.isNotEmpty
                                    ? (printerController.selectedPrinter != null &&
                                            ((device.typePrinter == MyPrinterType.usb && Platform.isWindows
                                                    ? device.deviceName == printerController.selectedPrinter!.deviceName
                                                    : device.vendorId != null && printerController.selectedPrinter!.vendorId == device.vendorId) ||
                                                (device.address != null && printerController.selectedPrinter!.address == device.address)))
                                        ? isSaved
                                            ? const Icon(
                                                Icons.data_saver_on,
                                                color: Colors.green,
                                              )
                                            : const Icon(
                                                Icons.check,
                                                color: Colors.green,
                                              )
                                        : isSaved
                                            ? const Icon(
                                                Icons.data_saver_on,
                                                color: Colors.green,
                                              )
                                            : null
                                    : isSaved
                                        ? const Icon(
                                            Icons.data_saver_on,
                                            color: Colors.green,
                                          )
                                        : null,
                                trailing: OutlinedButton(
                                  onPressed:
                                      (printerController.selectedPrinter == null || device.deviceName != printerController.selectedPrinter?.deviceName) &&
                                              !isSaved
                                          ? null
                                          : () async {
                                              if (isSaved) {
                                                printerController.selectedPrinter = device;
                                              }
                                              printerController.printReceiveTest();
                                            },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
                                    child: Text("Print test ticket".tr, textAlign: TextAlign.center),
                                  ),
                                ),
                              );
                            }),
                          )
                          .toList());
                }),
                // Visibility(
                //   visible: printerController.defaultPrinterType == PrinterType.network && Platform.isWindows,
                //   child: Padding(
                //     padding: const EdgeInsets.only(top: 10.0),
                //     child: TextFormField(
                //       controller: printerController.ipController,
                //       keyboardType: const TextInputType.numberWithOptions(signed: true),
                //       decoration: const InputDecoration(
                //         label: Text("Ip Address"),
                //         prefixIcon: Icon(Icons.wifi, size: 24),
                //       ),
                //       onChanged: printerController.setIpAddress,
                //     ),
                //   ),
                // ),
                // Visibility(
                //   visible: printerController.defaultPrinterType == PrinterType.network && Platform.isWindows,
                //   child: Padding(
                //     padding: const EdgeInsets.only(top: 10.0),
                //     child: TextFormField(
                //       controller: printerController.portController,
                //       keyboardType: const TextInputType.numberWithOptions(signed: true),
                //       decoration: const InputDecoration(
                //         label: Text("Port"),
                //         prefixIcon: Icon(Icons.numbers_outlined, size: 24),
                //       ),
                //       onChanged: printerController.setPort,
                //     ),
                //   ),
                // ),
                // Visibility(
                //   visible: printerController.defaultPrinterType == PrinterType.network && Platform.isWindows,
                //   child: Padding(
                //     padding: const EdgeInsets.only(top: 10.0),
                //     child: OutlinedButton(
                //       onPressed: () async {
                //         if (printerController.ipController.text.isNotEmpty)
                //           printerController.setIpAddress(printerController.ipController.text);
                //         printerController.printReceiveTest();
                //       },
                //       child: const Padding(
                //         padding: EdgeInsets.symmetric(vertical: 4, horizontal: 50),
                //         child: Text("Print test ticket", textAlign: TextAlign.center),
                //       ),
                //     ),
                //   ),
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
