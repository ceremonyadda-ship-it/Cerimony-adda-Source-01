import 'package:customer/models/on_boarding_model.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnBoardingController extends GetxController {
  var selectedPageIndex = 0.obs;

  bool get isLastPage => selectedPageIndex.value == onBoardingList.length - 1;
  var pageController = PageController();

  @override
  void onInit() {
    getOnBoardingData();
    super.onInit();
  }

  RxBool isLoading = true.obs;
  RxList<OnBoardingModel> onBoardingList = <OnBoardingModel>[].obs;

  getOnBoardingData() async {
    await FireStoreUtils.getOnBoardingList().then((value) {
      onBoardingList.value = value;
    });
    // onBoardingList.add(OnBoardingModel(id: "",title: "Vendors",description: "Discover a variety of Vendors near you.",image: "assets/images/image_1.png"));
    // onBoardingList.add(OnBoardingModel(id: "",title: "Order",description: "Order your favorite dishes in just a few taps.",image: "assets/images/image_2.png"));
    // onBoardingList.add(OnBoardingModel(id: "",title: "Delivery",description: "Get your food delivered hot and fresh.",image: "assets/images/image_3.png"));

    isLoading.value = false;
    update();
  }
}
