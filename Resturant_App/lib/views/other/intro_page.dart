import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resturantapp/constant/all_controller.dart';
import 'package:resturantapp/generated/assets.dart';
import 'package:resturantapp/utils/custom_scroll_behavior.dart';
import 'package:resturantapp/views/login/login_page.dart';
import 'package:resturantapp/views/widgets/my_button.dart';
import 'package:resturantapp/views/widgets/my_text.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScrollConfiguration(
        behavior: MyCustomScrollBehavior(),
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: Get.height / 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: MyText(
                    text: "Take orders & reservations\n for your restaurant ".tr,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                Image.asset(Assets.imagesIntroImage),
                MyButton(
                  title: "Login".tr,
                  onTap: () {
                    authController.isDisable.value = true;
                    Get.to(() => LoginPage());
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
