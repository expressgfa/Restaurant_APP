// To parse this JSON data, do
//
//     final itemModel = itemModelFromJson(jsonString);

import 'dart:convert';

ItemModel itemModelFromJson(String str) => ItemModel.fromJson(json.decode(str));

String itemModelToJson(ItemModel data) => json.encode(data.toJson());

class ItemModel {
  final String? itemId;
  final String? sortBy;
  final String? menuId;
  final String? itemName;
  final String? signature;
  final String? itemCost;
  final String? itemPoints;
  final String? pointsToPurchase;
  final String? itemTypeId;
  final String? itemImageName;
  final String? itemDescription;
  final String? status;
  final String? isMostSellingItem;
  final String? productId;
  final String? menuName;
  final String? itemType;
  ItemModel({
    this.itemId,
    this.sortBy,
    this.menuId,
    this.itemName,
    this.signature,
    this.itemCost,
    this.itemPoints,
    this.pointsToPurchase,
    this.itemTypeId,
    this.itemImageName,
    this.itemDescription,
    this.status,
    this.isMostSellingItem,
    this.productId,
    this.menuName,
    this.itemType,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) => ItemModel(
        itemId: json["item_id"],
        sortBy: json["sort_by"],
        menuId: json["menu_id"],
        itemName: json["item_name"],
        signature: json["Signature"],
        itemCost: json["item_cost"],
        itemPoints: json["item_points"],
        pointsToPurchase: json["points_to_purchase"],
        itemTypeId: json["item_type_id"],
        itemImageName: json["item_image_name"],
        itemDescription: json["item_description"],
        status: json["status"],
        isMostSellingItem: json["is_most_selling_item"],
        productId: json["product_id"],
        menuName: json["menu_name"],
        itemType: json["item_type"],
      );

  Map<String, dynamic> toJson() => {
        "item_id": itemId,
        "sort_by": sortBy,
        "menu_id": menuId,
        "item_name": itemName,
        "Signature": signature,
        "item_cost": itemCost,
        "item_points": itemPoints,
        "points_to_purchase": pointsToPurchase,
        "item_type_id": itemTypeId,
        "item_image_name": itemImageName,
        "item_description": itemDescription,
        "status": status,
        "is_most_selling_item": isMostSellingItem,
        "product_id": productId,
        "menu_name": menuName,
        "item_type": itemType,
      };
}
