import 'package:hive_flutter/hive_flutter.dart';

part 'printer_type_hive.g.dart';

@HiveType(typeId: 2)
enum MyPrinterType {
  @HiveField(0)
  bluetooth,
  @HiveField(1)
  usb,
  @HiveField(2)
  network,
}
