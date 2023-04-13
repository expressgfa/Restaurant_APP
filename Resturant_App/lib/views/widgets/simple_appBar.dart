import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resturantapp/views/widgets/my_text.dart';

AppBar simpleAppBar({String? title, bool? haveIcon = false, Function()? onBackPressed}) {
  return AppBar(
    leading: haveIcon == true
        ? GestureDetector(
            onTap: onBackPressed ?? () {
              log("pressed back Icon");
              Get.back();
            },
            child: const Icon(
              Icons.arrow_back_outlined,
              color: Colors.black,
            ),
          )
        : null,
    automaticallyImplyLeading: false,
    centerTitle: false,
    title: Row(
      children: [
        MyText(
          text: title ?? "",
          fontSize: 19,
          fontWeight: FontWeight.w500,
        ),
      ],
    ),
  );
}
