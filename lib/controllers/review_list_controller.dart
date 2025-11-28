import 'package:customer/models/rating_model.dart';
import 'package:customer/models/vendor_model.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:get/get.dart';

class ReviewListController extends GetxController {
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getArgument();
    super.onInit();
  }

  Rx<VendorModel> vendorModel = VendorModel().obs;
  RxList<RatingModel> ratingList = <RatingModel>[].obs;

  getArgument() {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      vendorModel.value = argumentData['vendorModel'];
      getAllReview();
    }
    isLoading.value = false;
  }

  getAllReview() async {
    await FireStoreUtils.getVendorReviews(vendorModel.value.id.toString()).then(
      (value) {
        ratingList.value = value;
      },
    );
    update();
  }
}
