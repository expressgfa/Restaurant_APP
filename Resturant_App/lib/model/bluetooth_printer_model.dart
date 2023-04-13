import 'package:hive_flutter/adapters.dart';
import 'package:resturantapp/model/printer_type_hive.dart';

part 'bluetooth_printer_model.g.dart';

@HiveType(typeId: 1)
class PrinterDataModel {
  @HiveField(0)
  int? id;
  @HiveField(1)
  String? deviceName;
  @HiveField(2)
  String? address;
  @HiveField(3)
  String? port;
  @HiveField(4)
  String? vendorId;
  @HiveField(5)
  String? productId;
  @HiveField(6)
  bool? isBle;
  @HiveField(7)
  MyPrinterType typePrinter;
  @HiveField(8)
  bool? state;

  PrinterDataModel({
    this.deviceName,
    this.address,
    this.port,
    this.state,
    this.vendorId,
    this.productId,
    this.typePrinter = MyPrinterType.bluetooth,
    this.isBle = false,
  });

  Map<String, dynamic> toJson() => {
    "deviceName": deviceName,
    "address": address,
    "port": port,
    "state": state,
    "vendorId": vendorId,
    "productId": productId,
    "typePrinter": typePrinter,
    "isBle": isBle
  };
}