import 'package:customer/controllers/splash_controller.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder<SplashController>(
      init: SplashController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppThemeData.primary300,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset("assets/images/ic_logo.png"),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "Welcome To Ceremony Adda".tr,
                  style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey50, fontSize: 28, fontFamily: AppThemeData.bold),
                ),
                Text(
                  "Trusted Platform for All Event Services".tr,
                  style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey50),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
