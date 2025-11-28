import 'package:customer/constant/constant.dart';
import 'package:customer/models/favourite_model.dart';
import 'package:customer/models/vendor_model.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:get/get.dart';

class RestaurantListController extends GetxController {
  RxBool isLoading = true.obs;
  RxList<VendorModel> vendorList = <VendorModel>[].obs;
  RxList<VendorModel> vendorSearchList = <VendorModel>[].obs;

  RxString title = "Vendors".obs;

  RxList<FavouriteModel> favouriteList = <FavouriteModel>[].obs;

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
      vendorSearchList.value = argumentData['vendorList'];
      title.value = argumentData['title'] ?? "Vendors";
    }

    await getFavouriteRestaurant();

    isLoading.value = false;
  }

  getFavouriteRestaurant() async {
    if (Constant.userModel != null) {
      await FireStoreUtils.getFavouriteRestaurant().then(
        (value) {
          favouriteList.value = value;
        },
      );
    }
  }

  @override
  void dispose() {
    vendorSearchList.clear();
    super.dispose();
  }
}
