import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:resturantapp/views/widgets/my_text.dart';

class MyButton extends StatelessWidget {
  final String? title;
  final VoidCallback? onTap;
  final Color? btnColor;
  final double? height;
  final double? width;

  const MyButton({Key? key, this.title, this.onTap, this.btnColor, this.height, this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: MaterialButton(
        color: btnColor ?? Colors.orange,
        height: height ?? 55,
        minWidth: width ?? Get.width - 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        onPressed: onTap,
        child: MyText(
          text: title ?? "",
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
    );
  }
}
