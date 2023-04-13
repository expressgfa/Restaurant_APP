// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SiteInfoAdapter extends TypeAdapter<SiteInfo> {
  @override
  final int typeId = 3;

  @override
  SiteInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SiteInfo(
      siteTitle: fields[0] as String,
      siteName: fields[1] as String,
      phone: fields[2] as String,
      landLine: fields[3] as String,
      fax: fields[4] as String,
      portalEmail: fields[5] as String,
      siteCountry: fields[6] as String,
      timeZone: fields[7] as String,
      rightsReservedContent: fields[8] as String,
      currency: fields[9] as String,
      currencySymbol: fields[10] as String,
      pickupAddress: fields[11] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SiteInfo obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.siteTitle)
      ..writeByte(1)
      ..write(obj.siteName)
      ..writeByte(2)
      ..write(obj.phone)
      ..writeByte(3)
      ..write(obj.landLine)
      ..writeByte(4)
      ..write(obj.fax)
      ..writeByte(5)
      ..write(obj.portalEmail)
      ..writeByte(6)
      ..write(obj.siteCountry)
      ..writeByte(7)
      ..write(obj.timeZone)
      ..writeByte(8)
      ..write(obj.rightsReservedContent)
      ..writeByte(9)
      ..write(obj.currency)
      ..writeByte(10)
      ..write(obj.currencySymbol)
      ..writeByte(11)
      ..write(obj.pickupAddress);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SiteInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
