import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:resturantapp/constant/app_constant.dart';
import 'package:resturantapp/controller/audio_controller/audio_feedback_provider.dart';
import 'package:resturantapp/controller/base_controller.dart';
import 'package:resturantapp/data/local_hive_database.dart';
import 'package:resturantapp/model/item_model.dart';
import 'package:resturantapp/model/menu_model.dart';
import 'package:resturantapp/model/order_model.dart';
import 'package:resturantapp/model/order_view_model.dart';
import 'package:resturantapp/model/site_data_model/site_model.dart';
import 'package:resturantapp/my_logger.dart';
import 'package:resturantapp/services/base_client.dart';
import 'package:resturantapp/utils/shared_pref.dart';
import 'package:resturantapp/utils/snack_bar.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ApiController extends GetxController with BaseController {
  static ApiController instance = Get.find<ApiController>();

  SiteInfo siteData = SiteInfo();

  late Timer inProgressTimer;
  late Timer readyOrderTimer;
  late Timer allOrdersTimer;


  Map<String, Timer?> myNewOrderBackgroundTimers = {};
  Map<String, Timer?> myNewOrderFOREGROUNDTimers = {};
  Map<String, int> myNewOrdersSeconds = {};

  bool isAppInBackground = false;
  RxBool isAcceptDisabled = true.obs;
  RxBool isCreatingTestOrderDisabled = false.obs;

  TextEditingController msgController = TextEditingController();
  RxString selectedReason = "".obs;
  String messageControllerText = "";
  List<String> reasonList = [
    "",
    "No specific reason",
    "Canceled by client",
    "Out of item(s)",
    "Custom message",
  ];

  List<String> rejectReasonList = [
    "",
    "No specific reason",
    "We are busy",
    "Out of item(s)",
    "Custom message",
  ];

  Rx<TextEditingController> timeController = TextEditingController().obs;
  final int perPage = 10;
  int offset = 0;
  int inProgressOrderOffset = 0;
  int readyOrderOffset = 0;
  RxBool isLoadingAcceptedInProgress = false.obs;
  RxBool isLoadingReady = false.obs;
  RxBool isLoadingAccepted = false.obs;

  List<String> deletedOrderIdsList = [];
  Map<String, bool> isAnsweredMap = {};
  Map<String, bool> secondPageTimerValMap = {};
  Map<String, int> secsOfAnOrderMap = {};

  // bool isAnswered = false;
  // bool isOnSecondPage = false;
  // int newOrdersNewItemsCount = 0;
  // List<bool> isAnsweredList = [];
  // Map<String, int> ranForMap = {};
  // Map<String, bool> timerValMap = {};
  // Map<String, int> backgroundSecsOfAnOrderMap = {};
  // Map<String, Map<String, bool>> timerValMapExtended = {};
  // Map<String, Map<String, bool>> backgroundTimerValMapExtended = {};
  // Map<String, bool> backgroundSecondPageTimerValMap = {}; //! not really being used

  RxList<Rx<OrderModel>> newOrdersList = <Rx<OrderModel>>[].obs;

  // RxList<OrderModel> orderList = List<OrderModel>.empty().obs;
  RxList<OrderModel> ordersList = <OrderModel>[].obs;

  //+ newOrderData - non paginated data
  Future<List<Rx<OrderModel>>> getNewOrderData() async {
    log("get getNewOrderData");
    var response = await BaseClient().get(baseUrl, newOrderEndpoint).catchError(handleError);
    if (response == null) return [];
    // log("new order response   $nextLine $response");
    // log(" $nextLine  Response data   $nextLine ${response['data']}");
    log("response body ------------ : $response");
    if (response['data'] != null) {
      List tempList = response['data'];

      newOrdersList.clear();
      // isAnsweredList.clear();
      isAnsweredMap.clear();
      for (var newOrder in tempList) {
        // newOrdersNewItemsCount++;
        newOrdersList.add(OrderModel.fromJson(newOrder).obs);
        // isAnsweredList.add(false);
        log('newOrder["orderId"]: ${newOrder["order_id"]}');
        isAnsweredMap.putIfAbsent((newOrder["order_id"] ?? ""), () => false);
        inProgressOrderList.removeWhere((acceptedOrder) => acceptedOrder.orderId == newOrder.orderId);
      }
      for (var order in newOrdersList) {
        log("just went IN background checking order: ${order.value.orderId}");
        if (!myNewOrderFOREGROUNDTimers.containsKey(order.value.orderId) && order.value.status == "new") {
          //! calculating seconds
          AudioFeedback.playSuccessSound(); //+ to ring when the order comes in
          tz.initializeTimeZones();
          var detroit = tz.getLocation('America/Los_Angeles');
          var now = tz.TZDateTime.now(detroit);
          log("BACKGROUND Los Angeles timeL ==: $now");
          Duration timeDifference = const Duration(seconds: 0);
          timeDifference = DateTime.parse("${now.toIso8601String().split(".")[0]}.000")
              .difference(order.value.dateCreated ?? DateTime.parse("${now.toIso8601String().split(".")[0]}.000"));
          log("BACKGROUND timeDifference on details page init: ${timeDifference.inSeconds}");
          log("BACKGROUND .newOrderList[index].dateCreated: ${order.value.dateCreated}");
          int acceptSecs = 180 - timeDifference.inSeconds;
          // backgroundSecondPageTimerValMap.clear();
          //! -------------------
          myNewOrdersSeconds.putIfAbsent(order.value.orderId ?? "", () => acceptSecs);
          myNewOrderFOREGROUNDTimers.putIfAbsent(
            order.value.orderId ?? "",
                () => Timer.periodic(
              const Duration(seconds: 1),
                  (timer) {
                int ranFor = (myNewOrdersSeconds[order.value.orderId] ?? 0) - timer.tick;
                if (ranFor >= 60) {
                  if (timer.tick % 7 == 0) {
                    debugLog("ranFor: ------------------------------------ $ranFor");
                    // if (!checkableIsAnsweredOuter && !apiController.isOnSecondPage) {
                    log("BACKGROUND MULTIPLE OF 7 and timeElapsed.inSeconds: ${timer.tick} at "
                        "orderId: ${order.value.orderId}");
                    String email = LocalSharedPrefDatabase.getUserEmail() ?? "";
                    if (ranFor >= 0 && email.isNotEmpty) {
                      wtfLog("Get.currentRoute in timer part ${Get.currentRoute} and "
                          "selectedOrderData.value.order.orderId: ${selectedOrderData.value.order.orderId} "
                          "order.value.orderId");
                      if (Get.currentRoute != "/AllOrderDetailsPage" ||
                          (Get.currentRoute == "/AllOrderDetailsPage" && selectedOrderData.value.order.orderId != order.value.orderId)) {
                        AudioFeedback.playSuccessSound();
                        log("BACKGROUND playing sound now");
                      }
                    }
                  }
                } else {
                  if (timer.tick % 3 == 0) {
                    debugLog("BACKGROUND ranFor: ------------------------------------ $ranFor");
                    log("BACKGROUND MULTIPLE OF 3 and timeElapsed.inSeconds: ${timer.tick} at"
                        "orderId: ${order.value.orderId}");
                    String email = LocalSharedPrefDatabase.getUserEmail() ?? "";
                    if (ranFor >= 0) {
                      log("BACKGROUND 3 part playing sound now");
                      if (email.isNotEmpty && (Get.currentRoute != "/AllOrderDetailsPage" ||
                          (Get.currentRoute == "/AllOrderDetailsPage" && selectedOrderData.value.order.orderId != order.value.orderId))) {
                        AudioFeedback.playSuccessSound();
                        log("BACKGROUND playing sound now");
                      }
                    } else {
                      errorLog("BACKGROUND ---------- canceling timer ----------");
                      missOrder(
                        order.value.orderId ?? "201",
                        newOrdersList.indexWhere(
                              (element) => element.value.orderId == order.value.orderId,
                        ),
                      );
                      timer.cancel();
                    }
                    // } else {
                    //   log("in main timer check 3 else means one of the vars was true.");
                    //   log("checkableIsAnsweredThree: $checkableIsAnsweredThree");
                    //   log("apiController.isOnSecondPage: ${apiController.isOnSecondPage}");
                    //   log("apiController.isAnsweredMap: ${apiController.isAnsweredMap}");
                    // }
                  }
                }
              },
            ),
          );
        }
      }
      log("newOrderList.length is: ${newOrdersList.length}");
    }
    return newOrdersList;
  }

  Future<List<Rx<OrderModel>>> getUpdatedInitialNewOrderData() async {
    // log("get getUpdatedInitialNewOrderData Called");
    var response = await BaseClient().get(baseUrl, newOrderEndpoint).catchError(handleError);
    if (response == null) return [];

    // log("new order response   $nextLine $response");

    String result = response.containsKey("responce")
        ? response["responce"].containsKey("status")
            ? response["responce"]["status"]
            : ""
        : "error";

    // warningLog(" result result result in getUpdatedInitialNewOrderData : $result}");

    if (result == "success") {
      // log(" $nextLine  Response data   $nextLine ${response['data']}");
      List tempList = response['data'];
      // errorLog("in success");
      // log(" $nextLine  Response data   $nextLine ${response['data']}");

      // log("tempList.length in new order update method: ${tempList.length}");
      List<OrderModel> tempNewOrderList = <OrderModel>[];
      // log("Clearing list");
      for (var element in tempList) {
        tempNewOrderList.add(OrderModel.fromJson(element));
      }

      if (tempNewOrderList.isNotEmpty) {
        for (var tempNewOrder in tempNewOrderList) {
          // log("newOrderList.firstWhere((element) => element.orderId == tempNewOrder.orderId).orderId == null: "
          //     "${newOrderList.firstWhere((element) => element.orderId == tempNewOrder.orderId, orElse: () => OrderModel()).orderId == null}");
          // log("newOrderList.firstWhere((element) => element.orderId == tempNewOrder.orderId).orderIdl: "
          //     "${newOrderList.firstWhere((element) => element.orderId == tempNewOrder.orderId, orElse: () => OrderModel()).orderId}");

          // if (newOrderList.isNotEmpty) {
          if (newOrdersList.firstWhere((element) => element.value.orderId == tempNewOrder.orderId,
              orElse: () => OrderModel().obs).value.orderId == null ||
              (newOrdersList.firstWhere((element) => element.value.orderId == tempNewOrder.orderId,
                  orElse: () => OrderModel().obs).value.orderId?.isEmpty ??
                  true)) {
            // verboseLog("inside the new order auto update list if for ${tempNewOrder.orderId}");
            // newOrdersNewItemsCount++;
            newOrdersList.add(tempNewOrder.obs);
            // isAnsweredList.add(false);
            // newOrdersList.insert(0, tempNewOrder.obs);
            // isAnsweredList.insert(0, false);
            isAnsweredMap.putIfAbsent(tempNewOrder.orderId ?? "", () => false);
            // log("isAnsweredList after insert in main New List updating: $isAnsweredList");
            log("isAnsweredMap after insert in main New List updating: $isAnsweredMap>");
            //+ I don't really have an explanation for this below line
            inProgressOrderList.removeWhere((acceptedOrder) => acceptedOrder.orderId == tempNewOrder.orderId);

            //+ ----------------------------------- this part is experimental -----------------------------------

            isAppInBackground = false;
            //! means now it would never go in here.
            if (isAppInBackground) {
              myNewOrderFOREGROUNDTimers.forEach((key, value) {
                if (value != null) value.cancel();
              });
              wtfLog("IN NEW ORDER LIST UPDATE WALa FUNCTION isAppInBackground");
              // myNewOrdersSeconds.clear();
              // myNewOrderBackgroundTimers.clear();
              for (var order in newOrdersList) {
                log("just went IN background checking order: ${order.value.orderId}");
                if (!myNewOrderBackgroundTimers.containsKey(order.value.orderId)) {
                  //! calculating seconds
                  tz.initializeTimeZones();
                  var detroit = tz.getLocation('America/Los_Angeles');
                  var now = tz.TZDateTime.now(detroit);
                  log("BACKGROUND Los Angeles timeL ==: $now");
                  Duration timeDifference = const Duration(seconds: 0);
                  timeDifference = DateTime.parse("${now.toIso8601String().split(".")[0]}.000")
                      .difference(order.value.dateCreated ?? DateTime.parse("${now.toIso8601String().split(".")[0]}.000"));
                  log("BACKGROUND timeDifference on details page init: ${timeDifference.inSeconds}");
                  log("BACKGROUND apiController.newOrderList[index].dateCreated: ${order.value.dateCreated}");
                  int acceptSecs = 180 - timeDifference.inSeconds;
                  // backgroundSecondPageTimerValMap.clear();
                  //! -------------------
                  myNewOrdersSeconds.putIfAbsent(order.value.orderId ?? "", () => acceptSecs);
                  myNewOrderBackgroundTimers.putIfAbsent(
                    order.value.orderId ?? "",
                    () => Timer.periodic(
                      const Duration(seconds: 1),
                      (timer) {
                        int ranFor = (myNewOrdersSeconds[order.value.orderId] ?? 0) - timer.tick;
                        if (ranFor >= 60) {
                          if (timer.tick % 7 == 0) {
                            debugLog("ranFor: ------------------------------------ $ranFor");
                            // if (!checkableIsAnsweredOuter && !apiController.isOnSecondPage) {
                            log("BACKGROUND MULTIPLE OF 7 and timeElapsed.inSeconds: ${timer.tick} at "
                                "orderId: ${order.value.orderId}");
                            if (ranFor >= 0) {
                              log("BACKGROUND playing sound now");
                              AudioFeedback.playSuccessSound();
                            }
                          }
                        } else {
                          if (timer.tick % 3 == 0) {
                            debugLog("BACKGROUND ranFor: ------------------------------------ $ranFor");
                            log("BACKGROUND MULTIPLE OF 3 and timeElapsed.inSeconds: ${timer.tick} at"
                                "orderId: ${order.value.orderId}");
                            if (ranFor >= 0) {
                              log("BACKGROUND 3 part playing sound now");
                              AudioFeedback.playSuccessSound();
                            } else {
                              errorLog("BACKGROUND ---------- canceling timer ----------");
                              missOrder(
                                order.value.orderId ?? "201",
                                newOrdersList.indexWhere(
                                  (element) => element.value.orderId == order.value.orderId,
                                ),
                              );
                              timer.cancel();
                            }
                            // } else {
                            //   log("in main timer check 3 else means one of the vars was true.");
                            //   log("checkableIsAnsweredThree: $checkableIsAnsweredThree");
                            //   log("apiController.isOnSecondPage: ${apiController.isOnSecondPage}");
                            //   log("apiController.isAnsweredMap: ${apiController.isAnsweredMap}");
                            // }
                          }
                        }
                      },
                    ),
                  );
                }
              }
            } else {
              // + 000000000000000000000000000000000000000000000000000000000000000000000
              for (var order in newOrdersList) {
                log("just went IN background checking order: ${order.value.orderId}");
                if (!myNewOrderFOREGROUNDTimers.containsKey(order.value.orderId) && order.value.status == "new") {
                  //! calculating seconds
                  AudioFeedback.playSuccessSound(); //+ to ring when the order comes in
                  tz.initializeTimeZones();
                  var detroit = tz.getLocation('America/Los_Angeles');
                  var now = tz.TZDateTime.now(detroit);
                  log("BACKGROUND Los Angeles timeL ==: $now");
                  Duration timeDifference = const Duration(seconds: 0);
                  timeDifference = DateTime.parse("${now.toIso8601String().split(".")[0]}.000")
                      .difference(order.value.dateCreated ?? DateTime.parse("${now.toIso8601String().split(".")[0]}.000"));
                  log("BACKGROUND timeDifference on details page init: ${timeDifference.inSeconds}");
                  log("BACKGROUND .newOrderList[index].dateCreated: ${order.value.dateCreated}");
                  int acceptSecs = 180 - timeDifference.inSeconds;
                  // backgroundSecondPageTimerValMap.clear();
                  //! -------------------
                  myNewOrdersSeconds.putIfAbsent(order.value.orderId ?? "", () => acceptSecs);
                  myNewOrderFOREGROUNDTimers.putIfAbsent(
                    order.value.orderId ?? "",
                    () => Timer.periodic(
                      const Duration(seconds: 1),
                      (timer) {
                        int ranFor = (myNewOrdersSeconds[order.value.orderId] ?? 0) - timer.tick;
                        if (ranFor >= 60) {
                          if (timer.tick % 7 == 0) {
                            debugLog("ranFor: ------------------------------------ $ranFor");
                            // if (!checkableIsAnsweredOuter && !apiController.isOnSecondPage) {
                            log("BACKGROUND MULTIPLE OF 7 and timeElapsed.inSeconds: ${timer.tick} at "
                                "orderId: ${order.value.orderId}");
                            String email = LocalSharedPrefDatabase.getUserEmail() ?? "";
                            if (ranFor >= 0 && email.isNotEmpty) {
                              wtfLog("Get.currentRoute in timer part ${Get.currentRoute} and "
                                  "selectedOrderData.value.order.orderId: ${selectedOrderData.value.order.orderId} "
                                  "order.value.orderId");
                              if (Get.currentRoute != "/AllOrderDetailsPage" ||
                                  (Get.currentRoute == "/AllOrderDetailsPage" && selectedOrderData.value.order.orderId != order.value.orderId)) {
                                AudioFeedback.playSuccessSound();
                                log("BACKGROUND playing sound now");
                              }
                            }
                          }
                        } else {
                          if (timer.tick % 3 == 0) {
                            debugLog("BACKGROUND ranFor: ------------------------------------ $ranFor");
                            log("BACKGROUND MULTIPLE OF 3 and timeElapsed.inSeconds: ${timer.tick} at"
                                "orderId: ${order.value.orderId}");
                            String email = LocalSharedPrefDatabase.getUserEmail() ?? "";
                            if (ranFor >= 0) {
                              log("BACKGROUND 3 part playing sound now");
                              if (email.isNotEmpty && (Get.currentRoute != "/AllOrderDetailsPage" ||
                                  (Get.currentRoute == "/AllOrderDetailsPage" && selectedOrderData.value.order.orderId != order.value.orderId))) {
                                  AudioFeedback.playSuccessSound();
                                  log("BACKGROUND playing sound now");
                              }
                            } else {
                              errorLog("BACKGROUND ---------- canceling timer ----------");
                              missOrder(
                                order.value.orderId ?? "201",
                                newOrdersList.indexWhere(
                                  (element) => element.value.orderId == order.value.orderId,
                                ),
                              );
                              timer.cancel();
                            }
                            // } else {
                            //   log("in main timer check 3 else means one of the vars was true.");
                            //   log("checkableIsAnsweredThree: $checkableIsAnsweredThree");
                            //   log("apiController.isOnSecondPage: ${apiController.isOnSecondPage}");
                            //   log("apiController.isAnsweredMap: ${apiController.isAnsweredMap}");
                            // }
                          }
                        }
                      },
                    ),
                  );
                }
              }
            }

            //+ ----------------------------------- this part is experimental -----------------------------------

          } else {
            //+ means that it is already in the list and probably with a different status
            verboseLog("in new orders auto update data else: ${tempNewOrder.orderId}");
            int indexOfItem = newOrdersList.indexWhere((element) => element.value.orderId == tempNewOrder.orderId);
            verboseLog("indexOfItem: $indexOfItem and "
                "tempNewOrder.status: ${tempNewOrder.status} && "
                "tempNewOrder.orderId: ${tempNewOrder.orderId}");
            newOrdersList.removeAt(indexOfItem);
            newOrdersList.insert(indexOfItem, tempNewOrder.obs);
            if(tempNewOrder.status != "new") {
              myNewOrderFOREGROUNDTimers[tempNewOrder.orderId]?.cancel();
              myNewOrderFOREGROUNDTimers.remove(tempNewOrder.orderId);
            }

            // if (tempNewOrder.status != "new") {
            //   newOrdersNewItemsCount--;
            // } else if (tempNewOrder.status == "new") {
            //   newOrdersNewItemsCount++;
            // }
          }
          // }
        }
      } else {
        await getUpdatedInitialOrderData();
          myNewOrderFOREGROUNDTimers.forEach((key, value) { 
            value?.cancel();
          });
          myNewOrderFOREGROUNDTimers.clear();
        newOrdersList.clear();
        // newOrdersNewItemsCount = 0;
      }
      //! removing

      // List<OrderModel> newOrdersListDuplicate = [];
      // newOrdersListDuplicate.addAll(newOrdersList);
      // for (var alreadyAddedOrder in newOrdersListDuplicate) {
      //   // if (newOrderList.isNotEmpty) {
      //   if (tempNewOrderList
      //               .firstWhere((element) => element.orderId == alreadyAddedOrder.orderId, orElse: () => OrderModel())
      //               .orderId ==
      //           null ||
      //       (tempNewOrderList
      //               .firstWhere((element) => element.orderId == alreadyAddedOrder.orderId, orElse: () => OrderModel())
      //               .orderId
      //               ?.isEmpty ??
      //           true)) {
      //     log("inside the new order list if");
      //     newOrdersList.removeWhere((element) => element.orderId == alreadyAddedOrder.orderId);
      //   }
      // }
      // }
    } else if (result == "error") {
      await getUpdatedInitialOrderData();
      myNewOrderFOREGROUNDTimers.forEach((key, value) {
        value?.cancel();
      });
      myNewOrderFOREGROUNDTimers.clear();
      // errorLog("result == \"error\"");
      newOrdersList.clear(); //+ we need to do this because this is the response when there is no new order remaining.
      // newOrdersNewItemsCount = 0;
    }
    return newOrdersList;
  }

  //+getOrderData
  Future<List<OrderModel>> getPaginatedOrderData({bool enforceOffset = false}) async {
    // log("get Data Called");
    isLoadingAccepted.value = true;
    // showLoading('Fetching data');

    Map<String, dynamic> queryParameters = {
      "per_page": perPage.toString(),
      "offset": enforceOffset ? "0" : offset.toString(),
      "order_by_id": "DESC",
    };

    try {
      var url = Uri.https(baseUrlForHttp, orderEndpoint, queryParameters);
      // log("url: $url");
      var response = await http.get(url);

      if (response == null) return [];

      var jsonResponse = jsonDecode(response.body);

      String result = jsonResponse.containsKey("responce")
          ? jsonResponse["responce"].containsKey("status")
              ? jsonResponse["responce"]["status"]
              : ""
          : "error";

      // log(" $nextLine  Response data   $nextLine ${jsonResponse['data']}");

      if (result == "success") {
        List tempList = jsonResponse['data'];
        // log("tempList.length: ${tempList.length}");

        // orderList.clear();
        // log("Clearing list");

        // orderList.forEach((element) {
        //   log("after clear ${element.toJson()}");
        // });
        log("deletedOrderIdsList ${deletedOrderIdsList.toString()}");

        // deletedOrderIdsList.forEach((element) {
        // });
        for (var element in tempList) {
          if (element['status'] != "new" && !deletedOrderIdsList.contains(element['order_id'])) {
            ordersList.add(OrderModel.fromJson(element));
          }
        }
        offset += perPage;
        isLoadingAccepted.value = false;
      } else if (result == "error") {
        isLoadingAccepted.value = false;
      }
    } catch (e) {
      log("error in getPaginatedOrderData: $e");
    }

    // hideLoading();

    return ordersList;
  }

  Future<List<OrderModel>> getUpdatedInitialOrderData() async {
    // log("get getUpdatedInitialOrderData Called");
    Map<String, dynamic> queryParameters = {
      "per_page": perPage.toString(),
      "offset": "0",
      "order_by_id": "DESC",
    };

    try {
      var url = Uri.https(baseUrlForHttp, orderEndpoint, queryParameters);
      // log("url: $url");
      var response = await http.get(url);
      if (response == null) return [];
      var jsonResponse = jsonDecode(response.body);

      String result = jsonResponse.containsKey("responce")
          ? jsonResponse["responce"].containsKey("status")
              ? jsonResponse["responce"]["status"]
              : ""
          : "error";

      if (result == "success") {
        // log(" $nextLine  Response data getUpdatedInitialOrderData  $nextLine ${jsonResponse['data']}");

        List tempList = jsonResponse['data'];
        // log("tempList.length: ${tempList.length}");
        List<OrderModel> tempOrderList = <OrderModel>[];

        // log("Clearing list");
        for (var element in tempList) {
          tempOrderList.add(OrderModel.fromJson(element));
        }

        for (var tempOrder in tempOrderList) {
          // log("orderList.firstWhere((element) => element.orderId == tempOrder.orderId).orderId == null: "
          //     "${orderList.firstWhere((element) => element.orderId == tempOrder.orderId, orElse: () => OrderModel()).orderId == null}");
          // log("orderList.firstWhere((element) => element.orderId == tempNewOrder.orderId).orderIdl: "
          //     "${orderList.firstWhere((element) => element.orderId == tempOrder.orderId, orElse: () => OrderModel()).orderId}");

          // if (orderList.isNotEmpty) {
          if (ordersList.firstWhere((element) => element.orderId == tempOrder.orderId, orElse: () => OrderModel()).orderId == null ||
              (ordersList.firstWhere((element) => element.orderId == tempOrder.orderId, orElse: () => OrderModel()).orderId?.isEmpty ?? true)) {
            log("inside the new order list if");
            if (tempOrder.status != "new" && !deletedOrderIdsList.contains(tempOrder.orderId)) {
              ordersList.insert(0, tempOrder);
            }
          } else {
            int index = ordersList.indexWhere((element) => element.orderId == tempOrder.orderId);
            ordersList[index] = tempOrder;
          }

          if (newOrdersList.firstWhere((element) => element.value.orderId == tempOrder.orderId, orElse: () => OrderModel().obs).value.orderId != null &&
              (newOrdersList.firstWhere((element) => element.value.orderId == tempOrder.orderId, orElse: () => OrderModel().obs).value.orderId?.isNotEmpty ??
                  true)) {
            int indexOfItem = newOrdersList.indexWhere((element) => element.value.orderId == tempOrder.orderId);
            // verboseLog("indexOfItem: $indexOfItem and "
            //     "tempNewOrder.status: ${tempOrder.status} && "
            //     "tempNewOrder.orderId: ${tempOrder.orderId}");
            newOrdersList.removeAt(indexOfItem);
            newOrdersList.insert(indexOfItem, tempOrder.obs);
            if (tempOrder.status != "new") {
              // newOrdersNewItemsCount--;
            }
            // else if (tempOrder.status == "new") {
            //   newOrdersNewItemsCount++;
            // }
            // newOrdersNewItemsCount++;
          }

          // }
        }
      }
    } catch (e) {
      log("error in getUpdatedInitialOrderData: $e");
    }

    return ordersList;
  }

  //+inProgressOrderList
  RxList<OrderModel> inProgressOrderList = <OrderModel>[].obs;

  Future<List<OrderModel>> getPaginatedInProgressOrderData() async {
    log("get getInProgressOrderPaginatedData Called");
    isLoadingAcceptedInProgress.value = true;

    // var response = await BaseClient().get(baseUrl, acceptOrderEndpoint).catchError(handleError);
    // if (response == null) return [];

    Map<String, dynamic> queryParameters = {
      "order_type": "accept",
      "per_page": perPage.toString(),
      "offset": inProgressOrderOffset.toString(),
      "order_by_id": "DESC",
    };

    try {
      var url = Uri.https(baseUrlForHttp, acceptOrderEndpoint, queryParameters);
      // log("url: $url");
      var response = await http.get(url);

      if (response == null) return [];

      var jsonResponse = jsonDecode(response.body);

      // String result = jsonResponse['responce']['status'];

      String result = jsonResponse.containsKey("responce")
          ? jsonResponse["responce"].containsKey("status")
              ? jsonResponse["responce"]["status"]
              : ""
          : "error";

      // log(" $nextLine  Response data   $nextLine ${jsonResponse['data']}");

      if (result == "success") {
        // log(" $nextLine  Response data   $nextLine ${jsonResponse['data']}");

        List tempList = jsonResponse['data'];
        // log("tempList.length: ${tempList.length}");

        // log("Clearing list");

        if (inProgressOrderOffset == 0) {
          inProgressOrderList.clear();
        }

        // orderList.forEach((element) {
        //   log("after clear ${element.toJson()}");
        // });
        for (var element in tempList) {
          inProgressOrderList.add(OrderModel.fromJson(element));
        }
        inProgressOrderOffset += perPage;
      } else if (result == "error") {
        isLoadingAcceptedInProgress.value = false;
      }
    } catch (e) {
      log("error in getInProgressOrderPaginatedData: $e");
    }
    return inProgressOrderList;
  }

  Future<List<OrderModel>> getUpdatedInitialInProgressOrderData() async {
    // log("get getUpdatedInitialInProgressOrderData Called");
    Map<String, dynamic> queryParameters = {
      "order_type": "accept",
      "per_page": perPage.toString(),
      "offset": "0",
      "order_by_id": "DESC",
    };

    try {
      var url = Uri.https(baseUrlForHttp, acceptOrderEndpoint, queryParameters);
      // log("url: $url");
      var response = await http.get(url);
      if (response == null) return [];
      var jsonResponse = jsonDecode(response.body);

      String result = jsonResponse.containsKey("responce")
          ? jsonResponse["responce"].containsKey("status")
              ? jsonResponse["responce"]["status"]
              : ""
          : "error";

      if (result == "success") {
        // log(" $nextLine  Response data   $nextLine ${jsonResponse['data']}");

        List tempList = jsonResponse['data'];
        // log("tempList.length: ${tempList.length}");
        List<OrderModel> tempOrderList = <OrderModel>[];

        // log("Clearing list");
        for (var element in tempList) {
          tempOrderList.add(OrderModel.fromJson(element));
        }

        for (var tempOrder in tempOrderList) {
          // log("orderList.firstWhere((element) => element.orderId == tempOrder.orderId).orderId == null: "
          //     "${orderList.firstWhere((element) => element.orderId == tempOrder.orderId, orElse: () => OrderModel()).orderId == null}");
          // log("orderList.firstWhere((element) => element.orderId == tempNewOrder.orderId).orderIdl: "
          //     "${orderList.firstWhere((element) => element.orderId == tempOrder.orderId, orElse: () => OrderModel()).orderId}");

          // if (acceptOrderList.isNotEmpty) {
          if (inProgressOrderList.firstWhere((element) => element.orderId == tempOrder.orderId, orElse: () => OrderModel()).orderId == null ||
              (inProgressOrderList.firstWhere((element) => element.orderId == tempOrder.orderId, orElse: () => OrderModel()).orderId?.isEmpty ?? true)) {
            log("inside the new order list if adding tempOrder.orderId: ${tempOrder.orderId} with time: ");
            log("time: ${tempOrder.dateCreated?.millisecondsSinceEpoch}");
            log("FIRST time: ${inProgressOrderList.first.dateCreated?.millisecondsSinceEpoch}");
            log("IF FIRST time < new time CHECK: ${(inProgressOrderList.first.dateCreated?.millisecondsSinceEpoch ?? 0) < (tempOrder.dateCreated?.millisecondsSinceEpoch ?? 0)}}");
            if ((inProgressOrderList.first.dateCreated?.millisecondsSinceEpoch ?? 0) < (tempOrder.dateCreated?.millisecondsSinceEpoch ?? 0)) {
              inProgressOrderList.insert(0, tempOrder);
            } else {
              inProgressOrderList.add(tempOrder);
            }
          } else {
            int index = inProgressOrderList.indexWhere((element) => element.orderId == tempOrder.orderId);
            inProgressOrderList[index] = tempOrder;
          }
          // }
        }
      }
    } catch (e) {
      log("error in getUpdatedInitialInProgressOrderData: $e");
    }
    return inProgressOrderList;
  }

  //+getReadyOrderData
  RxList<OrderModel> readyOrderList = <OrderModel>[].obs;

  Future<List<OrderModel>> getPaginatedReadyOrderData() async {
    log("get getReadyOrderPaginatedData Called with offset: $readyOrderOffset");
    isLoadingReady.value = true;

    // var response = await BaseClient().get(baseUrl, acceptOrderEndpoint).catchError(handleError);
    // if (response == null) return [];

    Map<String, dynamic> queryParameters = {
      "order_type": "delivered",
      "per_page": perPage.toString(),
      "offset": readyOrderOffset.toString(),
      "order_by_id": "DESC",
    };

    try {
      var url = Uri.https(baseUrlForHttp, readyOrderEndpoint, queryParameters);
      // log("url: $url");
      var response = await http.get(url);

      if (response == null) return [];

      var jsonResponse = jsonDecode(response.body);

      // String result = jsonResponse['responce']['status'];

      String result = jsonResponse.containsKey("responce")
          ? jsonResponse["responce"].containsKey("status")
              ? jsonResponse["responce"]["status"]
              : ""
          : "error";

      if (result == "success") {
        List tempList = jsonResponse['data'];
        // log("tempList.length: ${tempList.length}");

        // log("Clearing list");

        if (readyOrderOffset == 0) {
          readyOrderList.clear();
        }

        for (var element in tempList) {
          readyOrderList.add(OrderModel.fromJson(element));
        }
        // if(readyOrderList.length < 10){
        //   isLoadingReady.value = false;
        // }
        readyOrderOffset += perPage;
      } else if (result == "error") {
        isLoadingReady.value = false;
      }
    } catch (e) {
      log("error in getReadyOrderPaginatedData: $e");
    }
    return readyOrderList;
  }

  Future<List<OrderModel>> getUpdatedInitialReadyOrderData() async {
    // log("get getUpdatedInitialReadyOrderData Called");
    Map<String, dynamic> queryParameters = {
      "order_type": "delivered",
      "per_page": perPage.toString(),
      "offset": "0",
      "order_by_id": "DESC",
    };
    try {
      var url = Uri.https(baseUrlForHttp, readyOrderEndpoint, queryParameters);
      // log("url: $url");
      var response = await http.get(url);
      if (response == null) return [];
      var jsonResponse = jsonDecode(response.body);

      String result = jsonResponse.containsKey("responce")
          ? jsonResponse["responce"].containsKey("status")
              ? jsonResponse["responce"]["status"]
              : ""
          : "error";

      if (result == "success") {
        // log(" $nextLine  Response data in get Updated Ready data   $nextLine ${jsonResponse['data']}");
        List tempList = jsonResponse['data'];
        // log("tempList.length: ${tempList.length}");
        List<OrderModel> tempOrderList = <OrderModel>[];

        // log("Clearing list");
        for (var element in tempList) {
          tempOrderList.add(OrderModel.fromJson(element));
        }

        for (var tempOrder in tempOrderList) {
          // log("readyOrderList.firstWhere((element) => element.orderId == tempOrder.orderId).orderId == null: "
          //     "${readyOrderList.firstWhere((element) => element.orderId == tempOrder.orderId, orElse: () => OrderModel()).orderId == null}");
          // log("readyOrderList.firstWhere((element) => element.orderId == tempNewOrder.orderId).orderIdl: "
          //     "${readyOrderList.firstWhere((element) => element.orderId == tempOrder.orderId, orElse: () => OrderModel()).orderId}");

          // if (readyOrderList.isNotEmpty) {
          if (readyOrderList.firstWhere((element) => element.orderId == tempOrder.orderId, orElse: () => OrderModel()).orderId == null ||
              (readyOrderList.firstWhere((element) => element.orderId == tempOrder.orderId, orElse: () => OrderModel()).orderId?.isEmpty ?? true)) {
            log("inside the new order list if");
            readyOrderList.insert(0, tempOrder);
          } else {
            int index = readyOrderList.indexWhere((element) => element.orderId == tempOrder.orderId);
            readyOrderList[index] = tempOrder;
          }
          // }
        }
      }
    } catch (e) {
      log("error in getUpdatedInitialReadyOrderData: $e");
    }
    return readyOrderList;
  }

  //+getOrderViewData
  RxList<OrderViewModel> orderViewList = <OrderViewModel>[].obs;
  Rx<OrderViewModel> selectedOrderData = OrderViewModel(order: Order()).obs;
  Future<List<OrderViewModel>> getOrderViewData(String orderId) async {
    // showLoading('Fetching data');

    var response = await BaseClient().get(baseUrl, "/order-view?id=$orderId").catchError(handleError);
    if (response == null) return [];

    log("After getting data response in getOrderViewData $nextLine $response");
    log(" $nextLine  Response data in getOrderViewData  $nextLine ${response['data']}");

    try {
      orderViewList.clear();
      orderViewList.add(OrderViewModel.fromJson(response['data']));
      log("orderViewList data length is: ${orderViewList.length}");
      selectedOrderData.value = OrderViewModel.fromJson(response['data']);
    } catch (e) {
      log("$e");
    }
    // log("selectedOrderData...........: ${selectedOrderData.value.order}");
    // for (var element in orderViewList) {
    //   // log(" ----- ------ ---------------- -------------- ${element.toJson()}");
    // }

    return orderViewList;
  }

  //+ missOrder
  Future<void> missOrder(String orderId, int index) async {
    warningLog(
        "missed order called with orderId: $orderId -------------------------- index: $index and newOrdersList[index].seconds: ${newOrdersList[index].value.seconds}");
    // if (newOrdersList[index].value.seconds == 180) {
    var response = await BaseClient().post(baseUrl, updateOrderEndpoint, {
      'order_id': orderId,
      'status': 'missed',
    }).catchError(handleError);

    // String result = response['responce']['status'];
    if (response == null) {
      dismissLoading();
      showMsg(msg: "Something wrong please try again".tr);
      return;
    }

    String result = response.containsKey("responce")
        ? response["responce"].containsKey("status")
            ? response["responce"]["status"]
            : ""
        : "error";

    if (result == "success") {
      // showMsg(msg: orderId + " was missed due to timeout".tr);
      // newOrdersList.removeWhere((element) => element.orderId == orderId);
      getOrderViewData(selectedOrderData.value.order.orderId);
      Rx<OrderModel> order = newOrdersList.firstWhere((element) => element.value.orderId == orderId, orElse: () => OrderModel().obs);
      if (order.value.orderId != null) {
        order.value.status = "missed";
        newOrdersList[index].value.status = "missed";
        // newOrdersNewItemsCount--;
        int insertionIndex = newOrdersList.indexWhere((element) => element.value.orderId == orderId);
        newOrdersList.removeWhere((element) => element.value.orderId == orderId);
        // newOrdersList.removeAt(insertionIndex);
        newOrdersList.insert(insertionIndex, order);
      }

      //+ removing the timers
      myNewOrderFOREGROUNDTimers[orderId]?.cancel();
      myNewOrderFOREGROUNDTimers.remove(orderId);
      // for (var v in newOrdersList) {
      //   warningLog("v.value.status: ${v.value.status}");
      // }
      isAnsweredMap.update(orderId, (value) => true, ifAbsent: () => true);
      // timerValMap.clear();
      // timerValMapExtended.remove(orderId);
      // isAnswered = false;

      int unansweredOrders = newOrdersList.where((p0) => p0.value.status == "new").length;
      if (unansweredOrders == 0) {
        newOrdersList.clear();
        // timerValMapExtended.clear();
      }
      // getUpdatedInitialOrderData(); //+commented because now we are again using the periodic update for this
      // newOrderList[index].status == "missed";
    } else {
      showMsg(
        msg: "Something wrong while updating the order as missed after timeout. Please try again.".tr,
      );
    }
    // } else {
    //   log("time of that order was not 180");
    //   log("seconds: -------------- ${newOrdersList[index].value.seconds}");
    // }
  }

  //+ acceptOrder
  Future<void> acceptOrder(String orderId, String time) async {
    showCircularLoading();
    var response = await BaseClient().post(baseUrl, updateOrderEndpoint, {
      'order_id': orderId,
      'status': 'accept',
      'pickup_time': time,
    }).catchError(handleError);

    // String result = response['responce']['status'];

    if (response == null) {
      dismissLoading();
      showMsg(msg: "Something wrong please try again".tr);
      return;
    }

    errorLog("response: $response in acceptOrder");

    String result = response.containsKey("responce")
        ? response["responce"].containsKey("status")
            ? response["responce"]["status"]
            : ""
        : "error";

    if (result == "success") {
      errorLog("stausssssssssssss:  ${selectedOrderData.value.order.status} ");

      getOrderViewData(selectedOrderData.value.order.orderId);

      // Rx<OrderViewModel> oldOrderData = selectedOrderData;
      // oldOrderData.value.order.status = "accept";
      // selectedOrderData = oldOrderData;
      dismissLoading();
      showMsg(msg: "Order updated successfully".tr);
      timeController.value.clear();
      // newOrdersNewItemsCount--;
      // newOrdersList.removeWhere((element) => element.value.orderId == orderId);

      Rx<OrderModel> order = newOrdersList.firstWhere((element) => element.value.orderId == orderId, orElse: () => OrderModel().obs);
      if (order.value.orderId != null) {
        order.value.status = "accept";
        // newOrdersList[index].value.status = "missed";
        // newOrdersNewItemsCount--;
        int indexToBeUpdated = newOrdersList.indexWhere((element) => element.value.orderId == orderId);
        log("The index we got in accepted order is: $indexToBeUpdated");
        newOrdersList.removeWhere((element) => element.value.orderId == orderId);
        newOrdersList.insert(indexToBeUpdated, order);
      }
      //+ removing the timers
      myNewOrderFOREGROUNDTimers[orderId]?.cancel();
      myNewOrderFOREGROUNDTimers.remove(orderId);
      wtfLog("myNewOrderFOREGROUNDTimers: $myNewOrderFOREGROUNDTimers");
      // timerValMap.clear();
      // isAnsweredMap.putIfAbsent(orderId, () => false);
      log("before accept update AnswerMap is: $isAnsweredMap");
      isAnsweredMap.update(orderId, (value) => true, ifAbsent: () => true);
      log("after accept update AnswerMap is: $isAnsweredMap");
      // isAnswered = false;
      // timerValMapExtended.remove(orderId);
      int unansweredOrders = newOrdersList.where((p0) => p0.value.status == "new").length;
      if (unansweredOrders == 0) {
        newOrdersList.clear();
        // timerValMapExtended.clear();
      }
      // getUpdatedInitialOrderData(); //+commented because now we are again using the periodic update for this
      // getUpdatedInitialInProgressOrderData();
    } else {
      dismissLoading();

      showMsg(msg: "Something wrong please try again".tr);
    }
  }

  //+ rejectOrder
  Future<void> rejectOrder(String orderId) async {
    // String reason = (msgController.text.isNotEmpty) ? msgController.text : selectedReason.value;
    String reason = selectedReason.value == "Custom message" ? messageControllerText : selectedReason.value;
    showCircularLoading();
    var response = await BaseClient().post(baseUrl, updateOrderEndpoint, {
      'order_id': orderId,
      'status': 'cancelled',
      'reject_reason': reason,
    }).catchError(handleError);

    log("response is $response");

    if (response == null) {
      dismissLoading();
      showMsg(msg: "Something wrong please try again".tr);
      return;
    }

    // String result = response['responce']['status'];
    String result = response.containsKey("responce")
        ? response["responce"].containsKey("status")
            ? response["responce"]["status"]
            : ""
        : "error";
    dismissLoading();
    if (result == "success") {
      msgController.clear();
      errorLog("stausssssssssssss:  ${selectedOrderData.value.order.status} and orderId: $orderId");
      getOrderViewData(selectedOrderData.value.order.orderId);

      showMsg(msg: "Order rejected successfully".tr);
      // newOrdersList.removeWhere((element) => element.value.orderId == orderId);
      // newOrdersNewItemsCount--;

      Rx<OrderModel> order = newOrdersList.firstWhere((element) => element.value.orderId == orderId, orElse: () => OrderModel().obs);

      infoLog("order in REJECT IS: ${order.value.orderId}");

      if (order.value.orderId != null) {
        order.value.status = "cancelled";
        // newOrdersList[index].value.status = "missed";
        // newOrdersNewItemsCount--;
        int indexToBeUpdated = newOrdersList.indexWhere((element) => element.value.orderId == orderId);
        log("The index we got in accepted order is: $indexToBeUpdated");
        newOrdersList.removeWhere((element) => element.value.orderId == orderId);
        newOrdersList.insert(indexToBeUpdated, order);
      }

      //+ removing the timers
      wtfLog("myNewOrderFOREGROUNDTimers in reject before:  $myNewOrderFOREGROUNDTimers");
      myNewOrderFOREGROUNDTimers[orderId]?.cancel();
      myNewOrderFOREGROUNDTimers.remove(orderId);
      wtfLog("myNewOrderFOREGROUNDTimers in reject after:  $myNewOrderFOREGROUNDTimers");
      log("before reject update AnswerMap is: $isAnsweredMap");
      isAnsweredMap.update(orderId, (value) => true, ifAbsent: () => true);
      log("after reject update AnswerMap is: $isAnsweredMap");
      // timerValMapExtended.remove(orderId);
      // timerValMap.clear();
      int unansweredOrders = newOrdersList.where((p0) => p0.value.status == "new").length;
      if (unansweredOrders == 0) {
        newOrdersList.clear();
        // timerValMapExtended.clear();
      }
      // getUpdatedInitialOrderData(); //+commented because now we are again using the periodic update for this
    } else {
      showMsg(msg: "Something wrong please try again".tr);
    }
  }

  //+ cancelOrder
  Future<void> cancelOrder(String orderId) async {
    // String reason = (msgController.text.isNotEmpty) ? msgController.text : selectedReason.value;
    String reason = selectedReason.value == "Custom message" ? messageControllerText : selectedReason.value;
    // if () {
    showCircularLoading();
    var response = await BaseClient().post(baseUrl, updateOrderEndpoint, {
      'order_id': orderId,
      'status': 'cancel',
      'reason': reason,
    }).catchError(handleError);

    // String result = response['responce']['status'];

    if (response == null) {
      dismissLoading();
      showMsg(msg: "Something wrong please try again".tr);
      return;
    }

    String result = response.containsKey("responce")
        ? response["responce"].containsKey("status")
            ? response["responce"]["status"]
            : ""
        : "error";
    if (result == "success") {
      errorLog("stausssssssssssss:  ${selectedOrderData.value.order.status} ");

      getOrderViewData(selectedOrderData.value.order.orderId);
      dismissLoading();

      showMsg(msg: orderId + " was cancelled by you".tr);
      //+CHECK CHECK
      inProgressOrderList.removeWhere((element) => element.orderId == orderId);
      // getUpdatedInitialOrderData();
      // getUpdatedInitialInProgressOrderData();
      // getUpdatedInitialReadyOrderData();
      // newOrderList[index].status == "missed";
    } else {
      dismissLoading();
      showMsg(
        msg: "Something wrong while updating the order as missed after timeout. Please try again.".tr,
      );
    }
    // } else {
    //   showMsg(msg: "Please select a reason".tr);
    //
    // }
  }

  //+ Update Ready Order
  Future<void> updateReadyOrder(String orderId) async {
    showCircularLoading();
    errorLog("ORDER ID GETTING UPDATED IS: $orderId");
    var response = await BaseClient().post(baseUrl, updateOrderEndpoint, {
      'order_id': orderId,
      'status': 'delivered',
    }).catchError(handleError);

    log("response is $response");
    // String result = response['responce']['status'];

    if (response == null) {
      dismissLoading();
      showMsg(msg: "Something wrong please try again".tr);
      return;
    }

    String result = response.containsKey("responce")
        ? response["responce"].containsKey("status")
            ? response["responce"]["status"]
            : ""
        : "error";

    if (result == "success") {
      dismissLoading();
      showMsg(msg: "Order ready successfully".tr);
      for (var o in inProgressOrderList) {
        log("inProgressOrderList: ${o.orderId}");
      }
      log("inProgressOrderList ---- deletion in progress now");
      inProgressOrderList.removeWhere((element) => element.orderId == orderId);
      for (var o in inProgressOrderList) {
        log("inProgressOrderList: ${o.orderId}");
      }
      // getUpdatedInitialOrderData(); //+commented because now we are again using the periodic update for this
      //+ please uncomment this if manual deletion of that order is causing some issues
      // getUpdatedInitialInProgressOrderData();
      // getUpdatedInitialReadyOrderData();
    } else {
      dismissLoading();
      showMsg(msg: "Something wrong please try again".tr);
    }
  }

  //+ create test order
  Future<void> createTestOrder() async {
    // showCircularLoading();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      isCreatingTestOrderDisabled.value = true;
    });
    errorLog("In createTestOrder");
    var response = await BaseClient().post(baseUrl, createTestOrderEndpoint, {}).catchError(handleError);

    log("response is $response");
    // String result = response['responce']['status'];

    if (response == null) {
      dismissLoading();
      showMsg(msg: "Something wrong please try again".tr);
      return;
    }

    String result = response.containsKey("responce")
        ? response["responce"].containsKey("status")
            ? response["responce"]["status"]
            : ""
        : "error";

    if (result == "success") {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        isCreatingTestOrderDisabled.value = false;
      });
      // dismissLoading();
      // showMsg(msg: "Order ready successfully".tr);
    } else {
      dismissLoading();
      showMsg(msg: "Something wrong please try again".tr);
    }
  }

  //+getMenuListData
  RxList<MenuModel> menuList = <MenuModel>[].obs;
  Future<List<MenuModel>> getMenuListData() async {
    log("get Data Called");

    var response = await BaseClient().get(baseUrl, menuListEndpoint).catchError(handleError);
    log("response  before response = null $response");
    if (response == null) return [];

    // log(" $nextLine  Response data   $nextLine ${response['data']}");

    List tempList = response['data'];

    menuList.clear();
    for (var element in tempList) {
      menuList.add(MenuModel.fromJson(element));
    }
    for (var element in menuList) {
      log("after adding \n  ${element.toJson()}");
    }

    return menuList;
  }

  //+getItemListData
  RxList<ItemModel> itemList = <ItemModel>[].obs;
  Future<List<ItemModel>> getItemListData(String menuId) async {
    log("get Data Called");
    // showLoading('Fetching data');
    var response = await BaseClient().get(baseUrl, "/item-list?menu_id=$menuId").catchError(handleError);
    if (response == null) return [];

    // log(" $nextLine  Response data   $nextLine ${response['data']}");

    List tempList = response['data'];

    itemList.clear();
    // tempList.map((e) => itemList.add(ItemModel.fromJson(e))).toList();

    try {
      for (var element in tempList) {
        itemList.add(ItemModel.fromJson(element));
        // log("ItemModel.fromJson(element): ${ItemModel.fromJson(element).toJson()}");
      }
    } catch (e) {
      log("error in getItemListData $e");
    }

    // hideLoading();

    return itemList;
  }

  //+ get site info
  Future<void> getSiteInfo() async {
    // showCircularLoading();
    errorLog("In getSiteInfo");
    var response = await BaseClient().get(baseUrl, siteInfoEndpoint).catchError(handleError);

    log("response is $response");
    // String result = response['responce']['status'];

    String result = response.containsKey("responce")
        ? response["responce"].containsKey("status")
            ? response["responce"]["status"]
            : ""
        : "error";

    if (result == "success") {
      // dismissLoading();
      siteData = SiteInfo.fromJson(response["data"]["info"]);
      await LocalHiveDatabase.saveSiteData(siteData);
      wtfLog("siteData from model == : ${siteData.toJson()}");
      // showMsg(msg: "Order ready successfully".tr);
    } else {
      // dismissLoading();
      showMsg(msg: "Something wrong please try again".tr);
    }
  }

  clearAllLists() {
    for (OrderModel order in ordersList) {
      deletedOrderIdsList.add(order.orderId ?? "");
    }

    ordersList.clear();
    // acceptedOrderList.clear();
    // readyOrderList.clear();
    offset = 0;
    // inProgressOrderOffset = 0;
    // readyOrderOffset = 0;
    showMsg(msg: "All orders list cleared".tr);
  }

  logout() {
    ordersList.clear();
    deletedOrderIdsList.clear();
    inProgressOrderList.clear();
    readyOrderList.clear();
    newOrdersList.clear();
    offset = 0;
    inProgressOrderOffset = 0;
    readyOrderOffset = 0;
    try {
      inProgressTimer.cancel();
    } catch (e) {
      debugLog("ERROR IN CANCELLING TIMER IN API CONTROLLER: $e");
    }
    try {
      readyOrderTimer.cancel();
    } catch (e) {
      debugLog("ERROR IN CANCELLING TIMER IN API CONTROLLER: $e");
    }
    try {
      allOrdersTimer.cancel();
    } catch (e) {
      debugLog("ERROR IN CANCELLING TIMER IN API CONTROLLER: $e");
    }

    myNewOrderFOREGROUNDTimers.forEach((key, value) {
      try {
        value?.cancel();
      } catch (e) {
        log("error in canceling all timers: $e");
      }
    });
    myNewOrderFOREGROUNDTimers.clear();
    myNewOrdersSeconds.clear();
  }

/*! Commented methods !*/
// Future<List<OrderModel>> getOrderData() async {
  //   log("get Data Called");
  //   // showLoading('Fetching data');
  //
  //   var response = await BaseClient().get(baseUrl, orderEndpoint).catchError(handleError);
  //   if (response == null) return [];
  //
  //   // Map<String,dynamic> dataMap= jsonDecode(response);
  //   // log("data map $dataMap");
  //
  //   //
  //   // log(" $nextLine  Response data   $nextLine ${response['data']}");
  //   List tempList = response['data'];
  //   // log("tempList.length: ${tempList.length}");
  //
  //   ordersList.clear();
  //   // log("Clearing list");
  //
  //   for (var element in ordersList) {
  //     log("after clear ${element.toJson()}");
  //   }
  //   for (var element in tempList) {
  //     if (element.status != "new") {
  //       ordersList.add(OrderModel.fromJson(element));
  //     }
  //   }
  //
  //   // hideLoading();
  //
  //   return ordersList;
  // }
/* */
// Future<List<OrderModel>> getInProgressOrderData() async {
  //   log("get Data Called");
  //
  //   var response = await BaseClient().get(baseUrl, acceptOrderEndpoint).catchError(handleError);
  //   if (response == null) return [];
  //   // String result = response['responce']['status'];
  //
  //   String result = response.containsKey("responce")
  //       ? response["responce"].containsKey("status")
  //       ? response["responce"]["status"]
  //       : ""
  //       : "error";
  //
  //   if (result == "success") {
  //     // log(" $nextLine  Response data   $nextLine ${response['data']}");
  //     List tempList = response['data'];
  //
  //     acceptedOrderList.clear();
  //     for (var element in tempList) {
  //       acceptedOrderList.add(OrderModel.fromJson(element));
  //     }
  //   }
  //
  //   return acceptedOrderList;
  // }
/* */
// Future<List<OrderModel>> getReadyOrderData() async {
//   log("get Data Called");
//   // showLoading('Fetching data');
//
//   var response = await BaseClient().get(baseUrl, readyOrderEndpoint).catchError(handleError);
//   if (response == null) return [];
//
//   // Map<String,dynamic> dataMap= jsonDecode(response);
//   // log("data map $dataMap");
//
//   // log(" $nextLine  Response data   $nextLine ${response['data']}");
//   List tempList = response['data'];
//
//   readyOrderList.clear();
//   for (var element in tempList) {
//     readyOrderList.add(OrderModel.fromJson(element));
//   }
//
//   // hideLoading();
//
//   return readyOrderList;
// }
/* */
//+acceptOrderList

//  Future<List<OrderModel>> getNewOrderData() async {
//     log("get getNewOrderData");
//     log("get getNewOrderData");
//     log("get getNewOrderData");
//     log("get getNewOrderData");
//     log("get getNewOrderData");
//
//     Map<String, dynamic> queryParameters = {
//
//     };
//
//     // var response = await BaseClient().get(baseUrl, newOrderEndpoint).catchError(handleError);
//
//     var url = Uri.https(baseUrlForHttp, orderEndpoint, queryParameters);
//     log("url: $url");
//     Response response = await http.post(url);
//     if (response == null) return [];
//
//     log("new order response   $nextLine $response");
//     log(" $nextLine  Response data   $nextLine ${response['data']}");
//     List tempList = response['data'];
//
//     newOrderList.clear();
//     for (var element in tempList) {
//       newOrderList.add(OrderModel.fromJson(element));
//     }
//
//     // 0306 6850908
//
//     return newOrderList;
//   }
/* */
//+Update Reject Order
// Future<void> updateRejectOrder(String orderId) async {
//   var response = await BaseClient().post(baseUrl, updateOrderEndpoint, {
//     'order_id': orderId,
//     'status': 'ready',
//   }).catchError(handleError);
//
//   log("response is $response");
//   // String result = response['responce']['status'];
//
//   String result = response.containsKey("responce")
//       ? response["responce"].containsKey("status")
//           ? response["responce"]["status"]
//           : ""
//       : "error";
//
//   if (result == "success") {
//     //
//     showMsg(msg: "Order ready successfully");
//   } else {
//     //
//     showMsg(msg: "Something wrong please try again");
//   }
// }
/* */
// void postData() async {
//   var request = {'message': 'CodeX sucks!!!'};
//   showLoading('Posting data...');
//   var response = await BaseClient().post('https://jsonplaceholder.typicode.com', '/posts', request).catchError((error) {
//     if (error is BadRequestException) {
//       var apiError = json.decode(error.message!);
//       DialogHelper.showErrorDialog(description: apiError["reason"]);
//     } else {
//       handleError(error);
//     }
//   });
//   if (response == null) return [];
//   hideLoading();
//   print(response);
// }
}
