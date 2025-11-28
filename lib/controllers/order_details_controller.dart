import 'package:customer/constant/constant.dart';
import 'package:customer/models/cart_product_model.dart';
import 'package:customer/models/order_model.dart';
import 'package:customer/services/cart_provider.dart';
import 'package:get/get.dart';

class OrderDetailsController extends GetxController {
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getArgument();
    super.onInit();
  }

  Rx<OrderModel> orderModel = OrderModel().obs;

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      orderModel.value = argumentData['orderModel'];
    }
    calculatePrice();
    update();
  }

  RxDouble subTotal = 0.0.obs;
  RxDouble specialDiscountAmount = 0.0.obs;
  RxDouble taxAmount = 0.0.obs;
  RxDouble totalAmount = 0.0.obs;

  calculatePrice() async {
    subTotal.value = 0.0;
    specialDiscountAmount.value = 0.0;
    taxAmount.value = 0.0;
    totalAmount.value = 0.0;

    for (var element in orderModel.value.products!) {
      if (double.parse(element.discountPrice.toString()) <= 0) {
        subTotal.value = subTotal.value +
            double.parse(element.price.toString()) * double.parse(element.quantity.toString()) +
            (double.parse(element.extrasPrice.toString()) * double.parse(element.quantity.toString()));
      } else {
        subTotal.value = subTotal.value +
            double.parse(element.discountPrice.toString()) * double.parse(element.quantity.toString()) +
            (double.parse(element.extrasPrice.toString()) * double.parse(element.quantity.toString()));
      }
    }

    if (orderModel.value.specialDiscount != null && orderModel.value.specialDiscount!['special_discount'] != null) {
      specialDiscountAmount.value = double.parse(orderModel.value.specialDiscount!['special_discount'].toString());
    }

    if (orderModel.value.taxSetting != null) {
      for (var element in orderModel.value.taxSetting!) {
        taxAmount.value = taxAmount.value +
            Constant.calculateTax(amount: (subTotal.value - double.parse(orderModel.value.discount.toString()) - specialDiscountAmount.value).toString(), taxModel: element);
      }
    }

    totalAmount.value = (subTotal.value - double.parse(orderModel.value.discount.toString()) - specialDiscountAmount.value) +
        taxAmount.value +
        double.parse(orderModel.value.deliveryCharge.toString()) +
        double.parse(orderModel.value.tipAmount.toString());

    isLoading.value = false;
  }

  final CartProvider cartProvider = CartProvider();

  addToCart({required CartProductModel cartProductModel}) {
    cartProvider.addToCart(Get.context!, cartProductModel, cartProductModel.quantity!);
    update();
  }
}
