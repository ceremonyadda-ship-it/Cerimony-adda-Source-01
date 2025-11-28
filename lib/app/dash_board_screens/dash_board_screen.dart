import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controllers/dash_board_controller.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class DashBoardScreen extends StatelessWidget {
  const DashBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: DashBoardController(),
        builder: (controller) {
          return PopScope(
            canPop: controller.canPopNow.value,
            onPopInvoked: (didPop) {
              final now = DateTime.now();
              if (controller.currentBackPressTime == null || now.difference(controller.currentBackPressTime!) > const Duration(seconds: 2)) {
                controller.currentBackPressTime = now;
                controller.canPopNow.value = false;
                ShowToastDialog.showToast("Double press to exit".tr);
                return;
              } else {
                controller.canPopNow.value = true;
              }
            },
            // onPopInvokedWithResult: (didPop, dynamic) {
            //   final now = DateTime.now();
            //   if (controller.currentBackPressTime == null || now.difference(controller.currentBackPressTime!) > const Duration(seconds: 2)) {
            //     controller.currentBackPressTime = now;
            //     controller.canPopNow.value = false;
            //     ShowToastDialog.showToast("Double press to exit");
            //     return;
            //   } else {
            //     controller.canPopNow.value = true;
            //   }
            // },
            child: Scaffold(
              body: controller.pageList[controller.selectedIndex.value],
              bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                showUnselectedLabels: true,
                showSelectedLabels: true,
                selectedFontSize: 12,
                selectedLabelStyle: const TextStyle(fontFamily: AppThemeData.bold),
                unselectedLabelStyle: const TextStyle(fontFamily: AppThemeData.bold),
                currentIndex: controller.selectedIndex.value,
                backgroundColor: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                selectedItemColor: themeChange.getThem() ? AppThemeData.primary300 : AppThemeData.primary300,
                unselectedItemColor: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                onTap: (int index) {
                  if (index == 0) {
                    Get.put(DashBoardController());
                  }
                  controller.selectedIndex.value = index;
                },
                items: Constant.walletSetting == false
                    ? [
                        navigationBarItem(
                          themeChange,
                          index: 0,
                          assetIcon: "assets/icons/ic_home.svg",
                          label: 'Home'.tr,
                          controller: controller,
                        ),
                        navigationBarItem(
                          themeChange,
                          index: 1,
                          assetIcon: "assets/icons/ic_fav.svg",
                          label: 'Favourites'.tr,
                          controller: controller,
                        ),
                        navigationBarItem(
                          themeChange,
                          index: 2,
                          assetIcon: "assets/icons/ic_orders.svg",
                          label: 'Bookings'.tr,
                          controller: controller,
                        ),
                        navigationBarItem(
                          themeChange,
                          index: 3,
                          assetIcon: "assets/icons/ic_profile.svg",
                          label: 'Profile'.tr,
                          controller: controller,
                        ),
                      ]
                    : [
                        navigationBarItem(
                          themeChange,
                          index: 0,
                          assetIcon: "assets/icons/ic_home.svg",
                          label: 'Home'.tr,
                          controller: controller,
                        ),
                        navigationBarItem(
                          themeChange,
                          index: 1,
                          assetIcon: "assets/icons/ic_fav.svg",
                          label: 'Favourites'.tr,
                          controller: controller,
                        ),
                        navigationBarItem(
                          themeChange,
                          index: 2,
                          assetIcon: "assets/icons/ic_wallet.svg",
                          label: 'Wallet'.tr,
                          controller: controller,
                        ),
                        navigationBarItem(
                          themeChange,
                          index: 3,
                          assetIcon: "assets/icons/ic_orders.svg",
                          label: 'Bookings'.tr,
                          controller: controller,
                        ),
                        navigationBarItem(
                          themeChange,
                          index: 4,
                          assetIcon: "assets/icons/ic_profile.svg",
                          label: 'Profile'.tr,
                          controller: controller,
                        ),
                      ],
              ),
            ),
          );
        });
  }

  BottomNavigationBarItem navigationBarItem(themeChange, {required int index, required String label, required String assetIcon, required DashBoardController controller}) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: SvgPicture.asset(
          assetIcon,
          height: 22,
          width: 22,
          color: controller.selectedIndex.value == index
              ? themeChange.getThem()
                  ? AppThemeData.primary300
                  : AppThemeData.primary300
              : themeChange.getThem()
                  ? AppThemeData.grey300
                  : AppThemeData.grey600,
        ),
      ),
      label: label,
    );
  }
}
