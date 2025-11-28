import 'package:bottom_picker/bottom_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/app/address_screens/address_list_screen.dart';
import 'package:customer/app/cart_screen/coupon_list_screen.dart';
import 'package:customer/app/cart_screen/select_payment_screen.dart';
import 'package:customer/app/restaurant_details_screen/restaurant_details_screen.dart';
import 'package:customer/app/wallet_screen/wallet_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controllers/cart_controller.dart';
import 'package:customer/models/cart_product_model.dart';
import 'package:customer/models/product_model.dart';
import 'package:customer/models/tax_model.dart';
import 'package:customer/models/user_model.dart';
import 'package:customer/payment/createRazorPayOrderModel.dart';
import 'package:customer/payment/rozorpayConroller.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/themes/round_button_fill.dart';
import 'package:customer/themes/text_field_widget.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/network_image_widget.dart';
import 'package:customer/widget/my_separator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: CartController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: themeChange.getThem()
                ? AppThemeData.surfaceDark
                : AppThemeData.surface,
            appBar: AppBar(
              backgroundColor: themeChange.getThem()
                  ? AppThemeData.surfaceDark
                  : AppThemeData.surface,
            ),
            body: cartItem.isEmpty
                ? Constant.showEmptyView(message: "Item Not available".tr)
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        controller.selectedFoodType.value == 'TakeAway'
                            ? const SizedBox()
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: InkWell(
                                  onTap: () {
                                    Get.to(const AddressListScreen())!.then(
                                      (value) {
                                        if (value != null) {
                                          ShippingAddress addressModel = value;
                                          controller.selectedAddress.value =
                                              addressModel;
                                          controller.calculatePrice();
                                        }
                                      },
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        decoration: ShapeDecoration(
                                          color: themeChange.getThem()
                                              ? AppThemeData.grey900
                                              : AppThemeData.grey50,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SvgPicture.asset(
                                                      "assets/icons/ic_send_one.svg"),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      controller.selectedAddress
                                                          .value.addressAs
                                                          .toString(),
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                        fontFamily: AppThemeData
                                                            .semiBold,
                                                        color: themeChange
                                                                .getThem()
                                                            ? AppThemeData
                                                                .primary300
                                                            : AppThemeData
                                                                .primary300,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                  SvgPicture.asset(
                                                      "assets/icons/ic_down.svg"),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                controller.selectedAddress.value
                                                    .getFullAddress(),
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppThemeData.medium,
                                                  color: themeChange.getThem()
                                                      ? AppThemeData.grey400
                                                      : AppThemeData.grey500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            decoration: ShapeDecoration(
                              color: themeChange.getThem()
                                  ? AppThemeData.grey900
                                  : AppThemeData.grey50,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              child: ListView.separated(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount: cartItem.length,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  CartProductModel cartProductModel =
                                      cartItem[index];
                                  ProductModel? productModel;
                                  FireStoreUtils.getProductById(
                                          cartProductModel.id!.split('~').first)
                                      .then((value) {
                                    productModel = value;
                                  });
                                  print(
                                      "cartItem[index] :: ${cartItem[index].extras} ::${cartItem[index].extrasPrice}");
                                  return InkWell(
                                    onTap: () async {
                                      await FireStoreUtils.getVendorById(
                                              productModel!.vendorID.toString())
                                          .then(
                                        (value) {
                                          if (value != null) {
                                            Get.to(
                                                const RestaurantDetailsScreen(),
                                                arguments: {
                                                  "vendorModel": value
                                                });
                                          }
                                        },
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(16)),
                                                child: NetworkImageWidget(
                                                  imageUrl: cartProductModel
                                                      .photo
                                                      .toString(),
                                                  height: Responsive.height(
                                                      10, context),
                                                  width: Responsive.width(
                                                      20, context),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "${cartProductModel.name}",
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                        fontFamily: AppThemeData
                                                            .regular,
                                                        color: themeChange
                                                                .getThem()
                                                            ? AppThemeData
                                                                .grey50
                                                            : AppThemeData
                                                                .grey900,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    double.parse(cartProductModel
                                                                .discountPrice
                                                                .toString()) <=
                                                            0
                                                        ? Text(
                                                            Constant.amountShow(
                                                                amount:
                                                                    cartProductModel
                                                                        .price),
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              color: themeChange
                                                                      .getThem()
                                                                  ? AppThemeData
                                                                      .grey50
                                                                  : AppThemeData
                                                                      .grey900,
                                                              fontFamily:
                                                                  AppThemeData
                                                                      .semiBold,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          )
                                                        : Row(
                                                            children: [
                                                              Text(
                                                                Constant.amountShow(
                                                                    amount: cartProductModel
                                                                        .discountPrice
                                                                        .toString()),
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 16,
                                                                  color: themeChange.getThem()
                                                                      ? AppThemeData
                                                                          .grey50
                                                                      : AppThemeData
                                                                          .grey900,
                                                                  fontFamily:
                                                                      AppThemeData
                                                                          .semiBold,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 5,
                                                              ),
                                                              Text(
                                                                Constant.amountShow(
                                                                    amount: cartProductModel
                                                                        .price),
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 14,
                                                                  decoration:
                                                                      TextDecoration
                                                                          .lineThrough,
                                                                  decorationColor: themeChange.getThem()
                                                                      ? AppThemeData
                                                                          .grey500
                                                                      : AppThemeData
                                                                          .grey400,
                                                                  color: themeChange.getThem()
                                                                      ? AppThemeData
                                                                          .grey500
                                                                      : AppThemeData
                                                                          .grey400,
                                                                  fontFamily:
                                                                      AppThemeData
                                                                          .semiBold,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                decoration: ShapeDecoration(
                                                  color: themeChange.getThem()
                                                      ? AppThemeData.grey900
                                                      : AppThemeData.grey50,
                                                  shape: RoundedRectangleBorder(
                                                    side: const BorderSide(
                                                        width: 1,
                                                        color:
                                                            Color(0xFFD1D5DB)),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            200),
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 5,
                                                      horizontal: 5),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      InkWell(
                                                          onTap: () {
                                                            controller.addToCart(
                                                                cartProductModel:
                                                                    cartProductModel,
                                                                isIncrement:
                                                                    false,
                                                                quantity:
                                                                    cartProductModel
                                                                            .quantity! -
                                                                        1);
                                                          },
                                                          child: const Icon(
                                                              Icons.remove)),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 10),
                                                        child: Text(
                                                          cartProductModel
                                                              .quantity
                                                              .toString(),
                                                          textAlign:
                                                              TextAlign.start,
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            fontFamily:
                                                                AppThemeData
                                                                    .medium,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: themeChange
                                                                    .getThem()
                                                                ? AppThemeData
                                                                    .grey100
                                                                : AppThemeData
                                                                    .grey800,
                                                          ),
                                                        ),
                                                      ),
                                                      InkWell(
                                                          onTap: () {
                                                            if (productModel!
                                                                    .itemAttribute !=
                                                                null) {
                                                              if (productModel!
                                                                  .itemAttribute!
                                                                  .variants!
                                                                  .where((element) =>
                                                                      element
                                                                          .variantSku ==
                                                                      cartProductModel
                                                                          .variantInfo!
                                                                          .variantSku)
                                                                  .isNotEmpty) {
                                                                if (int.parse(productModel!
                                                                            .itemAttribute!
                                                                            .variants!
                                                                            .where((element) =>
                                                                                element.variantSku ==
                                                                                cartProductModel
                                                                                    .variantInfo!.variantSku)
                                                                            .first
                                                                            .variantQuantity
                                                                            .toString()) >
                                                                        (cartProductModel.quantity ??
                                                                            0) ||
                                                                    int.parse(productModel!
                                                                            .itemAttribute!
                                                                            .variants!
                                                                            .where((element) =>
                                                                                element.variantSku ==
                                                                                cartProductModel.variantInfo!.variantSku)
                                                                            .first
                                                                            .variantQuantity
                                                                            .toString()) ==
                                                                        -1) {
                                                                  controller.addToCart(
                                                                      cartProductModel:
                                                                          cartProductModel,
                                                                      isIncrement:
                                                                          true,
                                                                      quantity:
                                                                          cartProductModel.quantity! +
                                                                              1);
                                                                } else {
                                                                  ShowToastDialog
                                                                      .showToast(
                                                                          "Out of stock"
                                                                              .tr);
                                                                }
                                                              } else {
                                                                if ((productModel!.quantity ??
                                                                            0) >
                                                                        (cartProductModel.quantity ??
                                                                            0) ||
                                                                    productModel!
                                                                            .quantity ==
                                                                        -1) {
                                                                  controller.addToCart(
                                                                      cartProductModel:
                                                                          cartProductModel,
                                                                      isIncrement:
                                                                          true,
                                                                      quantity:
                                                                          cartProductModel.quantity! +
                                                                              1);
                                                                } else {
                                                                  ShowToastDialog
                                                                      .showToast(
                                                                          "Out of stock"
                                                                              .tr);
                                                                }
                                                              }
                                                            } else {
                                                              if ((productModel!
                                                                              .quantity ??
                                                                          0) >
                                                                      (cartProductModel
                                                                              .quantity ??
                                                                          0) ||
                                                                  productModel!
                                                                          .quantity ==
                                                                      -1) {
                                                                controller.addToCart(
                                                                    cartProductModel:
                                                                        cartProductModel,
                                                                    isIncrement:
                                                                        true,
                                                                    quantity:
                                                                        cartProductModel.quantity! +
                                                                            1);
                                                              } else {
                                                                ShowToastDialog
                                                                    .showToast(
                                                                        "Out of stock"
                                                                            .tr);
                                                              }
                                                            }
                                                          },
                                                          child: const Icon(
                                                              Icons.add)),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                          cartProductModel.variantInfo ==
                                                      null ||
                                                  cartProductModel.variantInfo!
                                                          .variantOptions ==
                                                      null ||
                                                  cartProductModel.variantInfo!
                                                      .variantOptions!.isEmpty
                                              ? Container()
                                              : Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 5,
                                                      vertical: 10),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "Variants".tr,
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              AppThemeData
                                                                  .semiBold,
                                                          color: themeChange
                                                                  .getThem()
                                                              ? AppThemeData
                                                                  .grey300
                                                              : AppThemeData
                                                                  .grey600,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      Wrap(
                                                        spacing: 6.0,
                                                        runSpacing: 6.0,
                                                        children: List.generate(
                                                          cartProductModel
                                                              .variantInfo!
                                                              .variantOptions!
                                                              .length,
                                                          (i) {
                                                            return Container(
                                                              decoration:
                                                                  ShapeDecoration(
                                                                color: themeChange.getThem()
                                                                    ? AppThemeData
                                                                        .grey800
                                                                    : AppThemeData
                                                                        .grey100,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8)),
                                                              ),
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        16,
                                                                    vertical:
                                                                        5),
                                                                child: Text(
                                                                  "${cartProductModel.variantInfo!.variantOptions!.keys.elementAt(i)} : ${cartProductModel.variantInfo!.variantOptions![cartProductModel.variantInfo!.variantOptions!.keys.elementAt(i)]}",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        AppThemeData
                                                                            .medium,
                                                                    color: themeChange.getThem()
                                                                        ? AppThemeData
                                                                            .grey500
                                                                        : AppThemeData
                                                                            .grey400,
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ).toList(),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                          cartProductModel.extras == null ||
                                                  cartProductModel
                                                      .extras!.isEmpty ||
                                                  cartProductModel
                                                          .extrasPrice ==
                                                      '0'
                                              ? const SizedBox()
                                              : Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            "Addons".tr,
                                                            textAlign:
                                                                TextAlign.start,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  AppThemeData
                                                                      .semiBold,
                                                              color: themeChange
                                                                      .getThem()
                                                                  ? AppThemeData
                                                                      .grey300
                                                                  : AppThemeData
                                                                      .grey600,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          Constant.amountShow(
                                                              amount: (double.parse(cartProductModel
                                                                          .extrasPrice
                                                                          .toString()) *
                                                                      double.parse(cartProductModel
                                                                          .quantity
                                                                          .toString()))
                                                                  .toString()),
                                                          textAlign:
                                                              TextAlign.start,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                AppThemeData
                                                                    .semiBold,
                                                            color: themeChange
                                                                    .getThem()
                                                                ? AppThemeData
                                                                    .primary300
                                                                : AppThemeData
                                                                    .primary300,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Wrap(
                                                      spacing: 6.0,
                                                      runSpacing: 6.0,
                                                      children: List.generate(
                                                        cartProductModel
                                                            .extras!.length,
                                                        (i) {
                                                          return Container(
                                                            decoration:
                                                                ShapeDecoration(
                                                              color: themeChange
                                                                      .getThem()
                                                                  ? AppThemeData
                                                                      .grey800
                                                                  : AppThemeData
                                                                      .grey100,
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8)),
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          16,
                                                                      vertical:
                                                                          5),
                                                              child: Text(
                                                                cartProductModel
                                                                    .extras![i]
                                                                    .toString(),
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      AppThemeData
                                                                          .medium,
                                                                  color: themeChange.getThem()
                                                                      ? AppThemeData
                                                                          .grey500
                                                                      : AppThemeData
                                                                          .grey400,
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ).toList(),
                                                    ),
                                                  ],
                                                ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: MySeparator(
                                        color: themeChange.getThem()
                                            ? AppThemeData.grey700
                                            : AppThemeData.grey200),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${'Delivery Type'.tr} (${controller.selectedFoodType.value})"
                                    .tr,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontFamily: AppThemeData.semiBold,
                                  color: themeChange.getThem()
                                      ? AppThemeData.grey50
                                      : AppThemeData.grey900,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              controller.selectedFoodType.value == 'TakeAway'
                                  ? const SizedBox()
                                  : Container(
                                      width: Responsive.width(100, context),
                                      decoration: ShapeDecoration(
                                        color: themeChange.getThem()
                                            ? AppThemeData.grey900
                                            : AppThemeData.grey50,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Instant Delivery".tr,
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AppThemeData.medium,
                                                      color:
                                                          themeChange.getThem()
                                                              ? AppThemeData
                                                                  .primary300
                                                              : AppThemeData
                                                                  .primary300,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    "Standard".tr,
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AppThemeData.medium,
                                                      fontSize: 12,
                                                      color: themeChange
                                                              .getThem()
                                                          ? AppThemeData.grey400
                                                          : AppThemeData
                                                              .grey500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Radio(
                                              value:
                                                  controller.deliveryType.value,
                                              groupValue: "instant".tr,
                                              activeColor:
                                                  AppThemeData.primary300,
                                              onChanged: (value) {
                                                controller.deliveryType.value =
                                                    "instant".tr;
                                              },
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                width: Responsive.width(100, context),
                                decoration: ShapeDecoration(
                                  color: themeChange.getThem()
                                      ? AppThemeData.grey900
                                      : AppThemeData.grey50,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    controller.deliveryType.value =
                                        "schedule".tr;
                                    BottomPicker.dateTime(
                                      onSubmit: (index) {
                                        controller.scheduleDateTime.value =
                                            index;
                                      },
                                      minDateTime: DateTime.now(),
                                      displaySubmitButton: true,
                                      pickerTitle: Text('Schedule Time'.tr),
                                      buttonSingleColor:
                                          AppThemeData.primary300,
                                    ).show(context);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Schedule Time".tr,
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppThemeData.medium,
                                                  color: themeChange.getThem()
                                                      ? AppThemeData.primary300
                                                      : AppThemeData.primary300,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                "${'Your preferred time'.tr} ${controller.deliveryType.value == "schedule" ? Constant.timestampToDateTime(Timestamp.fromDate(controller.scheduleDateTime.value)) : ""}",
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppThemeData.medium,
                                                  fontSize: 12,
                                                  color: themeChange.getThem()
                                                      ? AppThemeData.grey400
                                                      : AppThemeData.grey500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Radio(
                                          value: controller.deliveryType.value,
                                          groupValue: "schedule".tr,
                                          activeColor: AppThemeData.primary300,
                                          onChanged: (value) {
                                            controller.deliveryType.value =
                                                "schedule".tr;
                                            BottomPicker.dateTime(
                                              initialDateTime: controller
                                                  .scheduleDateTime.value,
                                              onSubmit: (index) {
                                                controller.scheduleDateTime
                                                    .value = index;
                                              },
                                              minDateTime: controller
                                                  .scheduleDateTime.value,
                                              displaySubmitButton: true,
                                              pickerTitle:
                                                  Text('Schedule Time'.tr),
                                              buttonSingleColor:
                                                  AppThemeData.primary300,
                                            ).show(context);
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Offers & Benefits".tr,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontFamily: AppThemeData.semiBold,
                                  color: themeChange.getThem()
                                      ? AppThemeData.grey50
                                      : AppThemeData.grey900,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              InkWell(
                                onTap: () {
                                  Get.to(const CouponListScreen());
                                },
                                child: Container(
                                  width: Responsive.width(100, context),
                                  decoration: ShapeDecoration(
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey900
                                        : AppThemeData.grey50,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    shadows: const [
                                      BoxShadow(
                                        color: Color(0x14000000),
                                        blurRadius: 52,
                                        offset: Offset(0, 0),
                                        spreadRadius: 0,
                                      )
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 14),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "Apply Coupons".tr,
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontFamily: AppThemeData.semiBold,
                                              color: themeChange.getThem()
                                                  ? AppThemeData.grey50
                                                  : AppThemeData.grey900,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        const Icon(Icons.keyboard_arrow_right)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Bill Details".tr,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontFamily: AppThemeData.semiBold,
                                  color: themeChange.getThem()
                                      ? AppThemeData.grey50
                                      : AppThemeData.grey900,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                width: Responsive.width(100, context),
                                decoration: ShapeDecoration(
                                  color: themeChange.getThem()
                                      ? AppThemeData.grey900
                                      : AppThemeData.grey50,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  shadows: const [
                                    BoxShadow(
                                      color: Color(0x14000000),
                                      blurRadius: 52,
                                      offset: Offset(0, 0),
                                      spreadRadius: 0,
                                    )
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 14),
                                  child: Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "Item totals".tr,
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontFamily:
                                                    AppThemeData.regular,
                                                color: themeChange.getThem()
                                                    ? AppThemeData.grey300
                                                    : AppThemeData.grey600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            Constant.amountShow(
                                                amount: controller
                                                    .subTotal.value
                                                    .toString()),
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontFamily: AppThemeData.regular,
                                              color: themeChange.getThem()
                                                  ? AppThemeData.grey50
                                                  : AppThemeData.grey900,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      controller.selectedFoodType.value ==
                                              'TakeAway'
                                          ? const SizedBox()
                                          : Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    "Delivery Fee".tr,
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AppThemeData.regular,
                                                      color: themeChange
                                                              .getThem()
                                                          ? AppThemeData.grey300
                                                          : AppThemeData
                                                              .grey600,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                                (controller.vendorModel.value
                                                                .isSelfDelivery ==
                                                            true &&
                                                        Constant.isSelfDeliveryFeature ==
                                                            true)
                                                    ? Text(
                                                        'Free Delivery',
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              AppThemeData
                                                                  .regular,
                                                          color: AppThemeData
                                                              .success400,
                                                          fontSize: 16,
                                                        ),
                                                      )
                                                    : Text(
                                                        Constant.amountShow(
                                                            amount: controller
                                                                .deliveryCharges
                                                                .value
                                                                .toString()),
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              AppThemeData
                                                                  .regular,
                                                          color: themeChange
                                                                  .getThem()
                                                              ? AppThemeData
                                                                  .grey50
                                                              : AppThemeData
                                                                  .grey900,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                              ],
                                            ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      MySeparator(
                                          color: themeChange.getThem()
                                              ? AppThemeData.grey700
                                              : AppThemeData.grey200),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "Coupon Discount".tr,
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontFamily:
                                                    AppThemeData.regular,
                                                color: themeChange.getThem()
                                                    ? AppThemeData.grey300
                                                    : AppThemeData.grey600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "- (${Constant.amountShow(amount: controller.couponAmount.value.toString())})",
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontFamily: AppThemeData.regular,
                                              color: themeChange.getThem()
                                                  ? AppThemeData.danger300
                                                  : AppThemeData.danger300,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      controller.vendorModel.value
                                                      .specialDiscountEnable ==
                                                  true &&
                                              Constant.specialDiscountOffer ==
                                                  true
                                          ? Column(
                                              children: [
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        "Special Discount".tr,
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              AppThemeData
                                                                  .regular,
                                                          color: themeChange
                                                                  .getThem()
                                                              ? AppThemeData
                                                                  .grey300
                                                              : AppThemeData
                                                                  .grey600,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      "- (${Constant.amountShow(amount: controller.specialDiscountAmount.value.toString())})",
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                        fontFamily: AppThemeData
                                                            .regular,
                                                        color:
                                                            themeChange
                                                                    .getThem()
                                                                ? AppThemeData
                                                                    .danger300
                                                                : AppThemeData
                                                                    .danger300,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            )
                                          : const SizedBox(),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      controller.selectedFoodType.value ==
                                                  'TakeAway' ||
                                              (controller.vendorModel.value
                                                          .isSelfDelivery ==
                                                      true &&
                                                  Constant.isSelfDeliveryFeature ==
                                                      true)
                                          ? const SizedBox()
                                          : Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "Delivery Tips".tr,
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              AppThemeData
                                                                  .regular,
                                                          color: themeChange
                                                                  .getThem()
                                                              ? AppThemeData
                                                                  .grey300
                                                              : AppThemeData
                                                                  .grey600,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      controller.deliveryTips
                                                                  .value ==
                                                              0
                                                          ? const SizedBox()
                                                          : InkWell(
                                                              onTap: () {
                                                                controller
                                                                    .deliveryTips
                                                                    .value = 0;
                                                                controller
                                                                    .calculatePrice();
                                                              },
                                                              child: Text(
                                                                "Remove".tr,
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      AppThemeData
                                                                          .medium,
                                                                  color: themeChange.getThem()
                                                                      ? AppThemeData
                                                                          .primary300
                                                                      : AppThemeData
                                                                          .primary300,
                                                                ),
                                                              ),
                                                            ),
                                                    ],
                                                  ),
                                                ),
                                                Text(
                                                  Constant.amountShow(
                                                      amount: controller
                                                          .deliveryTips
                                                          .toString()),
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                    fontFamily:
                                                        AppThemeData.regular,
                                                    color: themeChange.getThem()
                                                        ? AppThemeData.grey50
                                                        : AppThemeData.grey900,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      MySeparator(
                                          color: themeChange.getThem()
                                              ? AppThemeData.grey700
                                              : AppThemeData.grey200),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      ListView.builder(
                                        itemCount: Constant.taxList!.length,
                                        shrinkWrap: true,
                                        padding: EdgeInsets.zero,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          TaxModel taxModel =
                                              Constant.taxList![index];
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 5),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    "${taxModel.title.toString()} (${taxModel.type == "fix" ? Constant.amountShow(amount: taxModel.tax) : "${taxModel.tax}%"})",
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AppThemeData.regular,
                                                      color: themeChange
                                                              .getThem()
                                                          ? AppThemeData.grey300
                                                          : AppThemeData
                                                              .grey600,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  Constant.amountShow(
                                                      amount: Constant.calculateTax(
                                                              amount: (double.parse(controller
                                                                          .subTotal
                                                                          .value
                                                                          .toString()) -
                                                                      controller
                                                                          .couponAmount
                                                                          .value -
                                                                      controller
                                                                          .specialDiscountAmount
                                                                          .value)
                                                                  .toString(),
                                                              taxModel:
                                                                  taxModel)
                                                          .toString()),
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                    fontFamily:
                                                        AppThemeData.regular,
                                                    color: themeChange.getThem()
                                                        ? AppThemeData.grey50
                                                        : AppThemeData.grey900,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "To Pay".tr,
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontFamily:
                                                    AppThemeData.regular,
                                                color: themeChange.getThem()
                                                    ? AppThemeData.grey300
                                                    : AppThemeData.grey600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            Constant.amountShow(
                                                amount: controller
                                                    .totalAmount.value
                                                    .toString()),
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontFamily: AppThemeData.regular,
                                              color: themeChange.getThem()
                                                  ? AppThemeData.grey50
                                                  : AppThemeData.grey900,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        controller.selectedFoodType.value == 'TakeAway' ||
                                (controller.vendorModel.value.isSelfDelivery ==
                                        true &&
                                    Constant.isSelfDeliveryFeature == true)
                            ? const SizedBox()
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      "Thanks with a tip!".tr,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontFamily: AppThemeData.semiBold,
                                        color: themeChange.getThem()
                                            ? AppThemeData.grey50
                                            : AppThemeData.grey900,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      width: Responsive.width(100, context),
                                      decoration: ShapeDecoration(
                                        color: themeChange.getThem()
                                            ? AppThemeData.grey900
                                            : AppThemeData.grey50,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        shadows: const [
                                          BoxShadow(
                                            color: Color(0x14000000),
                                            blurRadius: 52,
                                            offset: Offset(0, 0),
                                            spreadRadius: 0,
                                          )
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 14),
                                        child: Column(
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    "Around the clock, our delivery partners bring you your favorite meals. Show your appreciation with a tip."
                                                        .tr,
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AppThemeData.medium,
                                                      color: themeChange
                                                              .getThem()
                                                          ? AppThemeData.grey300
                                                          : AppThemeData
                                                              .grey600,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                SvgPicture.asset(
                                                    "assets/images/ic_tips.svg")
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: () {
                                                      controller.deliveryTips
                                                          .value = 20;
                                                      controller
                                                          .calculatePrice();
                                                    },
                                                    child: Container(
                                                      decoration:
                                                          ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          side: BorderSide(
                                                              width: 1,
                                                              color: controller
                                                                          .deliveryTips
                                                                          .value ==
                                                                      20
                                                                  ? AppThemeData
                                                                      .primary300
                                                                  : themeChange
                                                                          .getThem()
                                                                      ? AppThemeData
                                                                          .grey800
                                                                      : AppThemeData
                                                                          .grey100),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 10),
                                                        child: Center(
                                                          child: Text(
                                                            Constant.amountShow(
                                                                amount: "20"),
                                                            style: TextStyle(
                                                              color: themeChange
                                                                      .getThem()
                                                                  ? AppThemeData
                                                                      .grey50
                                                                  : AppThemeData
                                                                      .grey900,
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  AppThemeData
                                                                      .medium,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: () {
                                                      controller.deliveryTips
                                                          .value = 30;
                                                      controller
                                                          .calculatePrice();
                                                    },
                                                    child: Container(
                                                      decoration:
                                                          ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          side: BorderSide(
                                                              width: 1,
                                                              color: controller
                                                                          .deliveryTips
                                                                          .value ==
                                                                      30
                                                                  ? AppThemeData
                                                                      .primary300
                                                                  : themeChange
                                                                          .getThem()
                                                                      ? AppThemeData
                                                                          .grey800
                                                                      : AppThemeData
                                                                          .grey100),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 10),
                                                        child: Center(
                                                          child: Text(
                                                            Constant.amountShow(
                                                                amount: "30"),
                                                            style: TextStyle(
                                                              color: themeChange
                                                                      .getThem()
                                                                  ? AppThemeData
                                                                      .grey50
                                                                  : AppThemeData
                                                                      .grey900,
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  AppThemeData
                                                                      .medium,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: () {
                                                      controller.deliveryTips
                                                          .value = 40;
                                                      controller
                                                          .calculatePrice();
                                                    },
                                                    child: Container(
                                                      decoration:
                                                          ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          side: BorderSide(
                                                              width: 1,
                                                              color: controller
                                                                          .deliveryTips
                                                                          .value ==
                                                                      40
                                                                  ? AppThemeData
                                                                      .primary300
                                                                  : themeChange
                                                                          .getThem()
                                                                      ? AppThemeData
                                                                          .grey800
                                                                      : AppThemeData
                                                                          .grey100),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 10),
                                                        child: Center(
                                                          child: Text(
                                                            Constant.amountShow(
                                                                amount: "40"),
                                                            style: TextStyle(
                                                              color: themeChange
                                                                      .getThem()
                                                                  ? AppThemeData
                                                                      .grey50
                                                                  : AppThemeData
                                                                      .grey900,
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  AppThemeData
                                                                      .medium,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return tipsDialog(
                                                              controller,
                                                              themeChange);
                                                        },
                                                      );
                                                    },
                                                    child: Container(
                                                      decoration:
                                                          ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          side: BorderSide(
                                                              width: 1,
                                                              color: themeChange
                                                                      .getThem()
                                                                  ? AppThemeData
                                                                      .grey800
                                                                  : AppThemeData
                                                                      .grey100),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 10),
                                                        child: Center(
                                                          child: Text(
                                                            'Other'.tr,
                                                            style: TextStyle(
                                                              color: themeChange
                                                                      .getThem()
                                                                  ? AppThemeData
                                                                      .grey50
                                                                  : AppThemeData
                                                                      .grey900,
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  AppThemeData
                                                                      .medium,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              TextFieldWidget(
                                title: 'Remarks'.tr,
                                controller: controller.reMarkController.value,
                                hintText: 'Write remarks for the restaurant'.tr,
                                maxLine: 4,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
            bottomNavigationBar: cartItem.isEmpty
                ? null
                : Container(
                    decoration: BoxDecoration(
                        color: themeChange.getThem()
                            ? AppThemeData.grey900
                            : AppThemeData.grey50,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20))),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: InkWell(
                              onTap: () {
                                Get.to(const SelectPaymentScreen());
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  controller.selectedPaymentMethod.value == ''
                                      ? cardDecoration(
                                          controller,
                                          PaymentGateway.wallet,
                                          themeChange,
                                          "")
                                      : controller.selectedPaymentMethod.value ==
                                              PaymentGateway.wallet.name
                                          ? cardDecoration(
                                              controller,
                                              PaymentGateway.wallet,
                                              themeChange,
                                              "assets/images/ic_wallet.png")
                                          : controller.selectedPaymentMethod.value ==
                                                  PaymentGateway.cod.name
                                              ? cardDecoration(
                                                  controller,
                                                  PaymentGateway.cod,
                                                  themeChange,
                                                  "assets/images/ic_cash.png")
                                              : controller.selectedPaymentMethod
                                                          .value ==
                                                      PaymentGateway.stripe.name
                                                  ? cardDecoration(
                                                      controller,
                                                      PaymentGateway.stripe,
                                                      themeChange,
                                                      "assets/images/stripe.png")
                                                  : controller.selectedPaymentMethod
                                                              .value ==
                                                          PaymentGateway
                                                              .paypal.name
                                                      ? cardDecoration(
                                                          controller,
                                                          PaymentGateway.paypal,
                                                          themeChange,
                                                          "assets/images/paypal.png")
                                                      : controller.selectedPaymentMethod
                                                                  .value ==
                                                              PaymentGateway
                                                                  .payStack.name
                                                          ? cardDecoration(
                                                              controller,
                                                              PaymentGateway
                                                                  .payStack,
                                                              themeChange,
                                                              "assets/images/paystack.png")
                                                          : controller.selectedPaymentMethod
                                                                      .value ==
                                                                  PaymentGateway
                                                                      .mercadoPago
                                                                      .name
                                                              ? cardDecoration(
                                                                  controller,
                                                                  PaymentGateway
                                                                      .mercadoPago,
                                                                  themeChange,
                                                                  "assets/images/mercado-pago.png")
                                                              : controller.selectedPaymentMethod.value ==
                                                                      PaymentGateway
                                                                          .flutterWave
                                                                          .name
                                                                  ? cardDecoration(
                                                                      controller,
                                                                      PaymentGateway
                                                                          .flutterWave,
                                                                      themeChange,
                                                                      "assets/images/flutterwave_logo.png")
                                                                  : controller.selectedPaymentMethod.value ==
                                                                          PaymentGateway.payFast.name
                                                                      ? cardDecoration(controller, PaymentGateway.payFast, themeChange, "assets/images/payfast.png")
                                                                      : controller.selectedPaymentMethod.value == PaymentGateway.paytm.name
                                                                          ? cardDecoration(controller, PaymentGateway.paytm, themeChange, "assets/images/paytm.png")
                                                                          : controller.selectedPaymentMethod.value == PaymentGateway.midTrans.name
                                                                              ? cardDecoration(controller, PaymentGateway.midTrans, themeChange, "assets/images/midtrans.png")
                                                                              : controller.selectedPaymentMethod.value == PaymentGateway.orangeMoney.name
                                                                                  ? cardDecoration(controller, PaymentGateway.orangeMoney, themeChange, "assets/images/orange_money.png")
                                                                                  : controller.selectedPaymentMethod.value == PaymentGateway.xendit.name
                                                                                      ? cardDecoration(controller, PaymentGateway.xendit, themeChange, "assets/images/xendit.png")
                                                                                      : cardDecoration(controller, PaymentGateway.razorpay, themeChange, "assets/images/razorpay.png"),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Pay Via".tr,
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontFamily: AppThemeData.semiBold,
                                          color: themeChange.getThem()
                                              ? AppThemeData.grey400
                                              : AppThemeData.grey500,
                                          fontSize: 12,
                                        ),
                                      ),
                                      controller.selectedPaymentMethod.value ==
                                              ''
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 4),
                                              child: Container(
                                                  width: 60,
                                                  height: 12,
                                                  color: themeChange.getThem()
                                                      ? AppThemeData.grey800
                                                      : AppThemeData.grey100),
                                            )
                                          : Text(
                                              controller
                                                  .selectedPaymentMethod.value,
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontFamily:
                                                    AppThemeData.semiBold,
                                                color: themeChange.getThem()
                                                    ? AppThemeData.grey50
                                                    : AppThemeData.grey900,
                                                fontSize: 16,
                                              ),
                                            ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: RoundedButtonFill(
                              textColor:
                                  controller.selectedPaymentMethod.value != ''
                                      ? AppThemeData.surface
                                      : themeChange.getThem()
                                          ? AppThemeData.grey800
                                          : AppThemeData.grey100,
                              isEnabled:
                                  controller.selectedPaymentMethod.value != '',
                              title: "Pay Now".tr,
                              height: 5,
                              color:
                                  controller.selectedPaymentMethod.value != ''
                                      ? AppThemeData.primary300
                                      : themeChange.getThem()
                                          ? AppThemeData.grey800
                                          : AppThemeData.grey100,
                              fontSizes: 16,
                              onPress: () async {
                                if ((controller.couponAmount.value >= 1) &&
                                    (controller.couponAmount.value >
                                        controller.totalAmount.value)) {
                                  ShowToastDialog.showToast(
                                      "The total price must be greater than or equal to the coupon discount value for the code to apply. Please review your cart total."
                                          .tr);
                                  return;
                                }
                                if ((controller.specialDiscountAmount.value >=
                                        1) &&
                                    (controller.specialDiscountAmount.value >
                                        controller.totalAmount.value)) {
                                  ShowToastDialog.showToast(
                                      "The total price must be greater than or equal to the special discount value for the code to apply. Please review your cart total."
                                          .tr);
                                  return;
                                }
                                if (controller.selectedPaymentMethod.value ==
                                    PaymentGateway.stripe.name) {
                                  controller.stripeMakePayment(
                                      amount: controller.totalAmount.value
                                          .toString());
                                } else if (controller
                                        .selectedPaymentMethod.value ==
                                    PaymentGateway.paypal.name) {
                                  controller.paypalPaymentSheet(
                                      controller.totalAmount.value.toString(),
                                      context);
                                } else if (controller
                                        .selectedPaymentMethod.value ==
                                    PaymentGateway.payStack.name) {
                                  controller.payStackPayment(
                                      controller.totalAmount.value.toString());
                                } else if (controller
                                        .selectedPaymentMethod.value ==
                                    PaymentGateway.mercadoPago.name) {
                                  controller.mercadoPagoMakePayment(
                                      context: context,
                                      amount: controller.totalAmount.value
                                          .toString());
                                } else if (controller
                                        .selectedPaymentMethod.value ==
                                    PaymentGateway.flutterWave.name) {
                                  controller.flutterWaveInitiatePayment(
                                      context: context,
                                      amount: controller.totalAmount.value
                                          .toString());
                                } else if (controller
                                        .selectedPaymentMethod.value ==
                                    PaymentGateway.payFast.name) {
                                  controller.payFastPayment(
                                      context: context,
                                      amount: controller.totalAmount.value
                                          .toString());
                                } else if (controller
                                        .selectedPaymentMethod.value ==
                                    PaymentGateway.paytm.name) {
                                  controller.getPaytmCheckSum(context,
                                      amount: double.parse(controller
                                          .totalAmount.value
                                          .toString()));
                                } else if (controller
                                        .selectedPaymentMethod.value ==
                                    PaymentGateway.cod.name) {
                                  controller.placeOrder();
                                } else if (controller
                                        .selectedPaymentMethod.value ==
                                    PaymentGateway.wallet.name) {
                                  controller.placeOrder();
                                } else if (controller
                                        .selectedPaymentMethod.value ==
                                    PaymentGateway.midTrans.name) {
                                  controller.midtransMakePayment(
                                      context: context,
                                      amount: controller.totalAmount.value
                                          .toString());
                                } else if (controller
                                        .selectedPaymentMethod.value ==
                                    PaymentGateway.orangeMoney.name) {
                                  controller.orangeMakePayment(
                                      context: context,
                                      amount: controller.totalAmount.value
                                          .toString());
                                } else if (controller
                                        .selectedPaymentMethod.value ==
                                    PaymentGateway.xendit.name) {
                                  controller.xenditPayment(context,
                                      controller.totalAmount.value.toString());
                                } else if (controller
                                        .selectedPaymentMethod.value ==
                                    PaymentGateway.razorpay.name) {
                                  RazorPayController()
                                      .createOrderRazorPay(
                                          amount: double.parse(controller
                                              .totalAmount.value
                                              .toString()),
                                          razorpayModel:
                                              controller.razorPayModel.value)
                                      .then((value) {
                                    if (value == null) {
                                      Get.back();
                                      ShowToastDialog.showToast(
                                          "Something went wrong, please contact admin."
                                              .tr);
                                    } else {
                                      CreateRazorPayOrderModel result = value;
                                      controller.openCheckout(
                                          amount: controller.totalAmount.value
                                              .toString(),
                                          orderId: result.id);
                                    }
                                  });
                                } else {
                                  ShowToastDialog.showToast(
                                      "Please select payment method".tr);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          );
        });
  }

  cardDecoration(CartController controller, PaymentGateway value, themeChange,
      String image) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        width: 40,
        height: 40,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(value.name == "payFast" ? 0 : 8.0),
          child: image == ''
              ? Container(
                  color: themeChange.getThem()
                      ? AppThemeData.grey800
                      : AppThemeData.grey100)
              : Image.asset(
                  image,
                ),
        ),
      ),
    );
  }

  tipsDialog(CartController controller, themeChange) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(10),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      backgroundColor: themeChange.getThem()
          ? AppThemeData.surfaceDark
          : AppThemeData.surface,
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: SizedBox(
          width: 500,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFieldWidget(
                title: 'Tips Amount'.tr,
                controller: controller.tipsController.value,
                textInputType: const TextInputType.numberWithOptions(
                    signed: true, decimal: true),
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                ],
                prefix: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Text(
                    "${Constant.currencyModel!.symbol}".tr,
                    style: TextStyle(
                        color: themeChange.getThem()
                            ? AppThemeData.grey50
                            : AppThemeData.grey900,
                        fontFamily: AppThemeData.semiBold,
                        fontSize: 18),
                  ),
                ),
                hintText: 'Enter Tips Amount'.tr,
              ),
              Row(
                children: [
                  Expanded(
                    child: RoundedButtonFill(
                      title: "Cancel".tr,
                      color: themeChange.getThem()
                          ? AppThemeData.grey700
                          : AppThemeData.grey200,
                      textColor: themeChange.getThem()
                          ? AppThemeData.grey50
                          : AppThemeData.grey900,
                      onPress: () async {
                        Get.back();
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: RoundedButtonFill(
                      title: "Add".tr,
                      color: AppThemeData.primary300,
                      textColor: AppThemeData.grey50,
                      onPress: () async {
                        if (controller.tipsController.value.text.isEmpty) {
                          ShowToastDialog.showToast(
                              "Please enter tips Amount".tr);
                        } else {
                          controller.deliveryTips.value = double.parse(
                              controller.tipsController.value.text);
                          controller.calculatePrice();
                          Get.back();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
