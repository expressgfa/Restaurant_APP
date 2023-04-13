// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bluetooth_printer_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PrinterDataModelAdapter extends TypeAdapter<PrinterDataModel> {
  @override
  final int typeId = 1;

  @override
  PrinterDataModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrinterDataModel(
      deviceName: fields[1] as String?,
      address: fields[2] as String?,
      port: fields[3] as String?,
      state: fields[8] as bool?,
      vendorId: fields[4] as String?,
      productId: fields[5] as String?,
      typePrinter: fields[7] as MyPrinterType,
      isBle: fields[6] as bool?,
    )..id = fields[0] as int?;
  }

  @override
  void write(BinaryWriter writer, PrinterDataModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.deviceName)
      ..writeByte(2)
      ..write(obj.address)
      ..writeByte(3)
      ..write(obj.port)
      ..writeByte(4)
      ..write(obj.vendorId)
      ..writeByte(5)
      ..write(obj.productId)
      ..writeByte(6)
      ..write(obj.isBle)
      ..writeByte(7)
      ..write(obj.typePrinter)
      ..writeByte(8)
      ..write(obj.state);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrinterDataModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
