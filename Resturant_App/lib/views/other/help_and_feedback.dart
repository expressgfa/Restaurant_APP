import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resturantapp/utils/device_info.dart';
import 'package:resturantapp/views/widgets/my_text.dart';
import 'package:resturantapp/views/widgets/simple_appBar.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpAndFeedBackPage extends StatelessWidget {
  const HelpAndFeedBackPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(title: "Help & feedback".tr, haveIcon: true),
      body: Column(
        // crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 25),
              physics: const BouncingScrollPhysics(),
              children: [
                const SizedBox(height: 25),
                MyText(
                  text: "Email our development team with your feedback.".tr,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                const SizedBox(height: 35),
                Row(
                  children: [
                    SizedBox(
                      width: 165,
                      child: GestureDetector(
                        onTap: () async {
                          print("Something pressed");

                          if (Platform.isAndroid) {
                            AndroidDeviceInfo deviceInfo = await getDeviceInfo() as AndroidDeviceInfo;

                            log("deviceInfo \n  ${deviceInfo} \n ");

                            log("deviceInfo.id = ${deviceInfo.id}");
                          } else {
                            IosDeviceInfo deviceInfo = await getDeviceInfo() as IosDeviceInfo;
                          }

                          launchUrl(
                            Uri.parse(
                              'mailto:expressgfa@gmail.com?subject=Feedback (Restaurant App on Android) &body='
                              'Hi Support team \n Your message :\n',
                            ),
                          );
                        },
                        child: Container(
                          height: 40,
                          width: 20,
                          decoration: BoxDecoration(
                            border: Border.all(),
                            color: Colors.white,
                          ),
                          child: Center(
                            child: MyText(
                              text: "SEND FEEDBACK".tr,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
