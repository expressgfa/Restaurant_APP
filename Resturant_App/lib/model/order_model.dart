class OrderModel {
  OrderModel({
    this.orderId,
    this.userId,
    this.seconds = 0,
    this.refUserUid,
    this.orderDate,
    this.orderTime,
    this.totalCost,
    this.deliveryFee,
    this.customerName,
    this.phone,
    this.email,
    this.houseNo,
    this.street,
    this.landmark,
    this.locality,
    this.city,
    this.cityId,
    this.pincode,
    this.isPointsRedeemed,
    this.noOfPointsRedeemed,
    this.pointsValue,
    this.totalEarnPoints,
    this.message,
    this.dateCreated,
    this.status,
    this.paymentType,
    this.paymentCard,
    this.paymentGateway,
    this.noOfItems,
    this.paidDate,
    this.paidAmount,
    this.transactionId,
    this.chargeId,
    this.payerId,
    this.payerEmail,
    this.payerName,
    this.paymentStatus,
    this.dateUpdated,
    this.deviceId,
    this.ratingValue,
    this.isAdminSentToKm,
    this.kmId,
    this.kmReceivedDatetime,
    this.isAdminSentToDm,
    this.isKmSentToDm,
    this.sentKmId,
    this.dmId,
    this.redeemedGiftCardNo,
    this.dmReceivedDatetime,
    this.lastUpdatedBy,
    this.lastUpdated,
    this.deliveredStatus,
    this.deliveredStatusDatetime,
    this.cancelledStatus,
    this.cancelledStatusDatetime,
    this.pickupTime,
    this.rejectReason,
    this.rejectedDateTme,
    this.acceptedDateTme,
    this.fulfilmentDateTme,
  });

  String? orderId;
  String? userId;
  int seconds;
  dynamic refUserUid;
  DateTime? orderDate;
  String? orderTime;
  String? totalCost;
  String? deliveryFee;
  String? customerName;
  String? phone;
  dynamic email;
  dynamic houseNo;
  dynamic street;
  dynamic landmark;
  dynamic locality;
  dynamic city;
  dynamic cityId;
  dynamic pincode;
  String? isPointsRedeemed;
  dynamic noOfPointsRedeemed;
  dynamic pointsValue;
  dynamic totalEarnPoints;
  String? message;
  DateTime? dateCreated;
  String? status;
  String? paymentType;
  dynamic paymentCard;
  dynamic paymentGateway;
  String? noOfItems;
  String? paidDate;
  String? paidAmount;
  String? transactionId;
  String? chargeId;
  String? payerId;
  dynamic payerEmail;
  String? payerName;
  String? paymentStatus;
  DateTime? dateUpdated;
  dynamic deviceId;
  dynamic ratingValue;
  dynamic isAdminSentToKm;
  dynamic kmId;
  dynamic kmReceivedDatetime;
  dynamic isAdminSentToDm;
  dynamic isKmSentToDm;
  dynamic sentKmId;
  dynamic dmId;
  dynamic redeemedGiftCardNo;
  dynamic dmReceivedDatetime;
  String? lastUpdatedBy;
  DateTime? lastUpdated;
  dynamic deliveredStatus;
  dynamic deliveredStatusDatetime;
  dynamic cancelledStatus;
  dynamic cancelledStatusDatetime;
  dynamic pickupTime;
  dynamic rejectReason;
  dynamic rejectedDateTme;
  dynamic acceptedDateTme;
  dynamic fulfilmentDateTme;

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    orderId: json["order_id"],
    userId: json["user_id"],
    seconds: json.containsKey("seconds") ? json["seconds"] : 0,
    refUserUid: json["ref_user_uid"],
    orderDate: json["order_date"] == null ? null : DateTime.parse(json["order_date"]),
    orderTime: json["order_time"],
    totalCost: json["total_cost"],
    deliveryFee: json["delivery_fee"],
    customerName: json["customer_name"],
    phone: json["phone"],
    email: json["email"],
    houseNo: json["house_no"],
    street: json["street"],
    landmark: json["landmark"],
    locality: json["locality"],
    city: json["city"],
    cityId: json["city_id"],
    pincode: json["pincode"],
    isPointsRedeemed: json["is_points_redeemed"],
    noOfPointsRedeemed: json["no_of_points_redeemed"],
    pointsValue: json["points_value"],
    totalEarnPoints: json["total_earn_points"],
    message: json["message"],
    dateCreated: json["date_created"] == null ? null : DateTime.parse(json["date_created"]),
    status: json["status"],
    paymentType: json["payment_type"],
    paymentCard: json["payment_card"],
    paymentGateway: json["payment_gateway"],
    noOfItems: json["no_of_items"],
    paidDate: json["paid_date"],
    paidAmount: json["paid_amount"],
    transactionId: json["transaction_id"],
    chargeId: json["charge_id"],
    payerId: json["payer_id"],
    payerEmail: json["payer_email"],
    payerName: json["payer_name"],
    paymentStatus: json["payment_status"],
    dateUpdated: json["date_updated"] == null ? null : DateTime.parse(json["date_updated"]),
    deviceId: json["device_id"],
    ratingValue: json["rating_value"],
    isAdminSentToKm: json["is_admin_sent_to_km"],
    kmId: json["km_id"],
    kmReceivedDatetime: json["km_received_datetime"],
    isAdminSentToDm: json["is_admin_sent_to_dm"],
    isKmSentToDm: json["is_km_sent_to_dm"],
    sentKmId: json["sent_km_id"],
    dmId: json["dm_id"],
    redeemedGiftCardNo: json["redeemed_gift_card_no"],
    dmReceivedDatetime: json["dm_received_datetime"],
    lastUpdatedBy: json["last_updated_by"],
    lastUpdated: json["last_updated"] == null ? null : DateTime.parse(json["last_updated"]),
    deliveredStatus: json["delivered_status"],
    deliveredStatusDatetime: json["delivered_status_datetime"],
    cancelledStatus: json["cancelled_status"],
    cancelledStatusDatetime: json["cancelled_status_datetime"],
    pickupTime: json["pickup_time"],
    rejectReason: json["reject_reason"],
    rejectedDateTme: json["rejected_date_tme"],
    acceptedDateTme: json["accepted_date_tme"],
    fulfilmentDateTme: json["fulfilment_date_tme"],
  );

  Map<String, dynamic> toJson() => {
    "order_id": orderId,
    "user_id": userId,
    "seconds": seconds,
    "ref_user_uid": refUserUid,
    "order_date": "${orderDate?.year.toString().padLeft(4, '0')}-${orderDate?.month.toString().padLeft(2, '0')}-${orderDate?.day.toString().padLeft(2, '0')}",
    "order_time": orderTime,
    "total_cost": totalCost,
    "delivery_fee": deliveryFee,
    "customer_name": customerName,
    "phone": phone,
    "email": email,
    "house_no": houseNo,
    "street": street,
    "landmark": landmark,
    "locality": locality,
    "city": city,
    "city_id": cityId,
    "pincode": pincode,
    "is_points_redeemed": isPointsRedeemed,
    "no_of_points_redeemed": noOfPointsRedeemed,
    "points_value": pointsValue,
    "total_earn_points": totalEarnPoints,
    "message": message,
    "date_created": dateCreated?.toIso8601String(),
    "status": status,
    "payment_type": paymentType,
    "payment_card": paymentCard,
    "payment_gateway": paymentGateway,
    "no_of_items": noOfItems,
    "paid_date": paidDate,
    "paid_amount": paidAmount,
    "transaction_id": transactionId,
    "charge_id": chargeId,
    "payer_id": payerId,
    "payer_email": payerEmail,
    "payer_name": payerName,
    "payment_status": paymentStatus,
    "date_updated": "${dateUpdated?.year.toString().padLeft(4, '0')}-${dateUpdated?.month.toString().padLeft(2, '0')}-${dateUpdated?.day.toString().padLeft(2, '0')}",
    "device_id": deviceId,
    "rating_value": ratingValue,
    "is_admin_sent_to_km": isAdminSentToKm,
    "km_id": kmId,
    "km_received_datetime": kmReceivedDatetime,
    "is_admin_sent_to_dm": isAdminSentToDm,
    "is_km_sent_to_dm": isKmSentToDm,
    "sent_km_id": sentKmId,
    "dm_id": dmId,
    "redeemed_gift_card_no": redeemedGiftCardNo,
    "dm_received_datetime": dmReceivedDatetime,
    "last_updated_by": lastUpdatedBy,
    "last_updated": lastUpdated?.toIso8601String(),
    "delivered_status": deliveredStatus,
    "delivered_status_datetime": deliveredStatusDatetime,
    "cancelled_status": cancelledStatus,
    "cancelled_status_datetime": cancelledStatusDatetime,
    "pickup_time": pickupTime,
    "reject_reason": rejectReason,
    "rejected_date_tme": rejectedDateTme,
    "accepted_date_tme": acceptedDateTme,
    "fulfilment_date_tme": fulfilmentDateTme,
  };
}


// import 'dart:convert';
//
// OrderModel orderModelFromJson(String str) => OrderModel.fromJson(json.decode(str));
//
// String orderModelToJson(OrderModel data) => json.encode(data.toJson());
// //+Here Below 3 fields are missings
// // "delivered_status_datetime": null,
// //     "cancelled_status": null,
// //     "cancelled_status_datetime": null
//
// class OrderModel {
//   OrderModel({
//     this.orderId,
//     this.seconds = 0,
//     this.userId,
//     this.refUserUid,
//     this.orderDate,
//     this.orderTime,
//     this.totalCost,
//     this.deliveryFee,
//     this.customerName,
//     this.phone,
//     this.email,
//     this.houseNo,
//     this.street,
//     this.landmark,
//     this.locality,
//     this.city,
//     this.cityId,
//     this.pincode,
//     this.isPointsRedeemed,
//     this.noOfPointsRedeemed,
//     this.pointsValue,
//     this.message,
//     this.dateCreated,
//     this.status,
//     this.paymentType,
//     this.paymentCard,
//     this.paymentGateway,
//     this.noOfItems,
//     this.paidDate,
//     this.paidAmount,
//     this.transactionId,
//     this.chargeId,
//     this.payerId,
//     this.payerEmail,
//     this.payerName,
//     this.paymentStatus,
//     this.dateUpdated,
//     this.deviceId,
//     this.ratingValue,
//     this.isAdminSentToKm,
//     this.kmId,
//     this.kmReceivedDatetime,
//     this.isAdminSentToDm,
//     this.isKmSentToDm,
//     this.sentKmId,
//     this.dmId,
//     this.dmReceivedDatetime,
//     this.lastUpdatedBy,
//     this.lastUpdated,
//     this.deliveredStatus,
//   });
//
//   final String? orderId;
//   int seconds;
//   final String? userId;
//   final dynamic refUserUid;
//   final DateTime? orderDate;
//   final String? orderTime;
//   final String? totalCost;
//   final String? deliveryFee;
//   String? customerName;
//   final String? phone;
//   final dynamic email;
//   final dynamic houseNo;
//   final dynamic street;
//   final dynamic landmark;
//   final dynamic locality;
//   final dynamic city;
//   final dynamic cityId;
//   final dynamic pincode;
//   final String? isPointsRedeemed;
//   final dynamic noOfPointsRedeemed;
//   final dynamic pointsValue;
//   final dynamic message;
//   final DateTime? dateCreated;
//   String? status;
//   final String? paymentType;
//   final dynamic paymentCard;
//   final dynamic paymentGateway;
//   final String? noOfItems;
//   final dynamic paidDate;
//   final dynamic paidAmount;
//   final dynamic transactionId;
//   final dynamic chargeId;
//   final dynamic payerId;
//   final dynamic payerEmail;
//   final dynamic payerName;
//   final dynamic paymentStatus;
//   final DateTime? dateUpdated;
//   final dynamic deviceId;
//   final dynamic ratingValue;
//   final dynamic isAdminSentToKm;
//   final dynamic kmId;
//   final dynamic kmReceivedDatetime;
//   final dynamic isAdminSentToDm;
//   final dynamic isKmSentToDm;
//   final dynamic sentKmId;
//   final dynamic dmId;
//   final dynamic dmReceivedDatetime;
//   final dynamic lastUpdatedBy;
//   final dynamic lastUpdated;
//   final dynamic deliveredStatus;
//
//   factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
//         orderId: json["order_id"],
//         seconds: json.containsKey("seconds") ? json["seconds"] : 0,
//         userId: json["user_id"],
//         refUserUid: json["ref_user_uid"],
//         orderDate: json["order_date"] == null ? null : DateTime.parse(json["order_date"]),
//         orderTime: json["order_time"],
//         totalCost: json["total_cost"],
//         deliveryFee: json["delivery_fee"],
//         customerName: json["customer_name"],
//         phone: json["phone"],
//         email: json["email"],
//         houseNo: json["house_no"],
//         street: json["street"],
//         landmark: json["landmark"],
//         locality: json["locality"],
//         city: json["city"],
//         cityId: json["city_id"],
//         pincode: json["pincode"],
//         isPointsRedeemed: json["is_points_redeemed"],
//         noOfPointsRedeemed: json["no_of_points_redeemed"],
//         pointsValue: json["points_value"],
//         message: json["message"],
//         dateCreated: json["date_created"] == null ? null : DateTime.parse(json["date_created"]),
//         status: json["status"],
//         paymentType: json["payment_type"],
//         paymentCard: json["payment_card"],
//         paymentGateway: json["payment_gateway"],
//         noOfItems: json["no_of_items"],
//         paidDate: json["paid_date"],
//         paidAmount: json["paid_amount"],
//         transactionId: json["transaction_id"],
//         chargeId: json["charge_id"],
//         payerId: json["payer_id"],
//         payerEmail: json["payer_email"],
//         payerName: json["payer_name"],
//         paymentStatus: json["payment_status"],
//         dateUpdated: json["date_updated"] == null ? null : DateTime.parse(json["date_updated"]),
//         deviceId: json["device_id"],
//         ratingValue: json["rating_value"],
//         isAdminSentToKm: json["is_admin_sent_to_km"],
//         kmId: json["km_id"],
//         kmReceivedDatetime: json["km_received_datetime"],
//         isAdminSentToDm: json["is_admin_sent_to_dm"],
//         isKmSentToDm: json["is_km_sent_to_dm"],
//         sentKmId: json["sent_km_id"],
//         dmId: json["dm_id"],
//         dmReceivedDatetime: json["dm_received_datetime"],
//         lastUpdatedBy: json["last_updated_by"],
//         lastUpdated: json["last_updated"],
//         deliveredStatus: json["delivered_status"],
//       );
//
//   Map<String, dynamic> toJson() => {
//         "order_id": orderId,
//         "seconds": seconds,
//         "user_id": userId,
//         "ref_user_uid": refUserUid,
//         "order_date":
//             "${orderDate!.year.toString().padLeft(4, '0')}-${orderDate!.month.toString().padLeft(2, '0')}-${orderDate!.day.toString().padLeft(2, '0')}",
//         "order_time": orderTime,
//         "total_cost": totalCost,
//         "delivery_fee": deliveryFee,
//         "customer_name": customerName,
//         "phone": phone,
//         "email": email,
//         "house_no": houseNo,
//         "street": street,
//         "landmark": landmark,
//         "locality": locality,
//         "city": city,
//         "city_id": cityId,
//         "pincode": pincode,
//         "is_points_redeemed": isPointsRedeemed,
//         "no_of_points_redeemed": noOfPointsRedeemed,
//         "points_value": pointsValue,
//         "message": message,
//         "date_created": dateCreated?.toIso8601String(),
//         "status": status,
//         "payment_type": paymentType,
//         "payment_card": paymentCard,
//         "payment_gateway": paymentGateway,
//         "no_of_items": noOfItems,
//         "paid_date": paidDate,
//         "paid_amount": paidAmount,
//         "transaction_id": transactionId,
//         "charge_id": chargeId,
//         "payer_id": payerId,
//         "payer_email": payerEmail,
//         "payer_name": payerName,
//         "payment_status": paymentStatus,
//         "date_updated":
//             "${dateUpdated!.year.toString().padLeft(4, '0')}-${dateUpdated!.month.toString().padLeft(2, '0')}-${dateUpdated!.day.toString().padLeft(2, '0')}",
//         "device_id": deviceId,
//         "rating_value": ratingValue,
//         "is_admin_sent_to_km": isAdminSentToKm,
//         "km_id": kmId,
//         "km_received_datetime": kmReceivedDatetime,
//         "is_admin_sent_to_dm": isAdminSentToDm,
//         "is_km_sent_to_dm": isKmSentToDm,
//         "sent_km_id": sentKmId,
//         "dm_id": dmId,
//         "dm_received_datetime": dmReceivedDatetime,
//         "last_updated_by": lastUpdatedBy,
//         "last_updated": lastUpdated,
//         "delivered_status": deliveredStatus,
//       };
// }
