import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resturantapp/constant/all_controller.dart';
import 'package:resturantapp/constant/color.dart';
import 'package:resturantapp/my_logger.dart';
import 'package:resturantapp/utils/shared_pref.dart';
import 'package:resturantapp/views/home/all_order_page.dart';
import 'package:resturantapp/views/home/in_progress_page.dart';
import 'package:resturantapp/views/home/ready_order_page.dart';
import 'package:resturantapp/views/internet_tutorial/improve_tutorial.dart';
import 'package:resturantapp/views/widgets/my_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int currentRestaurantHours = 5;

  Map<String, dynamic> activityMap = {};

  @override
  void initState() {
    authController.tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: MyText(
          text: "Orders".tr,
          fontWeight: FontWeight.w500,
        ),
        bottom: PreferredSize(
          preferredSize: const Size(0, 55),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TabBar(
              unselectedLabelColor: Colors.grey,
              labelColor: Colors.orange,
              indicatorColor: Colors.orange,
              indicatorWeight: 3,
              isScrollable: false,
              controller: authController.tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: [
                Tab(text: "All".tr),
                Tab(text: "In Progress".tr),
                Tab(text: "Ready".tr),
              ],
            ),
          ),
        ),
        actions: [
          //+ ACTIVITY STATUS SHEET
          //+ ACTIVITY STATUS SHEET
          //+ ACTIVITY STATUS SHEET
          GestureDetector(
            onTap: () {
              log("Pressed");

              DateTime currentDateTime = DateTime.now();
              String currentDateOnly = currentDateTime.toString().split(" ")[0];

              String? activityMapEncodedString = LocalSharedPrefDatabase.getActivity();
              activityMap = activityMapEncodedString != null ? jsonDecode(activityMapEncodedString) : {};
              authController.spentSecs.value = activityMap.containsKey(currentDateOnly)
                  ? (currentDateTime.difference(DateTime.parse(activityMap[currentDateOnly]["startedAt"])).inSeconds)
                  : 0;

              // activityMap.update(
              //   currentDateOnly,
              //       (value) => {
              //     "secs": value['secs'] + currentDateTime.difference(DateTime.parse(value["startedAt"])).inSeconds,
              //     "startedAt": currentDateTime.toString(),
              //   },
              //   ifAbsent: () => {
              //     "secs": 0,
              //     "startedAt": currentDateTime.toString(),
              //   },
              // );
              debugLog("activityMap in initstate after update in app pause is: $activityMap");
              String encodedActivityMap = jsonEncode(activityMap);
              LocalSharedPrefDatabase.setActivity(encodedActivityMap);

              DateTime yesterdayDate = currentDateTime.subtract(const Duration(days: 1));
              String yesterdayDateOnly = yesterdayDate.toString().split(" ")[0];

              log("yesterdayDateOnly : $yesterdayDateOnly");

              double yesterdayPercentage = activityMap.containsKey(yesterdayDateOnly)
                  ? ((activityMap[yesterdayDateOnly]["secs"]) / Duration(hours: currentRestaurantHours).inSeconds) * 100
                  : 0;
              // int currentSecs = activityMap.containsKey(currentDateOnly) ? (activityMap[currentDateOnly]["secs"]) : 0;
              log("authController.spentSecs.value: ${authController.spentSecs.value}");
              num searchableDaySecs = 0;
              for (int i = 0; i < 7; i++) {
                DateTime searchableDateTime = currentDateTime.subtract(const Duration(days: 1));
                String searchableDateOnly = searchableDateTime.toString().split(" ")[0];
                searchableDaySecs += activityMap.containsKey(searchableDateOnly) ? (activityMap[searchableDateOnly]["secs"]) : 0;
              }
              double sevenDayPercentage = (searchableDaySecs / (Duration(hours: (currentRestaurantHours * 7))).inSeconds) * 100;
              Get.bottomSheet(
                StatefulBuilder(
                  builder: (context, setState) {
                    return SingleChildScrollView(
                      child: Container(
                        // height: (Get.height / 2) - 200,
                        width: double.maxFinite,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 30),
                              MyText(
                                text: "CONNECTIVITY STATUS".tr,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: kGreyColor,
                              ),
                              const SizedBox(height: 30),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Get.back();
                                      },
                                      child: MyText(
                                        text: "Last successful connection".tr,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Get.back();
                                      },
                                      child: MyText(
                                        text: networkController.isConnected.value ? "${authController.spentSecs.value}s ago" : "N/A",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(),
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () {},
                                      child: MyText(
                                        text: "Yesterday".tr,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Get.back();
                                      },
                                      child: MyText(
                                        text: "${yesterdayPercentage.toStringAsFixed(1)} %",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () {},
                                      child: MyText(
                                        text: "Last 7 days".tr,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Get.back();
                                      },
                                      child: MyText(
                                        text: "${sevenDayPercentage.toStringAsFixed(1)} %",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              GestureDetector(
                                onTap: () {
                                  Get.back();
                                  Get.to(() => const ImproveTutorial());
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.arrow_forward,
                                        color: Colors.black,
                                        size: 15,
                                      ),
                                      const SizedBox(width: 5),
                                      SizedBox(
                                        width: Get.width / 1.2,
                                        child: MyText(
                                          text: "Improve".tr,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            child: Obx(() {
              return Container(
                height: 20,
                width: 30,
                color: Colors.white,
                child: Container(
                  height: 8,
                  width: 8,
                  margin: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: networkController.isConnected.value ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(width: 20),
          GestureDetector(
            onTap: () {
              Get.bottomSheet(
                StatefulBuilder(
                  builder: (context, setState) {
                    return SingleChildScrollView(
                      child: Container(
                        // height: (Get.height / 2) - 200,
                        width: double.maxFinite,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 30),
                              MyText(
                                text: "Options".tr,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: kGreyColor,
                              ),
                              const SizedBox(height: 20),
                              //+ implement Create Test Order
                              GestureDetector(
                                onTap: !apiController.isCreatingTestOrderDisabled.value
                                    ? () async {
                                        await apiController.createTestOrder();
                                        Get.closeAllSnackbars();
                                        Get.back();
                                      }
                                    : () {},
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        child: Obx(() {
                                          return MyText(
                                            text: "Create test order".tr,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: apiController.isCreatingTestOrderDisabled.value ? Colors.grey[300] : Colors.black,
                                          );
                                        }),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // const SizedBox(height: 30),
                              // GET SITE INFO TESTING
                              // GestureDetector(
                              //   onTap: () {
                              //     apiController.getSiteInfo();
                              //   },
                              //   child: Row(
                              //     children: [
                              //       Expanded(
                              //         child: MyText(
                              //           text: "Get Site Info".tr,
                              //           fontSize: 14,
                              //           fontWeight: FontWeight.w400,
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              Visibility(
                                visible: authController.tabController?.index == 0,
                                child: const SizedBox(height: 10),
                              ),
                              Visibility(
                                visible: authController.tabController?.index == 0,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: !apiController.isCreatingTestOrderDisabled.value
                                            ? () {
                                                Get.back();
                                                apiController.clearAllLists();
                                              }
                                            : () {},
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 5),
                                          child: Obx(() {
                                            return MyText(
                                              text: "Clear orders".tr,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: apiController.isCreatingTestOrderDisabled.value ? Colors.grey[300] : Colors.black,
                                            );
                                          }),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            child: const Icon(
              Icons.more_vert,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: TabBarView(
        physics: const BouncingScrollPhysics(),
        controller: authController.tabController,
        children: const [
          AllOrderPage(),
          ProgressOrderPage(),
          ReadyOrderPage(),
        ],
      ),
    );
  }
}
