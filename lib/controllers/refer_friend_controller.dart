import 'package:customer/models/referral_model.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:get/get.dart';

class ReferFriendController extends GetxController {
  Rx<ReferralModel> referralModel = ReferralModel().obs;

  RxBool isLoading = true.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getData();
    super.onInit();
  }

  getData() async {
    await FireStoreUtils.getReferralUserBy().then((value) {
      if (value != null) {
        referralModel.value = value;
      }
    });
    isLoading.value = false;
  }
}
