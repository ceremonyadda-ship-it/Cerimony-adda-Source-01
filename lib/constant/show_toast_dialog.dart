import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class ShowToastDialog {
  static showToast(String? message, {EasyLoadingToastPosition position = EasyLoadingToastPosition.top}) {
    EasyLoading.showToast(message!.tr, toastPosition: position);
  }

  static showLoader(String message) {
    EasyLoading.show(status: message);
  }

  static closeLoader() {
    EasyLoading.dismiss();
  }
}
