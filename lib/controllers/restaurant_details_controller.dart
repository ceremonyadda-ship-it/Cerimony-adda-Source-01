import 'dart:async';
import 'dart:developer';

import 'package:customer/constant/constant.dart';
import 'package:customer/models/AttributesModel.dart';
import 'package:customer/models/cart_product_model.dart';
import 'package:customer/models/coupon_model.dart';
import 'package:customer/models/favourite_item_model.dart';
import 'package:customer/models/favourite_model.dart';
import 'package:customer/models/product_model.dart';
import 'package:customer/models/vendor_category_model.dart';
import 'package:customer/models/vendor_model.dart';
import 'package:customer/services/cart_provider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class RestaurantDetailsController extends GetxController {
  Rx<TextEditingController> searchEditingController = TextEditingController().obs;

  RxBool isLoading = true.obs;
  Rx<PageController> pageController = PageController().obs;
  RxInt currentPage = 0.obs;

  RxBool isVag = false.obs;
  RxBool isNonVag = false.obs;
  RxBool isMenuOpen = false.obs;

  RxList<FavouriteModel> favouriteList = <FavouriteModel>[].obs;
  RxList<FavouriteItemModel> favouriteItemList = <FavouriteItemModel>[].obs;
  RxList<ProductModel> allProductList = <ProductModel>[].obs;
  RxList<ProductModel> productList = <ProductModel>[].obs;
  RxList<VendorCategoryModel> vendorCategoryList = <VendorCategoryModel>[].obs;

  RxList<CouponModel> couponList = <CouponModel>[].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getArgument();

    super.onInit();
  }

  void animateSlider() {
    if (vendorModel.value.photos != null && vendorModel.value.photos!.isNotEmpty) {
      Timer.periodic(const Duration(seconds: 2), (Timer timer) {
        if (currentPage < vendorModel.value.photos!.length - 1) {
          currentPage++;
        } else {
          currentPage.value = 0;
        }

        if (pageController.value.hasClients) {
          pageController.value.animateToPage(
            currentPage.value,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
          );
        }
      });
    }
  }

  Rx<VendorModel> vendorModel = VendorModel().obs;

  final CartProvider cartProvider = CartProvider();

  getArgument() async {
    cartProvider.cartStream.listen(
      (event) async {
        cartItem.clear();
        cartItem.addAll(event);
      },
    );
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      vendorModel.value = argumentData['vendorModel'];
    }
    animateSlider();
    statusCheck();

    await getProduct();

    isLoading.value = false;
    await getFavouriteList();

    update();
  }

  getProduct() async {
    await FireStoreUtils.getProductByVendorId(vendorModel.value.id.toString()).then((value) {
      if ((Constant.isSubscriptionModelApplied == true || Constant.adminCommission?.isEnabled == true) && vendorModel.value.subscriptionPlan != null) {
        if (vendorModel.value.subscriptionPlan?.itemLimit == '-1') {
          allProductList.value = value;
          productList.value = value;
        } else {
          int selectedProduct = value.length < int.parse(vendorModel.value.subscriptionPlan?.itemLimit ?? '0')
              ? (value.isEmpty ? 0 : (value.length))
              : int.parse(vendorModel.value.subscriptionPlan?.itemLimit ?? '0');
          allProductList.value = value.sublist(0, selectedProduct);
          productList.value = value.sublist(0, selectedProduct);
        }
      } else {
        allProductList.value = value;
        productList.value = value;
      }
    });

    for (var element in productList) {
      await FireStoreUtils.getVendorCategoryById(element.categoryID.toString()).then(
        (value) {
          if (value != null) {
            vendorCategoryList.add(value);
          }
        },
      );
    }
    var seen = <String>{};
    vendorCategoryList.value = vendorCategoryList.where((element) => seen.add(element.id.toString())).toList();
  }

  searchProduct(String name) {
    if (name.isEmpty) {
      productList.clear();
      productList.addAll(allProductList);
    } else {
      isVag.value = false;
      isNonVag.value = false;
      productList.value = allProductList.where((p0) => p0.name!.toLowerCase().contains(name.toLowerCase())).toList();
    }
    update();
  }

  filterRecord() {
    if (isVag.value == true && isNonVag.value == true) {
      productList.value = allProductList.where((p0) => p0.nonveg == true || p0.nonveg == false).toList();
    } else if (isVag.value == true && isNonVag.value == false) {
      productList.value = allProductList.where((p0) => p0.nonveg == false).toList();
    } else if (isVag.value == false && isNonVag.value == true) {
      productList.value = allProductList.where((p0) => p0.nonveg == true).toList();
    } else if (isVag.value == false && isNonVag.value == false) {
      productList.value = allProductList.where((p0) => p0.nonveg == true || p0.nonveg == false).toList();
    }
  }

  Future<List<ProductModel>> getProductByCategory(VendorCategoryModel vendorCategoryModel) async {
    return productList.where((p0) => p0.categoryID == vendorCategoryModel.id).toList();
  }

  getFavouriteList() async {
    if (Constant.userModel != null) {
      await FireStoreUtils.getFavouriteRestaurant().then(
        (value) {
          favouriteList.value = value;
        },
      );

      await FireStoreUtils.getFavouriteItem().then(
        (value) {
          favouriteItemList.value = value;
        },
      );

      await FireStoreUtils.getOfferByVendorId(vendorModel.value.id.toString()).then(
        (value) {
          couponList.value = value;
        },
      );
    }
    await getAttributeData();
    update();
  }

  RxBool isOpen = false.obs;

  statusCheck() {
    final now = DateTime.now();
    var day = DateFormat('EEEE', 'en_US').format(now);
    var date = DateFormat('dd-MM-yyyy').format(now);
    for (var element in vendorModel.value.workingHours ?? []) {
      if (day == element.day.toString()) {
        if (element.timeslot!.isNotEmpty) {
          for (var element in element.timeslot!) {
            var start = DateFormat("dd-MM-yyyy HH:mm").parse("$date ${element.from}");
            var end = DateFormat("dd-MM-yyyy HH:mm").parse("$date ${element.to}");
            if (isCurrentDateInRange(start, end)) {
              isOpen.value = true;
            }
          }
        }
      }
    }
  }

  bool isCurrentDateInRange(DateTime startDate, DateTime endDate) {
    print(startDate);
    print(endDate);
    final currentDate = DateTime.now();
    print(currentDate);
    return currentDate.isAfter(startDate) && currentDate.isBefore(endDate);
  }

  RxList<AttributesModel> attributesList = <AttributesModel>[].obs;
  RxList selectedVariants = [].obs;
  RxList selectedIndexVariants = [].obs;
  RxList selectedIndexArray = [].obs;

  RxList selectedAddOns = [].obs;

  RxInt quantity = 1.obs;

  calculatePrice(ProductModel productModel) {
    String mainPrice = "0";
    String variantPrice = "0";
    String adOnsPrice = "0";

    if (productModel.itemAttribute != null) {
      if (productModel.itemAttribute!.variants!.where((element) => element.variantSku == selectedVariants.join('-')).isNotEmpty) {
        variantPrice = Constant.productCommissionPrice(
            vendorModel.value, productModel.itemAttribute!.variants!.where((element) => element.variantSku == selectedVariants.join('-')).first.variantPrice ?? '0');
      }
    } else {
      String price = Constant.productCommissionPrice(vendorModel.value, productModel.price.toString());
      String disPrice = double.parse(productModel.disPrice.toString()) <= 0 ? "0" : Constant.productCommissionPrice(vendorModel.value, productModel.disPrice.toString());
      if (double.parse(disPrice) <= 0) {
        variantPrice = price;
      } else {
        variantPrice = disPrice;
      }
    }

    for (int i = 0; i < productModel.addOnsPrice!.length; i++) {
      if (selectedAddOns.contains(productModel.addOnsTitle![i]) == true) {
        adOnsPrice = (double.parse(adOnsPrice.toString()) + double.parse(Constant.productCommissionPrice(vendorModel.value, productModel.addOnsPrice![i].toString()))).toString();
      }
    }
    adOnsPrice = (quantity.value * double.parse(adOnsPrice)).toString();
    mainPrice = ((double.parse(variantPrice.toString()) * double.parse(quantity.value.toString())) + double.parse(adOnsPrice.toString())).toString();
    return mainPrice;
  }

  getAttributeData() async {
    await FireStoreUtils.getAttributes().then((value) {
      if (value != null) {
        attributesList.value = value;
      }
    });
  }

  addToCart({
    required ProductModel productModel,
    required String price,
    required String discountPrice,
    required bool isIncrement,
    required int quantity,
    VariantInfo? variantInfo,
  }) async {
    CartProductModel cartProductModel = CartProductModel();

    String adOnsPrice = "0";
    for (int i = 0; i < productModel.addOnsPrice!.length; i++) {
      if (selectedAddOns.contains(productModel.addOnsTitle![i]) == true && productModel.addOnsPrice![i] != '0') {
        adOnsPrice = (double.parse(adOnsPrice.toString()) + double.parse(Constant.productCommissionPrice(vendorModel.value, productModel.addOnsPrice![i].toString()))).toString();
      }
    }

    if (variantInfo != null) {
      cartProductModel.id = "${productModel.id!}~${variantInfo.variantId.toString()}";
      cartProductModel.name = productModel.name!;
      cartProductModel.photo = productModel.photo!;
      cartProductModel.categoryId = productModel.categoryID!;
      cartProductModel.price = price;
      cartProductModel.discountPrice = discountPrice;
      cartProductModel.vendorID = vendorModel.value.id;
      cartProductModel.quantity = quantity;
      cartProductModel.variantInfo = variantInfo;
      cartProductModel.extrasPrice = adOnsPrice;
      cartProductModel.extras = selectedAddOns.isEmpty ? [] : selectedAddOns;
    } else {
      cartProductModel.id = productModel.id!;
      cartProductModel.name = productModel.name!;
      cartProductModel.photo = productModel.photo!;
      cartProductModel.categoryId = productModel.categoryID!;
      cartProductModel.price = price;
      cartProductModel.discountPrice = discountPrice;
      cartProductModel.vendorID = vendorModel.value.id;
      cartProductModel.quantity = quantity;
      cartProductModel.variantInfo = VariantInfo();
      cartProductModel.extrasPrice = adOnsPrice;
      cartProductModel.extras = selectedAddOns.isEmpty ? [] : selectedAddOns;
    }

    if (isIncrement) {
      await cartProvider.addToCart(Get.context!, cartProductModel, quantity);
    } else {
      await cartProvider.removeFromCart(cartProductModel, quantity);
    }
    log("===> new ${cartItem.length}");
    update();
  }
}
