import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resturantapp/constant/all_controller.dart';
import 'package:resturantapp/my_logger.dart';
import 'package:resturantapp/views/widgets/my_button.dart';
import 'package:resturantapp/views/widgets/my_text.dart';
import 'package:resturantapp/views/widgets/my_text_field.dart';
import 'package:resturantapp/views/widgets/simple_appBar.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        authController.emailControllerForgot.clear();
        authController.isForgotDisabled.value = true;
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: simpleAppBar(
          title: "Forgot password".tr,
          haveIcon: true,
          onBackPressed: () {
            Get.back();
            authController.emailControllerForgot.clear();
            authController.isForgotDisabled.value = true;
          },
        ),
        body: Form(
          key: authController.forgotPasswordKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    SizedBox(height: Get.height * 0.28),
                    MyText(
                      text: "Please enter your email address below to receive password reset instructions".tr,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      paddingLeft: 18,
                    ),
                    const SizedBox(height: 15),
                    MyTextField(
                      hint: "Email Address".tr,
                      controller: authController.emailControllerForgot,
                      validator: (String? value) {
                        if (value?.isEmpty == true) {
                          return "Email is required".tr;
                        } else if (!GetUtils.isEmail(value?.trim() ?? "")) {
                          return "Please enter a valid email address".tr;
                        } else {
                          authController.isForgotDisabled.value = false;
                          errorLog("isForgotDisabled value changed");
                        }
                        return null;
                      },
                      prefixIcon: const Icon(
                        Icons.email,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: Get.height * 0.31),
                    Obx(() {
                      return MyButton(
                        btnColor: authController.isForgotDisabled.value ? Colors.orange[200] : Colors.orange,
                        title: "Reset Password".tr,
                        onTap: authController.isForgotDisabled.value ? () {} : () => authController.forgotPassword(),
                      );
                    }),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
