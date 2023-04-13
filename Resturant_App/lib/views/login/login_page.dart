import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:resturantapp/constant/all_controller.dart';
import 'package:resturantapp/views/login/forgot_password_page.dart';
import 'package:resturantapp/views/widgets/my_text.dart';
import 'package:resturantapp/views/widgets/my_text_field.dart';
import 'package:resturantapp/views/widgets/simple_appBar.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        authController.emailController.clear();
        authController.passwordController.clear();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: simpleAppBar(
          title: "Login Capped".tr,
          haveIcon: true,
          onBackPressed: () {
            Get.back();
            authController.emailController.clear();
            authController.passwordController.clear();
          },
        ),
        body: Form(
          key: authController.formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: AutofillGroup(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(),
                Container(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyTextField(
                        focusNode: emailFocusNode,
                        hint: "Email Address".tr,
                        controller: authController.emailController,
                        keyboardType: TextInputType.emailAddress,
                        autoFillHints: const [AutofillHints.email],
                        validator: (String? value) {
                          if (value?.isEmpty == true) {
                            return "Email is required".tr;
                          } else if (!GetUtils.isEmail(value?.trim() ?? "")) {
                            return "Please enter a valid email address".tr;
                          }
                          return null;
                        },
                        onChanged: (value) {
                          if ((!GetUtils.isEmail(value.trim()) || authController.passwordController.text.isEmpty)) {
                            authController.isDisable.value = true;
                          } else {
                            authController.isDisable.value = false;
                          }
                        },
                        prefixIcon: const Icon(
                          Icons.email,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 15),
                      MyTextField(
                        focusNode: passwordFocusNode,
                        controller: authController.passwordController,
                        hint: "Password".tr,
                        isObSecure: true,
                        keyboardType: TextInputType.visiblePassword,
                        autoFillHints: const [AutofillHints.password],
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (val) => TextInput.finishAutofillContext(),
                        validator: (String? value) {
                          if (value?.trim().isEmpty == true) {
                            return 'Password is Required'.tr;
                          } else if ((value?.trim().length ?? 0) < 6) {
                            return 'Password must have at least 6 elements'.tr;
                          }

                          return null;
                        },
                        onChanged: (value) {
                          if ((value.isEmpty) || (!GetUtils.isEmail(authController.emailController.text))) {
                            authController.isDisable.value = true;
                          } else {
                            authController.isDisable.value = false;
                          }
                        },
                        prefixIcon: const Icon(
                          Icons.lock,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Get.to(() => const ForgotPasswordPage());
                        },
                        child: MyText(
                          text: "FORGOT PASSWORD".tr,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          paddingLeft: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                Obx(() {
                  return Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 30),
                    child: MaterialButton(
                      color: authController.isDisable.value ? Colors.orange[200] : Colors.orange,
                      height: 52,
                      minWidth: Get.width - 30,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      onPressed: () {
                        authController.isDisable.value ? () {} : authController.logIn();
                      },
                      child: authController.loading.value == true
                          ? const Center(
                              child: SizedBox(
                                height: 25,
                                width: 25,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : MyText(
                              text: "Login".tr,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
