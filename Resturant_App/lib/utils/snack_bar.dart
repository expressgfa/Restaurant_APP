import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resturantapp/constant/color.dart';

showMsg({String? msg}) {
  Get.rawSnackbar(
    messageText: Text(
      msg ?? "",
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    ),
    isDismissible: true,
    duration: const Duration(seconds: 2),
    backgroundColor: Colors.black54,
    snackStyle: SnackStyle.GROUNDED,
    margin: const EdgeInsets.all(8),
    padding: const EdgeInsets.all(20),
  );
}

showCircularLoading({Color? color = kTertiaryColor2}) {
  Get.dialog(
    Center(
      child: SizedBox(
        height: 35,
        width: 35,
        child: CircularProgressIndicator(
          color: color ?? kGreenColor,
        ),
      ),
    ),
  );
}

dismissLoading() {
  if (Get.isDialogOpen == true) {
    Get.back();
  }
}
