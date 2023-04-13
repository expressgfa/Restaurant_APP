import 'dart:async';
import 'dart:developer';

import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resturantapp/constant/all_controller.dart';
import 'package:resturantapp/my_logger.dart';
import 'package:resturantapp/utils/custom_scroll_behavior.dart';
import 'package:resturantapp/utils/helper.dart';
import 'package:resturantapp/utils/shared_pref.dart';
import 'package:resturantapp/views/home/all_order_detail_page.dart';
import 'package:resturantapp/views/widgets/my_text.dart';

class ReadyOrderPage extends StatefulWidget {
  const ReadyOrderPage({Key? key}) : super(key: key);

  @override
  State<ReadyOrderPage> createState() => _ReadyOrderPageState();
}

class _ReadyOrderPageState extends State<ReadyOrderPage> {
  final readyOrdersScrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    readyOrdersScrollController.addListener(() {
      if (readyOrdersScrollController.position.maxScrollExtent == readyOrdersScrollController.offset) {
        apiController.getPaginatedReadyOrderData();
      }
    });


    if (apiController.readyOrderList.isEmpty) {
      // errorLog("apiController.acceptedOrderList.isEmpty: ${apiController.acceptedOrderList}");
      apiController.getPaginatedReadyOrderData();
    }


    apiController.readyOrderTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      // errorLog("readyOrderTimer called");
      String email = LocalSharedPrefDatabase.getUserEmail() ?? "";
      if (email.isNotEmpty) {
        apiController.getUpdatedInitialReadyOrderData();
      } else {
        verboseLog("cancelling readyOrderTimer timer");
        timer.cancel();
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    // if(readyOrderTimer.isActive) readyOrderTimer.cancel();
    log("dispose called on ready page");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Obx(() {
            if (apiController.readyOrderList.isNotEmpty) {
              return ScrollConfiguration(
                behavior: MyCustomScrollBehavior(),
                child: ListView.builder(
                  controller: readyOrdersScrollController,
                  itemCount: apiController.readyOrderList.length < 10
                      ? apiController.readyOrderList.length
                      : apiController.readyOrderList.length + 1,
                  // physics: const BouncingScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    if (index < apiController.readyOrderList.length) {
                      return GestureDetector(
                        onTap: () {
                          Get.to(() => AllOrderDetailsPage(orderId: apiController.readyOrderList[index].orderId ?? "232", index: index,));
                        },
                        child: Column(
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey[100],
                                child: const Icon(
                                  Icons.shopping_bag,
                                  color: Colors.black54,
                                ),
                              ),
                              title: MyText(
                                text: (apiController.readyOrderList[index].customerName ?? ""),
                                    // (apiController.readyOrderList[index].orderId ?? ""),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              subtitle: MyText(
                                text: getStatus(apiController.readyOrderList[index].status ?? "").tr,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              trailing: MyText(
                                text: "\$ ${apiController.readyOrderList[index].totalCost}",
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const Divider(),
                          ],
                        ),
                      );
                    } else {
                      return Obx(() {
                        if (!apiController.isLoadingReady.value) {
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
            return Center(
              child: Text("No orders to show".tr),
            );
          }),
        ),
      ],
    );
  }
}
