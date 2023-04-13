import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

getDeviceInfo() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    // log('Running on ${androidInfo.toString()}');  // e.g. "Moto G (4)"
    return androidInfo;
  } else if(Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    print('Running on ${iosInfo.utsname.machine}');  // e.g. "iPod7,1"
    return iosInfo;
  }

}