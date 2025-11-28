import 'dart:developer';

import 'package:customer/constant/constant.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/preferences.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class MyProfileController extends GetxController {
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getThem();
    super.onInit();
  }

  RxString isDarkMode = "Light".obs;
  RxBool isDarkModeSwitch = false.obs;

  getThem() {
    isDarkMode.value = Preferences.getString(Preferences.themKey);
    if (isDarkMode.value == "Dark") {
      isDarkModeSwitch.value = true;
    } else if (isDarkMode.value == "Light") {
      isDarkModeSwitch.value = false;
    } else {
      isDarkModeSwitch.value = false;
    }
    isLoading.value = false;
  }

  Future<bool> deleteUserFromServer() async {
    var url = '${Constant.websiteUrl}/api/delete-user';
    try {
      var response = await http.post(
        Uri.parse(url),
        body: {
          'uuid': FireStoreUtils.getCurrentUid(),
        },
      );
      log("deleteUserFromServer :: ${response.body}");
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
