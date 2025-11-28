import 'package:customer/models/coupon_model.dart';
import 'package:customer/models/vendor_model.dart';
import 'package:get/get.dart';

class DiscountRestaurantListController extends GetxController {
  RxBool isLoading = true.obs;
  RxList<VendorModel> vendorList = <VendorModel>[].obs;
  RxList<CouponModel> couponList = <CouponModel>[].obs;

  RxString title = "Vendors".obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getArgument();
    super.onInit();
  }

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      vendorList.value = argumentData['vendorList'];
      couponList.value = argumentData['couponList'];
      title.value = argumentData['title'] ?? "Vendors";
    }
    isLoading.value = false;
  }
}
