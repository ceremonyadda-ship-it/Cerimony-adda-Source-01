import 'dart:io';

import 'package:customer/constant/constant.dart';
import 'package:customer/controllers/rate_product_controller.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/themes/round_button_fill.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/network_image_widget.dart';
import 'package:customer/widget/my_separator.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class RateProductScreen extends StatelessWidget {
  const RateProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: RateProductController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
            appBar: AppBar(
              backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
              centerTitle: false,
              titleSpacing: 0,
              title: Text(
                "Rate the food".tr,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontFamily: AppThemeData.medium,
                  fontSize: 16,
                  color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                ),
              ),
            ),
            body: controller.isLoading.value
                ? Constant.loader()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            width: Responsive.width(100, context),
                            decoration: ShapeDecoration(
                              color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Rate for".tr,
                                    style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500, fontSize: 16, fontFamily: AppThemeData.medium),
                                  ),
                                  Text(
                                    "${controller.productModel.value.name}".tr,
                                    style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800, fontSize: 18, fontFamily: AppThemeData.semiBold),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  RatingBar.builder(
                                    initialRating: controller.ratings.value,
                                    minRating: 1,
                                    direction: Axis.horizontal,
                                    itemCount: 5,
                                    itemSize: 26,
                                    itemPadding: const EdgeInsets.symmetric(horizontal: 6.0),
                                    itemBuilder: (context, _) => const Icon(
                                      Icons.star,
                                      color: AppThemeData.warning300,
                                    ),
                                    onRatingUpdate: (double rate) {
                                      controller.ratings.value = rate;
                                    },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                    child: MySeparator(color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200),
                                  ),
                                  ListView.builder(
                                    itemCount: controller.reviewAttributeList.length,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    padding: EdgeInsets.zero,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                controller.reviewAttributeList[index].title.toString(),
                                                style: TextStyle(
                                                  color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                  fontSize: 16,
                                                  fontFamily: AppThemeData.semiBold,
                                                ),
                                              ),
                                            ),
                                            RatingBar.builder(
                                              initialRating: controller.ratingModel.value.id == null
                                                  ? 0.0
                                                  : controller.ratingModel.value.reviewAttributes![controller.reviewAttributeList[index].id] ?? 0.0,
                                              minRating: 1,
                                              direction: Axis.horizontal,
                                              itemCount: 5,
                                              itemSize: 18,
                                              itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                                              itemBuilder: (context, _) => const Icon(
                                                Icons.star,
                                                color: AppThemeData.warning300,
                                              ),
                                              onRatingUpdate: (double rate) {
                                                controller.reviewAttribute.addEntries([MapEntry(controller.reviewAttributeList[index].id.toString(), rate)]);
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  DottedBorder(
                                    // borderType: BorderType.RRect,
                                    // radius: const Radius.circular(12),
                                    // dashPattern: const [6, 6, 6, 6],
                                    // color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(12),
                                        ),
                                      ),
                                      child: SizedBox(
                                          height: Responsive.height(20, context),
                                          width: Responsive.width(90, context),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              SvgPicture.asset(
                                                'assets/icons/ic_folder.svg',
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                "Choose a image and upload here".tr,
                                                style: TextStyle(
                                                    color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800, fontFamily: AppThemeData.medium, fontSize: 16),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                "JPEG, PNG".tr,
                                                style: TextStyle(
                                                    fontSize: 12, color: themeChange.getThem() ? AppThemeData.grey200 : AppThemeData.grey700, fontFamily: AppThemeData.regular),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              RoundedButtonFill(
                                                title: "Brows Image".tr,
                                                color: AppThemeData.primary50,
                                                width: 30,
                                                height: 5,
                                                textColor: AppThemeData.primary300,
                                                onPress: () async {
                                                  buildBottomSheet(context, controller);
                                                },
                                              ),
                                            ],
                                          )),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  controller.images.isEmpty
                                      ? const SizedBox()
                                      : SizedBox(
                                          height: 90,
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: ListView.builder(
                                                  itemCount: controller.images.length,
                                                  shrinkWrap: true,
                                                  scrollDirection: Axis.horizontal,
                                                  // physics: const NeverScrollableScrollPhysics(),
                                                  itemBuilder: (context, index) {
                                                    return Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 5),
                                                      child: Stack(
                                                        children: [
                                                          ClipRRect(
                                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                            child: controller.images[index].runtimeType == XFile
                                                                ? Image.file(
                                                                    File(controller.images[index].path),
                                                                    fit: BoxFit.cover,
                                                                    width: 80,
                                                                    height: 80,
                                                                  )
                                                                : NetworkImageWidget(
                                                                    imageUrl: controller.images[index],
                                                                    fit: BoxFit.cover,
                                                                    width: 80,
                                                                    height: 80,
                                                                  ),
                                                          ),
                                                          Positioned(
                                                            bottom: 0,
                                                            top: 0,
                                                            left: 0,
                                                            right: 0,
                                                            child: InkWell(
                                                              onTap: () {
                                                                controller.images.removeAt(index);
                                                              },
                                                              child: const Icon(
                                                                Icons.remove_circle,
                                                                size: 28,
                                                                color: AppThemeData.danger300,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                            ],
                                          ),
                                        ),
                                  DottedBorder(
                                    // borderType: BorderType.RRect,
                                    // radius: const Radius.circular(12),
                                    // dashPattern: const [6, 6, 6, 6],
                                    // color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200,
                                    child: TextFormField(
                                      keyboardType: TextInputType.text,
                                      textCapitalization: TextCapitalization.sentences,
                                      controller: controller.commentController.value,
                                      maxLines: 4,
                                      textInputAction: TextInputAction.done,
                                      style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.medium),
                                      decoration: InputDecoration(
                                        errorStyle: const TextStyle(color: Colors.red),
                                        filled: true,
                                        fillColor: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                        disabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        border: InputBorder.none,
                                        hintText: "Type comment".tr,
                                        hintStyle: TextStyle(
                                          fontSize: 14,
                                          color: themeChange.getThem() ? AppThemeData.grey600 : AppThemeData.grey400,
                                          fontFamily: AppThemeData.regular,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            bottomNavigationBar: Container(
              color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: RoundedButtonFill(
                    title: "Submit Review".tr,
                    height: 5.5,
                    color: AppThemeData.primary300,
                    textColor: AppThemeData.grey50,
                    onPress: () async {
                      controller.saveRating();
                    },
                  )),
            ),
          );
        });
  }

  buildBottomSheet(BuildContext context, RateProductController controller) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          final themeChange = Provider.of<DarkThemeProvider>(context);
          return StatefulBuilder(builder: (context, setState) {
            return SizedBox(
              height: Responsive.height(22, context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Text(
                      "Please Select".tr,
                      style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.bold, fontSize: 16),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                                onPressed: () => controller.pickFile(source: ImageSource.camera),
                                icon: const Icon(
                                  Icons.camera_alt,
                                  size: 32,
                                )),
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text("Camera".tr),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                                onPressed: () => controller.pickFile(source: ImageSource.gallery),
                                icon: const Icon(
                                  Icons.photo_library_sharp,
                                  size: 32,
                                )),
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text("Gallery".tr),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            );
          });
        });
  }
}
