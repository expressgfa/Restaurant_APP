import 'package:hive_flutter/hive_flutter.dart';

part 'site_model.g.dart';

@HiveType(typeId: 3)
class SiteInfo {
  SiteInfo({
    this.siteTitle = "",
    this.siteName = "",
    this.phone = "",
    this.landLine = "",
    this.fax = "",
    this.portalEmail = "",
    this.siteCountry = "",
    this.timeZone = "",
    this.rightsReservedContent = "",
    this.currency = "",
    this.currencySymbol = "",
    this.pickupAddress = "",
  });

  @HiveField(0)
  String siteTitle;
  @HiveField(1)
  String siteName;
  @HiveField(2)
  String phone;
  @HiveField(3)
  String landLine;
  @HiveField(4)
  String fax;
  @HiveField(5)
  String portalEmail;
  @HiveField(6)
  String siteCountry;
  @HiveField(7)
  String timeZone;
  @HiveField(8)
  String rightsReservedContent;
  @HiveField(9)
  String currency;
  @HiveField(10)
  String currencySymbol;
  @HiveField(11)
  String pickupAddress;

  factory SiteInfo.fromJson(Map<String, dynamic> json) => SiteInfo(
    siteTitle: json["site_title"],
    siteName: json["site_name"],
    phone: json["phone"],
    landLine: json["land_line"],
    fax: json["fax"],
    portalEmail: json["portal_email"],
    siteCountry: json["site_country"],
    timeZone: json["time_zone"],
    rightsReservedContent: json["rights_reserved_content"],
    currency: json["currency"],
    currencySymbol: json["currency_symbol"],
    pickupAddress: json["pickup_address"],
  );

  Map<String, dynamic> toJson() => {
    "site_title": siteTitle,
    "site_name": siteName,
    "phone": phone,
    "land_line": landLine,
    "fax": fax,
    "portal_email": portalEmail,
    "site_country": siteCountry,
    "time_zone": timeZone,
    "rights_reserved_content": rightsReservedContent,
    "currency": currency,
    "currency_symbol": currencySymbol,
    "pickup_address": pickupAddress,
  };
}
