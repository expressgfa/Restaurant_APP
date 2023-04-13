// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'printer_type_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MyPrinterTypeAdapter extends TypeAdapter<MyPrinterType> {
  @override
  final int typeId = 2;

  @override
  MyPrinterType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MyPrinterType.bluetooth;
      case 1:
        return MyPrinterType.usb;
      case 2:
        return MyPrinterType.network;
      default:
        return MyPrinterType.bluetooth;
    }
  }

  @override
  void write(BinaryWriter writer, MyPrinterType obj) {
    switch (obj) {
      case MyPrinterType.bluetooth:
        writer.writeByte(0);
        break;
      case MyPrinterType.usb:
        writer.writeByte(1);
        break;
      case MyPrinterType.network:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MyPrinterTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
