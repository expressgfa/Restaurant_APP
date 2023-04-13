import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:resturantapp/constant/all_controller.dart';
import 'package:resturantapp/controller/audio_controller/audio_feedback_provider.dart';
import 'package:resturantapp/my_logger.dart';
import 'package:resturantapp/utils/custom_scroll_behavior.dart';
import 'package:resturantapp/utils/helper.dart';
import 'package:resturantapp/utils/shared_pref.dart';
import 'package:resturantapp/views/home/all_order_detail_page.dart';
import 'package:resturantapp/views/widgets/custom_listtile.dart';
import 'package:resturantapp/views/widgets/my_text.dart';
import 'package:simple_timer/simple_timer.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class AllOrderPage extends StatefulWidget {
  const AllOrderPage({Key? key}) : super(key: key);

  @override
  State<AllOrderPage> createState() => _AllOrderPageState();
}

class _AllOrderPageState extends State<AllOrderPage> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<AllOrderPage> {
  final allOrdersScrollController = ScrollController();
  final newOrdersScrollController = ScrollController();

  @override
  void initState() {
    log("ALL TAB INIT STATE");
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      tz.initializeTimeZones();
      var detroit = tz.getLocation('America/Los_Angeles');
      var now = tz.TZDateTime.now(detroit);
      log("Los Angeles timeL ==: $now");
      // log("Los Angeles timeL ==: ${tz.timeZoneDatabase.locations}");

      allOrdersScrollController.addListener(() {
        if (allOrdersScrollController.position.maxScrollExtent == allOrdersScrollController.offset) {
          apiController.getPaginatedOrderData();
        }
      });

      if (apiController.ordersList.isEmpty) {
        apiController.getPaginatedOrderData(enforceOffset: true);
      }
      apiController.getNewOrderData();
      //ch
      // apiController.getOrderViewData(widget.orderId);

      apiController.allOrdersTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        String email = LocalSharedPrefDatabase.getUserEmail() ?? "";
        if (email.isNotEmpty) {
          apiController.getUpdatedInitialOrderData();
          apiController.getUpdatedInitialNewOrderData();
        } else {
          verboseLog("cancelling inProgressTimer timer");
          timer.cancel();
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    if (apiController.allOrdersTimer.isActive) apiController.allOrdersTimer.cancel();
    log("dispose called on all orders page");
    super.dispose();
  }

  String activeOrderId = "";
  int counterWhenWeWentIn = 0;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ScrollConfiguration(
      behavior: MyCustomScrollBehavior(),
      child: ListView(
        shrinkWrap: true,
        controller: allOrdersScrollController,
        children: [
          // const SizedBox(height: 10),
          Obx(() {
            // log("apiController.newOrderList.length: ${apiController.newOrdersList.length}");
            if (apiController.newOrdersList.isNotEmpty) {
              log("inside if apiController.newOrderList.isNotEmpty inside...");
              return ListView.builder(
                itemCount: apiController.newOrdersList.length,
                controller: newOrdersScrollController,
                reverse: true,
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  // newOrdersScrollController.animateTo(apiController.newOrdersList.length -1, duration: const Duration(milliseconds: 300), curve: Curves.linear);
                  Duration timeDifference = const Duration(seconds: 1);
                  // declaration
                  TimerController timerController;
                  // instantiation
                  timerController = TimerController(this);

                  log("-------------------------------");
                  log("apiController.newOrderList[index].orderId: ${apiController.newOrdersList[index].value.orderId}");
                  log("-------------------------------");

                  log("Index Count $index");
                  var detroit = tz.getLocation('America/Los_Angeles');
                  var now = tz.TZDateTime.now(detroit);

                  // log("iso8601String date: ${now.toIso8601String().split(".")[0]}");
                  log("iso8601String date: ${"${now.toIso8601String().split(".")[0]}.000"}");
                  // log("iso8601String ----  date: ${DateTime.tryParse("${now.toIso8601String().split(".")[0]}.000")}");
                  timeDifference = DateTime.parse("${now.toIso8601String().split(".")[0]}.000")
                      .difference(apiController.newOrdersList[index].value.dateCreated ?? DateTime.now());

                  log("timeDifference: ${timeDifference.inSeconds}");
                  log("apiController.newOrderList[index].dateCreated: ${apiController.newOrdersList[index].value.dateCreated}");
                  // log("DateTime.now(): $now");
                  // log("(180 - timeDifference.inSeconds): ${(180 - timeDifference.inSeconds).isNegative}");

                  // Timer? outerTimer;
                  // Timer? internalTimer;
                  int counter = 90 - timeDifference.inSeconds;

                  int secs = 180 - timeDifference.inSeconds;
                  // int ranFor = 0;

                  if (!apiController.secsOfAnOrderMap.containsKey(apiController.newOrdersList[index].value.orderId)) {
                    apiController.secsOfAnOrderMap.putIfAbsent(apiController.newOrdersList[index].value.orderId ?? "", () => secs);
                    wtfLog("secs came out to be --------------- : $secs");
                  }
                  wtfLog("secs came out to be apiController.secsOfAnOrderMap--------------- : ${apiController.secsOfAnOrderMap}");


                  if (timeDifference.inSeconds > 180 && apiController.newOrdersList[index].value.status == "new") {
                    log("in if of not to start a timer");
                    apiController.newOrdersList[index].value.seconds = 180;
                    apiController.missOrder(apiController.newOrdersList[index].value.orderId ?? "", index);
                  }
                  /* */
                  // else {
                  //   log("counterL $counter");
                  //   if (counter > 60) {
                  //     outerTimer = Timer.periodic(const Duration(seconds: 7), (timer) {
                  //       if (apiController.newOrdersList.isNotEmpty) {
                  //         log("upper timer IF called orderId: ${apiController.newOrdersList[index].orderId}");
                  //         log("upper timer IF called apiController.isAnsweredList[index]"
                  //             "${apiController.isAnsweredMap[apiController.newOrdersList[index].orderId ?? ""]} "
                  //             "-- ${apiController.isOnSecondPage}");
                  //         log("apiController.isAnsweredMap.containsKey(apiController.newOrdersList[index].orderId ?? ) :"
                  //             " ${apiController.isAnsweredMap.containsKey(apiController.newOrdersList[index].orderId ?? "")}");
                  //
                  //         log("isAnsweredMap in upper timer: ${apiController.isAnsweredMap}");
                  //
                  //         bool checkableIsAnsweredOuter = apiController.isAnsweredMap
                  //                 .containsKey(apiController.newOrdersList[index].orderId ?? "")
                  //             ? apiController.isAnsweredMap[apiController.newOrdersList[index].orderId ?? ""] ?? true
                  //             : true;
                  //
                  //         if (!checkableIsAnsweredOuter && !apiController.isOnSecondPage) {
                  //           AudioFeedback.playSuccessSound();
                  //         } else {
                  //           log("ELSE outer timer called and inner timer got cancelled");
                  //           if (checkableIsAnsweredOuter) {
                  //             timer.cancel();
                  //           }
                  //         }
                  //         counter -= 7;
                  //         log("updated timer counter: $counter");
                  //         if (counter <= 65) {
                  //           log("inside internal timer if means counter<=60");
                  //           timer.cancel();
                  //           internalTimer = Timer.periodic(const Duration(seconds: 3), (internalTimer) {
                  //             if (apiController.newOrdersList.isNotEmpty) {
                  //               log("inner timer IF called orderId: ${apiController.newOrdersList[index].orderId}");
                  //               log("inner timer IF called apiController.isAnsweredList[index]: "
                  //                   "${apiController.isAnsweredMap[apiController.newOrdersList[index].orderId ?? ""]} "
                  //                   "-- apiController.isOnSecondPage: ${apiController.isOnSecondPage}");
                  //
                  //               log("apiController.isAnsweredMap.containsKey(apiController.newOrdersList[index].orderId ?? ) :"
                  //                   " ${apiController.isAnsweredMap.containsKey(apiController.newOrdersList[index].orderId ?? "")}");
                  //               log("isAnsweredMap in internal timer: ${apiController.isAnsweredMap}");
                  //
                  //               bool checkableIsAnsweredInternalUpper = apiController.isAnsweredMap
                  //                       .containsKey(apiController.newOrdersList[index].orderId ?? "")
                  //                   ? apiController.isAnsweredMap[apiController.newOrdersList[index].orderId ?? ""] ??
                  //                       true
                  //                   : true;
                  //               if (!checkableIsAnsweredInternalUpper && !apiController.isOnSecondPage) {
                  //                 AudioFeedback.playSuccessSound();
                  //               } else {
                  //                 log("ELSE inner timer called and inner timer got cancelled");
                  //                 if (checkableIsAnsweredInternalUpper) {
                  //                   internalTimer.cancel();
                  //                 }
                  //               }
                  //               counter -= 3;
                  //               if (counter < 3) {
                  //                 log("canceling internal timer");
                  //                 internalTimer.cancel();
                  //               }
                  //             }
                  //           });
                  //           log("canceling upper timer");
                  //         }
                  //       }
                  //     });
                  //   } else {
                  //     internalTimer = Timer.periodic(const Duration(seconds: 3), (internalTimer) {
                  //       if (apiController.newOrdersList.isNotEmpty) {
                  //         log("inner timer ELSE called orderId: ${apiController.newOrdersList[index].orderId}");
                  //         log("inner timer ELSE called apiController.isAnsweredList[index]: "
                  //             "${apiController.isAnsweredMap[apiController.newOrdersList[index].orderId ?? ""]} "
                  //             "-- apiController.isOnSecondPage: ${apiController.isOnSecondPage}");
                  //         log("apiController.isAnsweredMap.containsKey(apiController.newOrdersList[index].orderId ?? "
                  //             ") :"
                  //             " ${apiController.isAnsweredMap.containsKey(apiController.newOrdersList[index].orderId ?? "")}");
                  //
                  //         log("isAnsweredMap in ELSE internal timer: ${apiController.isAnsweredMap}");
                  //
                  //         bool checkableIsAnsweredInternal = apiController.isAnsweredMap
                  //                 .containsKey(apiController.newOrdersList[index].orderId ?? "")
                  //             ? apiController.isAnsweredMap[apiController.newOrdersList[index].orderId ?? ""] ?? true
                  //             : true;
                  //         if (!checkableIsAnsweredInternal && !apiController.isOnSecondPage) {
                  //           AudioFeedback.playSuccessSound();
                  //         } else {
                  //           log("ELSE ELSE inner timer called and inner timer got cancelled");
                  //           if (checkableIsAnsweredInternal) {
                  //             internalTimer.cancel();
                  //           }
                  //         }
                  //         counter -= 3;
                  //         if (counter < 1) {
                  //           log("canceling internal timer");
                  //           internalTimer.cancel();
                  //         }
                  //       }
                  //     });
                  //   }
                  // }
                  /* */
                  else {
                    warningLog("apiController.newOrdersList[index].value.status at index : $index "
                        "and orderId : ${apiController.newOrdersList[index].value.orderId} : "
                        "${apiController.newOrdersList[index].value.status} and secs: $secs");
                    if (apiController.newOrdersList[index].value.status == "new") {
                      try {
                        Future.delayed(const Duration(seconds: 1), () {
                          try {
                            timerController.start(
                              startFrom: Duration(
                                seconds: secs,
                              ),
                            );
                          } catch (e) {
                            log("error in timerController start $e");
                          }
                        });
                      } catch (e) {
                        log("error in timerController start $e");
                      }
                    }
                  }
                  return Visibility(
                    visible: apiController.newOrdersList[index].value.status != "missed" &&
                        apiController.newOrdersList[index].value.status != "accept" &&
                        apiController.newOrdersList[index].value.status != "delivered" &&
                        apiController.newOrdersList[index].value.status != "cancel" &&
                        apiController.newOrdersList[index].value.status != "ready" &&
                        apiController.newOrdersList[index].value.status != "cancelled",
                    child: GestureDetector(
                      onTap: () {
                        // if ((internalTimer?.isActive ?? false)) internalTimer!.cancel();
                        // if ((outerTimer?.isActive) ?? false) outerTimer!.cancel();
                        activeOrderId = apiController.newOrdersList[index].value.orderId ?? "232";
                        counterWhenWeWentIn = counter;
                        // apiController.isOnSecondPage = true;
                        Get.to(() => AllOrderDetailsPage(orderId: apiController.newOrdersList[index].value.orderId ?? "232", index: index));
                        // log("isAnswered: $isAnswered");
                        // if (!isAnswered) {
                        //   if (counter > 60) {
                        //     outerTimer = Timer.periodic(const Duration(seconds: 7), (timer) {
                        //       log("upper timer called");
                        //       AudioFeedback.playSuccessSound();
                        //       counter -= 7;
                        //       log("updated timer counter: $counter");
                        //       if (counter <= 65) {
                        //         log("inside internal timer if means counter<=60");
                        //         timer.cancel();
                        //         internalTimer = Timer.periodic(const Duration(seconds: 3), (internalTimer) {
                        //           log("inner timer called");
                        //           AudioFeedback.playSuccessSound();
                        //           counter -= 3;
                        //           if (counter < 3) {
                        //             log("canceling internal timer");
                        //             internalTimer.cancel();
                        //           }
                        //         });
                        //         log("canceling upper timer");
                        //       }
                        //     });
                        //   } else {
                        //     internalTimer = Timer.periodic(const Duration(seconds: 3), (internalTimer) {
                        //       log("inner timer called");
                        //       AudioFeedback.playSuccessSound();
                        //       counter -= 3;
                        //       if (counter < 1) {
                        //         log("canceling internal timer");
                        //         internalTimer.cancel();
                        //       }
                        //     });
                        //   }
                        // } else {
                        //   if ((internalTimer?.isActive ?? false)) internalTimer!.cancel();
                        //   if ((outerTimer?.isActive) ?? false) outerTimer!.cancel();
                        // }
                      },
                      child: Column(
                        children: [
                          Obx(() {
                            return CustomListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey[100],
                                child: Icon(
                                  Icons.shopping_bag,
                                  color: Colors.grey[800],
                                ),
                              ),
                              title: Obx(() {
                                return MyText(
                                  text: "${apiController.newOrdersList[index].value.customerName}",
                                  // "${apiController.newOrdersList[index].value.orderId ?? ""}",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                );
                              }),
                              subtitle: Row(
                                children: [
                                  Icon(
                                    getIcon(apiController.newOrdersList[index].value.status ?? ""),
                                    size: 18,
                                    color: getColour(apiController.newOrdersList[index].value.status ?? ""),
                                  ),
                                  const SizedBox(width: 5),
                                  Obx(() {
                                    log("apiController.newOrdersList[index].value.status: ${apiController.newOrdersList[index].value.status}");
                                    return MyText(
                                      text: getStatus(apiController.newOrdersList[index].value.status ?? "").tr,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: getColour(apiController.newOrdersList[index].value.status ?? ""),
                                    );
                                  }),
                                ],
                              ),
                              trailing: timeDifference.inSeconds > 180
                                  ? MyText(
                                text: "\$ ${apiController.newOrdersList[index].value.totalCost}",
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              )
                                  : Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 33,
                                      width: 45,
                                      child: SimpleTimer(
                                        key: Key(index.toString()),
                                        controller: timerController,
                                        strokeWidth: 0,
                                        displayProgressIndicator: false,
                                        progressTextStyle: const TextStyle(color: Colors.red),
                                        // status: TimerStatus.start,
                                        // valueListener: (timeElapsed) {
                                        //   if (apiController.newOrdersList.isNotEmpty && (apiController.newOrdersList.length - 1) <= index) {
                                        //     if (!(apiController.timerValMapExtended[apiController.newOrdersList[index].value.orderId]
                                        //             ?.containsKey(timeElapsed.inSeconds.toString()) ??
                                        //         false)) {
                                        //       wtfLog("index: $index : timeElapsed.inSeconds: : ${timeElapsed.inSeconds} ");
                                        //       apiController.timerValMapExtended.update(apiController.newOrdersList[index].value.orderId ?? "", (value) {
                                        //         value.putIfAbsent(timeElapsed.inSeconds.toString(), () => false);
                                        //         log("added new value");
                                        //         return value;
                                        //       }, ifAbsent: () => {"0": true});
                                        //       log("timeElapsed.inSeconds.toString(): ${timeElapsed.inSeconds.toString()}");
                                        //       log("apiController.timerValMapExtended[apiController.newOrdersList[index].value.orderId] "
                                        //           "${apiController.timerValMapExtended[apiController.newOrdersList[index].value.orderId]}");
                                        //       log("checking bool value in timerValMapExtended: "
                                        //           "${apiController.timerValMapExtended[apiController.newOrdersList[index].value.orderId]?.containsKey(timeElapsed.inSeconds.toString())}");
                                        //       log("timerValMapExtended: "
                                        //           "${apiController.timerValMapExtended}");
                                        //       int ranFor = (apiController.secsOfAnOrderMap[apiController.newOrdersList[index].value.orderId ?? "281"] ?? 180) -
                                        //           timeElapsed.inSeconds;
                                        //       if (apiController.ranForMap.containsKey(apiController.newOrdersList[index].value.orderId ?? "281")) {
                                        //         apiController.ranForMap.update(apiController.newOrdersList[index].value.orderId ?? "281", (value) => ranFor);
                                        //       } else {
                                        //         apiController.ranForMap.putIfAbsent(apiController.newOrdersList[index].value.orderId ?? "281", () => ranFor);
                                        //       }
                                        //       if (ranFor >= 60) {
                                        //         apiController.newOrdersList[index].value.seconds = timeElapsed.inSeconds;
                                        //         if (timeElapsed.inSeconds % 7 == 0) {
                                        //           debugLog("ranFor: at index: $index with secs: $secs"
                                        //               " (apiController.secsOfAnOrderMap[apiController.newOrdersList[index].value.orderId ?? \"281\"] ?? 180) : "
                                        //               "${(apiController.secsOfAnOrderMap[apiController.newOrdersList[index].value.orderId ?? "281"] ?? 180)}"
                                        //               " ------------------------------------ ranFor: $ranFor");
                                        //           bool checkableIsAnsweredOuter =
                                        //               apiController.isAnsweredMap.containsKey(apiController.newOrdersList[index].value.orderId ?? "")
                                        //                   ? apiController.isAnsweredMap[apiController.newOrdersList[index].value.orderId ?? ""] ?? true
                                        //                   : true;
                                        //
                                        //           if (!checkableIsAnsweredOuter) {
                                        //             log("MULTIPLE OF 7 and timeElapsed.inSeconds: ${timeElapsed.inSeconds} at index: $index "
                                        //                 "orderId: ${apiController.newOrdersList[index].value.orderId}");
                                        //             apiController.timerValMap.putIfAbsent(timeElapsed.inSeconds.toString(), () => false);
                                        //             // apiController.timerValMapExtended.update(apiController.newOrdersList[index].value.orderId ?? "", (value) {
                                        //             //   value.putIfAbsent(timeElapsed.inSeconds.toString(), () => false);
                                        //             //   log("added new value");
                                        //             //   return value;
                                        //             // }, ifAbsent: () => {"0": true});
                                        //             AudioFeedback.playSuccessSound();
                                        //             log("playing sound now");
                                        //           } else {
                                        //             log("in main timer check 7 else means one of the vars was true.");
                                        //             log("checkableIsAnsweredOuter: $checkableIsAnsweredOuter");
                                        //             log("apiController.isOnSecondPage: ${apiController.isOnSecondPage}");
                                        //             log("apiController.isAnsweredMap: ${apiController.isAnsweredMap}");
                                        //           }
                                        //         }
                                        //       } else {
                                        //         try {
                                        //           apiController.newOrdersList[index].value.seconds = timeElapsed.inSeconds;
                                        //         } catch (e) {
                                        //           log("index outbound error: $e");
                                        //         }
                                        //         if (timeElapsed.inSeconds % 3 == 0) {
                                        //           debugLog("ranFor: at index: $index with secs: $secs"
                                        //               " (apiController.secsOfAnOrderMap[apiController.newOrdersList[index].value.orderId ?? \"281\"] ?? 180) : "
                                        //               "${(apiController.secsOfAnOrderMap[apiController.newOrdersList[index].value.orderId ?? "281"] ?? 180)}"
                                        //               " ------------------------------------ ranFor: $ranFor");
                                        //           bool checkableIsAnsweredThree =
                                        //               apiController.isAnsweredMap.containsKey(apiController.newOrdersList[index].value.orderId ?? "")
                                        //                   ? apiController.isAnsweredMap[apiController.newOrdersList[index].value.orderId ?? ""] ?? true
                                        //                   : true;
                                        //
                                        //           if (!checkableIsAnsweredThree) {
                                        //             log("MULTIPLE OF 3 and timeElapsed.inSeconds: ${timeElapsed.inSeconds} at index: $index "
                                        //                 "orderId: ${apiController.newOrdersList[index].value.orderId}");
                                        //             apiController.timerValMap.putIfAbsent(timeElapsed.inSeconds.toString(), () => false);
                                        //             apiController.timerValMapExtended.update(apiController.newOrdersList[index].value.orderId ?? "", (value) {
                                        //               value.putIfAbsent(timeElapsed.inSeconds.toString(), () => false);
                                        //               log("added new value");
                                        //               return value;
                                        //             }, ifAbsent: () => {"0": true});
                                        //             log("playing sound now");
                                        //             if (ranFor >= 3) {
                                        //               AudioFeedback.playSuccessSound();
                                        //             }
                                        //           } else {
                                        //             log("in main timer check 3 else means one of the vars was true.");
                                        //             log("checkableIsAnsweredThree: $checkableIsAnsweredThree");
                                        //             log("apiController.isOnSecondPage: ${apiController.isOnSecondPage}");
                                        //             log("apiController.isAnsweredMap: ${apiController.isAnsweredMap}");
                                        //           }
                                        //         }
                                        //       }
                                        //     }
                                        //   }
                                        // },
                                        duration: Duration(seconds: secs),
                                        // duration: Duration(
                                        //   seconds: (180 - timeDifference.inSeconds).isNegative
                                        //       ? 0
                                        //       : (90 - timeDifference.inSeconds),
                                        // ),
                                        // onEnd: () async {
                                        //   apiController.isAnsweredList[index] = true;
                                        //   if (apiController.newOrdersList.isNotEmpty && (apiController.newOrdersList.length - 1) <= index) {
                                        //     bool checkableIsAnsweredFour =
                                        //         apiController.isAnsweredMap.containsKey(apiController.newOrdersList[index].value.orderId ?? "")
                                        //             ? apiController.isAnsweredMap[apiController.newOrdersList[index].value.orderId ?? ""] ?? false
                                        //             : false;
                                        //     log('MISSING ORDER AND :');
                                        //     log('MISSING ORDER AND :');
                                        //     log('apiController.newOrdersList[index].orderId: ${apiController.isAnsweredMap}');
                                        //     log('apiController.isAnsweredMap[apiController.newOrdersList[index].value.orderId ?? ""]: '
                                        //         '${apiController.isAnsweredMap[apiController.newOrdersList[index].value.orderId ?? ""]}');
                                        //     log('apiController.isAnsweredMap.containsKey(apiController.newOrdersList[index].value.orderId ?? ""): '
                                        //         '${apiController.isAnsweredMap.containsKey(apiController.newOrdersList[index].value.orderId ?? "")}');
                                        //     log('apiController.newOrdersList[index].orderId: ${apiController.newOrdersList[index].value.orderId}');
                                        //     log('apiController.newOrdersList[index].seconds: ${apiController.newOrdersList[index].value.seconds}');
                                        //     log('timeDifference.inSeconds: ${timeDifference.inSeconds}');
                                        //     log('checkableIsAnsweredFour: $checkableIsAnsweredFour');
                                        //     verboseLog('timeDifference.inSeconds + apiController.newOrdersList[index].value.seconds: '
                                        //         '${timeDifference.inSeconds + apiController.newOrdersList[index].value.seconds}');
                                        //     // (apiController.newOrdersList[index].value.seconds == 180 ||
                                        //     //         (timeDifference.inSeconds + apiController.newOrdersList[index].value.seconds) == 180) &&
                                        //     int ranForEnd = apiController.ranForMap[apiController.newOrdersList[index].value.orderId] ?? 0;
                                        //     infoLog("ranFor in onEND before missOrder is: missOrder "
                                        //         "apiController.ranForMap[ apiController.newOrdersList[index].value.orderId]: "
                                        //         "------------------ ------ : ${apiController.ranForMap[apiController.newOrdersList[index].value.orderId]}");
                                        //     infoLog("ranFor in onEND before missOrder is: missOrder: ------------------ ------ : $ranForEnd");
                                        //     if (!checkableIsAnsweredFour && ranForEnd <= 3) {
                                        //       apiController.newOrdersList[index].value.seconds = 180;
                                        //       await apiController.missOrder(apiController.newOrdersList[index].value.orderId ?? "", index);
                                        //     }
                                        //   }
                                        // },
                                      ),
                                    ),
                                    const Icon(
                                      Icons.access_alarm,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                              trailingTopPadding: 5,
                            );
                          }),
                          index == 0 ? const SizedBox() : const Divider(),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              return const SizedBox();
            }
          }),
          /* */
          Obx(() {
            return Visibility(
              visible: apiController.newOrdersList.isNotEmpty,
              child: const SizedBox(height: 10,),
            );
          }),
          /* */
          Obx(() {
            return Visibility(
              visible: apiController.newOrdersList.isNotEmpty,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.1)),
                child: MyText(
                  text: "Others".tr,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }),
          /*! MAIN ALL PART !*/
          Obx(() {
            if (apiController.ordersList.isNotEmpty) {
              return ListView.separated(
                // controller: allOrdersScrollController,
                itemCount: apiController.ordersList.length + 1,
                shrinkWrap: true,
                // reverse: true,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  // log("Index Count $index");
                  if (index < apiController.ordersList.length) {
                    return GestureDetector(
                      onTap: () {
                        Get.to(
                              () => AllOrderDetailsPage(orderId: apiController.ordersList[index].orderId ?? "232", index: index),
                        );
                      },
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey[100],
                          child: Icon(
                            Icons.shopping_bag,
                            color: Colors.grey[800],
                          ),
                        ),
                        title: MyText(
                          text: apiController.ordersList[index].customerName,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        subtitle: Row(
                          children: [
                            Icon(
                              getIcon(apiController.ordersList[index].status ?? ""),
                              size: 18,
                              color: getColour(apiController.ordersList[index].status ?? ""),
                            ),
                            const SizedBox(width: 5),
                            MyText(
                              text: getStatus(apiController.ordersList[index].status).tr,
                              //.replaceAll("_", " ")
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: getColour(apiController.ordersList[index].status ?? ""),
                            ),
                          ],
                        ),
                        trailing: MyText(
                          text: "\$ ${apiController.ordersList[index].totalCost}",
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          decoration: apiController.ordersList[index].status == "cancel" ||
                              apiController.ordersList[index].status == "cancelled" ||
                              apiController.ordersList[index].status == "missed"
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    );
                  } else {
                    if (apiController.ordersList.length < 10) {
                      return const SizedBox();
                    } else {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: Center(child: SizedBox(width: 30, height: 30, child: CircularProgressIndicator())),
                      );
                    }
                  }
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider();
                },
              );
            } else {
              return Obx(() {
                infoLog("All order page ${apiController.isLoadingAccepted.value}");

                if (!apiController.isLoadingAccepted.value) {
                  // infoLog("All order page ${apiController.isLoadingAccepted.value}");
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(child: Text("No more data to show".tr)),
                  );
                }
                // warningLog("out of else wala if");
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(child: SizedBox(width: 30, height: 30, child: CircularProgressIndicator())),
                );
              });
            }
          }),
        ],
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
