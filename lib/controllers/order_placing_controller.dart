import 'dart:async';

import 'package:customer/models/order_model.dart';
import 'package:customer/services/database_helper.dart';
import 'package:get/get.dart';

class OrderPlacingController extends GetxController {
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getArgument();
    startTimer();
    super.onInit();
  }

  Rx<OrderModel> orderModel = OrderModel().obs;

  getArgument() async {
    DatabaseHelper.instance.deleteAllCartProducts();
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      orderModel.value = argumentData['orderModel'];
    }
    isLoading.value = false;
    update();
  }

  Timer? timer;
  RxInt counter = 0.obs;

  RxBool isPlacing = false.obs;

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (counter.value == 3) {
        timer.cancel();
        isPlacing.value = true;
      }
      counter++;
    });
  }
}
