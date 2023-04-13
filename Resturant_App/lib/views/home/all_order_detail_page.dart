import 'dart:async';
import 'dart:developer';

import 'package:expandable/expandable.dart';
import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:resturantapp/constant/all_controller.dart';
import 'package:resturantapp/constant/color.dart';
import 'package:resturantapp/data/local_hive_database.dart';
import 'package:resturantapp/model/bluetooth_printer_model.dart';
import 'package:resturantapp/model/order_view_model.dart';
import 'package:resturantapp/my_logger.dart';
import 'package:resturantapp/utils/custom_scroll_behavior.dart';
import 'package:resturantapp/utils/helper.dart';
import 'package:resturantapp/utils/shared_pref.dart';
import 'package:resturantapp/utils/snack_bar.dart';
import 'package:resturantapp/views/widgets/my_button.dart';
import 'package:resturantapp/views/widgets/my_text.dart';
import 'package:resturantapp/views/widgets/my_text_field.dart';
import 'package:resturantapp/views/widgets/simple_appBar.dart';
import 'package:resturantapp/views/widgets/time_text_field.dart';
import 'package:simple_timer/simple_timer.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class AllOrderDetailsPage extends StatefulWidget {
  final String orderId;
  final int index;

  const AllOrderDetailsPage({Key? key, required this.orderId, required this.index}) : super(key: key);

  @override
  State<AllOrderDetailsPage> createState() => _AllOrderDetailsPageState();
}

class _AllOrderDetailsPageState extends State<AllOrderDetailsPage> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<AllOrderDetailsPage> {
  int count = 0;

  String dateFormat = "E dd MMM yy - hh:mma";

  String orderTotal = "--.--";
  bool isLoading = true;
  // bool isAnswered = false;

  // static RxBool isIdPartOpen = true.obs;
  // static RxBool isContactPartOpen = true.obs;

  ExpandableController idPart = ExpandableController(initialExpanded: true);
  ExpandableController contactPart = ExpandableController(initialExpanded: true);

  late TimerController timerController;

  int secs = 0;
  int acceptSecs = 0;
  int secondAcceptSecs = 0;

  @override
  void initState() {
    tz.initializeTimeZones();
    var detroit = tz.getLocation('America/Los_Angeles');
    var now = tz.TZDateTime.now(detroit);
    log("Los Angeles timeL ==: ${now}");
    wtfLog("Get.currentRoute: ${Get.currentRoute}");

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      apiController.getOrderViewData(widget.orderId).then((value) {
        if (value.isNotEmpty) {
          orderTotal = value[0].order.totalCost;
          // orderTotal = value[0].order!["total_cost"] ?? "";
          if (value[0].order.pickupTime != null && value[0].order.pickupTime.isNotEmpty) {
            int minutesPart = int.tryParse(value[0].order.pickupTime.toString().split(":")[0]) ?? 0;
            Duration difference =
                DateTime.parse("${now.toIso8601String().split(".")[0]}.000").difference(DateTime.tryParse(value[0].order.acceptedDateTme) ?? now);

            if (difference.inSeconds < Duration(minutes: minutesPart).inSeconds) {
              secs = Duration(minutes: minutesPart).inSeconds - difference.inSeconds;
            }
            // now.add(Duration(minutes: minutesPart));
          }

          isLoading = false;
          setState(() {
            Duration timeDifference = const Duration(seconds: 0);

            timeDifference = DateTime.parse("${now.toIso8601String().split(".")[0]}.000").difference(
                DateTime.tryParse(apiController.selectedOrderData.value.order.dateCreated) ?? DateTime.parse("${now.toIso8601String().split(".")[0]}.000"));

            log("timeDifference on details page init: ${timeDifference.inSeconds}");
            log("apiController.newOrderList[index].dateCreated: ${apiController.selectedOrderData.value.order.dateCreated}");

            acceptSecs = 180 - timeDifference.inSeconds;
            secondAcceptSecs = acceptSecs;
            apiController.secondPageTimerValMap.clear();
          });
        }
      });
    });

    // instantiation
    timerController = TimerController(this);

    try {
      timerController.start(
        startFrom: Duration(
          seconds: secs,
        ),
      );
    } catch (e) {
      log("error in timerController start $e");
    }

    // idPart.addListener(() {
    //   isIdPartOpen.value = !isIdPartOpen.value;
    // });
    //  contactPart.addListener(() {
    //   isContactPartOpen.value = !isContactPartOpen.value;
    // });
    super.initState();
  }

  RxList<String> nameList = <String>[].obs;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return WillPopScope(
      onWillPop: () async {
        // apiController.isOnSecondPage = false;
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () {
              log("pressed back Icon");
              // Get.back(result: isAnswered);
              // apiController.isOnSecondPage = false;
              Get.closeAllSnackbars();
              Get.back();
            },
            child: const Icon(
              Icons.arrow_back_outlined,
              color: Colors.black,
            ),
          ),
          automaticallyImplyLeading: false,
          centerTitle: false,
          title: Row(
            children: [
              MyText(
                text: "\$$orderTotal",
                fontSize: 19,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
        ),
        // simpleAppBar(title: "\$$orderTotal", haveIcon: true),
        body: isLoading
            ? Center(
                child: fadeShimmerWidget(),
              )
            : orderDetailPart(),
        // Obx(() {
        //   return ListView.builder(
        //     itemCount: apiController.orderViewList.length,
        //     physics: const BouncingScrollPhysics(),
        //     itemBuilder: (BuildContext context, int index) {
        //       return OrderDetailPart();
        //     },
        //   );
        // }),
        /* */
        // FutureBuilder(
        //         future: apiController.getOrderViewData(widget.orderId),
        //         builder: (BuildContext context, snapshot) {
        //           if (!snapshot.hasData) {
        //             return FadeShimmerWidget();
        //           }
        //           // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        //           //   setState(() {
        //           //     orderTotal = apiController.orderViewList[0].order.totalCost;
        //           //   });
        //           // });
        //           return Obx(() {
        //             return ListView.builder(
        //               itemCount: apiController.orderViewList.length,
        //               physics: const BouncingScrollPhysics(),
        //               itemBuilder: (BuildContext context, int index) {
        //                 return OrderDetailPart(index);
        //               },
        //             );
        //           });
        //         }),
        bottomNavigationBar: BottomAppBar(
          child: Container(
            height: 65,
            width: Get.width,
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(2, 2),
                  blurRadius: 5,
                )
              ],
            ),
            child: Visibility(
              visible: !isLoading,
              child: Obx(() {
                if (apiController.selectedOrderData.value.order.status == "new") {
                  //+ Accept Reject Button row
                  return buttonRow();
                } else {
                  //+ Printer and Timer row
                  return printerRow();
                }
              }),
            ),
          ),
        ),
      ),
    );
  }

  Row buttonRow() {
    return Row(
      children: [
        const SizedBox(width: 10),
        //+ Reject Button
        GestureDetector(
          onTap: () {
            Get.bottomSheet(
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StatefulBuilder(
                    builder: (context, setState) {
                      return Container(
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
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () => Get.back(),
                                    child: const Icon(
                                      Icons.arrow_back_outlined,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Divider(),
                              const SizedBox(height: 10),
                              MyText(
                                text: "Contact customer before rejection".tr,
                                fontSize: 14,
                                maxLines: 3,
                                overFlow: TextOverflow.ellipsis,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                                paddingLeft: 10,
                                paddingRight: 10,
                              ),
                              Container(
                                padding: const EdgeInsets.all(10),
                                child: MaterialButton(
                                  color: Colors.orange,
                                  height: 40,
                                  minWidth: Get.width - 10,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  onPressed: () async {
                                    if (apiController.selectedOrderData.value.order.phone.isNotEmpty) {
                                      final Uri uri = Uri.parse(
                                          'tel:${apiController.selectedOrderData.value.order.phone.contains("+1") ? "" : "+1"}${apiController.selectedOrderData.value.order.phone}');
                                      if (!await launchUrl(uri)) {
                                        showMsg(msg: "Could not launch the dialer. Please try again.".tr);
                                      }
                                    }
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.call,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                      MyText(
                                        text:
                                            "${apiController.selectedOrderData.value.order.phone.contains("+1") ? "" : "+1 "} ${apiController.selectedOrderData.value.order.phone}",
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        paddingLeft: 10,
                                        fontSize: 14,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              MyText(
                                text: "Mark as rejected".tr,
                                fontSize: 14,
                                maxLines: 3,
                                overFlow: TextOverflow.ellipsis,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                                paddingLeft: 10,
                                paddingRight: 10,
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(10),
                                child: MaterialButton(
                                  color: Colors.white,
                                  height: 40,
                                  minWidth: Get.width - 10,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  onPressed: () async {
                                    Get.back();
                                    apiController.selectedReason.value = "";
                                    apiController.messageControllerText = "";
                                    apiController.msgController.clear();
                                    Get.bottomSheet(
                                      StatefulBuilder(
                                        builder: (context, setState) {
                                          return WillPopScope(
                                            onWillPop: () async {
                                              apiController.messageControllerText = apiController.msgController.text.trim();
                                              apiController.msgController.clear();
                                              return true;
                                            },
                                            child: Container(
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
                                                child: ScrollConfiguration(
                                                  behavior: MyCustomScrollBehavior(),
                                                  child: SingleChildScrollView(
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        const SizedBox(height: 15),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 2),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              GestureDetector(
                                                                onTap: () {
                                                                  warningLog("Back Button Pressed ");
                                                                  apiController.messageControllerText = apiController.msgController.text.trim();
                                                                  apiController.msgController.clear();
                                                                  Get.back();
                                                                },
                                                                child: const Icon(
                                                                  Icons.arrow_back_outlined,
                                                                  color: Colors.black,
                                                                ),
                                                              ),
                                                              GestureDetector(
                                                                onTap: () {
                                                                  // Get.back();
                                                                  Get.back();
                                                                  apiController.messageControllerText = apiController.msgController.text.trim();
                                                                  apiController.msgController.clear();
                                                                  if (apiController.selectedReason.value.isNotEmpty) {
                                                                    if (apiController.selectedReason.value == "Custom message") {
                                                                      if (apiController.messageControllerText.isNotEmpty) {
                                                                        // isAnswered = true;
                                                                        // apiController.isAnswered = true;
                                                                        // apiController.isAnsweredList[widget.index] = true;
                                                                        apiController.isAnsweredMap
                                                                            .update(widget.orderId, (value) => true, ifAbsent: () => true);
                                                                        apiController.rejectOrder(widget.orderId);
                                                                      } else {
                                                                        showMsg(msg: "Please enter a message to cancel the order.");
                                                                      }
                                                                    } else {
                                                                      // isAnswered = true;
                                                                      // apiController.isAnswered = true;
                                                                      // apiController.isAnsweredList[widget.index] = true;
                                                                      apiController.isAnsweredMap.update(widget.orderId, (value) => true, ifAbsent: () => true);
                                                                      apiController.rejectOrder(widget.orderId);
                                                                    }
                                                                  } else {
                                                                    showMsg(msg: "Please select a reason to proceed.");
                                                                  }
                                                                },
                                                                child: Padding(
                                                                  padding: const EdgeInsets.fromLTRB(10, 2, 2, 2),
                                                                  child: MyText(
                                                                    text: "SEND".tr,
                                                                    fontSize: 14,
                                                                    fontWeight: FontWeight.w500,
                                                                    color: kGreyColor,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(height: 10),
                                                        const Divider(),
                                                        const SizedBox(height: 10),
                                                        MyText(
                                                          text: "Select Reason".tr,
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w500,
                                                          color: kGreyColor,
                                                        ),
                                                        Align(
                                                          alignment: Alignment.topLeft,
                                                          child: SizedBox(
                                                            height: 190,
                                                            child: ListView.builder(
                                                              padding: EdgeInsets.zero,
                                                              itemCount: apiController.rejectReasonList.length,
                                                              physics: const NeverScrollableScrollPhysics(),
                                                              itemBuilder: (BuildContext context, int index) {
                                                                if (index == 0) {
                                                                  return Container();
                                                                }
                                                                return GestureDetector(
                                                                  onTap: () {
                                                                    apiController.selectedReason.value = apiController.rejectReasonList[index];
                                                                  },
                                                                  child: Row(
                                                                    children: [
                                                                      Obx(() {
                                                                        return Radio(
                                                                          activeColor: Colors.green,
                                                                          value: apiController.rejectReasonList[index],
                                                                          groupValue: apiController.selectedReason.value,
                                                                          onChanged: (value) {
                                                                            apiController.selectedReason.value = value ?? "";
                                                                            log(apiController.selectedReason.value);
                                                                          },
                                                                        );
                                                                      }),
                                                                      const SizedBox(
                                                                        width: 5,
                                                                      ),
                                                                      Expanded(
                                                                        child: MyText(
                                                                          text: apiController.rejectReasonList[index],
                                                                          fontSize: 14,
                                                                          fontWeight: FontWeight.w400,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                                //   ListTile(
                                                                //   contentPadding: EdgeInsets.zero,
                                                                //   horizontalTitleGap: 0,
                                                                //   onTap: () {
                                                                //     apiController.selectedReason.value = apiController.reasonList[index];
                                                                //   },
                                                                //   leading: Obx(() {
                                                                //     return Radio(
                                                                //       activeColor: Colors.green,
                                                                //       value: apiController.reasonList[index],
                                                                //       groupValue: apiController.selectedReason.value,
                                                                //       onChanged: (value) {
                                                                //         apiController.selectedReason.value = value ?? "";
                                                                //         log(apiController.selectedReason.value);
                                                                //       },
                                                                //     );
                                                                //   }),
                                                                //   title: MyText(
                                                                //     text: apiController.reasonList[index],
                                                                //     fontSize: 14,
                                                                //     fontWeight: FontWeight.w400,
                                                                //   ),
                                                                // );
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                        Obx(() {
                                                          if (apiController.selectedReason.value == "Custom message") {
                                                            return MyTextField(
                                                              controller: apiController.msgController,
                                                              hint: "Type".tr,
                                                            );
                                                          }
                                                          return const SizedBox();
                                                        }),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.close,
                                        size: 20,
                                        color: Colors.red,
                                      ),
                                      MyText(
                                        text: "Reject order".tr,
                                        color: Colors.red,
                                        fontWeight: FontWeight.w600,
                                        paddingLeft: 10,
                                        fontSize: 14,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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
          child: Container(
            height: 55,
            width: 80,
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(5),
            ),
            child: const Center(
              child: Icon(
                Icons.close,
                color: Colors.white,
              ),
            ),
          ),
        ),
        //+ OUTER Accept Button
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: MaterialButton(
              color: Colors.green,
              height: 55,
              minWidth: Get.width - 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              onPressed: () {
                //+Open Pickup Time Sheet
                apiController.timeController.value.clear();
                apiController.isAcceptDisabled.value = true;
                Get.bottomSheet(
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StatefulBuilder(
                        builder: (context, setState) {
                          return SingleChildScrollView(
                            child: Container(
                              // height: (Get.height / 2) - 100,
                              width: double.maxFinite,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 42),
                                    MyText(
                                      text: "Pickup time".tr,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                    ),
                                    const Form(
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      child: TimeTextField(),
                                    ),
                                    // MyButton(
                                    //   title: "Accept".tr,
                                    //   btnColor: Colors.green,
                                    //   onTap: () async {
                                    //     //+ add loading here
                                    //     // Get.back(result: true);
                                    //     Get.back();
                                    //     if (apiController.timeController.value.text.trim().isNotEmpty &&
                                    //         (int.tryParse(apiController.timeController.value.text.trim()) != null)) {
                                    //       apiController.isAnswered = true;
                                    //       apiController.isAnsweredList[widget.index] = true;
                                    //       apiController.isAnsweredMap.update(widget.orderId, (value) => true, ifAbsent: () => true);
                                    //       isAnswered = true;
                                    //       await apiController.acceptOrder(widget.orderId, "${apiController.timeController.value.text}:00");
                                    //       List<PrinterDataModel> printers =
                                    //           LocalHiveDatabase.getPrintersListForASpecificUser(LocalSharedPrefDatabase.getUserEmail() ?? "email") ?? [];
                                    //       log("printers: $printers");
                                    //
                                    //       if (printers.isNotEmpty) {
                                    //         showMsg(msg: "Printing...");
                                    //         for (var device in printers) {
                                    //           log("------------------- DEVICE PRINTING ON -------------------------");
                                    //           log("before calling the method: ${apiController.selectedOrderData.value.toJson()}");
                                    //           printerController.selectedPrinter = device;
                                    //           // printerController.printReceiveTest();
                                    //           try {
                                    //             await printerController.printOrderDetails(apiController.selectedOrderData.value);
                                    //           } catch (e) {
                                    //             log("error in details page printing: $e");
                                    //           }
                                    //         }
                                    //       } else {
                                    //         showMsg(msg: "No saved printers found. Please go to settings to add your printer.");
                                    //       }
                                    //     } else if (apiController.timeController.value.text.trim().isEmpty) {
                                    //       showMsg(msg: "Please enter a time");
                                    //     } else if (int.tryParse(apiController.timeController.value.text.trim()) != null) {
                                    //       showMsg(msg: "Please enter a valid number");
                                    //     } else {
                                    //       showMsg(msg: "Please enter a valid time value in number format");
                                    //     }
                                    //     await Future.delayed(const Duration(seconds: 3));
                                    //   },
                                    // ),
                                    //+ INNER Accept Button
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      child: Obx(() {
                                        return MaterialButton(
                                          color: apiController.isAcceptDisabled.value ? Colors.green[200] : Colors.green,
                                          height: 55,
                                          minWidth: Get.width - 10,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          onPressed: !apiController.isAcceptDisabled.value ? () async {
                                            // Get.back(result: true);
                                            Get.back();
                                            if (secondAcceptSecs > 0) {
                                              if (apiController.timeController.value.text.trim().isNotEmpty &&
                                                  (int.tryParse(apiController.timeController.value.text.trim()) != null) &&
                                                  int.tryParse(apiController.timeController.value.text.trim()) != 0) {
                                                // apiController.isAnswered = true;
                                                // apiController.isAnsweredList[widget.index] = true;
                                                apiController.isAnsweredMap.update(widget.orderId, (value) => true, ifAbsent: () => true);
                                                // isAnswered = true;
                                                await apiController.acceptOrder(widget.orderId, "${apiController.timeController.value.text}:00");
                                                List<PrinterDataModel> printers =
                                                    LocalHiveDatabase.getPrintersListForASpecificUser(LocalSharedPrefDatabase.getUserEmail() ?? "email") ?? [];
                                                log("printers: $printers");

                                                if (printers.isNotEmpty) {
                                                  printerController.isPrinting.value = true;
                                                  // showMsg(msg: "Printing...".tr);
                                                  for (var device in printers) {
                                                    log("------------------- DEVICE PRINTING ON -------------------------");
                                                    log("before calling the method: ${apiController.selectedOrderData.value.toJson()}");
                                                    printerController.selectedPrinter = device;
                                                    // printerController.printReceiveTest();
                                                    try {
                                                      await printerController.printOrderDetails(apiController.selectedOrderData.value);
                                                    } catch (e) {
                                                      log("error in details page printing: $e");
                                                    }
                                                  }
                                                  Future.delayed(const Duration(seconds: 2), () => printerController.isPrinting.value = false);
                                                } else {
                                                  showMsg(msg: "No saved printers found. Please go to settings to add your printer.".tr);
                                                }
                                              } else if (apiController.timeController.value.text.trim().isEmpty) {
                                                showMsg(msg: "Please enter a time".tr);
                                              } else if (int.tryParse(apiController.timeController.value.text.trim()) == null) {
                                                showMsg(msg: "Please enter a valid number".tr);
                                              } else if (int.tryParse(apiController.timeController.value.text.trim()) == 0) {
                                                showMsg(msg: "Please enter a valid time".tr);
                                              } else {
                                                showMsg(msg: "Please enter a valid time value in number format".tr);
                                              }
                                            } else {
                                              showMsg(msg: "The order has expired. You cannot accept it now.".tr);
                                            }
                                            await Future.delayed(const Duration(seconds: 3));
                                          } : () {},
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              MyText(
                                                text: "ACCEPT".tr,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16,
                                              ),
                                              SizedBox(
                                                height: 35,
                                                width: 35,
                                                child: SimpleTimer(
                                                  key: Key("${widget.orderId}accept"),
                                                  // controller: timerController,
                                                  strokeWidth: 0,
                                                  progressTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
                                                  displayProgressIndicator: false,
                                                  status: TimerStatus.start,
                                                  duration: Duration(seconds: secondAcceptSecs < 0 ? 0 : secondAcceptSecs),
                                                  valueListener: (timeElapsed) {
                                                    // verboseLog("second internal timer running for {widget.orderId: and: ${timeElapsed.inSeconds}");
                                                  },
                                                  // onEnd: () async {
                                                  //   apiController.isAnsweredList[widget.index] = true;
                                                  //   // apiController.isAnsweredMap.update(
                                                  //   //     apiController.newOrdersList[index].value.orderId ?? "", (value) => true,
                                                  //   //     ifAbsent: () => true);
                                                  //
                                                  //   bool checkableIsAnsweredFour =
                                                  //       apiController.isAnsweredMap.containsKey(apiController.selectedOrderData.value.order.orderId)
                                                  //           ? apiController.isAnsweredMap[apiController.selectedOrderData.value.order.orderId] ?? false
                                                  //           : false;
                                                  //   log('MISSING ORDER IN SECOND INTERNAL TIMER AND :');
                                                  //   log('MISSING ORDER IN SECOND INTERNAL TIMER AND :');
                                                  //   log(' IN SECOND INTERNAL TIMER apiController.newOrdersList[index].orderId: ${apiController.isAnsweredMap}');
                                                  //   log(' IN SECOND INTERNAL TIMER apiController.isAnsweredMap[apiController.newOrdersList[index].value.orderId ?? ""]: '
                                                  //       '${apiController.isAnsweredMap[apiController.selectedOrderData.value.order.orderId]}');
                                                  //   log(' IN SECOND INTERNAL TIMER apiController.isAnsweredMap.containsKey(apiController.newOrdersList[index].value.orderId ?? ""): '
                                                  //       '${apiController.isAnsweredMap.containsKey(apiController.selectedOrderData.value.order.orderId)}');
                                                  //   log(' IN SECOND INTERNAL TIMER apiController.newOrdersList[index].orderId: ${apiController.selectedOrderData.value.order.orderId}');
                                                  //   // log(' IN SECOND INTERNAL TIMER apiController.newOrdersList[widget.index].orderId: ${apiController.newOrdersList[widget.index].value.orderId}');
                                                  //   // log(' IN SECOND INTERNAL TIMER apiController.newOrdersList[widget.index].seconds: ${apiController.newOrdersList[widget.index].value.seconds}');
                                                  //   log('apiController.selectedOrderData.value.order.orderId: ${apiController.selectedOrderData.value.order.orderId}');
                                                  //   log('secondAcceptSecs: $secondAcceptSecs');
                                                  //   log(' IN SECOND INTERNAL TIMER checkableIsAnsweredFour: $checkableIsAnsweredFour');
                                                  //   verboseLog(' IN SECOND INTERNAL TIMER acceptSecs+ secondAcceptSecs: '
                                                  //       '${acceptSecs + secondAcceptSecs}');
                                                  //   // (apiController.newOrdersList[index].value.seconds == 180 ||
                                                  //   //         (timeDifference.inSeconds + apiController.newOrdersList[index].value.seconds) == 180) &&
                                                  //   apiController.isOnSecondPage = false;
                                                  //   Get.back(closeOverlays: true);
                                                  //
                                                  //   if (!checkableIsAnsweredFour) {
                                                  //     // apiController.newOrdersList[widget.index].value.seconds = 180;
                                                  //     await apiController.missOrder(apiController.selectedOrderData.value.order.orderId, widget.index);
                                                  //   }
                                                  //   // Future.delayed(const Duration(seconds: 2), () {
                                                  //   await apiController.getOrderViewData(apiController.selectedOrderData.value.order.orderId);
                                                  //   // if(Get.isDialogOpen ?? false) dismissLoading();
                                                  //   // });
                                                  // },
                                                ),
                                              ),
                                              MyText(
                                                text: ")",
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 18,
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyText(
                    text: "ACCEPT".tr,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                  SizedBox(
                    height: 35,
                    width: 35,
                    child: SimpleTimer(
                      key: Key("${widget.orderId}accept"),
                      // controller: timerController,
                      strokeWidth: 0,
                      progressTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
                      displayProgressIndicator: false,
                      status: TimerStatus.start,
                      valueListener: (timeElapsed) {
                        if (!apiController.secondPageTimerValMap.containsKey(timeElapsed.inSeconds.toString())) {
                          secondAcceptSecs--;
                          apiController.secondPageTimerValMap.putIfAbsent(timeElapsed.inSeconds.toString(), () => true);
                          // debugLog("first internal timer running for {widget.orderId: and: ${timeElapsed.inSeconds} and secondAcceptSecs: $secondAcceptSecs}");
                        }
                      },
                      duration: Duration(seconds: acceptSecs),
                      // onEnd: () async {
                      //   apiController.isAnsweredList[widget.index] = true;
                      //   // apiController.isAnsweredMap.update(
                      //   //     apiController.newOrdersList[index].value.orderId ?? "", (value) => true,
                      //   //     ifAbsent: () => true);
                      //
                      //   bool checkableIsAnsweredFour = apiController.isAnsweredMap.containsKey(apiController.selectedOrderData.value.order.orderId)
                      //       ? apiController.isAnsweredMap[apiController.selectedOrderData.value.order.orderId] ?? false
                      //       : false;
                      //   log('MISSING ORDER IN FIRST INTERNAL TIMER AND :');
                      //   log('MISSING ORDER IN FIRST INTERNAL TIMER AND :');
                      //   log(' IN FIRST INTERNAL TIMER apiController.newOrdersList[index].orderId: ${apiController.isAnsweredMap}');
                      //   log(' IN FIRST INTERNAL TIMER apiController.isAnsweredMap[apiController.newOrdersList[index].value.orderId ?? ""]: '
                      //       '${apiController.isAnsweredMap[apiController.selectedOrderData.value.order.orderId]}');
                      //   log(' IN FIRST INTERNAL TIMER apiController.isAnsweredMap.containsKey(apiController.newOrdersList[index].value.orderId ?? ""): '
                      //       '${apiController.isAnsweredMap.containsKey(apiController.selectedOrderData.value.order.orderId)}');
                      //   log(' IN FIRST INTERNAL TIMER apiController.newOrdersList[index].orderId: ${apiController.selectedOrderData.value.order.orderId}');
                      //   // log(' IN FIRST INTERNAL TIMER apiController.newOrdersList[widget.index].orderId: ${apiController.newOrdersList[widget.index].value.orderId}');
                      //   // log(' IN FIRST INTERNAL TIMER apiController.newOrdersList[widget.index].seconds: ${apiController.newOrdersList[widget.index].value.seconds}');
                      //   log('apiController.selectedOrderData.value.order.orderId: ${apiController.selectedOrderData.value.order.orderId}');
                      //   // log('timeDifference.inSeconds: ${timeDifference.inSeconds}');
                      //   log(' IN FIRST INTERNAL TIMER checkableIsAnsweredFour: $checkableIsAnsweredFour');
                      //   verboseLog(' IN FIRST INTERNAL TIMER acceptSecs+ secondAcceptSecs: ${acceptSecs + secondAcceptSecs}');
                      //   verboseLog(' IN FIRST INTERNAL TIMER secondAcceptSecs: $secondAcceptSecs');
                      //   // (apiController.newOrdersList[index].value.seconds == 180 ||
                      //   //         (timeDifference.inSeconds + apiController.newOrdersList[index].value.seconds) == 180) &&
                      //   // showCircularLoading();
                      //
                      //   if (!checkableIsAnsweredFour) {
                      //     // apiController.newOrdersList[widget.index].value.seconds = 180;
                      //     await apiController.missOrder(apiController.selectedOrderData.value.order.orderId, widget.index);
                      //   }
                      //   // Future.delayed(const Duration(seconds: 2), () {
                      //   await apiController.getOrderViewData(apiController.selectedOrderData.value.order.orderId);
                      //   // if (Get.isDialogOpen ?? false) dismissLoading();
                      //   // });
                      // },
                    ),
                  ),
                  MyText(
                    text: ")",
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Row printerRow() {
    double height = MediaQuery.of(context).size.height;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Obx(() {
              if (apiController.selectedOrderData.value.order.pickupTime != null &&
                  apiController.selectedOrderData.value.order.pickupTime.isNotEmpty &&
                  apiController.selectedOrderData.value.order.orderId == widget.orderId) {
                var detroit = tz.getLocation('America/Los_Angeles');
                var now = tz.TZDateTime.now(detroit);
                log("Los Angeles timeL ==: $now");

                // if (apiController.selectedOrderData.value.order.pickupTime != null) {
                int minutesPart = int.tryParse(apiController.selectedOrderData.value.order.pickupTime.toString().split(":")[0]) ?? 0;
                Duration difference = DateTime.parse("${now.toIso8601String().split(".")[0]}.000")
                    .difference(DateTime.tryParse(apiController.selectedOrderData.value.order.acceptedDateTme) ?? now);
                log("difference.inSeconds: ${difference.inSeconds} -----");
                log("Duration(minutes: minutesPart).inSeconds: ${Duration(minutes: minutesPart).inSeconds} -----");

                if (difference.inSeconds < Duration(minutes: minutesPart).inSeconds) {
                  secs = Duration(minutes: minutesPart).inSeconds - difference.inSeconds;
                  log("secs: $secs -----");
                }

                timerController = TimerController(this);

                try {
                  timerController.start(
                    startFrom: Duration(
                      seconds: secs,
                    ),
                  );
                } catch (e) {
                  log("error in timerController start $e");
                }
                // now.add(Duration(minutes: minutesPart));
                // }

                return Container(
                  height: 35,
                  width: 45,
                  padding: const EdgeInsets.only(left: 12),
                  child: SimpleTimer(
                    key: Key(widget.orderId),
                    // controller: timerController,
                    strokeWidth: 0,
                    displayProgressIndicator: false,
                    status: TimerStatus.start,
                    // valueListener: (timeElapsed) {},
                    duration: Duration(seconds: secs),
                    onEnd: () async {},
                  ),
                );
              } else {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text("--:--"),
                );
              }
            }),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: (apiController.selectedOrderData.value.order.status != "missed" &&
                      apiController.selectedOrderData.value.order.status != "cancel" &&
                      apiController.selectedOrderData.value.order.status != "cancelled")
                  ? () async {
                      List<PrinterDataModel> printers =
                          LocalHiveDatabase.getPrintersListForASpecificUser(LocalSharedPrefDatabase.getUserEmail() ?? "email") ?? [];
                      log("printers: $printers");

                      if (printers.isNotEmpty) {
                        // showMsg(msg: "Printing...".tr);
                        printerController.isPrinting.value = true;
                        //+ remove this loop and choose one printer to print the receipt
                        for (var device in printers) {
                          log("------------------- DEVICE PRINTING ON -------------------------");
                          //! log("${device.toJson()}");
                          // log("before calling the method: ${apiController.selectedOrderData.value.toJson()}");
                          printerController.selectedPrinter = device;
                          log("printerController.selectedPrinter: ${printerController.selectedPrinter?.deviceName}");
                          // printerController.printReceiveTest();
                          try {
                            await printerController.printOrderDetails(apiController.selectedOrderData.value);
                          } catch (e) {
                            log("error in details page printing: $e");
                          }
                          Future.delayed(const Duration(seconds: 2), () => printerController.isPrinting.value = false);
                        }
                      } else {
                        showMsg(msg: "No saved printers found. Please go to settings to add your printer.".tr);
                      }
                      // printerController.printOrderDetails(apiController.orderViewList[0]);
                    }
                  : () {},
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 5, 2, 5),
                child: Obx(() {
                  if (apiController.selectedOrderData.value.order.status != "missed" &&
                      apiController.selectedOrderData.value.order.status != "cancel" &&
                      apiController.selectedOrderData.value.order.status != "cancelled") {
                    if(!printerController.isPrinting.value) {
                      return const Icon(Icons.print);
                    } else {
                      return const Center(
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    }
                  } else {
                    return const Icon(
                      Icons.print,
                      color: Colors.grey,
                    );
                  }
                }),
              ),
            ),
            const SizedBox(width: 15),
            GestureDetector(
              onTap: () {
                Get.bottomSheet(
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StatefulBuilder(
                        builder: (context, setState) {
                          return Container(
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
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: kGreyColor,
                                  ),
                                  Visibility(
                                    visible: apiController.selectedOrderData.value.order.status == "accept",
                                    child: const SizedBox(height: 30),
                                  ),
                                  Visibility(
                                    visible: apiController.selectedOrderData.value.order.status == "accept",
                                    child: GestureDetector(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: MyText(
                                              text: "Cancel Order".tr,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        //+Select Reason Bottom Sheet
                                        //+Select Reason Bottom Sheet
                                        //+Select Reason Bottom Sheet
                                        //+Select Reason Bottom Sheet
                                        Get.back();
                                        apiController.selectedReason.value = "";
                                        apiController.messageControllerText = "";
                                        apiController.msgController.clear();
                                        Get.bottomSheet(
                                          WillPopScope(
                                            onWillPop: () async {
                                              apiController.messageControllerText = apiController.msgController.text.trim();
                                              apiController.msgController.clear();
                                              return true;
                                            },
                                            child: Container(
                                              width: double.maxFinite,
                                              // height:height  ,
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  topRight: Radius.circular(10),
                                                ),
                                              ),
                                              child: ScrollConfiguration(
                                                behavior: MyCustomScrollBehavior(),
                                                child: SingleChildScrollView(
                                                  // physics: const BouncingScrollPhysics(),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const SizedBox(height: 20),
                                                      Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            GestureDetector(
                                                              onTap: () {
                                                                infoLog("Backed Pressed ");
                                                                apiController.messageControllerText = apiController.msgController.text.trim();
                                                                apiController.msgController.clear();
                                                                Get.back();
                                                              },
                                                              child: const Icon(
                                                                Icons.arrow_back_outlined,
                                                                color: Colors.black,
                                                              ),
                                                            ),
                                                            GestureDetector(
                                                              onTap: () {
                                                                Get.back();
                                                                apiController.messageControllerText = apiController.msgController.text.trim();
                                                                apiController.msgController.clear();
                                                                if (apiController.selectedReason.value.isNotEmpty) {
                                                                  if (apiController.selectedReason.value == "Custom message") {
                                                                    if (apiController.messageControllerText.isNotEmpty) {
                                                                      apiController.cancelOrder(widget.orderId);
                                                                    } else {
                                                                      showMsg(msg: "Please enter a message to cancel the order.");
                                                                    }
                                                                  } else {
                                                                    apiController.cancelOrder(widget.orderId);
                                                                  }
                                                                } else {
                                                                  showMsg(msg: "Please select a reason to proceed.");
                                                                }
                                                              },
                                                              child: Padding(
                                                                padding: const EdgeInsets.fromLTRB(10, 2, 2, 2),
                                                                child: MyText(
                                                                  text: "SEND".tr,
                                                                  fontSize: 14,
                                                                  fontWeight: FontWeight.w500,
                                                                  color: kGreyColor,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(height: 10),
                                                      const Divider(),
                                                      const SizedBox(height: 10),
                                                      MyText(
                                                        text: "Select Reason".tr,
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w500,
                                                        color: kGreyColor,
                                                        paddingLeft: 16,
                                                      ),
                                                      Column(
                                                        children: [
                                                          Wrap(
                                                            runSpacing: 0.0,
                                                            spacing: 0.0,
                                                            children: List.generate(apiController.reasonList.length, (index) {
                                                              if (index == 0) {
                                                                return Container();
                                                              }
                                                              return GestureDetector(
                                                                onTap: () {
                                                                  apiController.selectedReason.value = apiController.reasonList[index];
                                                                },
                                                                child: Row(
                                                                  children: [
                                                                    Obx(() {
                                                                      return Radio(
                                                                        activeColor: Colors.green,
                                                                        value: apiController.reasonList[index],
                                                                        groupValue: apiController.selectedReason.value,
                                                                        onChanged: (value) {
                                                                          apiController.selectedReason.value = value ?? "";
                                                                          log(apiController.selectedReason.value);
                                                                        },
                                                                      );
                                                                    }),
                                                                    const SizedBox(width: 5),
                                                                    Expanded(
                                                                      child: MyText(
                                                                        text: apiController.reasonList[index],
                                                                        fontSize: 14,
                                                                        fontWeight: FontWeight.w400,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            }),
                                                          ),
                                                        ],
                                                      ),
                                                      Obx(() {
                                                        if (apiController.selectedReason.value == "Custom message") {
                                                          return MyTextField(
                                                            controller: apiController.msgController,
                                                            hint: "Type".tr,
                                                          );
                                                        }
                                                        return const SizedBox();
                                                      }),
                                                      const SizedBox(height: 10),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  GestureDetector(
                                    onTap: () {
                                      OrderViewModel order = apiController.selectedOrderData.value;
                                      String itemsString = "";
                                      for (var item in order.orderItems) {
                                        itemsString += "${item.itemQty} x ${item.itemName}   US\$${item.finalCost}\n";
                                      }

                                      Get.back();
                                      String copiedText = ""
                                          // "THIS ORDER IS A TEST.\n"
                                          // "DO NOT FULFILL IT\n"
                                          "===${getStatus(order.order.status).tr} ${"order".tr}===\n\n"
                                          "${"Order no".tr}: ${order.order.orderId}\n"
                                          "${"Placed on".tr}: ${order.order.dateCreated.isEmpty ? "N/A" : "${apiController.selectedOrderData.value.order.orderDate} ${apiController.selectedOrderData.value.order.orderTime}"}\n"
                                          "${(order.order.status == "missed") ? "${"Timed out on".tr}: ${order.order.missedStatusDatetime.isEmpty ? "N/A" : order.order.missedStatusDatetime}\n" : ""}"
                                          "${(order.order.status != "cancelled" && order.order.status != "cancel" && order.order.status != "missed") ? "${"Accepted on".tr}: ${order.order.acceptedDateTme.isEmpty ? "N/A" : order.order.acceptedDateTme}\n" : ""}"
                                          "${order.order.status == "cancelled" ? "${"Rejected on".tr}: ${order.order.rejectedDateTme.toString().isEmpty ? "N/A" : order.order.rejectedDateTme.toString()}\n" : ""}"
                                          "${(order.order.status != "cancelled" && order.order.status != "cancel" && order.order.status != "missed") ? "${"Fulfilment on".tr}: ${order.order.orderDate.isEmpty ? "N/A" : "${apiController.selectedOrderData.value.order.orderDate} ${apiController.selectedOrderData.value.order.orderTime}"}\n" : ""}"
                                          "\n${"Type".tr}: ${"Pickup".tr}\n"
                                          // "Pickup time: null min\n"
                                          "${"Payment method".tr}: ${order.order.paymentType.toUpperCase()}\n\n"
                                          "${"Sub-Total".tr}:  US\$${order.order.totalCost}\n"
                                          "${"Sales Tax(8.875%)".tr}: US\$${((double.tryParse(order.order.totalCost) ?? 0.0) - (double.tryParse(order.order.totalCost) ?? 0.0) / 108.87 * 100).toStringAsFixed(2)}\n"
                                          "${"Total".tr}: US\$${order.order.totalCost}\n\n"
                                          "===${"Client info".tr}===\n"
                                          "${"Name".tr}: ${order.order.customerName.isEmpty ? "N/A" : order.order.customerName}\n"
                                          "${"Email".tr}: ${order.order.email.isEmpty ? "N/A" : order.order.email}\n"
                                          "${"Phone".tr}: ${order.order.phone.isEmpty ? "N/A" : order.order.phone}\n\n"

                                          // "Comment: I don't require plastic cutlery.\n\n"

                                          "===${"Order items".tr}=== \n"
                                          "$itemsString"
                                          "\n===${"end of order".tr}=== \n\n"
                                          "${"Get your order instantly confirmed by us in real-time".tr}: "
                                          // "https://winnien10.sg-host.com"
                                          "https://sanmiwagodumpling.com/menu"
                                          "";
                                      Clipboard.setData(ClipboardData(text: copiedText));
                                      log("Successfully Copied");
                                      showMsg(msg: "Order details copied".tr);
                                    },
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: MyText(
                                            text: "Copy to clipboard".tr,
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
              child: const Icon(
                Icons.more_vert,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
      ],
    );
  }

  Container fadeShimmerWidget() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: ListView.builder(
          itemCount: 15,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.all(3.0),
              child: FadeShimmer(
                height: 70,
                width: MediaQuery.of(context).size.width,
                radius: 4,
                highlightColor: const Color(0xffF9F9FB),
                baseColor: const Color(0xffE6E8EB),
              ),
            );
          }),
    );
  }

  ScrollConfiguration orderDetailPart() {
    // Rx<OrderViewModel> order = apiController.selectedOrderData;
    return ScrollConfiguration(
      behavior: MyCustomScrollBehavior(),
      child: ListView(
        children: [
          // const SizedBox(height: 55),
          const SizedBox(height: 20),
          //+Container
          Obx(() {
            return Container(
              height: 45,
              width: double.maxFinite,
              decoration: BoxDecoration(
                color: getContainerColour(apiController.selectedOrderData.value.order.status),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      getIcon(apiController.selectedOrderData.value.order.status),
                      // color: Colors.red,
                      color: getColour(apiController.selectedOrderData.value.order.status),
                    ),
                    const SizedBox(width: 10),
                    MyText(
                      text: getStatus(apiController.selectedOrderData.value.order.status).tr,
                      //.replaceAll("_", " ")
                      color: getColour(apiController.selectedOrderData.value.order.status),
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 20),

          //+ First ExpandablePanel
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.only(bottom: 10),
            decoration: const BoxDecoration(),
            child: ExpandablePanel(
              controller: idPart,
              theme: const ExpandableThemeData(
                // tapHeaderToExpand: false,
                // tapBodyToExpand: false,
                // tapBodyToCollapse: true,
                iconColor: kBlackColor,
                iconPadding: EdgeInsets.zero,
                headerAlignment: ExpandablePanelHeaderAlignment.center,
              ),
              header: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: MyText(
                          text: "${'ID'.tr}:",
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        flex: 2,
                        child: MyText(
                          text: apiController.selectedOrderData.value.order.orderId,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       flex: 1,
                  //       child: MyText(
                  //         text: '${'Placed on'.tr}:',
                  //         fontSize: 14,
                  //       ),
                  //     ),
                  //     const SizedBox(width: 5),
                  //     Expanded(
                  //       flex: 2,
                  //       child: Obx(() {
                  //         return MyText(
                  //           text: "${apiController.selectedOrderData.value.order.orderDate}"
                  //               " ${apiController.selectedOrderData.value.order.orderTime}",
                  //           fontSize: 14,
                  //         );
                  //       }),
                  //     ),
                  //   ],
                  // ),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: MyText(
                          text: '${'Placed on'.tr}:',
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        flex: 2,
                        child: Obx(() {
                          return MyText(
                            text: DateFormat(dateFormat).format(DateTime.tryParse("${apiController.selectedOrderData.value.order.orderDate} "
                                "${apiController.selectedOrderData.value.order.orderTime.split(" ")[0]}") ?? DateTime.now()),
                            fontSize: 14,
                          );
                        }),
                      ),
                    ],
                  ),
                ],
              ),
              collapsed: const SizedBox(),
              expanded: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                  Obx(() {
                    return Visibility(
                      visible: apiController.selectedOrderData.value.order.status == "cancelled",
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 8,
                            child: MyText(
                              text: '${'Rejected on'.tr}:',
                            ),
                          ),
                          // const SizedBox(width: 10),
                          Expanded(
                            flex: 17,
                            child: Obx(() {
                              return MyText(
                                text: apiController.selectedOrderData.value.order.rejectedDateTme.isEmpty
                                    ? "N/A"
                                    : DateFormat(dateFormat).format(DateTime.tryParse(apiController.selectedOrderData.value.order.rejectedDateTme) ?? DateTime.now()),
                              );
                            }),
                          ),
                        ],
                      ),
                    );
                  }),
                  Obx(() {
                    return Visibility(
                      visible: apiController.selectedOrderData.value.order.status == "missed",
                      child: Row(
                        children: [
                          Expanded(
                            flex: 8,
                            child: MyText(
                              text: '${'Timed out on'.tr}:',
                            ),
                          ),
                          // const SizedBox(width: 10),
                          Expanded(
                            flex: 17,
                            child: Obx(() {
                              return MyText(
                                text: apiController.selectedOrderData.value.order.missedStatusDatetime.isEmpty
                                    ? "N/A"
                                    : DateFormat(dateFormat).format(DateTime.tryParse(apiController.selectedOrderData.value.order.missedStatusDatetime) ?? DateTime.now()),
                              );
                            }),
                          ),
                        ],
                      ),
                    );
                  }),
                  Obx(() {
                    return Visibility(
                      visible: apiController.selectedOrderData.value.order.status != "cancelled" &&
                          apiController.selectedOrderData.value.order.status != "cancel" &&
                          apiController.selectedOrderData.value.order.status != "missed" &&
                          apiController.selectedOrderData.value.order.status != "new",
                      child: Row(
                        children: [
                          Expanded(
                            flex: 8,
                            child: MyText(
                              text: '${'Accepted on'.tr}:',
                            ),
                          ),
                          // const SizedBox(width: 10),
                          Expanded(
                            flex: 17,
                            child: Obx(() {
                              return MyText(
                                text: apiController.selectedOrderData.value.order.acceptedDateTme.isEmpty
                                    ? "N/A"
                                    : DateFormat(dateFormat).format(DateTime.tryParse(apiController.selectedOrderData.value.order.acceptedDateTme) ?? DateTime.now()),
                              );
                            }),
                          ),
                        ],
                      ),
                    );
                  }),
                  Obx(() {
                    return Visibility(
                      visible: apiController.selectedOrderData.value.order.status != "cancelled" &&
                          apiController.selectedOrderData.value.order.status != "cancel" &&
                          apiController.selectedOrderData.value.order.status != "missed" &&
                          apiController.selectedOrderData.value.order.status != "new",
                      child: Row(
                        children: [
                          Expanded(
                            flex: 8,
                            child: MyText(
                              text: '${'Fulfilment on'.tr}:',
                              fontSize: 14,
                            ),
                          ),
                          Expanded(
                            flex: 17,
                            child: Obx(() {
                              return MyText(
                                text: apiController.selectedOrderData.value.order.acceptedDateTme.isEmpty
                                    ? "N/A"
                                    : DateFormat(dateFormat).format(DateTime.tryParse(apiController.selectedOrderData.value.order.acceptedDateTme) ?? DateTime.now()),
                                fontSize: 14,
                              );
                            }),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
              builder: (BuildContext context, collapsed, expanded) {
                return Expandable(
                  collapsed: collapsed,
                  expanded: expanded,
                  theme: const ExpandableThemeData(
                    crossFadePoint: 0,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 5,
            width: double.maxFinite,
            decoration: const BoxDecoration(color: kSkyLightColor),
          ),
          const SizedBox(height: 20),

          //+ Second ExpandablePanel
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.only(bottom: 10),
            decoration: const BoxDecoration(),
            child: ExpandablePanel(
              controller: contactPart,
              theme: const ExpandableThemeData(
                iconColor: kBlackColor,
                iconPadding: EdgeInsets.zero,
                headerAlignment: ExpandablePanelHeaderAlignment.center,
                tapBodyToCollapse: true,
              ),
              header: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          text: apiController.selectedOrderData.value.order.customerName,
                          // text: "apiController selectedOrder Data Data",
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          overFlow: TextOverflow.ellipsis,
                          maxLines: 3,
                          paddingLeft: 0,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(width: 5),
                            Visibility(
                              visible: apiController.selectedOrderData.value.isFirstOrder == "Yes",
                              // visible: true,
                              child: const Icon(
                                Icons.star,
                                color: Colors.blue,
                                size: 18,
                              ),
                            ),
                            Visibility(
                              visible: apiController.selectedOrderData.value.isFirstOrder == "Yes",
                              child: const SizedBox(width: 5),
                            ),
                            Visibility(
                              visible: apiController.selectedOrderData.value.isFirstOrder == "Yes",
                              // visible: true,
                              child: MyText(
                                text: '1st order'.tr,
                                fontSize: 14,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              collapsed: const SizedBox(),
              expanded: ListView(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 3),
                  GestureDetector(
                    onTap: () async {
                      if (apiController.selectedOrderData.value.order.phone.isNotEmpty) {
                        final Uri uri = Uri.parse('tel:${apiController.selectedOrderData.value.order.phone}');
                        if (!await launchUrl(uri)) {
                          showMsg(msg: "Could not launch the dialer. Please try again.".tr);
                        }
                      }
                    },
                    child: Row(
                      children: [
                        const Icon(
                          Icons.call,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        MyText(
                          text: apiController.selectedOrderData.value.order.phone.isEmpty ? "N/A" : apiController.selectedOrderData.value.order.phone,
                          // fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 3),
                  GestureDetector(
                    onTap: () async {
                      if (apiController.selectedOrderData.value.order.email.isNotEmpty) {
                        final Uri uri = Uri.parse(
                          'mailto:${apiController.selectedOrderData.value.order.email}?subject=Order ${apiController.selectedOrderData.value.order.orderId} &body='
                          'Hi ${apiController.selectedOrderData.value.order.customerName} \n Message :\n',
                        );
                        if (!await launchUrl(uri)) {
                          showMsg(msg: "Could not launch the email app. Please try again.".tr);
                        }
                      }
                    },
                    child: Row(
                      children: [
                        const Icon(
                          Icons.email_outlined,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        MyText(
                          text: apiController.selectedOrderData.value.order.email.isEmpty ? "N/A" : apiController.selectedOrderData.value.order.email,
                          // fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 3),
                  Visibility(
                    visible: apiController.selectedOrderData.value.isFirstOrder == "Yes",
                    child: MyText(
                      text: 'First time order'.tr,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              builder: (_, collapsed, expanded) {
                return Expandable(
                  collapsed: collapsed,
                  expanded: expanded,
                  theme: const ExpandableThemeData(
                    crossFadePoint: 0,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 5,
            width: double.maxFinite,
            decoration: const BoxDecoration(color: kSkyLightColor),
          ),
          // const SizedBox(height: 25),
          // MyText(
          //   text: "I don't require plastic cutlery ",
          //   color: Colors.red,
          //   fontWeight: FontWeight.w500,
          //   paddingLeft: 20,
          // ),
          // const SizedBox(height: 25),
          // Container(
          //   height: 5,
          //   width: double.maxFinite,
          //   decoration: const BoxDecoration(
          //     color: kSkyLightColor,
          //   ),
          // ),
          const SizedBox(height: 20),
          //+Orders items
          //+Orders items
          MyText(
            text: "Orders items".tr,
            fontWeight: FontWeight.w600,
            paddingLeft: 20,
          ),
          const SizedBox(height: 10),

          //+ITEM NAME ROW
          Padding(
            padding: const EdgeInsets.symmetric(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: apiController.selectedOrderData.value.orderItems
                  .map<Widget>(
                    (e) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  "${e.itemQty}  x ",
                                  textAlign: TextAlign.start,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 14,
                                    fontFamily: "poppins",
                                    fontWeight: FontWeight.w500,
                                    height: 1.6,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 9,
                                child: Text(
                                  e.itemName.trim(),
                                  textAlign: TextAlign.start,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 14,
                                    fontFamily: "poppins",
                                    fontWeight: FontWeight.w500,
                                    height: 1.6,
                                  ),
                                ),
                              ),
                              Text(
                                "\$${e.finalCost}",
                                textAlign: TextAlign.start,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: "poppins",
                                  fontWeight: FontWeight.w400,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                          Visibility(
                            visible: e.specialInstruction != null && e.specialInstruction != "",
                            child: Row(
                              children: [
                                Expanded(
                                  child: MyText(
                                    text: "  ${e.specialInstruction.trim()}",
                                    maxLines: 5,
                                    overFlow: TextOverflow.ellipsis,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.red,
                                    fontSize: 14,
                                    paddingLeft: 25,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),

            // Column(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: apiController.selectedOrderData.value.orderItems
            //       .map<Widget>((e) => Padding(
            //           padding: const EdgeInsets.symmetric(horizontal: 10),
            //           child: Row(
            //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //             children: [
            //               Expanded(
            //                 child: Text(
            //                   "${e.itemQty} x    ${e.itemName}",
            //                   textAlign: TextAlign.start,
            //                   maxLines: 1,
            //                   style: const TextStyle(
            //                     overflow: TextOverflow.ellipsis,
            //                     fontSize: 14,
            //                     fontFamily: "poppins",
            //                     fontWeight: FontWeight.w500,
            //                     height: 1.6,
            //                   ),
            //                 ),
            //               ),
            //               Text(
            //                 "\$${e.finalCost}",
            //                 textAlign: TextAlign.start,
            //                 maxLines: 1,
            //                 overflow: TextOverflow.ellipsis,
            //                 style: const TextStyle(
            //                   fontSize: 14,
            //                   fontFamily: "poppins",
            //                   fontWeight: FontWeight.w400,
            //                   height: 1.6,
            //                 ),
            //               ),
            //             ],
            //           )))
            //       .toList(),
            // ),
          ),

          // Row(
          //   children: [
          //     MyText(
          //       text: "${order?.orderItems.first.itemQty} x",
          //       fontWeight: FontWeight.w500,
          //       paddingLeft: 20,
          //     ),
          //     MyText(
          //       text: "Pizza Prosciutto",
          //       fontWeight: FontWeight.w500,
          //       paddingLeft: 20,
          //     ),
          //     const Spacer(),
          //     MyText(
          //       text: "11.60",
          //       fontWeight: FontWeight.w500,
          //       paddingRight: 20,
          //     ),
          //   ],
          // ),
          // Row(
          //   children: [
          //     MyText(
          //       text: "------",
          //       fontWeight: FontWeight.w500,
          //       paddingLeft: 20,
          //     ),
          //     //! Note from the user
          //     MyText(
          //       text: "No mushrooms, please !",
          //       fontWeight: FontWeight.w400,
          //       color: Colors.red,
          //       fontSize: 14,
          //       paddingLeft: 20,
          //     ),
          //     const Spacer(),
          //     MyText(
          //       text: " ",
          //       fontWeight: FontWeight.w500,
          //       paddingRight: 20,
          //     ),
          //   ],
          // ),
          // Row(
          //   children: [
          //     MyText(
          //       text: "    ",
          //       fontWeight: FontWeight.w500,
          //       paddingLeft: 20,
          //     ),
          //     MyText(
          //       text: "size :",
          //       fontWeight: FontWeight.w400,
          //       fontSize: 14,
          //       paddingLeft: 20,
          //     ),
          //     MyText(
          //       text: " ",
          //       fontWeight: FontWeight.w500,
          //       paddingRight: 20,
          //     ),
          //   ],
          // ),
          // Row(
          //   children: [
          //     MyText(
          //       text: "    ",
          //       fontWeight: FontWeight.w500,
          //       paddingLeft: 20,
          //     ),
          //     MyText(
          //       text: "Crust :",
          //       fontWeight: FontWeight.w400,
          //       fontSize: 14,
          //       paddingLeft: 20,
          //     ),
          //     MyText(
          //       text: " ",
          //       fontWeight: FontWeight.w500,
          //       paddingRight: 20,
          //     ),
          //   ],
          // ),
          // Row(
          //   children: [
          //     MyText(
          //       text: "    ",
          //       fontWeight: FontWeight.w500,
          //       paddingLeft: 20,
          //     ),
          //     MyText(
          //       text: "Toppings :",
          //       fontWeight: FontWeight.w400,
          //       fontSize: 14,
          //       paddingLeft: 20,
          //     ),
          //     MyText(
          //       text: " ",
          //       fontWeight: FontWeight.w500,
          //       paddingRight: 20,
          //     ),
          //   ],
          // ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyText(
                text: "${"Sub-Total".tr} :",
                fontWeight: FontWeight.w500,
                paddingLeft: 20,
              ),
              MyText(
                text: "\$${((double.tryParse(apiController.selectedOrderData.value.order.totalCost) ?? 0.0) / 108.87 * 100).toStringAsFixed(2)}",
                fontWeight: FontWeight.w500,
                paddingRight: 20,
              ),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyText(
                text: "${"Sales Tax(8.875%)".tr}:",
                fontWeight: FontWeight.w500,
                paddingLeft: 20,
              ),
              MyText(
                text:
                    "\$${((double.tryParse(apiController.selectedOrderData.value.order.totalCost) ?? 0.0) - (double.tryParse(apiController.selectedOrderData.value.order.totalCost) ?? 0.0) / 108.87 * 100).toStringAsFixed(2)}",
                fontWeight: FontWeight.w500,
                paddingRight: 20,
              ),
            ],
          ),
          const SizedBox(height: 15),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     MyText(
          //       text: "Sales Tax (9%):",
          //       fontWeight: FontWeight.w500,
          //       paddingLeft: 20,
          //     ),
          //     MyText(
          //       // text: "\$11.60",
          //       text: "${apiController.orderViewList[index].order.totalCost}",
          //       fontWeight: FontWeight.w500,
          //       paddingRight: 20,
          //     ),
          //   ],
          // ),
          // const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyText(
                text: "${"Total".tr}:",
                fontWeight: FontWeight.w600,
                paddingLeft: 20,
              ),
              MyText(
                text: "\$${apiController.selectedOrderData.value.order.totalCost}",
                fontWeight: FontWeight.w600,
                paddingRight: 20,
              ),
            ],
          ),
          // const SizedBox(height: 10),
          const SizedBox(height: 30),
          //+Button Row moved up in the BottomAppBar
        ],
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

// cancelled => Reject Order & accept => Accept Order & cancel => Cancel Order
// delivered,process,cancelled,new,out_to_deliver,accept,cancel,missed,ready
