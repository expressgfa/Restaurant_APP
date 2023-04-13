import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:resturantapp/main.dart';

class NotificationServices {
  static selectNotification(NotificationResponse notificationResponse) async {
    log("inside selectNotification ");
  }

  static void onDidReceiveLocalNotification(int? id, String? title, String? body, String? payload) async {
    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) => CupertinoAlertDialog(
    //     title: Text(title!),
    //     content: Column(
    //       children: [
    //         Text(body!),
    //         Text(
    //           payload.toString(),
    //         )
    //       ],
    //     ),
    //     actions: [
    //       CupertinoDialogAction(
    //         isDefaultAction: true,
    //         child: Text('See ChatRoom'),
    //         onPressed: () async {
    //           debugPrint("Please check the payload data first");
    //         },
    //       )
    //     ],
    //   ),
    // );
    /**/
    // Get.dialog(CupertinoAlertDialog(
    //   title: Text(title!),
    //   content: Column(
    //     children: [
    //       Text(body!),
    //       Text(
    //         payload.toString(),
    //       )
    //     ],
    //   ),
    //   actions: [
    //     CupertinoDialogAction(
    //       isDefaultAction: true,
    //       child: Text('See ChatRoom'),
    //       onPressed: () async {
    //         debugPrint("Please check the payload data first");
    //       },
    //     )
    //   ],
    // ));
  }

  static Future<void> setUpNotifications() async {
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('ic_launcher'),
        iOS: DarwinInitializationSettings(
          onDidReceiveLocalNotification: onDidReceiveLocalNotification,
        ),
      ),
      onDidReceiveNotificationResponse: selectNotification,
    );

    //We need to configure for the ios as well

  }

  static showBackgroundNotification() {
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        'high_importance_channel',
        'restaurant_app',
        channelDescription: 'Vibrate and show notification',
        importance: Importance.max,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
        styleInformation: BigTextStyleInformation("Somehow you closed the app. Please open it again to start taking orders."),
        enableLights: true,
        color: Color.fromARGB(255, 255, 255, 255),
        ledColor: Color.fromARGB(255, 255, 0, 0),
        ledOnMs: 1000,
        ledOffMs: 500,
      ),
      iOS: DarwinNotificationDetails(
        categoryIdentifier: "backgroundReopen",
        subtitle: "Somehow you closed the app. Please open it again to start taking orders.",
      ),
    );

    flutterLocalNotificationsPlugin.show(
      1001,
      "Restaurant",
      "Somehow you closed the app. Please open it again to start taking orders.",
      platformChannelSpecifics,
      payload: "backgroundReopen",
    );
  }
}
