import 'package:customer/models/dine_in_booking_model.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:get/get.dart';

class DineInBookingController extends GetxController {
  RxBool isLoading = true.obs;

  RxBool isFeature = true.obs;

  RxList<DineInBookingModel> featureList = <DineInBookingModel>[].obs;
  RxList<DineInBookingModel> historyList = <DineInBookingModel>[].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getDineInBooking();
    super.onInit();
  }

  getDineInBooking() async {
    await FireStoreUtils.getDineInBooking(true).then(
      (value) {
        featureList.value = value;
      },
    );
    await FireStoreUtils.getDineInBooking(false).then(
      (value) {
        historyList.value = value;
      },
    );

    isLoading.value = false;
  }
}
