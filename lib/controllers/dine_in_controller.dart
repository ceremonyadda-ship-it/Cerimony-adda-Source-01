import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/models/BannerModel.dart';
import 'package:customer/models/favourite_model.dart';
import 'package:customer/models/vendor_category_model.dart';
import 'package:customer/models/vendor_model.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DineInController extends GetxController {
  RxBool isLoading = true.obs;
  RxBool isPopular = true.obs;

  @override
  void onInit() {
    getCategory();
    getData();
    // TODO: implement onInit
    super.onInit();
  }

  RxList<VendorCategoryModel> vendorCategoryModel = <VendorCategoryModel>[].obs;

  RxList<VendorModel> allNearestRestaurant = <VendorModel>[].obs;
  RxList<VendorModel> newArrivalRestaurantList = <VendorModel>[].obs;
  RxList<VendorModel> popularRestaurantList = <VendorModel>[].obs;

  RxList<BannerModel> bannerBottomModel = <BannerModel>[].obs;
  Rx<PageController> pageBottomController = PageController(viewportFraction: 0.877).obs;
  RxInt currentBottomPage = 0.obs;

  RxList<FavouriteModel> favouriteList = <FavouriteModel>[].obs;

  getData() async {
    isLoading.value = true;
    await getZone();
    FireStoreUtils.getAllNearestRestaurant(isDining: true).listen((event) async {
      newArrivalRestaurantList.clear();
      allNearestRestaurant.clear();
      popularRestaurantList.clear();

      allNearestRestaurant.addAll(event);
      newArrivalRestaurantList.addAll(event);
      popularRestaurantList.addAll(event);

      popularRestaurantList.sort(
        (a, b) => Constant.calculateReview(reviewCount: b.reviewsCount.toString(), reviewSum: b.reviewsSum.toString())
            .compareTo(Constant.calculateReview(reviewCount: a.reviewsCount.toString(), reviewSum: a.reviewsSum.toString())),
      );

      newArrivalRestaurantList.sort(
        (a, b) => (b.createdAt ?? Timestamp.now()).toDate().compareTo((a.createdAt ?? Timestamp.now()).toDate()),
      );
    });

    update();
    isLoading.value = false;
  }

  getCategory() async {
    await FireStoreUtils.getHomeVendorCategory().then(
      (value) {
        vendorCategoryModel.value = value;
      },
    );

    await FireStoreUtils.getHomeBottomBanner().then(
      (value) {
        bannerBottomModel.value = value;
      },
    );
    if (Constant.userModel != null) {
      await FireStoreUtils.getFavouriteRestaurant().then(
        (value) {
          favouriteList.value = value;
        },
      );
    }
  }

  getZone() async {
    await FireStoreUtils.getZone().then((value) {
      if (value != null) {
        for (int i = 0; i < value.length; i++) {
          if (Constant.isPointInPolygon(LatLng(Constant.selectedLocation.location!.latitude ?? 0.0, Constant.selectedLocation.location!.longitude ?? 0.0), value[i].area!)) {
            Constant.selectedZone = value[i];
            Constant.isZoneAvailable = true;
            break;
          } else {
            Constant.isZoneAvailable = false;
          }
        }
      }
    });
  }
}
