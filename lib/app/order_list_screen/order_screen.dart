import 'package:customer/app/auth_screen/login_screen.dart';
import 'package:customer/app/order_list_screen/live_tracking_screen.dart';
import 'package:customer/app/order_list_screen/order_details_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controllers/order_controller.dart';
import 'package:customer/models/cart_product_model.dart';
import 'package:customer/models/order_model.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/themes/round_button_fill.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/network_image_widget.dart';
import 'package:customer/widget/my_separator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: OrderController(),
        builder: (controller) {
          return Scaffold(
            body: Padding(
              padding:
                  EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top),
              child: controller.isLoading.value
                  ? Constant.loader()
                  : Constant.userModel == null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/images/login.gif",
                                height: 120,
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Text(
                                "Please Log In to Continue".tr,
                                style: TextStyle(
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey100
                                        : AppThemeData.grey800,
                                    fontSize: 22,
                                    fontFamily: AppThemeData.semiBold),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                "You’re not logged in. Please sign in to access your account and explore all features."
                                    .tr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey50
                                        : AppThemeData.grey500,
                                    fontSize: 16,
                                    fontFamily: AppThemeData.bold),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              RoundedButtonFill(
                                title: "Log in".tr,
                                width: 55,
                                height: 5.5,
                                color: AppThemeData.primary300,
                                textColor: AppThemeData.grey50,
                                onPress: () async {
                                  Get.offAll(const LoginScreen());
                                },
                              ),
                            ],
                          ),
                        )
                      : DefaultTabController(
                          length: 5,
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "My Bookings".tr,
                                            style: TextStyle(
                                              fontSize: 24,
                                              color: themeChange.getThem()
                                                  ? AppThemeData.grey50
                                                  : AppThemeData.grey900,
                                              fontFamily: AppThemeData.semiBold,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            "Keep track your delivered, In Progress and Rejected services all in just one place."
                                                .tr,
                                            style: TextStyle(
                                              color: themeChange.getThem()
                                                  ? AppThemeData.grey50
                                                  : AppThemeData.grey900,
                                              fontFamily: AppThemeData.regular,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 6, horizontal: 10),
                                        decoration: ShapeDecoration(
                                          color: themeChange.getThem()
                                              ? AppThemeData.grey800
                                              : AppThemeData.grey100,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(120),
                                          ),
                                        ),
                                        child: TabBar(
                                          indicator: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      50), // Creates border
                                              color: AppThemeData.primary300),
                                          labelColor: AppThemeData.grey50,
                                          isScrollable: true,
                                          tabAlignment: TabAlignment.start,
                                          indicatorWeight: 0.5,
                                          unselectedLabelColor:
                                              themeChange.getThem()
                                                  ? AppThemeData.grey50
                                                  : AppThemeData.grey900,
                                          dividerColor: Colors.transparent,
                                          indicatorSize:
                                              TabBarIndicatorSize.tab,
                                          tabs: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 18),
                                              child: Tab(
                                                text: 'All'.tr,
                                              ),
                                            ),
                                            Tab(
                                              text: 'In Progress'.tr,
                                            ),
                                            Tab(
                                              text: 'Delivered'.tr,
                                            ),
                                            Tab(
                                              text: 'Cancelled'.tr,
                                            ),
                                            Tab(
                                              text: 'Rejected'.tr,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Expanded(
                                        child: TabBarView(
                                          children: [
                                            controller.allList.isEmpty
                                                ? Constant.showEmptyView(
                                                    message:
                                                        "Booking Not Found".tr)
                                                : RefreshIndicator(
                                                    onRefresh: () =>
                                                        controller.getOrder(),
                                                    child: ListView.builder(
                                                      itemCount: controller
                                                          .allList.length,
                                                      shrinkWrap: true,
                                                      padding: EdgeInsets.zero,
                                                      itemBuilder:
                                                          (context, index) {
                                                        OrderModel orderModel =
                                                            controller
                                                                .allList[index];
                                                        return itemView(
                                                            themeChange,
                                                            context,
                                                            orderModel,
                                                            controller);
                                                      },
                                                    ),
                                                  ),
                                            controller.inProgressList.isEmpty
                                                ? Constant.showEmptyView(
                                                    message:
                                                        "Booking Not Found".tr)
                                                : RefreshIndicator(
                                                    onRefresh: () =>
                                                        controller.getOrder(),
                                                    child: ListView.builder(
                                                      itemCount: controller
                                                          .inProgressList
                                                          .length,
                                                      shrinkWrap: true,
                                                      padding: EdgeInsets.zero,
                                                      itemBuilder:
                                                          (context, index) {
                                                        OrderModel orderModel =
                                                            controller
                                                                    .inProgressList[
                                                                index];
                                                        return itemView(
                                                            themeChange,
                                                            context,
                                                            orderModel,
                                                            controller);
                                                      },
                                                    ),
                                                  ),
                                            controller.deliveredList.isEmpty
                                                ? Constant.showEmptyView(
                                                    message:
                                                        "Booking Not Found".tr)
                                                : RefreshIndicator(
                                                    onRefresh: () =>
                                                        controller.getOrder(),
                                                    child: ListView.builder(
                                                      itemCount: controller
                                                          .deliveredList.length,
                                                      shrinkWrap: true,
                                                      padding: EdgeInsets.zero,
                                                      itemBuilder:
                                                          (context, index) {
                                                        OrderModel orderModel =
                                                            controller
                                                                    .deliveredList[
                                                                index];
                                                        return itemView(
                                                            themeChange,
                                                            context,
                                                            orderModel,
                                                            controller);
                                                      },
                                                    ),
                                                  ),
                                            controller.cancelledList.isEmpty
                                                ? Constant.showEmptyView(
                                                    message:
                                                        "Booking Not Found".tr)
                                                : RefreshIndicator(
                                                    onRefresh: () =>
                                                        controller.getOrder(),
                                                    child: ListView.builder(
                                                      itemCount: controller
                                                          .cancelledList.length,
                                                      shrinkWrap: true,
                                                      padding: EdgeInsets.zero,
                                                      itemBuilder:
                                                          (context, index) {
                                                        OrderModel orderModel =
                                                            controller
                                                                    .cancelledList[
                                                                index];
                                                        return itemView(
                                                            themeChange,
                                                            context,
                                                            orderModel,
                                                            controller);
                                                      },
                                                    ),
                                                  ),
                                            controller.rejectedList.isEmpty
                                                ? Constant.showEmptyView(
                                                    message:
                                                        "Booking Not Found".tr)
                                                : RefreshIndicator(
                                                    onRefresh: () =>
                                                        controller.getOrder(),
                                                    child: ListView.builder(
                                                      itemCount: controller
                                                          .rejectedList.length,
                                                      shrinkWrap: true,
                                                      padding: EdgeInsets.zero,
                                                      itemBuilder:
                                                          (context, index) {
                                                        OrderModel orderModel =
                                                            controller
                                                                    .rejectedList[
                                                                index];
                                                        return itemView(
                                                            themeChange,
                                                            context,
                                                            orderModel,
                                                            controller);
                                                      },
                                                    ),
                                                  ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
            ),
          );
        });
  }

  itemView(DarkThemeProvider themeChange, BuildContext context,
      OrderModel orderModel, OrderController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        decoration: ShapeDecoration(
          color: themeChange.getThem()
              ? AppThemeData.grey900
              : AppThemeData.grey50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    child: Stack(
                      children: [
                        NetworkImageWidget(
                          imageUrl: orderModel.vendor!.photo.toString(),
                          fit: BoxFit.cover,
                          height: Responsive.height(10, context),
                          width: Responsive.width(20, context),
                        ),
                        Container(
                          height: Responsive.height(10, context),
                          width: Responsive.width(20, context),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: const Alignment(0.00, 1.00),
                              end: const Alignment(0, -1),
                              colors: [
                                Colors.black.withOpacity(0),
                                AppThemeData.grey900
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          orderModel.status.toString(),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Constant.statusColor(
                                status: orderModel.status.toString()),
                            fontFamily: AppThemeData.semiBold,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          orderModel.vendor!.title.toString(),
                          style: TextStyle(
                            fontSize: 16,
                            color: themeChange.getThem()
                                ? AppThemeData.grey50
                                : AppThemeData.grey900,
                            fontFamily: AppThemeData.medium,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          Constant.timestampToDateTime(orderModel.createdAt!),
                          style: TextStyle(
                            color: themeChange.getThem()
                                ? AppThemeData.grey300
                                : AppThemeData.grey600,
                            fontFamily: AppThemeData.medium,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              ListView.builder(
                itemCount: orderModel.products!.length,
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  CartProductModel cartProduct = orderModel.products![index];
                  return Row(
                    children: [
                      Expanded(
                        child: Text(
                          "${cartProduct.quantity} x ${cartProduct.name.toString()}",
                          style: TextStyle(
                            color: themeChange.getThem()
                                ? AppThemeData.grey50
                                : AppThemeData.grey900,
                            fontFamily: AppThemeData.regular,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Text(
                        Constant.amountShow(
                            amount: double.parse(
                                        cartProduct.discountPrice.toString()) <=
                                    0
                                ? (double.parse('${cartProduct.price ?? 0}') *
                                        double.parse(
                                            '${cartProduct.quantity ?? 0}'))
                                    .toString()
                                : (double.parse(
                                            '${cartProduct.discountPrice ?? 0}') *
                                        double.parse(
                                            '${cartProduct.quantity ?? 0}'))
                                    .toString()),
                        style: TextStyle(
                          color: themeChange.getThem()
                              ? AppThemeData.grey50
                              : AppThemeData.grey900,
                          fontFamily: AppThemeData.semiBold,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ],
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: MySeparator(
                    color: themeChange.getThem()
                        ? AppThemeData.grey700
                        : AppThemeData.grey200),
              ),
              Row(
                children: [
                  orderModel.status == Constant.orderCompleted
                      ? Expanded(
                          child: InkWell(
                            onTap: () {
                              for (var element in orderModel.products!) {
                                controller.addToCart(cartProductModel: element);
                                ShowToastDialog.showToast(
                                    "Item Added In a cart".tr);
                              }
                            },
                            child: Text(
                              "Reorder".tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: themeChange.getThem()
                                      ? AppThemeData.primary300
                                      : AppThemeData.primary300,
                                  fontFamily: AppThemeData.semiBold,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16),
                            ),
                          ),
                        )
                      : orderModel.status == Constant.orderShipped ||
                              orderModel.status == Constant.orderInTransit
                          ? Expanded(
                              child: InkWell(
                                onTap: () {
                                  Get.to(const LiveTrackingScreen(),
                                      arguments: {"orderModel": orderModel});
                                },
                                child: Text(
                                  "Track Order".tr,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: themeChange.getThem()
                                          ? AppThemeData.primary300
                                          : AppThemeData.primary300,
                                      fontFamily: AppThemeData.semiBold,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16),
                                ),
                              ),
                            )
                          : const SizedBox(),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Get.to(const OrderDetailsScreen(),
                            arguments: {"orderModel": orderModel});
                        // Get.off(const OrderPlacingScreen(), arguments: {"orderModel": orderModel});
                      },
                      child: Text(
                        "View Details".tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: themeChange.getThem()
                                ? AppThemeData.grey50
                                : AppThemeData.grey900,
                            fontFamily: AppThemeData.semiBold,
                            fontWeight: FontWeight.w600,
                            fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
