import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:resturantapp/constant/all_controller.dart';
import 'package:resturantapp/constant/app_constant.dart';
import 'package:resturantapp/controller/language_controller/language_controller.dart';
import 'package:resturantapp/model/bluetooth_printer_model.dart';
import 'package:resturantapp/model/printer_type_hive.dart';
import 'package:resturantapp/model/site_data_model/site_model.dart';
import 'package:resturantapp/utils/shared_pref.dart';
import 'package:resturantapp/utils/theme/light_theme.dart';
import 'package:resturantapp/views/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:resturantapp/views/other/intro_page.dart';

AndroidNotificationChannel? channel;
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // description
    importance: Importance.max,
  );
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel!);

  flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestPermission();

  await LocalSharedPrefDatabase.init();
  init();
  await Hive.initFlutter();
  Hive.registerAdapter(PrinterDataModelAdapter());
  Hive.registerAdapter(MyPrinterTypeAdapter());
  Hive.registerAdapter(SiteInfoAdapter());
  await Hive.openBox(printerBox);
  await Hive.openBox(siteInfoBox);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? email;
  @override
  void initState() {
    languageController.getLanguage();
    email = LocalSharedPrefDatabase.getUserEmail() ?? "";
    log("email from shared preference $email");

    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      locale: Localization.currentLocale,
      fallbackLocale: Localization.fallBackLocale,
      translations: Localization(),
      themeMode: ThemeMode.light,
      title: 'Restaurant',
      theme: lightTheme,
      home: (email == null || email == "") ? const IntroPage() : const BottomNavBar(),
    );
  }
}
