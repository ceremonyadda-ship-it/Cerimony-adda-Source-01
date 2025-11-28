import 'dart:convert';

import 'package:customer/constant/constant.dart';
import 'package:customer/controllers/change_language_controller.dart';
import 'package:customer/services/localization_service.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/network_image_widget.dart';
import 'package:customer/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class ChangeLanguageScreen extends StatelessWidget {
  const ChangeLanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: ChangeLanguageController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
              centerTitle: false,
              titleSpacing: 0,
            ),
            body: controller.isLoading.value
                ? Constant.loader()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Change Language".tr,
                          style: TextStyle(
                            fontSize: 24,
                            color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                            fontFamily: AppThemeData.semiBold,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "Select your preferred language for a personalized app experience.".tr,
                          style: TextStyle(
                            fontSize: 16,
                            color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                            fontFamily: AppThemeData.regular,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Expanded(
                          child: GridView.count(
                            crossAxisCount: 2,
                            childAspectRatio: (1.1 / 1),
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 1,
                            children: controller.languageList
                                .map(
                                  (data) => Obx(
                                    () => GestureDetector(
                                      onTap: () {
                                        LocalizationService().changeLocale(data.slug.toString());
                                        Preferences.setString(Preferences.languageCodeKey, jsonEncode(data));
                                        controller.selectedLanguage.value = data;
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          children: [
                                            NetworkImageWidget(
                                              imageUrl: data.image.toString(),
                                              height: 80,
                                              width: 80,
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              "${data.title}",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: controller.selectedLanguage.value.slug == data.slug
                                                    ? AppThemeData.primary300
                                                    : themeChange.getThem()
                                                        ? AppThemeData.grey400
                                                        : AppThemeData.grey500,
                                                fontFamily: AppThemeData.medium,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
          );
        });
  }
}
