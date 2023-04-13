import 'package:flutter/material.dart';
import 'package:flutter_pos_printer_platform/flutter_pos_printer_platform.dart';
import 'package:resturantapp/model/printer_type_hive.dart';
import 'package:resturantapp/my_logger.dart';

class Utils {
  static PrinterType mapMyPrinterTypeToPrinterType(MyPrinterType myPrinterType) {
    switch (myPrinterType) {
      case MyPrinterType.bluetooth:
        return PrinterType.bluetooth;
      case MyPrinterType.network:
        return PrinterType.network;
      case MyPrinterType.usb:
        return PrinterType.usb;
      default:
        return PrinterType.bluetooth;
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

Color getColour(String orderName) {
  Color color = Colors.grey;
  switch (orderName) {
    case "missed":
      return color = Colors.red;

    case "ready":
      return color = Colors.black;

    case "process":
      return color = Colors.black;

    case "out_to_deliver":
      return color = Colors.black;

    case "accept":
      return color = Colors.green;

    case "cancel":
      return color = Colors.red;
    case "cancelled":
      return color = Colors.red;

    default:
      return Colors.black;
  }
}

String getStatus(String? status) {
  // verboseLog("status: $status");
  switch (status ?? "new") {
    case "missed":
      return "Missed";

    case "new":
      return "New";

    case "delivered":
      return "Ready";

    case "ready":
      return "Ready";

    case "process":
      return "In process";

    case "out_to_deliver":
      return "Out to deliver";

    case "accept":
      return "Accepted";

    case "cancel":
      return "Cancelled";

    case "cancelled":
      return "Rejected";

    default:
      return "New";
  }
}

Color getContainerColour(String orderName) {
  Color color = Colors.black;
  switch (orderName) {
    case "new":
      return color = Colors.grey;
    case "missed":
      return color = Colors.red.shade100;

    case "ready":
      return color = Colors.grey;

    case "process":
      return color = Colors.grey;

    case "out_to_deliver":
      return color = Colors.grey;

    case "accept":
      return color = Colors.green.shade100;

    case "cancel":
      return color = Colors.red.shade100;
    case "cancelled":
      return color = Colors.red.shade100;

    default:
      return Colors.grey;
  }
}

IconData getIcon(String orderName) {
  IconData icon = Icons.check;

  // const Icon(Icons.check),
  // const Icon(Icons.call_missed),
  // const Icon(Icons.close),

  switch (orderName) {
    case "missed":
      return icon = Icons.call_missed;

    case "ready":
      return icon = Icons.check;

    case "process":
      return icon = Icons.check;

    case "out_to_deliver":
      return icon = Icons.delivery_dining_outlined;

    case "accept":
      return icon = Icons.check;

    case "cancel":
      return icon = Icons.close;

    case "cancelled":
      return icon = Icons.close;

    default:
      return icon;
  }
}
