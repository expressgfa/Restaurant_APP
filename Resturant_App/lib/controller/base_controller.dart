import 'dart:developer';

import 'package:get/get.dart';
import 'package:resturantapp/constant/all_controller.dart';
import 'package:resturantapp/services/app_exceptions.dart';
import 'package:resturantapp/utils/dialog_helper.dart';
import 'package:resturantapp/utils/snack_bar.dart';

class BaseController {
  void handleError(error) {
    hideLoading();
    authController.loading.value = false;
    dismissLoading();
    if (error is BadRequestException) {
      var message = error.message;
      log("inside error is BadRequestException");
      DialogHelper.showErroDialog(description: message);
    }
    //
    else if (error is FetchDataException) {
      log("inside error is FetchDataException");
      var message = error.message;
      // DialogHelper.showErroDialog(description: message);
      ///
      // showMsg(msg: "No internet please try again".tr + (message ?? ""));
    }
    //
    else if (error is ApiNotRespondingException) {
      log("inside error is ApiNotRespondingException");

      // DialogHelper.showErroDialog(description: 'Oops! It took longer to respond.');
      // showMsg(msg: "Something went wrong please try again");
    }
  }

  showLoading([String? message]) {
    DialogHelper.showLoading(message);
  }

  hideLoading() {
    DialogHelper.hideLoading();
  }
}
