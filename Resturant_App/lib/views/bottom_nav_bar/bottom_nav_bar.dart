import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:resturantapp/constant/all_controller.dart';
import 'package:resturantapp/controller/audio_controller/audio_feedback_provider.dart';
import 'package:resturantapp/generated/assets.dart';
import 'package:resturantapp/main.dart';
import 'package:resturantapp/my_logger.dart';
import 'package:resturantapp/services/notification_services.dart';
import 'package:resturantapp/utils/shared_pref.dart';
import 'package:resturantapp/views/bottom_nav_bar/setting_page.dart';
import 'package:resturantapp/views/home/home_page.dart';
import 'package:sound_mode/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key? key}) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> with WidgetsBindingObserver, TickerProviderStateMixin {
  RxInt currentIndex = 0.obs;

  Map<String, dynamic> activityMap = {};

  List<Widget> pages = [
    const HomePage(),
    const SettingPage(),
  ];

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    // SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
    //   apiController.getOrderData();
    // });
    log("init of bottom nav bar");

    DateTime currentDateTime = DateTime.now();
    infoLog("currentDate: ${currentDateTime.toString().split(" ")[0]}");
    infoLog("currentDate.toString(): ${currentDateTime.toString()}");
    // infoLog("currentDate.toIso8601String(): ${currentDateTime.toIso8601String()}");
    // infoLog("currentDate.toIso8601String(): ${DateTime.tryParse(currentDateTime.toString())}");
    // infoLog("currentDate.toIso8601String(): ${DateTime.tryParse(currentDateTime.toIso8601String())}");

    String currentDateOnly = currentDateTime.toString().split(" ")[0];
    String? activityMapEncodedString = LocalSharedPrefDatabase.getActivity();
    //Map<String, Map<String, dynamic>>
    activityMap = activityMapEncodedString != null ? jsonDecode(activityMapEncodedString) : {};

    errorLog("activityMapEncodedString in initstate from the shared pref is: $activityMapEncodedString");
    errorLog("activityMap in initstate from the shared pref is: $activityMap");
    if (activityMap.containsKey(currentDateOnly)) {
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
    } else {
      activityMap.putIfAbsent(
        currentDateOnly,
        () => {
          "secs": 0,
          "startedAt": currentDateTime.toString(),
        },
      );
    }

    debugLog("activityMap in initstate after update based on the app start is: $activityMap");

    String encodedActivityMap = jsonEncode(activityMap);

    LocalSharedPrefDatabase.setActivity(encodedActivityMap);

    printerController.bluetoothStreamInitializer();
    PermissionHandler.permissionsGranted.then((isGranted) async {
      if (!(isGranted ?? false)) {
        // Opens the Do Not Disturb Access settings to grant the access
        await PermissionHandler.openDoNotDisturbSetting();
      }
    });
    super.initState();
  }

  Timer? myBackgroundTimer;
  // Map<String, Timer?> myNewOrderBackgroundTimers = {};
  // Map<String, int> myNewOrdersSeconds = {};

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
        log("App was paused");
        apiController.isAppInBackground = true;
        String email = "";
        email = LocalSharedPrefDatabase.getUserEmail() ?? "";
        if (email.isNotEmpty) {
          NotificationServices.showBackgroundNotification();
          myBackgroundTimer = Timer.periodic(const Duration(minutes: 3), (timer) {
            log("TIMER HIT ____________________ in paused");
            AudioFeedback.playBackgroundSound();
          });

          DateTime currentDateTime = DateTime.now();
          String currentDateOnly = currentDateTime.toString().split(" ")[0];
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
          debugLog("activityMap in initstate after update in app pause is: $activityMap");
          String encodedActivityMap = jsonEncode(activityMap);
          LocalSharedPrefDatabase.setActivity(encodedActivityMap);

          // apiController.myNewOrdersSeconds.clear();
          // apiController.myNewOrderBackgroundTimers.clear();
          //
          // for (var order in apiController.newOrdersList) {
          //   log("just went IN background checking order: ${order.value.orderId}");
          //   //! calculating seconds
          //   tz.initializeTimeZones();
          //   var detroit = tz.getLocation('America/Los_Angeles');
          //   var now = tz.TZDateTime.now(detroit);
          //   log("BACKGROUND Los Angeles timeL ==: $now");
          //
          //   Duration timeDifference = const Duration(seconds: 0);
          //
          //   timeDifference = DateTime.parse("${now.toIso8601String().split(".")[0]}.000")
          //       .difference(order.value.dateCreated ?? DateTime.parse("${now.toIso8601String().split(".")[0]}.000"));
          //
          //   log("BACKGROUND timeDifference on details page init: ${timeDifference.inSeconds}");
          //   log("BACKGROUND apiController.newOrderList[index].dateCreated: ${order.value.dateCreated}");
          //
          //   int acceptSecs = 180 - timeDifference.inSeconds;
          //   apiController.backgroundSecondPageTimerValMap.clear();
          //   //! -------------------
          //   apiController.myNewOrdersSeconds.putIfAbsent(order.value.orderId ?? "", () => acceptSecs);
          //   apiController.myNewOrderBackgroundTimers.putIfAbsent(
          //     order.value.orderId ?? "",
          //     () => Timer.periodic(
          //       const Duration(seconds: 1),
          //       (timer) {
          //         int ranFor = (apiController.myNewOrdersSeconds[order.value.orderId] ?? 0) - timer.tick;
          //         if (ranFor >= 60) {
          //           if (timer.tick % 7 == 0) {
          //             debugLog("ranFor: ------------------------------------ $ranFor");
          //
          //             // if (!checkableIsAnsweredOuter && !apiController.isOnSecondPage) {
          //             log("BACKGROUND MULTIPLE OF 7 and timeElapsed.inSeconds: ${timer.tick} at "
          //                 "orderId: ${order.value.orderId}");
          //             // apiController.timerValMapExtended.update(apiController.newOrdersList[index].value.orderId ?? "", (value) {
          //             //   value.putIfAbsent(timeElapsed.inSeconds.toString(), () => false);
          //             //   log("added new value");
          //             //   return value;
          //             // }, ifAbsent: () => {"0": true});
          //             if (ranFor >= 0) {
          //               log("BACKGROUND playing sound now");
          //               AudioFeedback.playSuccessSound();
          //             }
          //             // } else {
          //             //   log("in main timer check 7 else means one of the vars was true.");
          //             //   log("checkableIsAnsweredOuter: $checkableIsAnsweredOuter");
          //             //   log("apiController.isOnSecondPage: ${apiController.isOnSecondPage}");
          //             //   log("apiController.isAnsweredMap: ${apiController.isAnsweredMap}");
          //             // }
          //           }
          //         } else {
          //           if (timer.tick % 3 == 0) {
          //             debugLog("BACKGROUND ranFor: ------------------------------------ $ranFor");
          //             // bool checkableIsAnsweredThree =
          //             // apiController.isAnsweredMap.containsKey(apiController.newOrdersList[index].value.orderId ?? "")
          //             //     ? apiController.isAnsweredMap[apiController.newOrdersList[index].value.orderId ?? ""] ?? true
          //             //     : true;
          //             //
          //             // if (!checkableIsAnsweredThree && !apiController.isOnSecondPage) {
          //             log("BACKGROUND MULTIPLE OF 3 and timeElapsed.inSeconds: ${timer.tick} at"
          //                 "orderId: ${order.value.orderId}");
          //             // apiController.timerValMapExtended.update(apiController.newOrdersList[index].value.orderId ?? "", (value) {
          //             //   value.putIfAbsent(timeElapsed.inSeconds.toString(), () => false);
          //             //   log("added new value");
          //             //   return value;
          //             // }, ifAbsent: () => {"0": true});
          //             if (ranFor >= 0) {
          //               log("BACKGROUND 3 part playing sound now");
          //               AudioFeedback.playSuccessSound();
          //             } else {
          //               errorLog("BACKGROUND ---------- canceling timer ----------");
          //               apiController.missOrder(
          //                 order.value.orderId ?? "201",
          //                 apiController.newOrdersList.indexWhere(
          //                   (element) => element.value.orderId == order.value.orderId,
          //                 ),
          //               );
          //               timer.cancel();
          //             }
          //             // } else {
          //             //   log("in main timer check 3 else means one of the vars was true.");
          //             //   log("checkableIsAnsweredThree: $checkableIsAnsweredThree");
          //             //   log("apiController.isOnSecondPage: ${apiController.isOnSecondPage}");
          //             //   log("apiController.isAnsweredMap: ${apiController.isAnsweredMap}");
          //             // }
          //           }
          //         }
          //       },
          //     ),
          //   );
          // }
        }
        break;
      case AppLifecycleState.resumed:
        apiController.isAppInBackground = false;
        log("App was resumed");
        authController.spentSecs.value = 0;
        if (myBackgroundTimer != null) {
          log("IN TIMER NOT NULL");
          if (myBackgroundTimer?.isActive ?? false) myBackgroundTimer?.cancel();
          AudioFeedback.audioPlayer.stop();
          flutterLocalNotificationsPlugin.cancel(1001);
        }
        // // myNewOrdersSeconds.clear();
        // apiController.myNewOrderBackgroundTimers.forEach((key, value) {
        //   if(value != null) value.cancel();
        // });
        // apiController.myNewOrderBackgroundTimers.clear();
        DateTime currentDateTime = DateTime.now();
        String currentDateOnly = currentDateTime.toString().split(" ")[0];
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
        debugLog("activityMap in initstate after update in app resumed is: $activityMap");
        String encodedActivityMap = jsonEncode(activityMap);
        LocalSharedPrefDatabase.setActivity(encodedActivityMap);
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Obx(() {
        return Container(
          child: pages[currentIndex.value],
        );
      }),
      bottomNavigationBar: Obx(() {
        return Container(
          height: 58,
          decoration: const BoxDecoration(
            color: Colors.grey,
          ),
          child: BottomNavigationBar(
            currentIndex: currentIndex.value,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.orange,
            unselectedItemColor: Colors.grey.withOpacity(0.5),
            showSelectedLabels: false,
            showUnselectedLabels: false,
            elevation: 10,
            backgroundColor: Colors.white,
            onTap: (int? index) {
              currentIndex.value = index!;
            },
            items: const [
              BottomNavigationBarItem(
                // icon: Icon(FontAwesomeIcons.burger, size: 20),
                icon: ImageIcon(
                  AssetImage(Assets.iconsOrderTabIcon),
                  // color: Colors.red,
                  size: 26,
                ),
                label: "",
              ),
              BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.gear, size: 22),
                label: "",
              ),
            ],
          ),
        );
      }),
    );
  }
}
