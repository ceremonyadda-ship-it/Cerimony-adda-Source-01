import 'package:customer/constant/constant.dart';
import 'package:customer/models/advertisement_model.dart';
import 'package:customer/models/favourite_model.dart';
import 'package:customer/models/vendor_model.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:get/get.dart';

class AdvertisementListController extends GetxController {
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    getAdvertisementList();
    getFavouriteRestaurant();
    super.onInit();
  }

  RxList<AdvertisementModel> advertisementList = <AdvertisementModel>[].obs;

  getAdvertisementList() async {
    advertisementList.clear();
    List<VendorModel> allNearestRestaurant = <VendorModel>[];
    FireStoreUtils.getAllNearestRestaurant().listen((event) async {
      allNearestRestaurant.addAll(event);
      await FireStoreUtils.getAllAdvertisement().then((value) {
        List<AdvertisementModel> adsList = value;
        advertisementList.addAll(
          adsList.where((ads) => allNearestRestaurant.any((restaurant) => restaurant.id == ads.vendorId)),
        );
      });
      isLoading.value = false;
    });
  }

  RxList<FavouriteModel> favouriteList = <FavouriteModel>[].obs;

  getFavouriteRestaurant() async {
    if (Constant.userModel != null) {
      await FireStoreUtils.getFavouriteRestaurant().then(
        (value) {
          favouriteList.value = value;
        },
      );
    }
  }
}
