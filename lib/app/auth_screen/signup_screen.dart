import 'package:country_code_picker/country_code_picker.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controllers/signup_controller.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/round_button_fill.dart';
import 'package:customer/themes/text_field_widget.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: SignupController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: GestureDetector(
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Create an Account 🚀".tr,
                        style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontSize: 22, fontFamily: AppThemeData.semiBold),
                      ),
                      Text(
                        "Sign up to start your journy with ceremony adda".tr,
                        style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500, fontSize: 16, fontFamily: AppThemeData.regular),
                      ),
                      const SizedBox(
                        height: 32,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFieldWidget(
                              title: 'First Name'.tr,
                              controller: controller.firstNameEditingController.value,
                              hintText: 'Enter First Name'.tr,
                              prefix: Padding(
                                padding: const EdgeInsets.all(12),
                                child: SvgPicture.asset(
                                  "assets/icons/ic_user.svg",
                                  colorFilter: ColorFilter.mode(
                                    themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: TextFieldWidget(
                              title: 'Last Name'.tr,
                              controller: controller.lastNameEditingController.value,
                              hintText: 'Enter Last Name'.tr,
                              prefix: Padding(
                                padding: const EdgeInsets.all(12),
                                child: SvgPicture.asset(
                                  "assets/icons/ic_user.svg",
                                  colorFilter: ColorFilter.mode(
                                    themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      TextFieldWidget(
                        title: 'Email Address'.tr,
                        textInputType: TextInputType.emailAddress,
                        controller: controller.emailEditingController.value,
                        enable: controller.type.value == "google" || controller.type.value == "apple" ? false : true,
                        hintText: 'Enter Email Address'.tr,
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
                        title: 'Phone Number'.tr,
                        controller: controller.phoneNUmberEditingController.value,
                        hintText: 'Enter Phone Number'.tr,
                        enable: controller.type.value == "mobileNumber" ? false : true,
                        textInputType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                        textInputAction: TextInputAction.done,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                        ],
                        prefix: CountryCodePicker(
                          enabled: controller.type.value == "mobileNumber" ? false : true,
                          onChanged: (value) {
                            controller.countryCodeEditingController.value.text = value.dialCode.toString();
                          },
                          dialogTextStyle:
                              TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontWeight: FontWeight.w500, fontFamily: AppThemeData.medium),
                          dialogBackgroundColor: themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey100,
                          initialSelection: controller.countryCodeEditingController.value.text,
                          comparator: (a, b) => b.name!.compareTo(a.name.toString()),
                          textStyle: TextStyle(fontSize: 14, color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.medium),
                          searchDecoration: InputDecoration(iconColor: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900),
                          searchStyle:
                              TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontWeight: FontWeight.w500, fontFamily: AppThemeData.medium),
                        ),
                      ),
                      controller.type.value == "google" || controller.type.value == "apple" || controller.type.value == "mobileNumber"
                          ? const SizedBox()
                          : Column(
                              children: [
                                TextFieldWidget(
                                  title: 'Password'.tr,
                                  controller: controller.passwordEditingController.value,
                                  hintText: 'Enter Password'.tr,
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
                                TextFieldWidget(
                                  title: 'Confirm Password'.tr,
                                  controller: controller.conformPasswordEditingController.value,
                                  hintText: 'Enter Confirm Password'.tr,
                                  obscureText: controller.conformPasswordVisible.value,
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
                                          controller.conformPasswordVisible.value = !controller.conformPasswordVisible.value;
                                        },
                                        child: controller.conformPasswordVisible.value
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
                              ],
                            ),
                      TextFieldWidget(
                        title: 'Referral Code(Optional)'.tr,
                        controller: controller.referralCodeEditingController.value,
                        hintText: 'Referral Code(Optional)'.tr,
                      ),
                      RoundedButtonFill(
                        title: "Signup".tr,
                        color: AppThemeData.primary300,
                        textColor: AppThemeData.grey50,
                        onPress: () async {
                          if (controller.type.value == "google" || controller.type.value == "apple" || controller.type.value == "mobileNumber") {
                            if (controller.firstNameEditingController.value.text.trim().isEmpty) {
                              ShowToastDialog.showToast("Please enter first name".tr);
                            } else if (controller.lastNameEditingController.value.text.trim().isEmpty) {
                              ShowToastDialog.showToast("Please enter last name".tr);
                            } else if (controller.emailEditingController.value.text.trim().isEmpty) {
                              ShowToastDialog.showToast("Please enter valid email".tr);
                            } else if (controller.phoneNUmberEditingController.value.text.trim().isEmpty) {
                              ShowToastDialog.showToast("Please enter Phone number".tr);
                            } else {
                              controller.signUpWithEmailAndPassword();
                            }
                          } else {
                            if (controller.firstNameEditingController.value.text.trim().isEmpty) {
                              ShowToastDialog.showToast("Please enter first name".tr);
                            } else if (controller.lastNameEditingController.value.text.trim().isEmpty) {
                              ShowToastDialog.showToast("Please enter last name".tr);
                            } else if (controller.emailEditingController.value.text.trim().isEmpty) {
                              ShowToastDialog.showToast("Please enter valid email".tr);
                            } else if (controller.phoneNUmberEditingController.value.text.trim().isEmpty) {
                              ShowToastDialog.showToast("Please enter Phone number".tr);
                            } else if (controller.passwordEditingController.value.text.trim().length < 6) {
                              ShowToastDialog.showToast("Please enter minimum 6 characters password".tr);
                            } else if (controller.passwordEditingController.value.text.trim().isEmpty) {
                              ShowToastDialog.showToast("Please enter password".tr);
                            } else if (controller.conformPasswordEditingController.value.text.trim().isEmpty) {
                              ShowToastDialog.showToast("Please enter Confirm password".tr);
                            } else if (controller.passwordEditingController.value.text.trim() != controller.conformPasswordEditingController.value.text.trim()) {
                              ShowToastDialog.showToast("Password and Confirm password doesn't match".tr);
                            } else {
                              controller.signUpWithEmailAndPassword();
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
