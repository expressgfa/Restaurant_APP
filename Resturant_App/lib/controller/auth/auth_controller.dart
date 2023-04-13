import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:resturantapp/constant/all_controller.dart';
import 'package:resturantapp/constant/app_constant.dart';
import 'package:resturantapp/controller/base_controller.dart';
import 'package:resturantapp/services/base_client.dart';
import 'package:resturantapp/utils/device_info.dart';
import 'package:resturantapp/utils/shared_pref.dart';
import 'package:resturantapp/utils/snack_bar.dart';
import 'package:resturantapp/views/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:resturantapp/views/other/intro_page.dart';

class AuthController extends GetxController with BaseController {
  static AuthController instance = Get.find<AuthController>();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> forgotPasswordKey = GlobalKey<FormState>();

  TabController? tabController;

  TextEditingController emailController = TextEditingController();
  TextEditingController emailControllerForgot = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  RxBool isDisable = true.obs;
  RxBool isForgotDisabled = true.obs;

  RxInt spentSecs = 0.obs;

  RxBool loading = false.obs;
  Future<void> logIn1() async {
    if (formKey.currentState?.validate() ?? false) {
      formKey.currentState?.save();
      loading.value = true;

      String deviceId = "";
      if (Platform.isAndroid) {
        AndroidDeviceInfo deviceInfo = await getDeviceInfo() as AndroidDeviceInfo;
        deviceId = deviceInfo.id;
        log("deviceInfo.id = ${deviceInfo.id}");
      } else {
        IosDeviceInfo deviceInfo = await getDeviceInfo() as IosDeviceInfo;
        deviceId = deviceInfo.identifierForVendor ?? "";
      }

      log("Inside login function");
      http.Response response = await http.post(
        Uri.parse("http://154.12.251.49/app-login"),
        body: {
          'email': emailController.text.trim(),
          'password': passwordController.text,
          'app_id': "$deviceId-${emailController.text.trim()}",
        },
      );
      log("Response \n ${response.body}");
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        String status = jsonResponse['responce']['status'];
        if (status == "success") {
          await LocalSharedPrefDatabase.setUserEmail(emailController.text.trim());
          log("Login Successfully");
          loading.value = false;
          // Get.to(() => BottomNavBar());
        } else {
          loading.value = false;
          log("Something wrong");
          // showMsg(msg: jsonResponse['responce']["message"]);
          showMsg(msg: "Incorrect Login".tr);
        }
      } else {
        loading.value = false;
        log("Error in json response");
      }
    } else {
      log("form not validated");
    }
  }

  Future<void> logIn() async {
    if (formKey.currentState?.validate() ?? false) {
      formKey.currentState?.save();
      loading.value = true;

      String deviceId = "";
      if (Platform.isAndroid) {
        AndroidDeviceInfo deviceInfo = await getDeviceInfo() as AndroidDeviceInfo;
        deviceId = deviceInfo.id;
        log("deviceInfo.id = ${deviceInfo.id}");
      } else {
        IosDeviceInfo deviceInfo = await getDeviceInfo() as IosDeviceInfo;
        deviceId = deviceInfo.identifierForVendor ?? "";
      }

      var response = await BaseClient().post(baseUrl, loginEndpoint, {
        'email': emailController.text.trim(),
        'password': passwordController.text,
        'app_id': "$deviceId-${emailController.text.trim()}",
      }).catchError(handleError);

      log("response is  $response");

      if (response != null) {
        String status = response['responce']['status'];
        if (status == "success") {
          await LocalSharedPrefDatabase.setUserEmail(emailController.text.trim());
          try {
            await apiController.getSiteInfo();
          } catch (e) {
            log("error in getting site info: $e");
          }
          log("Login Successfully");
          apiController.logout(); //+ clearing all lists on login
          loading.value = false;
          passwordController.clear();
          emailController.clear();
          Get.offAll(() => const BottomNavBar());
        } else {
          loading.value = false;
          // showMsg(msg: response['responce']["message"]);
          showMsg(msg: "Incorrect Login".tr);
          log("Something wrong");
        }
      } else if (!networkController.isConnected.value) {
        showMsg(msg: "No internet please try again".tr);
      }   else {
        showMsg(msg: "There seems to be some issue on our side. We will resolve it as soon as we can.".tr);
      }
    } else {
      log("form not validated");
    }
  }

  Future<void> forgotPassword() async {
    if (forgotPasswordKey.currentState?.validate() ?? false) {
      forgotPasswordKey.currentState?.save();

      log("Inside forgotPassword function");

      var response = await BaseClient().post(baseUrl, forgotEndPoint, {
        'email': emailControllerForgot.text.trim(),
      }).catchError(handleError);

      emailControllerForgot.clear();

      log("Response \n ${response}");

      String status = response['responce']['status'];
      if (status == "success") {
        //
        log("reset email send successfully !");
        showMsg(msg: "Reset email sent successfully.".tr);
      } else {
        //
        log("Something wrong");
      }
    } else {
      log("form not validated");
    }
  }

  Future<void> checkIfStillLoggedIn() async {
    log("Inside checkIfStillLoggedIn function");
    String email = LocalSharedPrefDatabase.getUserEmail() ?? "";
    http.Response response = await http.post(
      Uri.parse("http://154.12.251.49/fetch-appid-status"),
      body: {
        'email': email,
      },
    );
    log("Response \n ${response.body}");
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);

      String status = jsonResponse['responce']['status'];
      String loginStatus = jsonResponse['responce']['message']['status'];
      if (status == "success") {
        if (loginStatus == "true") {
          //+ User is still logged In
        } else {
          //+ User should be logged out with the message that he logged in from another device
        }
        log("reset email send successfully !");
      } else {
        //
        log("Something wrong");
      }
    } else {
      log("Error in json response");
    }
  }

  Future<void> logOutUser() async {
    LocalSharedPrefDatabase.logout();
    emailController.clear();
    emailControllerForgot.clear();
    passwordController.clear();
    isDisable.value = true;
    isForgotDisabled.value = true;
    apiController.logout();
    Get.offAll(() => const IntroPage());
  }

// void postData() async {
//   var request = {'message': 'CodeX sucks!!!'};
//   showLoading('Posting data...');
//   var response = await BaseClient().post('https://jsonplaceholder.typicode.com', '/posts', request).catchError((error) {
//     if (error is BadRequestException) {
//       var apiError = json.decode(error.message!);
//       DialogHelper.showErroDialog(description: apiError["reason"]);
//     } else {
//       handleError(error);
//     }
//   });
//   if (response == null) return;
//   hideLoading();
//   print(response);
// }

}
