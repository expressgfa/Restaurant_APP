import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resturantapp/constant/all_controller.dart';
import 'package:resturantapp/my_logger.dart';
import 'package:resturantapp/utils/shared_pref.dart';
import 'package:resturantapp/views/internet_tutorial/internet_tutorial.dart';

class NetworkController extends GetxController {
  static NetworkController instance = Get.find<NetworkController>();
  final Connectivity _connectivity = Connectivity();
  late ConnectivityResult _connectivityResult;
  late StreamSubscription<ConnectivityResult> streamSubscription;

  RxBool isConnected = false.obs;

  @override
  void onInit() async {
    super.onInit();
    _initConnectivity();
    streamSubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _initConnectivity() async {
    _connectivityResult = await _connectivity.checkConnectivity();
    log("_connectivityResult $_connectivityResult");
    if (_connectivityResult==ConnectivityResult.none) {
      isConnected.value = false;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Get.rawSnackbar(
          messageText: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'No internet connection',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.to(() => InternetTutorial());
                },
                child: const Text(
                  'FIX THIS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          isDismissible: true,
          duration: const Duration(seconds: 10),
          backgroundColor: Colors.black54,
          snackStyle: SnackStyle.GROUNDED,
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(20),
        );
      });

    } else {
      isConnected.value = true;
      infoLog("STATUS inside if  : $_connectivityResult");

    }
  }

  Future<void> _updateConnectionStatus(ConnectivityResult connectivityResult) async {
    infoLog("STATUS : $connectivityResult");

    if (connectivityResult == ConnectivityResult.none) {
      infoLog("STATUS inside if  : $connectivityResult");

      isConnected.value = false;

      Map<String, dynamic> activityMap = {};

      DateTime currentDateTime = DateTime.now();
      String currentDateOnly = currentDateTime.toString().split(" ")[0];

      String? activityMapEncodedString = LocalSharedPrefDatabase.getActivity();
      activityMap = activityMapEncodedString != null ? jsonDecode(activityMapEncodedString) : {};
      authController.spentSecs.value = 0;

      activityMap.update(
        currentDateOnly,
        (value) => {
          "secs": value['secs'] + currentDateTime.difference(DateTime.parse(value["startedAt"])).inSeconds,
          "startedAt": currentDateTime.toString(),
        },
        ifAbsent: () => {
          "secs": 0,
          "startedAt": currentDateTime.toString(),
        },
      );

      String encodedActivityMap = jsonEncode(activityMap);
      LocalSharedPrefDatabase.setActivity(encodedActivityMap);

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Get.rawSnackbar(
          messageText: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'No internet connection',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.to(() => InternetTutorial());
                },
                child: const Text(
                  'FIX THIS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          isDismissible: true,
          duration: const Duration(seconds: 10),
          backgroundColor: Colors.black54,
          snackStyle: SnackStyle.GROUNDED,
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(20),
        );
      });
    } else {
      Map<String, dynamic> activityMap = {};

      DateTime currentDateTime = DateTime.now();
      String currentDateOnly = currentDateTime.toString().split(" ")[0];

      String? activityMapEncodedString = LocalSharedPrefDatabase.getActivity();
      activityMap = activityMapEncodedString != null ? jsonDecode(activityMapEncodedString) : {};
      authController.spentSecs.value = 0;

      activityMap.update(
        currentDateOnly,
        (value) => {
          "secs": value['secs'],
          "startedAt": currentDateTime.toString(),
        },
        ifAbsent: () => {
          "secs": 0,
          "startedAt": currentDateTime.toString(),
        },
      );

      String encodedActivityMap = jsonEncode(activityMap);
      LocalSharedPrefDatabase.setActivity(encodedActivityMap);

      isConnected.value = true;
      // infoLog("Internet Connected Successfully !");
    }
  }

  @override
  void onClose() {
    streamSubscription.cancel();
  }

  showSnackBar() {}
}
