import 'package:get/get.dart';
import 'package:resturantapp/controller/api_controller.dart';
import 'package:resturantapp/controller/auth/auth_controller.dart';
import 'package:resturantapp/controller/language_controller/language_controller.dart';
import 'package:resturantapp/controller/network/network_controller.dart';
import 'package:resturantapp/controller/printer_provider/printer_provider.dart';

//
LanguageController languageController = LanguageController.instance;
ApiController apiController = ApiController.instance;
NetworkController networkController = NetworkController.instance;
AuthController authController = AuthController.instance;
PrinterController printerController = PrinterController.instance;

void init() {
  Get.put<NetworkController>(NetworkController(), permanent: true);

  Get.put(AuthController());
  Get.put(PrinterController());
  Get.put(LanguageController());
  Get.put(ApiController());
}
