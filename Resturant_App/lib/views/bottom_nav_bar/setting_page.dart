import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resturantapp/constant/all_controller.dart';
import 'package:resturantapp/constant/color.dart';
import 'package:resturantapp/generated/assets.dart';
import 'package:resturantapp/utils/custom_scroll_behavior.dart';
import 'package:resturantapp/views/internet_tutorial/internet_tutorial.dart';
import 'package:resturantapp/views/menu/menu_item_page.dart';
import 'package:resturantapp/views/other/choice_and_addons.dart';
import 'package:resturantapp/views/other/about_page.dart';
import 'package:resturantapp/views/other/help_and_feedback.dart';
import 'package:resturantapp/views/other/language_page.dart';
import 'package:resturantapp/views/other/profile_page.dart';
import 'package:resturantapp/views/other/terms_and_conditions_page.dart';
import 'package:resturantapp/views/print/printer_attach.dart';
import 'package:resturantapp/views/widgets/my_text.dart';
import 'package:resturantapp/views/widgets/simple_appBar.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(title: "Settings".tr),
      // appBar: AppBar(
      //   title: MyText(
      //     text: "Settings",
      //     fontSize: 18,
      //     fontWeight: FontWeight.bold,
      //   ),
      // ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ScrollConfiguration(
              behavior: MyCustomScrollBehavior(),
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 25),
                physics: const ClampingScrollPhysics(),

                children: [
                  const SizedBox(height: 25),
                  MyText(
                    text: "Availability".tr,
                    fontSize: 12,
                    color: kGreyColor2,
                    fontWeight: FontWeight.w500,
                  ),
                  const SizedBox(height: 30),
                  settingTiles(
                    title: "Menu items".tr,
                    image: Assets.iconsShopRBG,
                    onTap: () async {
                      Get.to(() => const MenuItemPage());
                      // // Get.to(() => const TestPage());
                      // Get.to(() => const TestPageTwo());
                      //
                      // // apiController.getData();
                    },
                  ),
                  const SizedBox(height: 10),
                  settingTiles(
                    title: "Choices & addons".tr,
                    image: Assets.iconsShopRBG,
                    onTap: () {
                      Get.to(() => const ChoiceAndAddonsPage());
                    },
                  ),
                  const SizedBox(height: 10),
                  //+2nd
                  MyText(
                    text: "Settings".tr,
                    fontSize: 12,
                    color: kGreyColor2,
                    fontWeight: FontWeight.w500,
                  ),
                  const SizedBox(height: 30),
                  settingTiles(
                    title: "Auto-Print orders".tr,
                    image: Assets.iconsPrinterRBG,
                    onTap: () {
                      //  Get.to(() => const AutoPrintOrders());
                      Get.to(() => PrinterAttach(
                            homeContext: context,
                          ));
                    },
                  ),

                  const SizedBox(height: 10),
                  //+3rd
                  MyText(
                    text: "Account".tr,
                    fontSize: 12,
                    color: kGreyColor2,
                    fontWeight: FontWeight.w500,
                  ),
                  const SizedBox(height: 30),
                  settingTiles(
                    title: "Profile".tr,
                    image: Assets.iconsShopRBG,
                    onTap: () {
                      Get.to(() => const ProfilePage());
                    },
                  ),
                  const SizedBox(height: 10),
                  settingTiles(
                    title: "Language".tr,
                    image: Assets.iconsLanguageRBG,
                    onTap: () {
                      log("On pressed");

                      Get.to(() => const LanguagePage());
                    },
                  ),
                  const SizedBox(height: 10),
                  //+Terms and Conditions
                  settingTiles(
                    title: "Terms and conditions".tr,
                    image: Assets.iconsTermRBG,
                    // height: 22,
                    // width: 22,
                    onTap: () {
                      log("On pressed");
                      Get.to(() => const TermsAndConditions());
                    },
                  ),
                  const SizedBox(height: 10),
                  settingTiles(
                    title: "About".tr,
                    image: Assets.iconsAboutrBG,
                    // height: 24,
                    // width: 24,
                    onTap: () {
                      Get.to(() => const AboutPage());
                    },
                  ),
                  const SizedBox(height: 10),
                  settingTiles(
                    title: "Help & feedback".tr,
                    image: Assets.iconsHelpRBG,
                    // height: 24,
                    // width: 24,
                    onTap: () {
                      log("On pressed");
                      Get.to(() => const HelpAndFeedBackPage());
                    },
                  ),
                  const SizedBox(height: 10),
                  settingTiles(
                    title: "Logout".tr,
                    image: Assets.iconsLogoutRemovedBg,
                    // height: 24,
                    // width: 24,
                    onTap: () {
                      Get.bottomSheet(
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            StatefulBuilder(
                              builder: (context, setState) {
                                return Container(
                                  // height: (Get.height / 2) - 100,
                                  width: double.maxFinite,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 15),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 42),
                                        MyText(
                                          text: "Are you sure?".tr,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(height: 25),
                                        GestureDetector(
                                          onTap: () {
                                            Get.back();
                                            if(networkController.isConnected.value) {
                                              authController.logOutUser();
                                            } else {
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
                                                          Get.to(() => const InternetTutorial());
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
                                                  duration: const Duration(seconds: 3),
                                                  backgroundColor: Colors.black54,
                                                  snackStyle: SnackStyle.GROUNDED,
                                                  margin: const EdgeInsets.all(8),
                                                  padding: const EdgeInsets.all(20),
                                                );
                                              });
                                            }
                                          },
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: MyText(
                                                  text: "Logout".tr,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        GestureDetector(
                                          onTap: () {
                                            Get.back();
                                          },
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: MyText(
                                                  text: "Cancel".tr,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 30),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget settingTiles({String? title, String? image, VoidCallback? onTap, Color? color, double? height, double? width}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      horizontalTitleGap: 10,
      leading: CircleAvatar(
        radius: 18,
        // backgroundColor: kSecondaryColor,
        backgroundColor: kSecondaryColor,
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Image.asset(
            image ?? Assets.imagesLanguageIcon,
            color: color ?? Colors.white,
            fit: BoxFit.cover,
            height: 28,
            width: 28,
          ),
        ),
      ),
      onTap: onTap,
      title: MyText(
        text: title ?? "",
        fontSize: 15,
        // fontWeight: FontWeight.w400,
      ),
    );
  }
}
