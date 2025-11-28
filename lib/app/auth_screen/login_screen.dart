import 'dart:io';

import 'package:customer/app/auth_screen/phone_number_screen.dart';
import 'package:customer/app/auth_screen/signup_screen.dart';
import 'package:customer/app/dash_board_screens/dash_board_screen.dart';
import 'package:customer/app/forgot_password_screen/forgot_password_screen.dart';
import 'package:customer/app/location_permission_screen/location_permission_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controllers/login_controller.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/round_button_fill.dart';
import 'package:customer/themes/text_field_widget.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: LoginController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
              actions: [
                InkWell(
                  onTap: () async {
                    LocationPermission permission = await Geolocator.checkPermission();
                    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
                      if (Constant.selectedLocation.location == null) {
                        Get.offAll(const LocationPermissionScreen());
                      } else {
                        Get.offAll(const DashBoardScreen());
                      }
                    } else {
                      Get.offAll(const LocationPermissionScreen());
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Skip".tr,
                      style: TextStyle(color: themeChange.getThem() ? AppThemeData.primary300 : AppThemeData.primary300, fontSize: 18, fontFamily: AppThemeData.semiBold),
                    ),
                  ),
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome Back! 👋".tr,
                      style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontSize: 22, fontFamily: AppThemeData.semiBold),
                    ),
                    Text(
                      "Log in to continue enjoying services with Ceremony Adda.".tr,
                      style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500, fontSize: 16, fontFamily: AppThemeData.regular),
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    TextFieldWidget(
                      title: 'Email Address'.tr,
                      controller: controller.emailEditingController.value,
                      hintText: 'Enter email address'.tr,
                      prefix: Padding(
                        padding: const EdgeInsets.all(12),
                        child: SvgPicture.asset(
                          "assets/icons/ic_mail.svg",
                          colorFilter: ColorFilter.mode(
                            themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    TextFieldWidget(
                      title: 'Password'.tr,
                      controller: controller.passwordEditingController.value,
                      hintText: 'Enter password'.tr,
                      obscureText: controller.passwordVisible.value,
                      prefix: Padding(
                        padding: const EdgeInsets.all(12),
                        child: SvgPicture.asset(
                          "assets/icons/ic_lock.svg",
                          colorFilter: ColorFilter.mode(
                            themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      suffix: Padding(
                        padding: const EdgeInsets.all(12),
                        child: InkWell(
                            onTap: () {
                              controller.passwordVisible.value = !controller.passwordVisible.value;
                            },
                            child: controller.passwordVisible.value
                                ? SvgPicture.asset(
                                    "assets/icons/ic_password_show.svg",
                                    colorFilter: ColorFilter.mode(
                                      themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                      BlendMode.srcIn,
                                    ),
                                  )
                                : SvgPicture.asset(
                                    "assets/icons/ic_password_close.svg",
                                    colorFilter: ColorFilter.mode(
                                      themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                      BlendMode.srcIn,
                                    ),
                                  )),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {
                          Get.to(const ForgotPasswordScreen());
                        },
                        child: Text(
                          "Forgot Password".tr,
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              decorationColor: AppThemeData.secondary300,
                              color: themeChange.getThem() ? AppThemeData.secondary300 : AppThemeData.secondary300,
                              fontSize: 14,
                              fontFamily: AppThemeData.regular),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    RoundedButtonFill(
                      title: "Login".tr,
                      color: AppThemeData.primary300,
                      textColor: AppThemeData.grey50,
                      onPress: () async {
                        if (controller.emailEditingController.value.text.trim().isEmpty) {
                          ShowToastDialog.showToast("Please enter valid email".tr);
                        } else if (controller.passwordEditingController.value.text.trim().isEmpty) {
                          ShowToastDialog.showToast("Please enter valid password".tr);
                        } else {
                          controller.loginWithEmailAndPassword();
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Row(
                        children: [
                          const Expanded(child: Divider(thickness: 1)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                            child: Text(
                              "or".tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: themeChange.getThem() ? AppThemeData.grey500 : AppThemeData.grey400,
                                fontSize: 16,
                                fontFamily: AppThemeData.medium,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                    ),
                    RoundedButtonFill(
                      title: "Continue with Mobile Number".tr,
                      textColor: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey900,
                      color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey100,
                      icon: SvgPicture.asset(
                        "assets/icons/ic_phone.svg",
                        colorFilter: const ColorFilter.mode(AppThemeData.grey900, BlendMode.srcIn),
                      ),
                      isRight: false,
                      onPress: () async {
                        Get.to(const PhoneNumberScreen());
                      },
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: RoundedButtonFill(
                            title: "with Google".tr,
                            textColor: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey900,
                            color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey100,
                            icon: SvgPicture.asset("assets/icons/ic_google.svg"),
                            isRight: false,
                            onPress: () async {
                              controller.loginWithGoogle();
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Platform.isIOS
                            ? Expanded(
                                child: RoundedButtonFill(
                                  title: "with Apple".tr,
                                  textColor: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey900,
                                  color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey100,
                                  icon: SvgPicture.asset("assets/icons/ic_apple.svg"),
                                  isRight: false,
                                  onPress: () async {
                                    controller.loginWithApple();
                                  },
                                ),
                              )
                            : const SizedBox(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: Padding(
              padding: EdgeInsets.symmetric(vertical: Platform.isAndroid ? 10 : 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                            text: 'Didn’t have an account?'.tr,
                            style: TextStyle(
                              color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                              fontFamily: AppThemeData.medium,
                              fontWeight: FontWeight.w500,
                            )),
                        const WidgetSpan(
                          child: SizedBox(
                            width: 10,
                          ),
                        ),
                        TextSpan(
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Get.to(const SignupScreen());
                              },
                            text: 'Sign up'.tr,
                            style: TextStyle(
                                color: AppThemeData.primary300,
                                fontFamily: AppThemeData.bold,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                                decorationColor: AppThemeData.primary300)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
