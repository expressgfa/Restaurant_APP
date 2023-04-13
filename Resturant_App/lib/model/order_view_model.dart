// To parse this JSON data, do
//
//     final orderViewModel = orderViewModelFromJson(jsonString);

import 'dart:convert';

OrderViewModel orderViewModelFromJson(String str) => OrderViewModel.fromJson(json.decode(str));

String orderViewModelToJson(OrderViewModel data) => json.encode(data.toJson());

class OrderViewModel {
  OrderViewModel({
    required this.order,
    this.orderItems = const [],
    this.isFirstOrder = "No",
    this.addons = const [],
    this.offers = const [],
  });

  Order order;
  List<OrderItem> orderItems;
  String isFirstOrder;
  List<dynamic> addons;
  List<dynamic> offers;

  factory OrderViewModel.fromJson(Map<String, dynamic> json) => OrderViewModel(
        order: Order.fromJson(json["order"]),
        isFirstOrder: json.containsKey("is_first_order") ? json["is_first_order"] : "No",
        orderItems: List<OrderItem>.from(json["order_items"].map((x) => OrderItem.fromJson(x))),
        addons: List<dynamic>.from(json["addons"].map((x) => x)),
        offers: List<dynamic>.from(json["offers"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "order": order.toJson(),
        "is_first_order": isFirstOrder,
        "order_items": List<dynamic>.from(orderItems.map((x) => x.toJson())),
        "addons": List<dynamic>.from(addons.map((x) => x)),
        "offers": List<dynamic>.from(offers.map((x) => x)),
      };
}

class Order {
  Order({
    this.orderId = "",
    this.userId = "",
    this.refUserUid = "",
    this.orderDate = "",
    this.orderTime = "",
    this.totalCost = "",
    this.deliveryFee = "",
    this.customerName = "",
    this.phone = "",
    this.email = "",
    this.houseNo = "",
    this.street = "",
    this.landmark = "",
    this.locality = "",
    this.city = "",
    this.cityId = "",
    this.pincode = "",
    this.isPointsRedeemed = "",
    this.noOfPointsRedeemed = "",
    this.pointsValue = "",
    this.totalEarnPoints = "",
    this.message = "",
    this.dateCreated = "",
    this.status = "",
    this.paymentType = "",
    this.paymentCard = "",
    this.paymentGateway = "",
    this.noOfItems = "",
    this.paidDate = "",
    this.paidAmount = "",
    this.transactionId = "",
    this.chargeId = "",
    this.payerId = "",
    this.payerEmail = "",
    this.payerName = "",
    this.paymentStatus = "",
    this.dateUpdated = "",
    this.deviceId = "",
    this.ratingValue = "",
    this.isAdminSentToKm = "",
    this.kmId = "",
    this.kmReceivedDatetime = "",
    this.isAdminSentToDm = "",
    this.isKmSentToDm = "",
    this.sentKmId = "",
    this.dmId = "",
    this.redeemedGiftCardNo = "",
    this.dmReceivedDatetime = "",
    this.lastUpdatedBy = "",
    this.lastUpdated = "",
    this.deliveredStatus = "",
    this.deliveredStatusDatetime = "",
    this.cancelledStatus = "",
    this.cancelledStatusDatetime = "",
    this.missedStatusDatetime = "",
    this.pickupTime = "",
    this.rejectReason = "",
    this.rejectedDateTme = "",
    this.acceptedDateTme = "",
    this.fulfilmentDateTme = "",
    this.kitchenManager = "",
    this.sentKmUser = "",
    this.deliveryManager = "",
  });

  String orderId;
  String userId;
  dynamic refUserUid;
  String orderDate;
  String orderTime;
  String totalCost;
  String deliveryFee;
  String customerName;
  String phone;
  String email;
  dynamic houseNo;
  dynamic street;
  dynamic landmark;
  dynamic locality;
  dynamic city;
  dynamic cityId;
  dynamic pincode;
  String isPointsRedeemed;
  dynamic noOfPointsRedeemed;
  dynamic pointsValue;
  String totalEarnPoints;
  dynamic message;
  String dateCreated;
  String status;
  String paymentType;
  dynamic paymentCard;
  dynamic paymentGateway;
  String noOfItems;
  dynamic paidDate;
  dynamic paidAmount;
  dynamic transactionId;
  dynamic chargeId;
  dynamic payerId;
  dynamic payerEmail;
  dynamic payerName;
  dynamic paymentStatus;
  String dateUpdated;
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
  dynamic lastUpdatedBy;
  dynamic lastUpdated;
  dynamic deliveredStatus;
  dynamic deliveredStatusDatetime;
  dynamic cancelledStatus;
  dynamic cancelledStatusDatetime;
  dynamic missedStatusDatetime;
  dynamic pickupTime;
  dynamic rejectReason;
  dynamic rejectedDateTme;
  dynamic acceptedDateTme;
  dynamic fulfilmentDateTme;
  dynamic kitchenManager;
  dynamic sentKmUser;
  dynamic deliveryManager;

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        orderId: json["order_id"] ?? "",
        userId: json["user_id"] ?? "",
        refUserUid: json["ref_user_uid"] ?? "",
        orderDate: json["order_date"] ?? "",
        orderTime: json["order_time"] ?? "",
        totalCost: json["total_cost"] ?? "",
        deliveryFee: json["delivery_fee"] ?? "",
        customerName: json["customer_name"] ?? "",
        phone: json["phone"] ?? "",
        email: json["email"] ?? "",
        houseNo: json["house_no"] ?? "",
        street: json["street"] ?? "",
        landmark: json["landmark"] ?? "",
        locality: json["locality"] ?? "",
        city: json["city"] ?? "",
        cityId: json["city_id"] ?? "",
        pincode: json["pincode"] ?? "",
        isPointsRedeemed: json["is_points_redeemed"] ?? "",
        noOfPointsRedeemed: json["no_of_points_redeemed"] ?? "",
        pointsValue: json["points_value"] ?? "",
        totalEarnPoints: json["total_earn_points"] ?? "",
        message: json["message"] ?? "",
        dateCreated: json["date_created"] ?? "",
        status: json["status"] ?? "",
        paymentType: json["payment_type"] ?? "",
        paymentCard: json["payment_card"] ?? "",
        paymentGateway: json["payment_gateway"] ?? "",
        noOfItems: json["no_of_items"] ?? "",
        paidDate: json["paid_date"] ?? "",
        paidAmount: json["paid_amount"] ?? "",
        transactionId: json["transaction_id"] ?? "",
        chargeId: json["charge_id"] ?? "",
        payerId: json["payer_id"] ?? "",
        payerEmail: json["payer_email"] ?? "",
        payerName: json["payer_name"] ?? "",
        paymentStatus: json["payment_status"] ?? "",
        dateUpdated: json["date_updated"] ?? "",
        deviceId: json["device_id"] ?? "",
        ratingValue: json["rating_value"] ?? "",
        isAdminSentToKm: json["is_admin_sent_to_km"] ?? "",
        kmId: json["km_id"] ?? "",
        kmReceivedDatetime: json["km_received_datetime"] ?? "",
        isAdminSentToDm: json["is_admin_sent_to_dm"] ?? "",
        isKmSentToDm: json["is_km_sent_to_dm"] ?? "",
        sentKmId: json["sent_km_id"] ?? "",
        dmId: json["dm_id"] ?? "",
        redeemedGiftCardNo: json["redeemed_gift_card_no"] ?? "",
        dmReceivedDatetime: json["dm_received_datetime"] ?? "",
        lastUpdatedBy: json["last_updated_by"] ?? "",
        lastUpdated: json["last_updated"] ?? "",
        deliveredStatus: json["delivered_status"] ?? "",
        deliveredStatusDatetime: json["delivered_status_datetime"] ?? "",
        cancelledStatus: json["cancelled_status"] ?? "",
        cancelledStatusDatetime: json["cancelled_status_datetime"] ?? "",
        missedStatusDatetime: json["missed_status_datetime"] ?? "",
        pickupTime: json["pickup_time"] ?? "",
        rejectReason: json["reject_reason"] ?? "",
        rejectedDateTme: json["rejected_date_tme"] ?? "",
        acceptedDateTme: json["accepted_date_tme"] ?? "",
        fulfilmentDateTme: json["fulfilment_date_tme"] ?? "",
        kitchenManager: json["kitchen_manager"] ?? "",
        sentKmUser: json["sent_km_user"] ?? "",
        deliveryManager: json["delivery_manager"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "order_id": orderId,
        "user_id": userId,
        "ref_user_uid": refUserUid,
        "order_date": orderDate,
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
        "date_created": dateCreated,
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
        "date_updated": dateUpdated,
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
        "last_updated": lastUpdated,
        "delivered_status": deliveredStatus,
        "delivered_status_datetime": deliveredStatusDatetime,
        "cancelled_status": cancelledStatus,
        "cancelled_status_datetime": cancelledStatusDatetime,
        "missed_status_datetime": missedStatusDatetime,
        "pickup_time": pickupTime,
        "reject_reason": rejectReason,
        "rejected_date_tme": rejectedDateTme,
        "accepted_date_tme": acceptedDateTme,
        "fulfilment_date_tme": fulfilmentDateTme,
        "kitchen_manager": kitchenManager,
        "sent_km_user": sentKmUser,
        "delivery_manager": deliveryManager,
      };
}

class OrderItem {
  OrderItem({
    this.opId = "",
    this.isDeleted = "",
    this.orderId = "",
    this.itemId = "",
    this.menuId = "",
    this.itemName = "",
    this.itemImageName = "",
    this.sizeId = "",
    this.sizeName = "",
    this.itemSizeId = "",
    this.sizePrice = "",
    this.finalCost = "",
    this.itemQty = "",
    this.itemCost = "",
    this.commonId = "",
    this.specialInstruction = "",
  });

  String opId;
  String isDeleted;
  String orderId;
  String itemId;
  String menuId;
  String itemName;
  String itemImageName;
  String sizeId;
  String sizeName;
  String itemSizeId;
  String sizePrice;
  String finalCost;
  String itemQty;
  String itemCost;
  String commonId;
  String specialInstruction;

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        opId: json["op_id"] ?? "",
        isDeleted: json["is_deleted"] ?? "",
        orderId: json["order_id"] ?? "",
        itemId: json["item_id"] ?? "",
        menuId: json["menu_id"] ?? "",
        itemName: json["item_name"] ?? "",
        itemImageName: json["item_image_name"] ?? "",
        sizeId: json["size_id"] ?? "",
        sizeName: json["size_name"] ?? "",
        itemSizeId: json["item_size_id"] ?? "",
        sizePrice: json["size_price"] ?? "",
        finalCost: json["final_cost"] ?? "",
        itemQty: json["item_qty"] ?? "",
        itemCost: json["item_cost"] ?? "",
        commonId: json["common_id"] ?? "",
        specialInstruction: json["special_instruction"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "op_id": opId,
        "is_deleted": isDeleted,
        "order_id": orderId,
        "item_id": itemId,
        "menu_id": menuId,
        "item_name": itemName,
        "item_image_name": itemImageName,
        "size_id": sizeId,
        "size_name": sizeName,
        "item_size_id": itemSizeId,
        "size_price": sizePrice,
        "final_cost": finalCost,
        "item_qty": itemQty,
        "item_cost": itemCost,
        "common_id": commonId,
        "special_instruction": specialInstruction,
      };
}

// class OrderViewModel {
//   Map<String, String?>? order;
//   List<OrderItem>? orderItems;
//   List<dynamic>? addons;
//   List<dynamic>? offers;
//
//   OrderViewModel({
//     this.order,
//     this.orderItems,
//     this.addons,
//     this.offers,
//   });
//
//   factory OrderViewModel.fromJson(Map<String, dynamic> json) => OrderViewModel(
//         order: Map.from(json["order"]!).map((k, v) => MapEntry<String, String?>(k, v)),
//         orderItems: json["order_items"] == null ? [] : List<OrderItem>.from(json["order_items"]!.map((x) => OrderItem.fromJson(x))),
//         addons: json["addons"] == null ? [] : List<dynamic>.from(json["addons"]!.map((x) => x)),
//         offers: json["offers"] == null ? [] : List<dynamic>.from(json["offers"]!.map((x) => x)),
//       );
//
//   Map<String, dynamic> toJson() => {
//         "order": Map.from(order!).map((k, v) => MapEntry<String, dynamic>(k, v)),
//         "order_items": orderItems == null ? [] : List<dynamic>.from(orderItems!.map((x) => x.toJson())),
//         "addons": addons == null ? [] : List<dynamic>.from(addons!.map((x) => x)),
//         "offers": offers == null ? [] : List<dynamic>.from(offers!.map((x) => x)),
//       };
// }
//
// class OrderItem {
//   OrderItem({
//     this.opId,
//     this.isDeleted,
//     this.orderId,
//     this.itemId,
//     this.menuId,
//     this.itemName,
//     this.itemImageName,
//     this.sizeId,
//     this.sizeName,
//     this.itemSizeId,
//     this.sizePrice,
//     this.finalCost,
//     this.itemQty,
//     this.itemCost,
//     this.commonId,
//   });
//
//   String? opId;
//   String? isDeleted;
//   String? orderId;
//   String? itemId;
//   String? menuId;
//   String? itemName;
//   String? itemImageName;
//   String? sizeId;
//   String? sizeName;
//   String? itemSizeId;
//   String? sizePrice;
//   String? finalCost;
//   String? itemQty;
//   String? itemCost;
//   String? commonId;
//
//   factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
//         opId: json["op_id"],
//         isDeleted: json["is_deleted"],
//         orderId: json["order_id"],
//         itemId: json["item_id"],
//         menuId: json["menu_id"],
//         itemName: json["item_name"],
//         itemImageName: json["item_image_name"],
//         sizeId: json["size_id"],
//         sizeName: json["size_name"],
//         itemSizeId: json["item_size_id"],
//         sizePrice: json["size_price"],
//         finalCost: json["final_cost"],
//         itemQty: json["item_qty"],
//         itemCost: json["item_cost"],
//         commonId: json["common_id"],
//       );
//
//   Map<String, dynamic> toJson() => {
//         "op_id": opId,
//         "is_deleted": isDeleted,
//         "order_id": orderId,
//         "item_id": itemId,
//         "menu_id": menuId,
//         "item_name": itemName,
//         "item_image_name": itemImageName,
//         "size_id": sizeId,
//         "size_name": sizeName,
//         "item_size_id": itemSizeId,
//         "size_price": sizePrice,
//         "final_cost": finalCost,
//         "item_qty": itemQty,
//         "item_cost": itemCost,
//         "common_id": commonId,
//       };
// }
