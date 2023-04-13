// To parse this JSON data, do
//
//     final menuModel = menuModelFromJson(jsonString);

import 'dart:convert';

MenuModel menuModelFromJson(String str) => MenuModel.fromJson(json.decode(str));

String menuModelToJson(MenuModel data) => json.encode(data.toJson());

class MenuModel {
  MenuModel({
    this.menuId,
    this.orderBy,
    this.menuName,
    this.punchLine,
    this.description,
    this.menuImageName,
    this.status,
  });

  final String? menuId;
  final String? orderBy;
  final String? menuName;
  final String? punchLine;
  final String? description;
  final String? menuImageName;
  final String? status;

  factory MenuModel.fromJson(Map<String, dynamic> json) => MenuModel(
        menuId: json["menu_id"],
        orderBy: json["order_by"],
        menuName: json["menu_name"],
        punchLine: json["punch_line"],
        description: json["description"],
        menuImageName: json["menu_image_name"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "menu_id": menuId,
        "order_by": orderBy,
        "menu_name": menuName,
        "punch_line": punchLine,
        "description": description,
        "menu_image_name": menuImageName,
        "status": status,
      };
}
