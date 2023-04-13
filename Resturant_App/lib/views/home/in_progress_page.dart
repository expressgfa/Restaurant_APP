import 'dart:async';
import 'dart:developer';

import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:resturantapp/constant/all_controller.dart';
import 'package:resturantapp/generated/assets.dart';
import 'package:resturantapp/my_logger.dart';
import 'package:resturantapp/utils/custom_scroll_behavior.dart';
import 'package:resturantapp/utils/helper.dart';
import 'package:resturantapp/utils/shared_pref.dart';
import 'package:resturantapp/utils/snack_bar.dart';
import 'package:resturantapp/views/home/all_order_detail_page.dart';
import 'package:resturantapp/views/widgets/custom_listtile.dart';
import 'package:resturantapp/views/widgets/my_text.dart';
import 'package:simple_timer/simple_timer.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ProgressOrderPage extends StatefulWidget {
  const ProgressOrderPage({Key? key}) : super(key: key);

  @override
  State<ProgressOrderPage> createState() => _ProgressOrderPageState();
}

class _ProgressOrderPageState extends State<ProgressOrderPage> {
  final inProgressOrdersScrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    log("initstate called again ....");

    inProgressOrdersScrollController.addListener(() {
      if (inProgressOrdersScrollController.position.maxScrollExtent == inProgressOrdersScrollController.offset) {
        apiController.getPaginatedInProgressOrderData();
      }
    });
    debugLog("apiController.acceptedOrderList.isEmpty: ${apiController.inProgressOrderList}");

    if (apiController.inProgressOrderList.isEmpty) {
      // errorLog("apiController.acceptedOrderList.isEmpty: ${apiController.acceptedOrderList}");
      apiController.getPaginatedInProgressOrderData();
    }

    apiController.inProgressTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      // errorLog("inProgressTimer called");
      String email = LocalSharedPrefDatabase.getUserEmail() ?? "";
      if (email.isNotEmpty) {
        apiController.getUpdatedInitialInProgressOrderData();
      } else {
        verboseLog("cancelling inProgressTimer timer");
        timer.cancel();
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    // if (inProgressTimer.isActive) inProgressTimer.cancel();
    log("dispose called on in progress page");
    super.dispose();
  }

  @override
  Widget build(BuildContext pageContext) {
    return Column(
      children: [
        Expanded(
          child: Obx(
            () {
              if (apiController.inProgressOrderList.isNotEmpty) {
                return ScrollConfiguration(
                  behavior: MyCustomScrollBehavior(),
                  child: ListView.builder(
                    controller: inProgressOrdersScrollController,
                    itemCount:
                        apiController.inProgressOrderList.length < 10 ? apiController.inProgressOrderList.length : apiController.inProgressOrderList.length + 1,
                    // physics: const BouncingScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      // timerController = TimerController(this);
                      // try {
                      //   timerController.start(
                      //     startFrom: Duration(
                      //       seconds: secs,
                      //     ),
                      //   );
                      // } catch (e) {
                      //   log("error in timerController start $e");
                      // }

                      if (index < apiController.inProgressOrderList.length) {
                        // log("Index Count $index");
                        int secs = 0;
                        var detroit = tz.getLocation('America/Los_Angeles');
                        var now = tz.TZDateTime.now(detroit);
                        int minutesPart = int.tryParse((apiController.inProgressOrderList[index].pickupTime ?? "00:00").toString().split(":")[0]) ?? 0;
                        Duration difference = DateTime.parse("${now.toIso8601String().split(".")[0]}.000").difference(
                            DateTime.tryParse(apiController.inProgressOrderList[index].acceptedDateTme ?? "${now.toIso8601String().split(".")[0]}.000") ?? now);
                        // log("difference.inSeconds: ${difference.inSeconds} -----");
                        // log("Duration(minutes: minutesPart).inSeconds: ${Duration(minutes: minutesPart).inSeconds} -----");
                        if (difference.inSeconds < Duration(minutes: minutesPart).inSeconds) {
                          secs = Duration(minutes: minutesPart).inSeconds - difference.inSeconds;
                          // log("secs: $secs -----");
                        }
                        return Slidable(
                          key: ValueKey(apiController.inProgressOrderList[index].orderId),
                          endActionPane: ActionPane(
                            extentRatio: 0.3,
                            motion: const ScrollMotion(),
                            children: [
                              CustomSlidableAction(
                                onPressed: (context) async {
                                  await apiController.updateReadyOrder(apiController.inProgressOrderList[index].orderId ?? "");
                                  /* */
                                  // showDialog(
                                  //   context: context,
                                  //   builder: (_) {
                                  //     return const CircularProgressIndicator();
                                  //   },
                                  // );
                                  // custom pop Up
                                  //   CustomPopup(
                                  //   heading: 'sure'.tr,
                                  //   description: 'deleteChatMessage'.tr,
                                  //   onCancel: () => Get.back(),
                                  //   onConfirm: () async {
                                  //     try {
                                  //       Get.back();
                                  //
                                  //     } catch (e) {
                                  //       print(e);
                                  //         log("error in chat deletion $e");
                                  //     }
                                  //   },
                                  // );
                                },
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.black,
                                autoClose: true,
                                flex: 1,
                                borderRadius: BorderRadius.circular(8),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Container(
                                  height: 90,
                                  width: 100,
                                  margin: const EdgeInsets.only(bottom: 5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.green,
                                  ),
                                  child: Center(
                                    child: MyText(
                                      text: "Ready For Pickup".tr,
                                      color: Colors.white,
                                      align: TextAlign.right,
                                    ),
                                  ),
                                ),
                              ),
                              /* */
                              // Expanded(
                              //   child: Row(
                              //     mainAxisAlignment: MainAxisAlignment.center,
                              //     children: [
                              //       GestureDetector(
                              //         onTap: () async {
                              //           // Get.back();
                              //           // Slidable.of(pageContext)?.close();
                              //           // Slidable.of(pageContext)?.dismiss(ResizeRequest(const Duration(milliseconds: 200), () {}));
                              //           // Slidable.of(context)?.close();
                              //           apiController
                              //               .updateReadyOrder(apiController.acceptedOrderList[index].orderId ?? "");
                              //
                              //           // showDialog(
                              //           //   context: context,
                              //           //   builder: (_) {
                              //           //     return const CircularProgressIndicator();
                              //           //   },
                              //           // );
                              //           // custom pop Up
                              //           //   CustomPopup(
                              //           //   heading: 'sure'.tr,
                              //           //   description: 'deleteChatMessage'.tr,
                              //           //   onCancel: () => Get.back(),
                              //           //   onConfirm: () async {
                              //           //     try {
                              //           //       Get.back();
                              //           //
                              //           //     } catch (e) {
                              //           //       print(e);
                              //           //         log("error in chat deletion $e");
                              //           //     }
                              //           //   },
                              //           // );
                              //         },
                              //         child: Container(
                              //           height: 90,
                              //           width: 80,
                              //           margin: const EdgeInsets.only(bottom: 5),
                              //           decoration: BoxDecoration(
                              //             borderRadius: BorderRadius.circular(8),
                              //             color: Colors.green,
                              //           ),
                              //           child: Center(
                              //             child: MyText(
                              //               text: "Ready",
                              //             ),
                              //           ),
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                            ],
                          ),
                          child: Column(
                            children: [
                              CustomListTile(
                                leading: Container(
                                  // color: Colors.grey,
                                  height: 50,
                                  width: 50,
                                  padding: const EdgeInsets.only(top: 4),
                                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(100)),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        Assets.iconsShoppingBagBlackImageCr,
                                        color: Colors.grey[800],
                                        height: 15,
                                        width: 15,
                                      ),
                                      // Text("00:00"),
                                      SizedBox(
                                        height: 28,
                                        width: 35,
                                        child: SimpleTimer(
                                          key: Key(apiController.inProgressOrderList[index].orderId ?? "orderId"),
                                          strokeWidth: 0,
                                          progressTextStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                          displayProgressIndicator: false,
                                          status: TimerStatus.start,
                                          duration: Duration(seconds: secs),
                                          onEnd: () async {},
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                title: MyText(
                                  text: (apiController.inProgressOrderList[index].customerName ?? ""),
                                  // + (apiController.inProgressOrderList[index].orderId ?? ""),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                                subtitle: Row(
                                  children: [
                                    Icon(
                                      getIcon(apiController.inProgressOrderList[index].status ?? ""),
                                      size: 18,
                                      color: getColour(apiController.inProgressOrderList[index].status ?? ""),
                                    ),
                                    const SizedBox(width: 5),
                                    MyText(
                                      text: getStatus(apiController.inProgressOrderList[index].status).tr,
                                      //?.replaceAll("_", " ")
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: getColour(apiController.inProgressOrderList[index].status ?? ""),
                                    ),
                                  ],
                                ),
                                trailing: MyText(
                                  text: "\$ ${apiController.inProgressOrderList[index].totalCost}",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                                onTap: () {
                                  Get.to(
                                    () => AllOrderDetailsPage(
                                      orderId: apiController.inProgressOrderList[index].orderId ?? "232",
                                      index: index,
                                    ),
                                  );
                                },
                                trailingTopPadding: 15,
                              ),
                              const Divider(),
                            ],
                          ),
                        );
                      } else {
                        return Obx(() {
                          if (!apiController.isLoadingAcceptedInProgress.value) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20.0),
                              child: Center(child: Text("No more data to load".tr)),
                            );
                          }
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.0),
                            child: Center(child: SizedBox(width: 30, height: 30, child: CircularProgressIndicator())),
                          );
                        });
                      }
                    },
                  ),
                );
              }
              return const Center(
                child: Text("No orders to show"),
              );
            },
          ),
          // FutureBuilder(
          //     future: apiController.getAcceptOrderData(),
          //     builder: (BuildContext context, snapshot) {
          //       if (!snapshot.hasData) {
          //         return Container(
          //           margin: const EdgeInsets.all(10),
          //           child: ListView.builder(
          //               itemCount: 15,
          //               itemBuilder: (BuildContext context, int index) {
          //                 return Padding(
          //                   padding: const EdgeInsets.all(3.0),
          //                   child: FadeShimmer(
          //                     height: 70,
          //                     width: MediaQuery.of(context).size.width,
          //                     radius: 4,
          //                     highlightColor: const Color(0xffF9F9FB),
          //                     baseColor: const Color(0xffE6E8EB),
          //                   ),
          //                 );
          //               }),
          //         );
          //       }
          //       return Obx(() {
          //         return ListView.builder(
          //           itemCount: apiController.acceptOrderList.length,
          //           physics: const BouncingScrollPhysics(),
          //           itemBuilder: (BuildContext context, int index) {
          //             log("Index Count $index");
          //             return GestureDetector(
          //               onTap: () {
          //                 Get.to(AllOrderDetailsPage(orderId: apiController.acceptOrderList[index].orderId ?? "232"));
          //               },
          //               child: Slidable(
          //                 endActionPane: ActionPane(
          //                   extentRatio: 0.3,
          //                   motion: const ScrollMotion(),
          //                   children: [
          //                     Expanded(
          //                       child: Row(
          //                         mainAxisAlignment: MainAxisAlignment.center,
          //                         children: [
          //                           GestureDetector(
          //                             onTap: () async {
          //                               apiController.updateReadyOrder(apiController.acceptOrderList[index].orderId ?? "");
          //
          //                               // showDialog(
          //                               //   context: context,
          //                               //   builder: (_) {
          //                               //     return const CircularProgressIndicator();
          //                               //   },
          //                               // );
          //                               // custom pop Up
          //                               //   CustomPopup(
          //                               //   heading: 'sure'.tr,
          //                               //   description: 'deleteChatMessage'.tr,
          //                               //   onCancel: () => Get.back(),
          //                               //   onConfirm: () async {
          //                               //     try {
          //                               //       Get.back();
          //                               //
          //                               //     } catch (e) {
          //                               //       print(e);
          //                               //         log("error in chat deletion $e");
          //                               //     }
          //                               //   },
          //                               // );
          //                             },
          //                             child: Container(
          //                               height: 90,
          //                               width: 80,
          //                               margin: EdgeInsets.only(bottom: 5),
          //                               decoration: BoxDecoration(
          //                                 borderRadius: BorderRadius.circular(8),
          //                                 color: Colors.green,
          //                               ),
          //                               child: Center(
          //                                 child: MyText(
          //                                   text: "Ready",
          //                                 ),
          //                               ),
          //                             ),
          //                           ),
          //                         ],
          //                       ),
          //                     ),
          //                   ],
          //                 ),
          //                 //
          //
          //                 child: Column(
          //                   children: [
          //                     ListTile(
          //                       leading: const CircleAvatar(
          //                         backgroundColor: Colors.grey,
          //                         child: Icon(
          //                           Icons.shopping_bag,
          //                           color: Colors.black54,
          //                         ),
          //                       ),
          //                       title: MyText(
          //                         text: apiController.acceptOrderList[index].customerName,
          //                         fontSize: 14,
          //                         fontWeight: FontWeight.w400,
          //                       ),
          //                       subtitle: Row(
          //                         children: [
          //                           Icon(
          //                             getIcon(apiController.acceptOrderList[index].status ?? ""),
          //                             size: 18,
          //                             color: getColour(apiController.acceptOrderList[index].status ?? ""),
          //                           ),
          //                           const SizedBox(width: 5),
          //                           MyText(
          //                             text: apiController.acceptOrderList[index].status,
          //                             fontSize: 14,
          //                             fontWeight: FontWeight.w400,
          //                             color: getColour(apiController.acceptOrderList[index].status ?? ""),
          //                           ),
          //                         ],
          //                       ),
          //                       trailing: MyText(
          //                         text: "\$ ${apiController.acceptOrderList[index].totalCost}",
          //                         fontSize: 14,
          //                         fontWeight: FontWeight.w400,
          //                       ),
          //                     ),
          //                     const Divider(),
          //                   ],
          //                 ),
          //               ),
          //             );
          //           },
          //         );
          //       });
          //     }),
        ),
      ],
    );
  }
}
