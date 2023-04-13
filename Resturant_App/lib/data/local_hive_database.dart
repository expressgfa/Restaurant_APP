import 'dart:developer';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:resturantapp/constant/app_constant.dart' as cn;
import 'package:resturantapp/model/bluetooth_printer_model.dart';
import 'package:resturantapp/model/printer_type_hive.dart';
import 'package:resturantapp/model/site_data_model/site_model.dart';

class LocalHiveDatabase {
  static Box printerBox = Hive.box(cn.printerBox);
  static Box siteInfoBox = Hive.box(cn.siteInfoBox);

  static String siteInfoKey = "siteInfo";

  //+ ---------------------------- Printers --------------------------------------

  static savePrintersListForASpecificUser(String userId, List<PrinterDataModel> printers) async {
    await printerBox.put(userId, printers);
  }

  static savePrinterForASpecificUser(String userId, PrinterDataModel printer) async {
    // log("printers in savePrinterForASpecificUser is: ${printer.toJson()}\n");
    log("userId: $userId");
    List<PrinterDataModel> printers = getPrintersListForASpecificUser(userId) ?? [];

    // for (var p in printers) {
    //   log(" BEFORE printers in savePrinterForASpecificUser in for loop is: ${p.toJson()}");
    // }

    PrinterDataModel containedPrinter = printers.firstWhere(
        (device) =>
            (device.address == printer.address &&
                // device.productId == printer.productId &&
                device.typePrinter == printer.typePrinter) ||
            (device.typePrinter == MyPrinterType.usb && printer.vendorId == device.vendorId),
        orElse: () => PrinterDataModel());

    // log("Contained Printer: ${containedPrinter.toJson()}");

    if (containedPrinter.address?.isEmpty ?? true) {
      printers.clear();
      printers.add(printer);
    }
    for (var p in printers) {
      log("printers in savePrinterForASpecificUser in for loop is: ${p.toJson()}");
    }
    await printerBox.put(userId, printers);
  }

  static bool checkIfADeviceIsSaved(String userId, PrinterDataModel printer) {
    bool returnable = false;
    List<PrinterDataModel> printers = getPrintersListForASpecificUser(userId) ?? [];
    PrinterDataModel containedPrinter = printers.firstWhere(
        (device) =>
            (device.address == printer.address &&
                // device.productId == printer.productId &&
                device.typePrinter == printer.typePrinter) ||
            (device.typePrinter == MyPrinterType.usb && printer.vendorId == device.vendorId),
        orElse: () => PrinterDataModel());

    // log("Contained Printer: ${containedPrinter.toJson()}");

    if (containedPrinter.address?.isEmpty ?? true) {
      returnable = false;
    } else {
      returnable = true;
    }
    return returnable;
  }

  static savePaperSize(int size) async {
    printerBox.put(cn.paperSizeKey, size);
  }

  static int getPaperSize() {
    return printerBox.get(cn.paperSizeKey) ?? 80;
  }

  static List<PrinterDataModel>? getPrintersListForASpecificUser(String userId) {
    // log("printerBox.get(userId): ${printerBox.get(userId)}");
    return printerBox.get(userId, defaultValue: List<PrinterDataModel>.from([])).cast<PrinterDataModel>();
    // return [];
  }

  static deleteAllPrintersForASpecificUser(String userId) async {
    await printerBox.delete(userId);
  }

  static deleteAllPrintersForAllUsers() async {
    await printerBox.clear();
  }

  static deleteASpecificPrinterForASpecificUser(String userId, String productId, String vendorId, String address, MyPrinterType typePrinter) async {
    List<PrinterDataModel> printers = getPrintersListForASpecificUser(userId) ?? [];
    printers.removeWhere(
      (device) =>
          (device.address == address &&
              // device.productId == productId &&
              device.typePrinter == typePrinter) ||
          (device.typePrinter == MyPrinterType.usb && vendorId == device.vendorId),
    );
    await printerBox.put(userId, printers);
  }

//+ ----------------------------------------------------------------------------

  static saveSiteData(SiteInfo siteData) async {
    await siteInfoBox.put(siteInfoKey, siteData);
  }

  static getSiteData() {
    return siteInfoBox.get(siteInfoKey);
  }
}
