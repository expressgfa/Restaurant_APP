import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:charset_converter/charset_converter.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pos_printer_platform/flutter_pos_printer_platform.dart';
import 'package:get/get.dart';
import 'package:html_unescape/html_unescape_small.dart';
import 'package:resturantapp/constant/all_controller.dart';
import 'package:resturantapp/data/local_hive_database.dart';
import 'package:resturantapp/generated/assets.dart';
import 'package:resturantapp/model/bluetooth_printer_model.dart';
import 'package:resturantapp/model/order_view_model.dart';
import 'package:resturantapp/model/printer_type_hive.dart';
import 'package:resturantapp/model/site_data_model/site_model.dart';
import 'package:resturantapp/utils/helper.dart';
import 'package:resturantapp/utils/shared_pref.dart';
import 'package:resturantapp/utils/snack_bar.dart';
import 'package:image/image.dart' as img;

class PrinterController extends GetxController {
  static PrinterController instance = Get.find<PrinterController>();

  RxBool isPrinting = false.obs;
  var defaultPrinterType = MyPrinterType.network;
  RxBool isBle = false.obs;
  RxBool reconnect = false.obs;
  RxBool isConnected = false.obs;
  var printerManager = PrinterManager.instance;
  RxList devices = <PrinterDataModel>[].obs;

  List<String> months = [
    'Months',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  StreamSubscription<PrinterDevice>? subscription;
  StreamSubscription<BTStatus>? subscriptionBtStatus;
  StreamSubscription<USBStatus>? subscriptionUsbStatus;
  BTStatus currentStatus = BTStatus.none;
  // _currentUsbStatus is only supports on Android
  // ignore: unused_field
  USBStatus currentUsbStatus = USBStatus.none;
  List<int>? pendingTask;
  String ipAddress = '';
  String port = '9100';
  final ipController = TextEditingController();
  final portController = TextEditingController();
  PrinterDataModel? selectedPrinter;
  RxString selectedPrinterAddress = "".obs;

  PaperSize paperSize = PaperSize.mm58;

  bluetoothStreamInitializer() {
    log("stream of bluetooth");
    subscriptionBtStatus = PrinterManager.instance.stateBluetooth.listen((status) {
      log(' ----------------- status bt $status ------------------ ');
      currentStatus = status;
      if (status == BTStatus.connected) {
        isConnected.value = true;
      }
      if (status == BTStatus.none) {
        isConnected.value = false;
        // showMsg(msg: "Could not connect to bluetooth");
      }
      if (status == BTStatus.connected && pendingTask != null) {
        if (Platform.isAndroid) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (pendingTask != null) {
              PrinterManager.instance.send(type: PrinterType.bluetooth, bytes: pendingTask!);
              pendingTask = null;
            }
          });
        } else if (Platform.isIOS) {
          if (pendingTask != null) {
            PrinterManager.instance.send(type: PrinterType.bluetooth, bytes: pendingTask!);
          }
          pendingTask = null;
        }
      }
    });
  }

  usbStreamInitializer() {
    subscriptionUsbStatus = PrinterManager.instance.stateUSB.listen((status) {
      log(' ----------------- status usb $status ------------------ ');
      currentUsbStatus = status;
      if (Platform.isAndroid) {
        if (status == USBStatus.connected && pendingTask != null) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            PrinterManager.instance.send(type: PrinterType.usb, bytes: pendingTask!);
            pendingTask = null;
          });
        }
      }
    });
  }

  // method to scan devices according MyPrinterType
  void scan() {
    devices.clear();
    subscription = printerManager.discovery(type: Utils.mapMyPrinterTypeToPrinterType(defaultPrinterType), isBle: isBle.value).listen((device) {
      devices.add(PrinterDataModel(
        deviceName: device.name,
        address: device.address,
        isBle: isBle.value,
        vendorId: device.vendorId,
        productId: device.productId,
        typePrinter: defaultPrinterType,
      ));
      // notifyListeners();
      for (var v in devices) {
        log("v.toJson(): ${v.toJson()}");
      }
    });
    log("printers are: ");
  }

  //+ only called on Windows
  void setPort(String value) {
    if (value.isEmpty) value = '9100';
    port = value;
    var device = PrinterDataModel(
      deviceName: value,
      address: ipAddress,
      port: port,
      typePrinter: MyPrinterType.network,
      state: false,
    );
    selectDevice(device);
  }

  //+ only called on Windows
  void setIpAddress(String value) {
    ipAddress = value;
    var device = PrinterDataModel(
      deviceName: value,
      address: ipAddress,
      port: port,
      typePrinter: MyPrinterType.network,
      state: false,
    );
    selectDevice(device);
  }

  void selectDevice(PrinterDataModel device) async {
    if (selectedPrinter != null) {
      if ((device.address != selectedPrinter!.address) || (device.typePrinter == MyPrinterType.usb && selectedPrinter!.vendorId != device.vendorId)) {
        await PrinterManager.instance.disconnect(type: Utils.mapMyPrinterTypeToPrinterType(selectedPrinter!.typePrinter));
      }
    }
    selectedPrinter = device;
    selectedPrinterAddress.value = (selectedPrinter?.address?.isNotEmpty ?? false) ? selectedPrinter?.address ?? "" : selectedPrinter?.vendorId ?? "";
    // UserDetailsModel userDetails = LocalDatabase.getUserDetailsWithoutAsync();
    await LocalHiveDatabase.savePrinterForASpecificUser(LocalSharedPrefDatabase.getUserEmail() ?? "email", selectedPrinter!);
    log("device in selectedDevice = ${device.toJson()}");
    // setState(() {});
    // notifyListeners();
  }

  Future printReceiveTest() async {
    log("something .... ---- ,,,, -----");
    print("something .... ---- ,,,, -----");
    final ByteData data = await rootBundle.load(Assets.imagesScissorsCutApp);
    final Uint8List imgBytes = data.buffer.asUint8List();
    // log("imgBytes: ${imgBytes.reactive}");
    final img.Image image = img.decodeImage(imgBytes)!;

    final ByteData checkBoxData = await rootBundle.load(Assets.imagesBlankCheckBox);
    final Uint8List checkBoxImgBytes = checkBoxData.buffer.asUint8List();
    final img.Image checkBoxImage = img.decodeImage(checkBoxImgBytes)!;
    final img.Image checkBoxResized = img.copyResize(checkBoxImage, width: 558);
    final img.Image checkBoxResized400 = img.copyResize(checkBoxImage, width: 400);
    final img.Image checkBoxResized300 = img.copyResize(checkBoxImage, width: 300);
    final img.Image checkBoxResized200 = img.copyResize(checkBoxImage, width: 200);
    final img.Image checkBoxResized100 = img.copyResize(checkBoxImage, width: 20);
    int localPaperSize = LocalHiveDatabase.getPaperSize();
    // int localPaperSize = 58;
    if (localPaperSize == 80) {
      paperSize = PaperSize.mm80;
    } else {
      paperSize = PaperSize.mm58;
    }
    // log("CharsetConverter.availableCharsets(): ${await CharsetConverter.availableCharsets()}");
    // print("CharsetConverter.availableCharsets(): ${await CharsetConverter.availableCharsets()}");

    // CharsetConverter.availableCharsets().then((value) {
    //   print("print charset: $value");
    // });

    List<int> bytes = [];

    log("lenggggggggggggth: ${'Size 1 Product 1: 招牌韮黃鍋貼 , Signature: Pork W/ Yellow Chive'.length}");

    // Xprinter XP-N160I
    final profile = await CapabilityProfile.load(name: 'default');
    // PaperSize.mm80 or PaperSize.mm58
    final generator = Generator(paperSize, profile);
    bytes += generator.setGlobalCodeTable('UTF-8');
    bytes += generator.text('Test Print', styles: const PosStyles(align: PosAlign.center));
    final img.Image resized = img.copyResize(image, width: 558);
    bytes += generator.image(resized);
    // bytes += generator.image(checkBoxResized);
    // bytes += generator.image(checkBoxResized400);
    // bytes += generator.image(checkBoxResized300);
    // bytes += generator.image(checkBoxResized200);
    bytes += generator.image(checkBoxResized100);
    // bytes += generator.image(image2);

    // String text = "鲜虾猪肉冷冻水饺, Ears";
    // String text = "香芋珍珠拿铁, Taro Latte";
    String text = "芝麻雪糕 Black Sesame";
    // String text = "鸡肉大白菜冷冻水饺, Frozen Dumplings W. Shrimp & Pork";
    // String text = "鸡肉大白菜冷冻水饺, Signature: Pork W/ Yellow Chive";
    // String text = "招牌韮黃鍋貼 , Signature: Pork W/ Yellow Chive";

    int length = text.length;
    int chineseLength = 0;
    int englishLength = 0;

    if (text.contains(",")) {
      chineseLength = text.split(",")[0].length;
      englishLength = text.split(",")[1].length;
    } else {
      chineseLength = text.split(" ")[0].length;
    }

    log("chineseLength: $chineseLength");

    /* */
    // bytes += generator.text('Product 1: 招牌韮黃鍋貼 , Signature: Pork W/ Yellow Chive');
    // PosTextSize.decSize(PosTextSize.size8, PosTextSize.size8);
    bytes += generator.text('Items:', styles: const PosStyles(align: PosAlign.left, bold: true));
    // bytes += generator.row([
    //   PosColumn(
    //     // text: '${order.orderItems[index].itemQty} x ${order.orderItems[index].itemName}',
    //     textEncoded:
    //         await CharsetConverter.encode("cp851", 'Column Product 1: 招牌韮黃鍋貼 , Signature: Pork W/ Yellow Chive'),
    //     width: 12,
    //     styles: const PosStyles(align: PosAlign.left, underline: false, bold: true),
    //   ),
    // ]);

    //+ Full + half and text

    /*! text.split(",")[0].trim() !*/

    bytes += generator.hr(len: localPaperSize == 80 ? 47 : 32);

    //+ half + half and text

    if (length < 15) {
      bytes += generator.row([
        PosColumn(
          // text: 'Size 1 Product 1: 招牌韮黃鍋貼 , Signature: Pork W/ Yellow Chive',
          // containsChinese: true,
          textEncoded: await CharsetConverter.encode("UTF-8", text),
          width: 9,
          styles: const PosStyles(
            align: PosAlign.left,
            underline: false,
            bold: true,
          ),
        ),
        PosColumn(
          // text: '',
          // containsChinese: true,
          textEncoded: await CharsetConverter.encode("UTF-8", '\$2500.00'),
          width: 3,
          styles: const PosStyles(
            align: PosAlign.left,
            underline: false,
            bold: true,
          ),
        ),
      ]);
    } else if (length > 15 && length <= 20) {
      bytes += generator.textEncoded(await CharsetConverter.encode("UTF-8", text.substring(0, 15)), styles: const PosStyles(align: PosAlign.left, bold: true));
      bytes += generator.row([
        PosColumn(
          // text: 'Size 1 Product 1: 招牌韮黃鍋貼 , Signature: Pork W/ Yellow Chive',
          // containsChinese: true,
          textEncoded: await CharsetConverter.encode("UTF-8", text.substring(15)),
          width: 9,
          styles: const PosStyles(
            align: PosAlign.left,
            underline: false,
            bold: true,
          ),
        ),
        PosColumn(
          // text: 'Size 1 Product 1: 招牌韮黃鍋貼 , Signature: Pork W/ Yellow Chive',
          // containsChinese: true,
          textEncoded: await CharsetConverter.encode("UTF-8", '\$2500.00'),
          width: 3,
          styles: const PosStyles(
            align: PosAlign.left,
            underline: false,
            bold: true,
          ),
        ),
      ]);
    } else {
      bytes += generator.textEncoded(await CharsetConverter.encode("UTF-8", text.substring(0, 20)), styles: const PosStyles(align: PosAlign.left, bold: true));
      bytes += generator.row([
        PosColumn(
          // text: 'Size 1 Product 1: 招牌韮黃鍋貼 , Signature: Pork W/ Yellow Chive',
          // containsChinese: true,
          textEncoded: await CharsetConverter.encode("UTF-8", text.substring(20)),
          width: 9,
          styles: const PosStyles(
            align: PosAlign.left,
            underline: false,
            bold: true,
          ),
        ),
        PosColumn(
          // text: 'Size 1 Product 1: 招牌韮黃鍋貼 , Signature: Pork W/ Yellow Chive',
          // containsChinese: true,
          textEncoded: await CharsetConverter.encode("UTF-8", '\$2500.00'),
          width: 3,
          styles: const PosStyles(
            align: PosAlign.left,
            underline: false,
            bold: true,
          ),
        ),
      ]);
    }
    // bytes += generator.row([
    //   PosColumn(
    //     // text: 'Size 1 Product 1: 招牌韮黃鍋貼 , Signature: Pork W/ Yellow Chive',
    //     // containsChinese: true,
    //     textEncoded: await CharsetConverter.encode("UTF-8", text.split(",")[1].trim()),
    //     width: 9,
    //     styles: const PosStyles(
    //       align: PosAlign.left,
    //       underline: false,
    //       bold: true,
    //     ),
    //   ),
    //   PosColumn(
    //     text: '',
    //     // containsChinese: true,
    //     textEncoded: await CharsetConverter.encode("UTF-8", '\$2500.00'),
    //     width: 3,
    //     styles: const PosStyles(
    //       align: PosAlign.left,
    //       underline: false,
    //       bold: true,
    //     ),
    //   ),
    // ]);
    /* */
    bytes += generator.emptyLines(1);

    // bytes += generator.text('Product 2: 韮菜豬肉鍋貼, Chive With Pork');
    bytes += generator.hr(len: localPaperSize == 80 ? 47 : 32);

    printEscPos(bytes, generator);
  }

  Future printOrderDetails(OrderViewModel order) async {
    log("order0======: ${order.toJson()}");
    SiteInfo siteData = SiteInfo();
    var siteInfo = LocalHiveDatabase.getSiteData();
    // log("site data here from local is: ${siteInfo.toJson()}");
    if (siteInfo == null) {
      apiController.getSiteInfo().then((value) {
        siteData = apiController.siteData;
      });
    } else {
      siteData = siteInfo;
    }

    final ByteData cutHereData = await rootBundle.load(Assets.imagesScissorsCutApp);
    final Uint8List cutHereImgBytes = cutHereData.buffer.asUint8List();
    final img.Image cutHereImage = img.decodeImage(cutHereImgBytes)!;
    final img.Image cutHereResized = img.copyResize(cutHereImage, width: 558);

    int localPaperSize = LocalHiveDatabase.getPaperSize();
    // int localPaperSize = 58;
    if (localPaperSize == 80) {
      paperSize = PaperSize.mm80;
    } else {
      paperSize = PaperSize.mm58;
    }
    List<int> bytes = [];

    // DateTime createdDate =
    //     DateTime.tryParse(order.data?.dateCreated ?? DateTime.now().toIso8601String()) ?? DateTime.now();
    // DateTime deliveryDate =
    //     DateTime.tryParse(order.data?.deliveryDate ?? DateTime.now().toIso8601String()) ?? DateTime.now();

    // Xprinter XP-N160I
    // final profile = await CapabilityProfile.load(name: 'default');
    final profile = await CapabilityProfile.load(name: 'default');
    // PaperSize.mm80 or PaperSize.mm58
    final generator = Generator(paperSize, profile);
    bytes += generator.setGlobalCodeTable('UTF-8');
    // bytes += generator.printCodeTable();
    bytes += generator.emptyLines(1);
    bytes += generator.text(
        " ${order.order.paymentType.toUpperCase().padRight(
              localPaperSize == 80 ? (46 - order.order.paymentType.length) : (33 - order.order.paymentType.length),
            )}",
        styles: const PosStyles(align: PosAlign.center, bold: true, reverse: true));
    bytes += generator.emptyLines(1);
    bytes += generator.text('Order Details', styles: const PosStyles(align: PosAlign.center, bold: true));
    // bytes += generator.emptyLines(1);
    // bytes += generator.text(
    //     order.orderData?.status.toLowerCase() == "paid"
    //         ? 'Paid ('
    //             '${(deliveryDate.month == createdDate.month && deliveryDate.day > createdDate.day) || (deliveryDate.month > createdDate.month) ? 'Future Order' : 'New Order'}):'
    //         : 'Unpaid (${(deliveryDate.month == createdDate.month && deliveryDate.day > createdDate.day) || (deliveryDate.month > createdDate.month) ? 'Future Order' : 'New Order'}):',
    //     styles: const PosStyles(align: PosAlign.center, bold: true));
    // bytes += generator.hr(len: localPaperSize == 80 ? 47 : 32);
    // bytes += generator.text('TRN Date: ${order.orderData?.dateCreated}');
    ///OLD
    String numberString = "Number ${order.order.orderId}";
    // String numberString = "Number ${order.order!["orderId"]}";
    int lengthOfNumberString = numberString.length;
    bytes += generator.row([
      PosColumn(
        text: 'Number:',
        width: 3,
        styles: const PosStyles(align: PosAlign.left, underline: false),
      ),
      PosColumn(
        ///OLD
        // text: order.order!["orderId"] ?? "",
        text: (order.order.orderId.length < 17) ? "            ${order.order.orderId}" : order.order.orderId,
        width: 9,
        styles: const PosStyles(align: PosAlign.right, underline: false),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Date:',
        width: 3,
        styles: const PosStyles(align: PosAlign.left, underline: false),
      ),
      PosColumn(
        text: '${order.order.orderDate} ${order.order.orderTime}',
        // text: '${order.order?["orderDate"]} ${order.order!["orderTime"]}',
        width: 9,
        styles: const PosStyles(align: PosAlign.right, underline: false),
      ),
    ]);
    bytes += generator.emptyLines(1);

    bytes += generator.text('Client Info:', styles: const PosStyles(align: PosAlign.left, bold: true));

    bytes += generator.row([
      PosColumn(
        text: 'Name:',
        width: 3,
        styles: const PosStyles(align: PosAlign.left, underline: false),
      ),
      PosColumn(
        text: order.order.customerName,
        // text: order.order!["customerName"] ?? "",
        width: 9,
        styles: const PosStyles(align: PosAlign.right, underline: false),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Phone:',
        width: 3,
        styles: const PosStyles(align: PosAlign.left, underline: false),
      ),
      PosColumn(
        text: order.order.phone,
        // text: order.order!["phone"] ?? "",
        width: 9,
        styles: const PosStyles(align: PosAlign.right, underline: false),
      ),
    ]);

    if (order.order.email != null && order.order.email.toString().isNotEmpty) {
      // if (order.order!["email"] != null && order.order!["email"].toString().isNotEmpty) {
      bytes += generator.row([
        PosColumn(
          text: 'Email:',
          width: 3,
          styles: const PosStyles(align: PosAlign.left, underline: false),
        ),
        PosColumn(
          text: order.order.email,
          // text: '${order.order!["email"]}',
          width: 9,
          styles: const PosStyles(align: PosAlign.right, underline: false),
        ),
      ]);
    }

    bytes += generator.emptyLines(1);
    bytes += generator.text('Items:', styles: const PosStyles(align: PosAlign.left, bold: true));
    for (int index = 0; index < (order.orderItems.length); index++) {
      String text = order.orderItems[index].itemName;

      int length = text.length;
      int chineseLength = 0;
      int englishLength = 0;

      if (text.contains(",")) {
        chineseLength = text.split(",")[0].length;
        englishLength = text.split(",")[1].length;
      } else {
        chineseLength = text.split(" ")[0].length;
        chineseLength = text.split(" ")[0].length;
      }

      log("chineseLength: $chineseLength");

      if (length < 15) {
        bytes += generator.row([
          PosColumn(
            // text: 'Size 1 Product 1: 招牌韮黃鍋貼 , Signature: Pork W/ Yellow Chive',
            // containsChinese: true,
            textEncoded: await CharsetConverter.encode("UTF-8", "${order.orderItems[index].itemQty}x$text"),
            width: 9,
            styles: const PosStyles(
              align: PosAlign.left,
              underline: false,
              bold: true,
            ),
          ),
          PosColumn(
            // text: '',
            // containsChinese: true,
            textEncoded: await CharsetConverter.encode("UTF-8", '\$${order.orderItems[index].finalCost}'),
            width: 3,
            styles: const PosStyles(
              align: PosAlign.right,
              underline: false,
              bold: true,
            ),
          ),
        ]);
      } else if (length > 15 && length <= 20) {
        bytes += generator.textEncoded(await CharsetConverter.encode("UTF-8", "${order.orderItems[index].itemQty} x ${text.substring(0, 13)}"),
            styles: const PosStyles(align: PosAlign.left, bold: true));
        bytes += generator.row([
          PosColumn(
            // containsChinese: true,
            textEncoded: await CharsetConverter.encode("UTF-8", text.substring(13)),
            width: 9,
            styles: const PosStyles(
              align: PosAlign.left,
              underline: false,
              bold: true,
            ),
          ),
          PosColumn(
            // containsChinese: true,
            textEncoded: await CharsetConverter.encode("UTF-8", '\$${order.orderItems[index].finalCost}'),
            width: 3,
            styles: const PosStyles(
              align: PosAlign.right,
              underline: false,
              bold: true,
            ),
          ),
        ]);
      } else {
        bytes += generator.textEncoded(
          await CharsetConverter.encode("UTF-8", "${order.orderItems[index].itemQty} x ${text.substring(0, 20)}"),
          styles: const PosStyles(align: PosAlign.left, bold: true),
        );
        bytes += generator.row([
          PosColumn(
            // containsChinese: true,
            textEncoded: await CharsetConverter.encode("UTF-8", text.substring(20)),
            width: 9,
            styles: const PosStyles(align: PosAlign.left, underline: false, bold: true),
          ),
          PosColumn(
            // containsChinese: true,
            textEncoded: await CharsetConverter.encode("UTF-8", '\$${order.orderItems[index].finalCost}'),
            width: 3,
            styles: const PosStyles(align: PosAlign.right, underline: false, bold: true),
          ),
        ]);
      }

      // bytes += generator.row([
      //   PosColumn(
      //     // text: '${order.orderItems[index].itemQty} x ${order.orderItems[index].itemName}',
      //     // containsChinese: true,
      //     textEncoded: await CharsetConverter.encode("UTF-8", '${order.orderItems[index].itemQty}x${order.orderItems[index].itemName}'),
      //     width: 9,
      //     styles: const PosStyles(
      //       align: PosAlign.left,
      //       underline: false,
      //       bold: true,
      //     ),
      //   ),
      //   PosColumn(
      //     text: "\$${order.orderItems[index].finalCost}",
      //     width: 3,
      //     styles: const PosStyles(align: PosAlign.right, underline: false, bold: true),
      //   ),
      // ]);
      bytes += generator.emptyLines(1);
    }
    bytes += generator.hr(len: localPaperSize == 80 ? 47 : 32);

    bytes += generator.row([
      PosColumn(
        text: 'Sub Total:',
        width: 6,
        styles: const PosStyles(align: PosAlign.left, underline: false),
      ),
      PosColumn(
        text: "\$${((double.tryParse(order.order.totalCost) ?? 0.0) / 108.87 * 100).toStringAsFixed(2)}",
        // text: "\$${HtmlUnescape().convert(order.order.totalCost)}",
        // text: "\$${HtmlUnescape().convert(order.order!["totalCost"] ?? "")}",
        width: 6,
        styles: const PosStyles(align: PosAlign.right, underline: false),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Sales Tax(8.875%):',
        width: 7,
        styles: const PosStyles(align: PosAlign.left, underline: false),
      ),
      PosColumn(
        text: "\$${((double.tryParse(order.order.totalCost) ?? 0.0) - (double.tryParse(order.order.totalCost) ?? 0.0) / 108.87 * 100).toStringAsFixed(2)}",
        // text: "\$${HtmlUnescape().convert(order.order.totalCost)}",
        // text: "\$${HtmlUnescape().convert(order.order!["totalCost"] ?? "")}",
        width: 5,
        styles: const PosStyles(align: PosAlign.right, underline: false),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Total:',
        width: 6,
        styles: const PosStyles(align: PosAlign.left, underline: false, bold: true),
      ),
      PosColumn(
        text: "\$${HtmlUnescape().convert(order.order.totalCost)}",
        // text: "\$${HtmlUnescape().convert(order.order!["totalCost"] ?? "")}",
        width: 6,
        styles: const PosStyles(align: PosAlign.right, underline: false, bold: true),
      ),
    ]);

    //+ order online part
    bytes += generator.emptyLines(2);
    bytes += generator.hr(len: localPaperSize == 80 ? 47 : 32);
    bytes += generator.emptyLines(1);
    bytes += generator.text('Order online:', styles: const PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.text('Sanmiwagodumpling.com', styles: const PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.emptyLines(1);
    // bytes += generator.text('-'.padLeft(10 ,"-"), styles: const PosStyles(align: PosAlign.right, bold: true, turn90: true));
    bytes += generator.hr(len: localPaperSize == 80 ? 47 : 32);

    //+ company info
    bytes += generator.emptyLines(1);
    bytes += generator.text(siteData.siteTitle, styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text(siteData.pickupAddress, styles: const PosStyles(align: PosAlign.center));
    bytes += generator.textEncoded(await CharsetConverter.encode("UTF-8", "+1 ${siteData.phone}"), styles: const PosStyles(align: PosAlign.center));
    bytes += generator.emptyLines(1);
    bytes += generator.image(cutHereResized);
    bytes += generator.emptyLines(1);

    //+ client acknowledgement part
    bytes += generator.text('Client confirmation:', styles: const PosStyles(align: PosAlign.left, bold: true));
    DateTime date = DateTime.tryParse(order.order.dateCreated) ?? DateTime.now();

    bytes += generator.text(
        'I acknowledge the reception of order ${order.order.orderId} from ${siteData.siteTitle} '
        'on ${months[date.month]} ${date.day}.',
        styles: const PosStyles(align: PosAlign.left));
    bytes += generator.emptyLines(1);
    bytes += generator.text('My name is:', styles: const PosStyles(align: PosAlign.left));
    bytes += generator.emptyLines(1);

    //+ empty field for authorized person name
    List<int> nameDataList = List.empty(growable: true);
    nameDataList.addAll(Uint8List.fromList([0xE2, 0x98, 0x90]));
    nameDataList.addAll(await CharsetConverter.encode("UTF-8", "  ${order.order.customerName}"));
    bytes += generator.textEncoded(Uint8List.fromList(nameDataList));
    bytes += generator.emptyLines(1);

    //+ empty field for authorized person name
    List<int> dataList = List.empty(growable: true);
    dataList.addAll(Uint8List.fromList([0xE2, 0x98, 0x90]));
    dataList.addAll(await CharsetConverter.encode("UTF-8", "  -".padRight(localPaperSize == 80 ? 45 : 30, "-")));
    bytes += generator.textEncoded(Uint8List.fromList(dataList));
    bytes += generator.text('I am authorized to act on behalf of ${order.order.customerName}', styles: const PosStyles(align: PosAlign.left));
    bytes += generator.emptyLines(2);
    bytes += generator.text('Signature: ${"-".padRight(localPaperSize == 80 ? 45-10 : 30-10, "-")}', styles: const PosStyles(align: PosAlign.left));
    bytes += generator.emptyLines(2);

    printEscPos(bytes, generator);
    printEscPos(bytes, generator);
  }

  /// print ticket
  void printEscPos(List<int> bytes, Generator generator) async {
    log("selectedPrinter: $selectedPrinter");
    if (selectedPrinter == null) return;
    var printerToPrintTo = selectedPrinter!;

    log("printerType: ${selectedPrinter?.typePrinter}");

    switch (printerToPrintTo.typePrinter) {
      case MyPrinterType.usb:
        bytes += generator.feed(2);
        bytes += generator.cut();
        await printerManager.connect(
            type: Utils.mapMyPrinterTypeToPrinterType(printerToPrintTo.typePrinter),
            model: UsbPrinterInput(name: printerToPrintTo.deviceName, productId: printerToPrintTo.productId, vendorId: printerToPrintTo.vendorId));
        pendingTask = null;
        break;
      case MyPrinterType.bluetooth:
        log("in case  MyPrinterType.bluetooth");
        log("in case  ${printerToPrintTo.deviceName}");
        log("in case  ${printerToPrintTo.address}");
        log("in case  ${printerToPrintTo.isBle}");
        log("in case  ${reconnect.value}");
        bytes += generator.cut();
        try {
          await printerManager.connect(
              type: Utils.mapMyPrinterTypeToPrinterType(printerToPrintTo.typePrinter),
              model: BluetoothPrinterInput(
                  name: printerToPrintTo.deviceName, address: printerToPrintTo.address!, isBle: printerToPrintTo.isBle ?? false, autoConnect: reconnect.value));
        } catch (e) {
          log("message error in BT Party");
          print(e);
        }
        pendingTask = null;
        if (Platform.isAndroid) pendingTask = bytes;
        break;
      case MyPrinterType.network:
        bytes += generator.feed(2);
        bytes += generator.cut();
        await printerManager.connect(
            type: Utils.mapMyPrinterTypeToPrinterType(printerToPrintTo.typePrinter), model: TcpPrinterInput(ipAddress: printerToPrintTo.address!));
        break;
      default:
    }
    if (printerToPrintTo.typePrinter == MyPrinterType.bluetooth && Platform.isAndroid) {
      log("in if of printerToPrintTo.typePrinter == MyPrinterType.bluetooth && Platform.isAndroid and currentStatus: $currentStatus");
      if (currentStatus == BTStatus.connected) {
        log("in btstatus connected");
        printerManager.send(type: Utils.mapMyPrinterTypeToPrinterType(printerToPrintTo.typePrinter), bytes: bytes);
        pendingTask = null;
      }
    } else {
      printerManager.send(type: Utils.mapMyPrinterTypeToPrinterType(printerToPrintTo.typePrinter), bytes: bytes);
    }
    // UserDetailsModel userDetails = LocalDatabase.getUserDetailsWithoutAsync();
    // LocalDatabase.savePrinterForASpecificUser(userDetails.posUserId, selectedPrinter!);
    LocalHiveDatabase.savePrinterForASpecificUser(LocalSharedPrefDatabase.getUserEmail() ?? "email", selectedPrinter!);
  }

  //+ connecting device here
  connectDevice(BuildContext context) async {
    // loadingPopup(context);
    isConnected.value = false;
    if (selectedPrinter == null) return;
    switch (selectedPrinter!.typePrinter) {
      case MyPrinterType.usb:
        await printerManager.connect(
          type: Utils.mapMyPrinterTypeToPrinterType(selectedPrinter!.typePrinter),
          model: UsbPrinterInput(
            name: selectedPrinter!.deviceName,
            productId: selectedPrinter!.productId,
            vendorId: selectedPrinter!.vendorId,
          ),
        );
        isConnected.value = true;
        break;
      case MyPrinterType.bluetooth:
        // try {
        //   log("in bt part thingy");
        //   bool isConnectedToBT =
        await printerManager.connect(
            type: Utils.mapMyPrinterTypeToPrinterType(selectedPrinter!.typePrinter),
            model: BluetoothPrinterInput(
                name: selectedPrinter!.deviceName, address: selectedPrinter!.address!, isBle: selectedPrinter!.isBle ?? false, autoConnect: reconnect.value));
        // log("after the connection part in BT");
        // showMsg(msg: "isConnectedToBT in Bluetooth connection: $isConnectedToBT");
        // } catch (e) {
        //   showMsg(msg: "Error in Bluetooth connection: $e");
        // }
        break;
      case MyPrinterType.network:
        await printerManager.connect(
            type: Utils.mapMyPrinterTypeToPrinterType(selectedPrinter!.typePrinter), model: TcpPrinterInput(ipAddress: selectedPrinter!.address!));
        isConnected.value = true;
        break;
      default:
    }
    // notifyListeners();
    // UserDetailsModel userDetails = LocalDatabase.getUserDetailsWithoutAsync();
    // LocalDatabase.savePrinterForASpecificUser(userDetails.posUserId, selectedPrinter!);
    LocalHiveDatabase.savePrinterForASpecificUser(LocalSharedPrefDatabase.getUserEmail() ?? "email", selectedPrinter!);
    // Navigator.of(context).pop();
  }
}
