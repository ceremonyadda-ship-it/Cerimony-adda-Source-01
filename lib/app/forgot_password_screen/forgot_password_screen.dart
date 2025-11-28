import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controllers/forgot_password_controller.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/round_button_fill.dart';
import 'package:customer/themes/text_field_widget.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: ForgotPasswordController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Forgot Password".tr,
                    style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontSize: 22, fontFamily: AppThemeData.semiBold),
                  ),
                  Text(
                    "No worries!! We’ll send you reset instructions".tr,
                    style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey500, fontSize: 16, fontFamily: AppThemeData.regular),
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
                  const SizedBox(
                    height: 32,
                  ),
                  RoundedButtonFill(
                    title: "Forgot Password".tr,
                    color: AppThemeData.primary300,
                    textColor: AppThemeData.grey50,
                    onPress: () async {
                      if (controller.emailEditingController.value.text.trim().isEmpty) {
                        ShowToastDialog.showToast("Please enter valid email".tr);
                      } else {
                        controller.forgotPassword();
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }
}
