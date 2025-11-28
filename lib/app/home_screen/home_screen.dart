import 'package:badges/badges.dart' as badges;
import 'package:customer/app/address_screens/address_list_screen.dart';
import 'package:customer/app/advertisement_screens/all_advertisement_screen.dart';
import 'package:customer/app/auth_screen/login_screen.dart';
import 'package:customer/app/cart_screen/cart_screen.dart';
import 'package:customer/app/home_screen/category_restaurant_screen.dart';
import 'package:customer/app/home_screen/discount_restaurant_list_screen.dart';
import 'package:customer/app/home_screen/restaurant_list_screen.dart';
import 'package:customer/app/home_screen/story_view.dart';
import 'package:customer/app/home_screen/view_all_category_screen.dart';
import 'package:customer/app/location_permission_screen/location_permission_screen.dart';
import 'package:customer/app/restaurant_details_screen/restaurant_details_screen.dart';
import 'package:customer/app/scan_qrcode_screen/scan_qr_code_screen.dart';
import 'package:customer/app/search_screen/search_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controllers/dash_board_controller.dart';
import 'package:customer/controllers/home_controller.dart';
import 'package:customer/controllers/map_view_controller.dart';
import 'package:customer/models/BannerModel.dart';
import 'package:customer/models/advertisement_model.dart';
import 'package:customer/models/coupon_model.dart';
import 'package:customer/models/favourite_model.dart';
import 'package:customer/models/product_model.dart';
import 'package:customer/models/story_model.dart';
import 'package:customer/models/user_model.dart';
import 'package:customer/models/vendor_category_model.dart';
import 'package:customer/models/vendor_model.dart';
import 'package:customer/services/database_helper.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/custom_dialog_box.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/themes/round_button_fill.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/network_image_widget.dart';
import 'package:customer/utils/preferences.dart';
import 'package:customer/widget/osm_map/map_picker_page.dart';
import 'package:customer/widget/restaurant_image_view.dart';
import 'package:customer/widget/video_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as flutterMap;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:latlong2/latlong.dart' as location;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../themes/text_field_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
      init: HomeController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: themeChange.getThem()
              ? AppThemeData.grey900
              : AppThemeData.grey50,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: const Alignment(0.00, -3),
                colors: [
                  themeChange.getThem()
                      ? AppThemeData.secondary600
                      : AppThemeData.secondary50,
                  themeChange.getThem()
                      ? AppThemeData.surfaceDark
                      : AppThemeData.surface
                ],
                end: const Alignment(0, 1),
              ),
            ),
            child: controller.isLoading.value
                ? Constant.loader()
                : Constant.isZoneAvailable == false ||
                        controller.allNearestRestaurant.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/images/location.gif",
                              height: 120,
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Text(
                              "No Vendors Found in Your Area".tr,
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
                              "Currently, there are no available Vendors in your zone. Try changing your location to find nearby options."
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
                              title: "Change Zone".tr,
                              width: 55,
                              height: 5.5,
                              color: AppThemeData.primary300,
                              textColor: AppThemeData.grey50,
                              onPress: () async {
                                Get.offAll(const LocationPermissionScreen());
                              },
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).viewPadding.top),
                        child: controller.isListView.value == false
                            ? const MapView()
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: Column(
                                      children: [
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                DashBoardController
                                                    dashBoardController =
                                                    Get.put(
                                                        DashBoardController());
                                                if (Constant.walletSetting ==
                                                    false) {
                                                  dashBoardController
                                                      .selectedIndex.value = 3;
                                                } else {
                                                  dashBoardController
                                                      .selectedIndex.value = 4;
                                                }
                                              },
                                              child: ClipOval(
                                                child: NetworkImageWidget(
                                                  imageUrl:
                                                      Constant.userModel == null
                                                          ? ""
                                                          : Constant.userModel!
                                                              .profilePictureURL
                                                              .toString(),
                                                  height: 40,
                                                  width: 40,
                                                  fit: BoxFit.cover,
                                                  errorWidget: Image.asset(
                                                    Constant.userPlaceHolder,
                                                    fit: BoxFit.cover,
                                                    height: 40,
                                                    width: 40,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Constant.userModel == null
                                                      ? InkWell(
                                                          onTap: () {
                                                            Get.offAll(
                                                                const LoginScreen());
                                                          },
                                                          child: Text(
                                                            "Login".tr,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  AppThemeData
                                                                      .medium,
                                                              color: themeChange
                                                                      .getThem()
                                                                  ? AppThemeData
                                                                      .grey50
                                                                  : AppThemeData
                                                                      .grey900,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        )
                                                      : Text(
                                                          "${Constant.userModel!.fullName()}",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                AppThemeData
                                                                    .medium,
                                                            color: themeChange
                                                                    .getThem()
                                                                ? AppThemeData
                                                                    .grey50
                                                                : AppThemeData
                                                                    .grey900,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                  InkWell(
                                                    onTap: () async {
                                                      if (Constant.userModel !=
                                                          null) {
                                                        Get.to(const AddressListScreen())!
                                                            .then(
                                                          (value) {
                                                            if (value != null) {
                                                              ShippingAddress
                                                                  addressModel =
                                                                  value;
                                                              Constant.selectedLocation =
                                                                  addressModel;
                                                              controller
                                                                  .getData();
                                                            }
                                                          },
                                                        );
                                                      } else {
                                                        Constant
                                                            .checkPermission(
                                                                onTap:
                                                                    () async {
                                                                  ShowToastDialog
                                                                      .showLoader(
                                                                          "Please wait"
                                                                              .tr);
                                                                  ShippingAddress
                                                                      addressModel =
                                                                      ShippingAddress();
                                                                  try {
                                                                    await Geolocator
                                                                        .requestPermission();
                                                                    await Geolocator
                                                                        .getCurrentPosition();
                                                                    ShowToastDialog
                                                                        .closeLoader();
                                                                    if (Constant
                                                                            .selectedMapType ==
                                                                        'osm') {
                                                                      final result =
                                                                          await Get.to(() =>
                                                                              MapPickerPage());
                                                                      if (result !=
                                                                          null) {
                                                                        final firstPlace =
                                                                            result;
                                                                        final lat = firstPlace
                                                                            .coordinates
                                                                            .latitude;
                                                                        final lng = firstPlace
                                                                            .coordinates
                                                                            .longitude;
                                                                        final address =
                                                                            firstPlace.address;

                                                                        addressModel.addressAs =
                                                                            "Home";
                                                                        addressModel.locality =
                                                                            address.toString();
                                                                        addressModel.location = UserLocation(
                                                                            latitude:
                                                                                lat,
                                                                            longitude:
                                                                                lng);
                                                                        Constant.selectedLocation =
                                                                            addressModel;
                                                                        controller
                                                                            .getData();
                                                                        Get.back();
                                                                      }
                                                                    } else {
                                                                      Navigator
                                                                          .push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              PlacePicker(
                                                                            apiKey:
                                                                                Constant.mapAPIKey,
                                                                            onPlacePicked:
                                                                                (result) async {
                                                                              ShippingAddress addressModel = ShippingAddress();
                                                                              addressModel.addressAs = "Home";
                                                                              addressModel.locality = result.formattedAddress!.toString();
                                                                              addressModel.location = UserLocation(latitude: result.geometry!.location.lat, longitude: result.geometry!.location.lng);
                                                                              Constant.selectedLocation = addressModel;
                                                                              controller.getData();
                                                                              Get.back();
                                                                            },
                                                                            initialPosition:
                                                                                const LatLng(-33.8567844, 151.213108),
                                                                            useCurrentLocation:
                                                                                true,
                                                                            selectInitialPosition:
                                                                                true,
                                                                            usePinPointingSearch:
                                                                                true,
                                                                            usePlaceDetailSearch:
                                                                                true,
                                                                            zoomGesturesEnabled:
                                                                                true,
                                                                            zoomControlsEnabled:
                                                                                true,
                                                                            resizeToAvoidBottomInset:
                                                                                false, // only works in page mode, less flickery, remove if wrong offsets
                                                                          ),
                                                                        ),
                                                                      );
                                                                    }
                                                                  } catch (e) {
                                                                    await placemarkFromCoordinates(
                                                                            19.228825,
                                                                            72.854118)
                                                                        .then(
                                                                            (valuePlaceMaker) {
                                                                      Placemark
                                                                          placeMark =
                                                                          valuePlaceMaker[
                                                                              0];
                                                                      addressModel.location = UserLocation(
                                                                          latitude:
                                                                              19.228825,
                                                                          longitude:
                                                                              72.854118);
                                                                      String
                                                                          currentLocation =
                                                                          "${placeMark.name}, ${placeMark.subLocality}, ${placeMark.locality}, ${placeMark.administrativeArea}, ${placeMark.postalCode}, ${placeMark.country}";
                                                                      addressModel
                                                                              .locality =
                                                                          currentLocation;
                                                                    });

                                                                    Constant.selectedLocation =
                                                                        addressModel;
                                                                    ShowToastDialog
                                                                        .closeLoader();
                                                                    controller
                                                                        .getData();
                                                                  }
                                                                },
                                                                context:
                                                                    context);
                                                      }
                                                    },
                                                    child: Text.rich(
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      TextSpan(
                                                        children: [
                                                          TextSpan(
                                                            text: Constant
                                                                .selectedLocation
                                                                .getFullAddress(),
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  AppThemeData
                                                                      .medium,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              color: themeChange
                                                                      .getThem()
                                                                  ? AppThemeData
                                                                      .grey50
                                                                  : AppThemeData
                                                                      .grey900,
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                          WidgetSpan(
                                                            child: SvgPicture.asset(
                                                                "assets/icons/ic_down.svg"),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Obx(
                                              () => badges.Badge(
                                                showBadge: cartItem.isEmpty
                                                    ? false
                                                    : true,
                                                badgeContent: Text(
                                                  "${cartItem.length}",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    fontFamily:
                                                        AppThemeData.semiBold,
                                                    fontWeight: FontWeight.w600,
                                                    color: themeChange.getThem()
                                                        ? AppThemeData.grey50
                                                        : AppThemeData.grey50,
                                                  ),
                                                ),
                                                badgeStyle:
                                                    const badges.BadgeStyle(
                                                  shape:
                                                      badges.BadgeShape.circle,
                                                  badgeColor:
                                                      AppThemeData.secondary300,
                                                ),
                                                child: InkWell(
                                                  onTap: () async {
                                                    (await Get.to(
                                                        const CartScreen()));
                                                    controller.getCartData();
                                                  },
                                                  child: ClipOval(
                                                    child: Container(
                                                      width: 42,
                                                      height: 42,
                                                      decoration:
                                                          ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          side: BorderSide(
                                                              width: 1,
                                                              color: themeChange
                                                                      .getThem()
                                                                  ? AppThemeData
                                                                      .grey700
                                                                  : AppThemeData
                                                                      .grey200),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      120),
                                                        ),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: SvgPicture.asset(
                                                          "assets/icons/ic_shoping_cart.svg",
                                                          colorFilter: ColorFilter.mode(
                                                              themeChange
                                                                      .getThem()
                                                                  ? AppThemeData
                                                                      .grey50
                                                                  : AppThemeData
                                                                      .grey900,
                                                              BlendMode.srcIn),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Get.to(const SearchScreen(),
                                                arguments: {
                                                  "vendorList": controller
                                                      .allNearestRestaurant
                                                });
                                          },
                                          child: TextFieldWidget(
                                            hintText:
                                                'Search the dish, restaurant, food, meals'
                                                    .tr,
                                            controller: null,
                                            enable: false,
                                            prefix: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              child: SvgPicture.asset(
                                                  "assets/icons/ic_search.svg"),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          controller.storyList.isEmpty ||
                                                  Constant.storyEnable == false
                                              ? const SizedBox()
                                              : Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 16),
                                                  child: StoryView(
                                                      controller: controller),
                                                ),
                                          SizedBox(
                                            height: controller.storyList.isEmpty
                                                ? 0
                                                : 20,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                titleView(themeChange,
                                                    "Explore the Categories",
                                                    () {
                                                  Get.to(
                                                      const ViewAllCategoryScreen());
                                                }),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                CategoryView(
                                                    controller: controller),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 32,
                                          ),
                                          controller.bannerModel.isEmpty
                                              ? const SizedBox()
                                              : Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 16),
                                                  child: BannerView(
                                                      controller: controller),
                                                ),
                                          controller
                                                  .couponRestaurantList.isEmpty
                                              ? const SizedBox()
                                              : Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 16),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      titleView(
                                                          themeChange,
                                                          "Largest Discounts"
                                                              .tr, () {
                                                        Get.to(
                                                            const DiscountRestaurantListScreen(),
                                                            arguments: {
                                                              "vendorList":
                                                                  controller
                                                                      .couponRestaurantList,
                                                              "couponList":
                                                                  controller
                                                                      .couponList,
                                                              "title":
                                                                  "Discounts Vendors"
                                                            });
                                                      }),
                                                      const SizedBox(
                                                        height: 16,
                                                      ),
                                                      OfferView(
                                                          controller:
                                                              controller),
                                                    ],
                                                  ),
                                                ),
                                          const SizedBox(
                                            height: 28,
                                          ),
                                          controller.newArrivalRestaurantList
                                                  .isEmpty
                                              ? const SizedBox()
                                              : Container(
                                                  decoration: const BoxDecoration(
                                                      image: DecorationImage(
                                                          image: AssetImage(
                                                              "assets/images/ic_new_arrival_bg.png"),
                                                          fit: BoxFit.cover)),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 16,
                                                        vertical: 16),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                "New Arrivals"
                                                                    .tr,
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      AppThemeData
                                                                          .semiBold,
                                                                  fontSize: 16,
                                                                  color: themeChange.getThem()
                                                                      ? AppThemeData
                                                                          .grey50
                                                                      : AppThemeData
                                                                          .grey50,
                                                                ),
                                                              ),
                                                            ),
                                                            InkWell(
                                                              onTap: () {
                                                                Get.to(
                                                                    const RestaurantListScreen(),
                                                                    arguments: {
                                                                      "vendorList":
                                                                          controller
                                                                              .newArrivalRestaurantList,
                                                                      "title":
                                                                          "New Arrival"
                                                                    })?.then(
                                                                    (v) {
                                                                  controller
                                                                      .getFavouriteRestaurant();
                                                                });
                                                              },
                                                              child: Text(
                                                                "View all".tr,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      AppThemeData
                                                                          .regular,
                                                                  color: themeChange.getThem()
                                                                      ? AppThemeData
                                                                          .primary300
                                                                      : AppThemeData
                                                                          .primary300,
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 16,
                                                        ),
                                                        NewArrival(
                                                            controller:
                                                                controller),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          controller.bannerBottomModel.isEmpty
                                              ? const SizedBox()
                                              : Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 16),
                                                  child: BannerBottomView(
                                                      controller: controller),
                                                ),
                                          Visibility(
                                            visible:
                                                (Constant.isEnableAdsFeature ==
                                                        true &&
                                                    controller.advertisementList
                                                        .isNotEmpty),
                                            child: const SizedBox(
                                              height: 20,
                                            ),
                                          ),
                                          Visibility(
                                            visible:
                                                Constant.isEnableAdsFeature ==
                                                    true,
                                            child:
                                                controller.advertisementList
                                                        .isEmpty
                                                    ? const SizedBox()
                                                    : Container(
                                                        color: AppThemeData
                                                            .primary300
                                                            .withAlpha(40),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      16,
                                                                  vertical: 16),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: Text(
                                                                      "Highlights for you"
                                                                          .tr,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .start,
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            AppThemeData.semiBold,
                                                                        fontSize:
                                                                            16,
                                                                        color: themeChange.getThem()
                                                                            ? AppThemeData.grey50
                                                                            : AppThemeData.grey900,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  InkWell(
                                                                    onTap: () {
                                                                      Get.to(AllAdvertisementScreen())
                                                                          ?.then(
                                                                              (value) {
                                                                        controller
                                                                            .getFavouriteRestaurant();
                                                                      });
                                                                    },
                                                                    child: Text(
                                                                      "View all"
                                                                          .tr,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            AppThemeData.regular,
                                                                        color: themeChange.getThem()
                                                                            ? AppThemeData.primary300
                                                                            : AppThemeData.primary300,
                                                                      ),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 16,
                                                              ),
                                                              SizedBox(
                                                                height: 220,
                                                                child: ListView
                                                                    .builder(
                                                                  physics:
                                                                      const BouncingScrollPhysics(),
                                                                  scrollDirection:
                                                                      Axis.horizontal,
                                                                  itemCount: controller
                                                                              .advertisementList
                                                                              .length >=
                                                                          10
                                                                      ? 10
                                                                      : controller
                                                                          .advertisementList
                                                                          .length,
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              0),
                                                                  itemBuilder:
                                                                      (BuildContext
                                                                              context,
                                                                          int index) {
                                                                    return AdvertisementHomeCard(
                                                                        controller:
                                                                            controller,
                                                                        model: controller
                                                                            .advertisementList[index]);
                                                                  },
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16),
                                            child: Container(
                                              decoration: ShapeDecoration(
                                                color: themeChange.getThem()
                                                    ? AppThemeData.grey700
                                                    : AppThemeData.grey200,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          120),
                                                ),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: InkWell(
                                                        onTap: () {
                                                          controller.isPopular
                                                              .value = true;
                                                        },
                                                        child: Container(
                                                          decoration: controller
                                                                      .isPopular
                                                                      .value ==
                                                                  false
                                                              ? null
                                                              : ShapeDecoration(
                                                                  color: AppThemeData
                                                                      .grey900,
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            120),
                                                                  ),
                                                                ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        16,
                                                                    vertical:
                                                                        10),
                                                            child: Text(
                                                              "Popular Vendors"
                                                                  .tr,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    AppThemeData
                                                                        .semiBold,
                                                                color: themeChange.getThem()
                                                                    ? AppThemeData
                                                                        .primary300
                                                                    : AppThemeData
                                                                        .primary300,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: InkWell(
                                                        onTap: () {
                                                          controller.isPopular
                                                              .value = false;
                                                        },
                                                        child: Container(
                                                          decoration: controller
                                                                      .isPopular
                                                                      .value ==
                                                                  true
                                                              ? null
                                                              : ShapeDecoration(
                                                                  color: AppThemeData
                                                                      .grey900,
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            120),
                                                                  ),
                                                                ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        16,
                                                                    vertical:
                                                                        10),
                                                            child: Text(
                                                              "All Vendors"
                                                                  .tr,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    AppThemeData
                                                                        .semiBold,
                                                                color: controller
                                                                            .isPopular
                                                                            .value ==
                                                                        true
                                                                    ? themeChange
                                                                            .getThem()
                                                                        ? AppThemeData
                                                                            .grey400
                                                                        : AppThemeData
                                                                            .grey500
                                                                    : themeChange
                                                                            .getThem()
                                                                        ? AppThemeData
                                                                            .primary300
                                                                        : AppThemeData
                                                                            .primary300,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 20),
                                            child: controller.isPopular.value
                                                ? PopularRestaurant(
                                                    controller: controller)
                                                : AllRestaurant(
                                                    controller: controller),
                                          ),
                                          // controller.isPopular.value
                                          //     ? PopularRestaurant(
                                          //   controller: controller,
                                          // )
                                          //     : PopularRestaurant(
                                          //   controller: controller,
                                          // ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                      ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Container(
            decoration: BoxDecoration(
                color: themeChange.getThem()
                    ? AppThemeData.grey800
                    : AppThemeData.grey100,
                borderRadius: const BorderRadius.all(Radius.circular(30))),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: themeChange.getThem()
                          ? AppThemeData.grey900
                          : AppThemeData.grey50,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              controller.isListView.value = true;
                            },
                            child: ClipOval(
                              child: Container(
                                  decoration: BoxDecoration(
                                      color: controller.isListView.value
                                          ? AppThemeData.primary300
                                          : null),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SvgPicture.asset(
                                      "assets/icons/ic_view_grid_list.svg",
                                      colorFilter: ColorFilter.mode(
                                          controller.isListView.value
                                              ? AppThemeData.grey50
                                              : AppThemeData.grey500,
                                          BlendMode.srcIn),
                                    ),
                                  )),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          InkWell(
                            onTap: () {
                              controller.isListView.value = false;
                              controller.update();
                            },
                            child: ClipOval(
                              child: Container(
                                  decoration: BoxDecoration(
                                      color:
                                          controller.isListView.value == false
                                              ? AppThemeData.primary300
                                              : null),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SvgPicture.asset(
                                      "assets/icons/ic_map_draw.svg",
                                      colorFilter: ColorFilter.mode(
                                          controller.isListView.value == false
                                              ? AppThemeData.grey50
                                              : AppThemeData.grey500,
                                          BlendMode.srcIn),
                                    ),
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  InkWell(
                    onTap: () {
                      Get.to(const ScanQrCodeScreen());
                    },
                    child: ClipOval(
                      child: Container(
                          decoration: BoxDecoration(
                              color: themeChange.getThem()
                                  ? AppThemeData.grey900
                                  : AppThemeData.grey50),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: SvgPicture.asset(
                              "assets/icons/ic_scan_code.svg",
                              colorFilter: ColorFilter.mode(
                                  themeChange.getThem()
                                      ? AppThemeData.grey400
                                      : AppThemeData.grey500,
                                  BlendMode.srcIn),
                            ),
                          )),
                    ),
                  ),
                  const SizedBox(
                    width: 14,
                  ),
                  Text("Services",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w600,fontSize: 15),)
                  // DropdownButton<String>(
                  //   isDense: false,
                  //   underline: const SizedBox(),
                  //   value: controller.selectedOrderTypeValue.value.tr,
                  //   icon: const Icon(Icons.keyboard_arrow_down),
                  //   items: <String>['Delivery', 'TakeAway'].map((String value) {
                  //     return DropdownMenuItem<String>(
                  //       value: value,
                  //       child: Text(
                  //         value.tr,
                  //         style: TextStyle(
                  //           fontFamily: AppThemeData.semiBold,
                  //           fontSize: 16,
                  //           color: themeChange.getThem()
                  //               ? AppThemeData.grey50
                  //               : AppThemeData.grey900,
                  //         ),
                  //       ),
                  //     );
                  //   }).toList(),
                  //   onChanged: (value) async {
                  //     if (cartItem.isEmpty) {
                  //       await Preferences.setString(
                  //           Preferences.foodDeliveryType, value!);
                  //       controller.selectedOrderTypeValue.value = value;
                  //       controller.getData();
                  //     } else {
                  //       showDialog(
                  //           context: context,
                  //           builder: (BuildContext context) {
                  //             return CustomDialogBox(
                  //               title: "Alert".tr,
                  //               descriptions:
                  //                   "Do you really want to change the delivery option? Your cart will be empty."
                  //                       .tr,
                  //               positiveString: "Ok".tr,
                  //               negativeString: "Cancel".tr,
                  //               positiveClick: () async {
                  //                 await Preferences.setString(
                  //                     Preferences.foodDeliveryType, value!);
                  //                 controller.selectedOrderTypeValue.value =
                  //                     value;
                  //                 controller.getData();
                  //                 DatabaseHelper.instance
                  //                     .deleteAllCartProducts();
                  //                 controller.cartProvider.clearDatabase();
                  //                 controller.getCartData();
                  //                 Get.back();
                  //               },
                  //               negativeClick: () {
                  //                 Get.back();
                  //               },
                  //               img: null,
                  //             );
                  //           });
                  //     }
                  //   },
                  // )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  titleView(DarkThemeProvider themeChange, String name, Function()? onPress) {
    return Row(
      children: [
        Expanded(
          child: Text(
            name.tr,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontFamily: AppThemeData.bold,
              color: themeChange.getThem()
                  ? AppThemeData.grey50
                  : AppThemeData.grey900,
            ),
          ),
        ),
        InkWell(
          onTap: () {
            onPress!();
          },
          child: Text(
            "View all".tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppThemeData.regular,
              color: themeChange.getThem()
                  ? AppThemeData.primary300
                  : AppThemeData.primary300,
            ),
          ),
        )
      ],
    );
  }
}

class PopularRestaurant extends StatelessWidget {
  final HomeController controller;

  const PopularRestaurant({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      itemCount: controller.popularRestaurantList.length,
      itemBuilder: (BuildContext context, int index) {
        VendorModel vendorModel = controller.popularRestaurantList[index];
        return InkWell(
          onTap: () {
            Get.to(const RestaurantDetailsScreen(),
                arguments: {"vendorModel": vendorModel})?.then((v) {
              controller.getFavouriteRestaurant();
            });
          },
          child: Padding(
            padding: EdgeInsets.only(
                bottom: controller.popularRestaurantList.length - 1 == index
                    ? 60
                    : 20),
            child: Container(
              decoration: ShapeDecoration(
                color: themeChange.getThem()
                    ? AppThemeData.grey900
                    : AppThemeData.grey50,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16)),
                        child: Stack(
                          children: [
                            RestaurantImageView(
                              vendorModel: vendorModel,
                            ),
                            Container(
                              height: Responsive.height(20, context),
                              width: Responsive.width(100, context),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: const Alignment(-0.00, -1.00),
                                  end: const Alignment(0, 1),
                                  colors: [
                                    Colors.black.withOpacity(0),
                                    const Color(0xFF111827)
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              right: 10,
                              top: 10,
                              child: InkWell(
                                onTap: () async {
                                  if (controller.favouriteList
                                      .where((p0) =>
                                          p0.restaurantId == vendorModel.id)
                                      .isNotEmpty) {
                                    FavouriteModel favouriteModel =
                                        FavouriteModel(
                                            restaurantId: vendorModel.id,
                                            userId:
                                                FireStoreUtils.getCurrentUid());
                                    controller.favouriteList.removeWhere(
                                        (item) =>
                                            item.restaurantId ==
                                            vendorModel.id);
                                    await FireStoreUtils
                                        .removeFavouriteRestaurant(
                                            favouriteModel);
                                  } else {
                                    FavouriteModel favouriteModel =
                                        FavouriteModel(
                                            restaurantId: vendorModel.id,
                                            userId:
                                                FireStoreUtils.getCurrentUid());
                                    controller.favouriteList
                                        .add(favouriteModel);
                                    await FireStoreUtils.setFavouriteRestaurant(
                                        favouriteModel);
                                  }
                                },
                                child: Obx(
                                  () => controller.favouriteList
                                          .where((p0) =>
                                              p0.restaurantId == vendorModel.id)
                                          .isNotEmpty
                                      ? SvgPicture.asset(
                                          "assets/icons/ic_like_fill.svg",
                                        )
                                      : SvgPicture.asset(
                                          "assets/icons/ic_like.svg",
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(Responsive.width(-3, context),
                            Responsive.height(17.5, context)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Visibility(
                              visible: (vendorModel.isSelfDelivery == true &&
                                  Constant.isSelfDeliveryFeature == true),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: AppThemeData.lightGreen,
                                      borderRadius: BorderRadius.circular(
                                          120), // Optional
                                    ),
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(
                                          "assets/icons/ic_free_delivery.svg",
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          "Free Delivery".tr,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppThemeData.darkGreen,
                                            fontFamily: AppThemeData.semiBold,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 6,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 7),
                              decoration: ShapeDecoration(
                                color: themeChange.getThem()
                                    ? AppThemeData.primary600
                                    : AppThemeData.primary50,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(120)),
                              ),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    "assets/icons/ic_star.svg",
                                    colorFilter: ColorFilter.mode(
                                        AppThemeData.primary300,
                                        BlendMode.srcIn),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    "${Constant.calculateReview(reviewCount: vendorModel.reviewsCount!.toStringAsFixed(0), reviewSum: vendorModel.reviewsSum.toString())} (${vendorModel.reviewsCount!.toStringAsFixed(0)})",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: themeChange.getThem()
                                          ? AppThemeData.primary300
                                          : AppThemeData.primary300,
                                      fontFamily: AppThemeData.semiBold,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 7),
                              decoration: ShapeDecoration(
                                color: themeChange.getThem()
                                    ? AppThemeData.secondary600
                                    : AppThemeData.secondary50,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(120)),
                              ),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    "assets/icons/ic_map_distance.svg",
                                    colorFilter: const ColorFilter.mode(
                                        AppThemeData.secondary300,
                                        BlendMode.srcIn),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    "${Constant.getDistance(
                                      lat1: vendorModel.latitude.toString(),
                                      lng1: vendorModel.longitude.toString(),
                                      lat2: Constant
                                          .selectedLocation.location!.latitude
                                          .toString(),
                                      lng2: Constant
                                          .selectedLocation.location!.longitude
                                          .toString(),
                                    )} ${Constant.distanceType}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: themeChange.getThem()
                                          ? AppThemeData.secondary300
                                          : AppThemeData.secondary300,
                                      fontFamily: AppThemeData.semiBold,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vendorModel.title.toString(),
                          textAlign: TextAlign.start,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 18,
                            overflow: TextOverflow.ellipsis,
                            fontFamily: AppThemeData.semiBold,
                            color: themeChange.getThem()
                                ? AppThemeData.grey50
                                : AppThemeData.grey900,
                          ),
                        ),
                        Text(
                          vendorModel.location.toString(),
                          textAlign: TextAlign.start,
                          maxLines: 1,
                          style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontFamily: AppThemeData.medium,
                            fontWeight: FontWeight.w500,
                            color: themeChange.getThem()
                                ? AppThemeData.grey400
                                : AppThemeData.grey400,
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class AllRestaurant extends StatelessWidget {
  final HomeController controller;

  const AllRestaurant({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      itemCount: controller.allNearestRestaurant.length,
      itemBuilder: (BuildContext context, int index) {
        VendorModel vendorModel = controller.allNearestRestaurant[index];
        return InkWell(
          onTap: () {
            Get.to(const RestaurantDetailsScreen(),
                arguments: {"vendorModel": vendorModel})?.then((v) {
              controller.getFavouriteRestaurant();
            });
          },
          child: Padding(
            padding: EdgeInsets.only(
                bottom: controller.allNearestRestaurant.length - 1 == index
                    ? 60
                    : 20),
            child: Container(
              decoration: ShapeDecoration(
                color: themeChange.getThem()
                    ? AppThemeData.grey900
                    : AppThemeData.grey50,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16)),
                        child: Stack(
                          children: [
                            RestaurantImageView(
                              vendorModel: vendorModel,
                            ),
                            Container(
                              height: Responsive.height(20, context),
                              width: Responsive.width(100, context),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: const Alignment(-0.00, -1.00),
                                  end: const Alignment(0, 1),
                                  colors: [
                                    Colors.black.withOpacity(0),
                                    const Color(0xFF111827)
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              right: 10,
                              top: 10,
                              child: InkWell(
                                onTap: () async {
                                  if (controller.favouriteList
                                      .where((p0) =>
                                          p0.restaurantId == vendorModel.id)
                                      .isNotEmpty) {
                                    FavouriteModel favouriteModel =
                                        FavouriteModel(
                                            restaurantId: vendorModel.id,
                                            userId:
                                                FireStoreUtils.getCurrentUid());
                                    controller.favouriteList.removeWhere(
                                        (item) =>
                                            item.restaurantId ==
                                            vendorModel.id);
                                    await FireStoreUtils
                                        .removeFavouriteRestaurant(
                                            favouriteModel);
                                  } else {
                                    FavouriteModel favouriteModel =
                                        FavouriteModel(
                                            restaurantId: vendorModel.id,
                                            userId:
                                                FireStoreUtils.getCurrentUid());
                                    controller.favouriteList
                                        .add(favouriteModel);
                                    await FireStoreUtils.setFavouriteRestaurant(
                                        favouriteModel);
                                  }
                                },
                                child: Obx(
                                  () => controller.favouriteList
                                          .where((p0) =>
                                              p0.restaurantId == vendorModel.id)
                                          .isNotEmpty
                                      ? SvgPicture.asset(
                                          "assets/icons/ic_like_fill.svg",
                                        )
                                      : SvgPicture.asset(
                                          "assets/icons/ic_like.svg",
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(Responsive.width(-3, context),
                            Responsive.height(17.5, context)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Visibility(
                              visible: (vendorModel.isSelfDelivery == true &&
                                  Constant.isSelfDeliveryFeature == true),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: AppThemeData.lightGreen,
                                      borderRadius: BorderRadius.circular(
                                          120), // Optional
                                    ),
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(
                                          "assets/icons/ic_free_delivery.svg",
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          "Free Delivery".tr,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppThemeData.darkGreen,
                                            fontFamily: AppThemeData.semiBold,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 6,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 7),
                              decoration: ShapeDecoration(
                                color: themeChange.getThem()
                                    ? AppThemeData.primary600
                                    : AppThemeData.primary50,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(120)),
                              ),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    "assets/icons/ic_star.svg",
                                    colorFilter: ColorFilter.mode(
                                        AppThemeData.primary300,
                                        BlendMode.srcIn),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    "${Constant.calculateReview(reviewCount: vendorModel.reviewsCount.toString(), reviewSum: vendorModel.reviewsSum.toString())} (${vendorModel.reviewsCount!.toStringAsFixed(0)})",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: themeChange.getThem()
                                          ? AppThemeData.primary300
                                          : AppThemeData.primary300,
                                      fontFamily: AppThemeData.semiBold,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 7),
                              decoration: ShapeDecoration(
                                color: themeChange.getThem()
                                    ? AppThemeData.secondary600
                                    : AppThemeData.secondary50,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(120)),
                              ),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    "assets/icons/ic_map_distance.svg",
                                    colorFilter: const ColorFilter.mode(
                                        AppThemeData.secondary300,
                                        BlendMode.srcIn),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    "${Constant.getDistance(
                                      lat1: vendorModel.latitude.toString(),
                                      lng1: vendorModel.longitude.toString(),
                                      lat2: Constant
                                          .selectedLocation.location!.latitude
                                          .toString(),
                                      lng2: Constant
                                          .selectedLocation.location!.longitude
                                          .toString(),
                                    )} ${Constant.distanceType}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: themeChange.getThem()
                                          ? AppThemeData.secondary300
                                          : AppThemeData.secondary300,
                                      fontFamily: AppThemeData.semiBold,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vendorModel.title.toString(),
                          textAlign: TextAlign.start,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 18,
                            overflow: TextOverflow.ellipsis,
                            fontFamily: AppThemeData.semiBold,
                            color: themeChange.getThem()
                                ? AppThemeData.grey50
                                : AppThemeData.grey900,
                          ),
                        ),
                        Text(
                          vendorModel.location.toString(),
                          textAlign: TextAlign.start,
                          maxLines: 1,
                          style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontFamily: AppThemeData.medium,
                            fontWeight: FontWeight.w500,
                            color: themeChange.getThem()
                                ? AppThemeData.grey400
                                : AppThemeData.grey400,
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class NewArrival extends StatelessWidget {
  final HomeController controller;

  const NewArrival({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return SizedBox(
      height: Responsive.height(24, context),
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: controller.newArrivalRestaurantList.length >= 10
            ? 10
            : controller.newArrivalRestaurantList.length,
        itemBuilder: (BuildContext context, int index) {
          VendorModel vendorModel = controller.newArrivalRestaurantList[index];
          return InkWell(
            onTap: () {
              Get.to(const RestaurantDetailsScreen(),
                  arguments: {"vendorModel": vendorModel})?.then((v) {
                controller.getFavouriteRestaurant();
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: SizedBox(
                width: Responsive.width(55, context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        child: Stack(
                          children: [
                            NetworkImageWidget(
                              imageUrl: vendorModel.photo.toString(),
                              fit: BoxFit.cover,
                              height: Responsive.height(100, context),
                              width: Responsive.width(100, context),
                            ),
                            Container(
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
                            Positioned(
                              right: 10,
                              top: 10,
                              child: InkWell(
                                onTap: () async {
                                  if (controller.favouriteList
                                      .where((p0) =>
                                          p0.restaurantId == vendorModel.id)
                                      .isNotEmpty) {
                                    FavouriteModel favouriteModel =
                                        FavouriteModel(
                                            restaurantId: vendorModel.id,
                                            userId:
                                                FireStoreUtils.getCurrentUid());
                                    controller.favouriteList.removeWhere(
                                        (item) =>
                                            item.restaurantId ==
                                            vendorModel.id);
                                    await FireStoreUtils
                                        .removeFavouriteRestaurant(
                                            favouriteModel);
                                  } else {
                                    FavouriteModel favouriteModel =
                                        FavouriteModel(
                                            restaurantId: vendorModel.id,
                                            userId:
                                                FireStoreUtils.getCurrentUid());
                                    controller.favouriteList
                                        .add(favouriteModel);
                                    await FireStoreUtils.setFavouriteRestaurant(
                                        favouriteModel);
                                  }
                                },
                                child: Obx(
                                  () => controller.favouriteList
                                          .where((p0) =>
                                              p0.restaurantId == vendorModel.id)
                                          .isNotEmpty
                                      ? SvgPicture.asset(
                                          "assets/icons/ic_like_fill.svg",
                                        )
                                      : SvgPicture.asset(
                                          "assets/icons/ic_like.svg",
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      vendorModel.title.toString(),
                      textAlign: TextAlign.start,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 16,
                        overflow: TextOverflow.ellipsis,
                        fontFamily: AppThemeData.semiBold,
                        color: themeChange.getThem()
                            ? AppThemeData.grey50
                            : AppThemeData.grey50,
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Visibility(
                            visible: (vendorModel.isSelfDelivery == true &&
                                Constant.isSelfDeliveryFeature == true),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  "assets/icons/ic_free_delivery.svg",
                                ),
                                const SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  "Free Delivery",
                                  textAlign: TextAlign.start,
                                  maxLines: 1,
                                  style: TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    fontFamily: AppThemeData.medium,
                                    fontWeight: FontWeight.w500,
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey400
                                        : AppThemeData.grey400,
                                  ),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              SvgPicture.asset(
                                "assets/icons/ic_star.svg",
                                colorFilter: ColorFilter.mode(
                                    AppThemeData.primary300, BlendMode.srcIn),
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              Text(
                                "${Constant.calculateReview(reviewCount: vendorModel.reviewsCount.toString(), reviewSum: vendorModel.reviewsSum.toString())} (${vendorModel.reviewsCount!.toStringAsFixed(0)})",
                                textAlign: TextAlign.start,
                                maxLines: 1,
                                style: TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  fontFamily: AppThemeData.medium,
                                  fontWeight: FontWeight.w500,
                                  color: themeChange.getThem()
                                      ? AppThemeData.grey400
                                      : AppThemeData.grey400,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Row(
                            children: [
                              SvgPicture.asset(
                                  "assets/icons/ic_map_distance.svg"),
                              const SizedBox(
                                width: 4,
                              ),
                              Text(
                                "${Constant.getDistance(
                                  lat1: vendorModel.latitude.toString(),
                                  lng1: vendorModel.longitude.toString(),
                                  lat2: Constant
                                      .selectedLocation.location!.latitude
                                      .toString(),
                                  lng2: Constant
                                      .selectedLocation.location!.longitude
                                      .toString(),
                                )} ${Constant.distanceType}",
                                textAlign: TextAlign.start,
                                maxLines: 1,
                                style: TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  fontFamily: AppThemeData.medium,
                                  fontWeight: FontWeight.w500,
                                  color: themeChange.getThem()
                                      ? AppThemeData.grey400
                                      : AppThemeData.grey400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(
                      vendorModel.location.toString(),
                      textAlign: TextAlign.start,
                      maxLines: 1,
                      style: TextStyle(
                        overflow: TextOverflow.ellipsis,
                        fontFamily: AppThemeData.medium,
                        fontWeight: FontWeight.w500,
                        color: themeChange.getThem()
                            ? AppThemeData.grey400
                            : AppThemeData.grey400,
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class AdvertisementHomeCard extends StatelessWidget {
  final AdvertisementModel model;
  final HomeController controller;

  const AdvertisementHomeCard(
      {super.key, required this.controller, required this.model});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return InkWell(
      onTap: () async {
        ShowToastDialog.showLoader("Please wait".tr);
        VendorModel? vendorModel =
            await FireStoreUtils.getVendorById(model.vendorId!);
        ShowToastDialog.closeLoader();
        Get.to(const RestaurantDetailsScreen(),
            arguments: {"vendorModel": vendorModel});
      },
      child: Container(
        margin: EdgeInsets.only(right: 16),
        width: Responsive.width(70, context),
        decoration: BoxDecoration(
          color: themeChange.getThem()
              ? AppThemeData.info600
              : AppThemeData.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: themeChange.getThem() ? 6 : 2,
              spreadRadius: 0,
              offset: Offset(0, themeChange.getThem() ? 3 : 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                model.type == 'restaurant_promotion'
                    ? ClipRRect(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16)),
                        child: NetworkImageWidget(
                          imageUrl: model.coverImage ?? '',
                          height: 135,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    : VideoAdvWidget(
                        url: model.video ?? '',
                        height: 135,
                        width: double.infinity,
                      ),
                if (model.type != 'video_promotion' &&
                    model.vendorId != null &&
                    (model.showRating == true || model.showReview == true))
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: FutureBuilder(
                        future: FireStoreUtils.getVendorById(model.vendorId!),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox();
                          } else {
                            if (snapshot.hasError) {
                              return const SizedBox();
                            } else if (snapshot.data == null) {
                              return const SizedBox();
                            } else {
                              VendorModel vendorModel = snapshot.data!;
                              return Container(
                                decoration: ShapeDecoration(
                                  color: themeChange.getThem()
                                      ? AppThemeData.primary600
                                      : AppThemeData.primary50,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(120)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        "assets/icons/ic_star.svg",
                                        colorFilter: ColorFilter.mode(
                                            AppThemeData.primary300,
                                            BlendMode.srcIn),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        "${model.showRating == true ? Constant.calculateReview(reviewCount: vendorModel.reviewsCount!.toStringAsFixed(0), reviewSum: vendorModel.reviewsSum.toString()) : ''} ${model.showReview == true ? '(${vendorModel.reviewsCount!.toStringAsFixed(0)})' : ''}",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: themeChange.getThem()
                                              ? AppThemeData.primary300
                                              : AppThemeData.primary300,
                                          fontFamily: AppThemeData.semiBold,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                          }
                        }),
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (model.type == 'restaurant_promotion')
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: NetworkImageWidget(
                        imageUrl: model.profileImage ?? '',
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          model.title ?? '',
                          style: TextStyle(
                            color: themeChange.getThem()
                                ? AppThemeData.grey50
                                : AppThemeData.grey900,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          model.description ?? '',
                          style: TextStyle(
                              fontSize: 12,
                              fontFamily: AppThemeData.medium,
                              color: themeChange.getThem()
                                  ? AppThemeData.grey400
                                  : AppThemeData.grey600),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  model.type == 'restaurant_promotion'
                      ? IconButton(
                          icon: Obx(
                            () => controller.favouriteList
                                    .where((p0) =>
                                        p0.restaurantId == model.vendorId)
                                    .isNotEmpty
                                ? SvgPicture.asset(
                                    "assets/icons/ic_like_fill.svg",
                                  )
                                : SvgPicture.asset(
                                    "assets/icons/ic_like.svg",
                                    colorFilter: ColorFilter.mode(
                                        themeChange.getThem()
                                            ? AppThemeData.grey400
                                            : AppThemeData.grey600,
                                        BlendMode.srcIn),
                                  ),
                          ),
                          onPressed: () async {
                            if (controller.favouriteList
                                .where(
                                    (p0) => p0.restaurantId == model.vendorId)
                                .isNotEmpty) {
                              FavouriteModel favouriteModel = FavouriteModel(
                                  restaurantId: model.vendorId,
                                  userId: FireStoreUtils.getCurrentUid());
                              controller.favouriteList.removeWhere((item) =>
                                  item.restaurantId == model.vendorId);
                              await FireStoreUtils.removeFavouriteRestaurant(
                                  favouriteModel);
                            } else {
                              FavouriteModel favouriteModel = FavouriteModel(
                                  restaurantId: model.vendorId,
                                  userId: FireStoreUtils.getCurrentUid());
                              controller.favouriteList.add(favouriteModel);
                              await FireStoreUtils.setFavouriteRestaurant(
                                  favouriteModel);
                            }
                            controller.update();
                          },
                        )
                      : Container(
                          decoration: ShapeDecoration(
                            color: themeChange.getThem()
                                ? AppThemeData.primary600
                                : AppThemeData.primary50,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                          ),
                          child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              child: Icon(Icons.arrow_forward,
                                  size: 20, color: AppThemeData.primary300)))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OfferView extends StatelessWidget {
  final HomeController controller;

  const OfferView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return SizedBox(
      height: Responsive.height(17, context),
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: controller.couponRestaurantList.length >= 15
            ? 15
            : controller.couponRestaurantList.length,
        itemBuilder: (BuildContext context, int index) {
          VendorModel vendorModel = controller.couponRestaurantList[index];
          CouponModel offerModel = controller.couponList[index];
          return InkWell(
            onTap: () {
              Get.to(const RestaurantDetailsScreen(),
                  arguments: {"vendorModel": vendorModel});
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: SizedBox(
                width: Responsive.width(38, context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        child: Stack(
                          children: [
                            NetworkImageWidget(
                              imageUrl: vendorModel.photo.toString(),
                              fit: BoxFit.cover,
                              height: Responsive.height(100, context),
                              width: Responsive.width(100, context),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: const Alignment(-0.00, -1.00),
                                  end: const Alignment(0, 1),
                                  colors: [
                                    Colors.black.withOpacity(0),
                                    AppThemeData.grey900
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 5,
                              left: 10,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Upto".tr,
                                    textAlign: TextAlign.start,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 18,
                                      overflow: TextOverflow.ellipsis,
                                      fontFamily: AppThemeData.regular,
                                      fontWeight: FontWeight.w900,
                                      color: themeChange.getThem()
                                          ? AppThemeData.grey50
                                          : AppThemeData.grey50,
                                    ),
                                  ),
                                  Text(
                                    "${offerModel.discountType == "Fix Price" ? "${Constant.currencyModel!.symbol}" : ""}${offerModel.discount}${offerModel.discountType == "Percentage" ? "% off".tr : "off".tr}",
                                    textAlign: TextAlign.start,
                                    maxLines: 1,
                                    style: TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      fontFamily: AppThemeData.semiBold,
                                      color: themeChange.getThem()
                                          ? AppThemeData.grey50
                                          : AppThemeData.grey50,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      vendorModel.title.toString(),
                      textAlign: TextAlign.start,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 16,
                        overflow: TextOverflow.ellipsis,
                        fontFamily: AppThemeData.semiBold,
                        color: themeChange.getThem()
                            ? AppThemeData.grey50
                            : AppThemeData.grey900,
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Visibility(
                            visible: (vendorModel.isSelfDelivery == true &&
                                Constant.isSelfDeliveryFeature == true),
                            child: Row(
                              children: [
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      "assets/icons/ic_free_delivery.svg",
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      "Free Delivery".tr,
                                      style: TextStyle(
                                        fontSize: 12,
                                        overflow: TextOverflow.ellipsis,
                                        fontFamily: AppThemeData.medium,
                                        fontWeight: FontWeight.w500,
                                        color: themeChange.getThem()
                                            ? AppThemeData.grey300
                                            : AppThemeData.grey600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  width: 6,
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              SvgPicture.asset(
                                "assets/icons/ic_star.svg",
                                colorFilter: ColorFilter.mode(
                                    AppThemeData.primary300, BlendMode.srcIn),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                "${Constant.calculateReview(reviewCount: vendorModel.reviewsCount.toString(), reviewSum: vendorModel.reviewsSum.toString())} (${vendorModel.reviewsCount!.toStringAsFixed(0)})",
                                textAlign: TextAlign.start,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 12,
                                  overflow: TextOverflow.ellipsis,
                                  fontFamily: AppThemeData.medium,
                                  fontWeight: FontWeight.w500,
                                  color: themeChange.getThem()
                                      ? AppThemeData.grey300
                                      : AppThemeData.grey600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class BannerView extends StatelessWidget {
  final HomeController controller;

  const BannerView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PageView.builder(
            physics: const BouncingScrollPhysics(),
            controller: controller.pageController.value,
            scrollDirection: Axis.horizontal,
            itemCount: controller.bannerModel.length,
            padEnds: false,
            pageSnapping: true,
            allowImplicitScrolling: true,
            onPageChanged: (value) {
              controller.currentPage.value = value;
            },
            itemBuilder: (BuildContext context, int index) {
              BannerModel bannerModel = controller.bannerModel[index];
              return InkWell(
                onTap: () async {
                  if (bannerModel.redirect_type == "store") {
                    ShowToastDialog.showLoader("Please wait".tr);
                    VendorModel? vendorModel =
                        await FireStoreUtils.getVendorById(
                            bannerModel.redirect_id.toString());

                    if (vendorModel!.zoneId == Constant.selectedZone!.id) {
                      ShowToastDialog.closeLoader();
                      Get.to(const RestaurantDetailsScreen(),
                          arguments: {"vendorModel": vendorModel});
                    } else {
                      ShowToastDialog.closeLoader();
                      ShowToastDialog.showToast(
                          "Sorry, The Zone is not available in your area. change the other location first."
                              .tr);
                    }
                  } else if (bannerModel.redirect_type == "product") {
                    ShowToastDialog.showLoader("Please wait".tr);
                    ProductModel? productModel =
                        await FireStoreUtils.getProductById(
                            bannerModel.redirect_id.toString());
                    VendorModel? vendorModel =
                        await FireStoreUtils.getVendorById(
                            productModel!.vendorID.toString());

                    if (vendorModel!.zoneId == Constant.selectedZone!.id) {
                      ShowToastDialog.closeLoader();
                      Get.to(const RestaurantDetailsScreen(),
                          arguments: {"vendorModel": vendorModel});
                    } else {
                      ShowToastDialog.closeLoader();
                      ShowToastDialog.showToast(
                          "Sorry, The Zone is not available in your area. change the other location first."
                              .tr);
                    }
                  } else if (bannerModel.redirect_type == "external_link") {
                    final uri = Uri.parse(bannerModel.redirect_id.toString());
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      ShowToastDialog.showToast("Could not launch".tr);
                    }
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    child: NetworkImageWidget(
                      imageUrl: bannerModel.photo.toString(),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(
              controller.bannerModel.length,
              (index) {
                return Obx(
                  () => Container(
                    margin: const EdgeInsets.only(right: 5),
                    alignment: Alignment.centerLeft,
                    height: 9,
                    width: 9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: controller.currentPage.value == index
                          ? AppThemeData.primary300
                          : Colors.black12,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class BannerBottomView extends StatelessWidget {
  final HomeController controller;

  const BannerBottomView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PageView.builder(
            physics: const BouncingScrollPhysics(),
            controller: controller.pageBottomController.value,
            scrollDirection: Axis.horizontal,
            itemCount: controller.bannerBottomModel.length,
            padEnds: false,
            pageSnapping: true,
            allowImplicitScrolling: true,
            onPageChanged: (value) {
              controller.currentBottomPage.value = value;
            },
            itemBuilder: (BuildContext context, int index) {
              BannerModel bannerModel = controller.bannerBottomModel[index];
              return InkWell(
                onTap: () async {
                  if (bannerModel.redirect_type == "store") {
                    ShowToastDialog.showLoader("Please wait".tr);
                    VendorModel? vendorModel =
                        await FireStoreUtils.getVendorById(
                            bannerModel.redirect_id.toString());

                    if (vendorModel!.zoneId == Constant.selectedZone!.id) {
                      ShowToastDialog.closeLoader();
                      Get.to(const RestaurantDetailsScreen(),
                          arguments: {"vendorModel": vendorModel});
                    } else {
                      ShowToastDialog.closeLoader();
                      ShowToastDialog.showToast(
                          "Sorry, The Zone is not available in your area. change the other location first."
                              .tr);
                    }
                  } else if (bannerModel.redirect_type == "product") {
                    ShowToastDialog.showLoader("Please wait".tr);
                    ProductModel? productModel =
                        await FireStoreUtils.getProductById(
                            bannerModel.redirect_id.toString());
                    VendorModel? vendorModel =
                        await FireStoreUtils.getVendorById(
                            productModel!.vendorID.toString());

                    if (vendorModel!.zoneId == Constant.selectedZone!.id) {
                      ShowToastDialog.closeLoader();
                      Get.to(const RestaurantDetailsScreen(),
                          arguments: {"vendorModel": vendorModel});
                    } else {
                      ShowToastDialog.closeLoader();
                      ShowToastDialog.showToast(
                          "Sorry, The Zone is not available in your area. change the other location first."
                              .tr);
                    }
                  } else if (bannerModel.redirect_type == "external_link") {
                    final uri = Uri.parse(bannerModel.redirect_id.toString());
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      ShowToastDialog.showToast("Could not launch".tr);
                    }
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    child: NetworkImageWidget(
                      imageUrl: bannerModel.photo.toString(),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(
              controller.bannerBottomModel.length,
              (index) {
                return Obx(
                  () => Container(
                    margin: const EdgeInsets.only(right: 5),
                    alignment: Alignment.centerLeft,
                    height: 9,
                    width: 9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: controller.currentBottomPage.value == index
                          ? AppThemeData.primary300
                          : Colors.black12,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class CategoryView extends StatelessWidget {
  final HomeController controller;

  const CategoryView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return SizedBox(
      height: 124,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: controller.vendorCategoryModel.length,
        itemBuilder: (context, index) {
          VendorCategoryModel vendorCategoryModel =
              controller.vendorCategoryModel[index];
          return InkWell(
            onTap: () {
              Get.to(const CategoryVendorscreen(), arguments: {
                "vendorCategoryModel": vendorCategoryModel,
                "dineIn": false
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              child: SizedBox(
                width: 78,
                child: Container(
                  decoration: ShapeDecoration(
                    color: themeChange.getThem()
                        ? AppThemeData.grey900
                        : AppThemeData.grey50,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        strokeAlign: BorderSide.strokeAlignOutside,
                        color: themeChange.getThem()
                            ? AppThemeData.grey800
                            : AppThemeData.grey100,
                      ),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: ClipOval(
                          child: NetworkImageWidget(
                            imageUrl: vendorCategoryModel.photo.toString(),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: Text(
                          '${vendorCategoryModel.title}',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: TextStyle(
                            color: themeChange.getThem()
                                ? AppThemeData.grey50
                                : AppThemeData.grey900,
                            fontFamily: AppThemeData.medium,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class StoryView extends StatelessWidget {
  final HomeController controller;

  const StoryView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: controller.storyList.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          StoryModel storyModel = controller.storyList[index];
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => MoreStories(
                          storyList: controller.storyList,
                          index: index,
                        )));
              },
              child: SizedBox(
                width: 134,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: Stack(
                    children: [
                      NetworkImageWidget(
                        imageUrl: storyModel.videoThumbnail.toString(),
                        fit: BoxFit.cover,
                        height: Responsive.height(100, context),
                        width: Responsive.width(100, context),
                      ),
                      Container(
                        color: Colors.black.withOpacity(0.30),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 8),
                        child: FutureBuilder(
                            future: FireStoreUtils.getVendorById(
                                storyModel.vendorID.toString()),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Constant.loader();
                              } else {
                                if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Error: ${snapshot.error}'));
                                } else if (snapshot.data == null) {
                                  return const SizedBox();
                                } else {
                                  VendorModel vendorModel = snapshot.data!;
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipOval(
                                        child: NetworkImageWidget(
                                          imageUrl:
                                              vendorModel.photo.toString(),
                                          width: 30,
                                          height: 30,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              vendorModel.title.toString(),
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                overflow: TextOverflow.ellipsis,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                SvgPicture.asset(
                                                    "assets/icons/ic_star.svg"),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  "${Constant.calculateReview(reviewCount: vendorModel.reviewsCount.toString(), reviewSum: vendorModel.reviewsSum!.toStringAsFixed(0))} reviews",
                                                  textAlign: TextAlign.center,
                                                  maxLines: 1,
                                                  style: const TextStyle(
                                                    color:
                                                        AppThemeData.warning300,
                                                    fontSize: 10,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              }
                            }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
      init: MapViewController(),
      builder: (controller) {
        return Stack(
          children: [
            Constant.selectedMapType == "osm"
                ? flutterMap.FlutterMap(
                    mapController: controller.osmMapController,
                    options: flutterMap.MapOptions(
                      initialCenter: location.LatLng(
                          Constant.selectedLocation.location!.latitude ?? 0.0,
                          Constant.selectedLocation.location!.longitude ?? 0.0),
                      initialZoom: 10,
                    ),
                    children: [
                      flutterMap.TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.app',
                      ),
                      flutterMap.MarkerLayer(
                        markers: controller.osmMarker,
                      ),
                    ],
                  )
                : GoogleMap(
                    mapType: MapType.terrain,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    zoomControlsEnabled: false,
                    markers: Set<Marker>.of(controller.markers.values),
                    onMapCreated: (GoogleMapController mapController) {
                      controller.mapController = mapController;
                    },
                    mapToolbarEnabled: true,
                    initialCameraPosition: CameraPosition(
                      zoom: 18,
                      target: controller
                              .homeController.allNearestRestaurant.isEmpty
                          ? LatLng(
                              Constant.selectedLocation.location!.latitude ??
                                  45.521563,
                              Constant.selectedLocation.location!.longitude ??
                                  -122.677433,
                            )
                          : LatLng(
                              controller.homeController.allNearestRestaurant
                                      .first.latitude ??
                                  45.521563,
                              controller.homeController.allNearestRestaurant
                                      .first.longitude ??
                                  -122.677433,
                            ),
                    ),
                  ),
            controller.homeController.allNearestRestaurant.isEmpty
                ? Container()
                : Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 80),
                      child: SizedBox(
                        height: Responsive.height(25, context),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: PageView.builder(
                                pageSnapping: true,
                                controller:
                                    PageController(viewportFraction: 0.88),
                                onPageChanged: (value) async {
                                  if (Constant.selectedMapType == "osm") {
                                    controller.osmMapController.move(
                                        location.LatLng(
                                          controller
                                              .homeController
                                              .allNearestRestaurant[value]
                                              .latitude!,
                                          controller
                                              .homeController
                                              .allNearestRestaurant[value]
                                              .longitude!,
                                        ),
                                        16);
                                  } else {
                                    CameraUpdate cameraUpdate =
                                        CameraUpdate.newCameraPosition(
                                            CameraPosition(
                                      zoom: 18,
                                      target: LatLng(
                                        controller
                                            .homeController
                                            .allNearestRestaurant[value]
                                            .latitude!,
                                        controller
                                            .homeController
                                            .allNearestRestaurant[value]
                                            .longitude!,
                                      ),
                                    ));
                                    controller.mapController!
                                        .animateCamera(cameraUpdate);
                                  }
                                },
                                itemCount: controller
                                    .homeController.allNearestRestaurant.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  VendorModel vendorModel = controller
                                      .homeController
                                      .allNearestRestaurant[index];
                                  return InkWell(
                                    onTap: () {
                                      Get.to(const RestaurantDetailsScreen(),
                                          arguments: {
                                            "vendorModel": vendorModel
                                          })?.then((v) {
                                        controller.homeController
                                            .getFavouriteRestaurant();
                                      });
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: index == 0 ? 0 : 10),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: themeChange.getThem()
                                              ? AppThemeData.grey900
                                              : AppThemeData.grey50,
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(16)),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Stack(
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  16),
                                                          topRight:
                                                              Radius.circular(
                                                                  16)),
                                                  child: Stack(
                                                    children: [
                                                      NetworkImageWidget(
                                                        imageUrl: vendorModel
                                                            .photo
                                                            .toString(),
                                                        fit: BoxFit.cover,
                                                        height:
                                                            Responsive.height(
                                                                14, context),
                                                        width: Responsive.width(
                                                            100, context),
                                                      ),
                                                      Container(
                                                        height:
                                                            Responsive.height(
                                                                14, context),
                                                        width: Responsive.width(
                                                            100, context),
                                                        decoration:
                                                            BoxDecoration(
                                                          gradient:
                                                              LinearGradient(
                                                            begin:
                                                                const Alignment(
                                                                    -0.00,
                                                                    -1.00),
                                                            end:
                                                                const Alignment(
                                                                    0, 1),
                                                            colors: [
                                                              Colors.black
                                                                  .withOpacity(
                                                                      0),
                                                              const Color(
                                                                  0xFF111827)
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Positioned(
                                                        right: 10,
                                                        top: 10,
                                                        child: InkWell(
                                                          onTap: () async {
                                                            if (controller
                                                                .homeController
                                                                .favouriteList
                                                                .where((p0) =>
                                                                    p0.restaurantId ==
                                                                    vendorModel
                                                                        .id)
                                                                .isNotEmpty) {
                                                              FavouriteModel
                                                                  favouriteModel =
                                                                  FavouriteModel(
                                                                      restaurantId:
                                                                          vendorModel
                                                                              .id,
                                                                      userId: FireStoreUtils
                                                                          .getCurrentUid());
                                                              controller
                                                                  .homeController
                                                                  .favouriteList
                                                                  .removeWhere((item) =>
                                                                      item.restaurantId ==
                                                                      vendorModel
                                                                          .id);
                                                              await FireStoreUtils
                                                                  .removeFavouriteRestaurant(
                                                                      favouriteModel);
                                                            } else {
                                                              FavouriteModel
                                                                  favouriteModel =
                                                                  FavouriteModel(
                                                                      restaurantId:
                                                                          vendorModel
                                                                              .id,
                                                                      userId: FireStoreUtils
                                                                          .getCurrentUid());
                                                              controller
                                                                  .homeController
                                                                  .favouriteList
                                                                  .add(
                                                                      favouriteModel);
                                                              await FireStoreUtils
                                                                  .setFavouriteRestaurant(
                                                                      favouriteModel);
                                                            }
                                                          },
                                                          child: Obx(
                                                            () => controller
                                                                    .homeController
                                                                    .favouriteList
                                                                    .where((p0) =>
                                                                        p0.restaurantId ==
                                                                        vendorModel
                                                                            .id)
                                                                    .isNotEmpty
                                                                ? SvgPicture
                                                                    .asset(
                                                                    "assets/icons/ic_like_fill.svg",
                                                                  )
                                                                : SvgPicture
                                                                    .asset(
                                                                    "assets/icons/ic_like.svg",
                                                                  ),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Transform.translate(
                                                  offset: Offset(
                                                      Responsive.width(
                                                          -3, context),
                                                      Responsive.height(
                                                          11, context)),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Container(
                                                        decoration:
                                                            ShapeDecoration(
                                                          color: themeChange
                                                                  .getThem()
                                                              ? AppThemeData
                                                                  .primary600
                                                              : AppThemeData
                                                                  .primary50,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          120)),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      12,
                                                                  vertical: 8),
                                                          child: Row(
                                                            children: [
                                                              SvgPicture.asset(
                                                                "assets/icons/ic_star.svg",
                                                                colorFilter: ColorFilter.mode(
                                                                    AppThemeData
                                                                        .primary300,
                                                                    BlendMode
                                                                        .srcIn),
                                                              ),
                                                              const SizedBox(
                                                                width: 5,
                                                              ),
                                                              Text(
                                                                "${Constant.calculateReview(reviewCount: vendorModel.reviewsCount.toString(), reviewSum: vendorModel.reviewsSum.toString())} (${vendorModel.reviewsCount!.toStringAsFixed(0)})",
                                                                style: TextStyle(
                                                                    color: themeChange.getThem()
                                                                        ? AppThemeData
                                                                            .primary300
                                                                        : AppThemeData
                                                                            .primary300,
                                                                    fontFamily:
                                                                        AppThemeData
                                                                            .semiBold,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      Container(
                                                        decoration:
                                                            ShapeDecoration(
                                                          color: themeChange
                                                                  .getThem()
                                                              ? AppThemeData
                                                                  .secondary600
                                                              : AppThemeData
                                                                  .secondary50,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          120)),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      12,
                                                                  vertical: 8),
                                                          child: Row(
                                                            children: [
                                                              SvgPicture.asset(
                                                                "assets/icons/ic_map_distance.svg",
                                                                colorFilter: const ColorFilter
                                                                    .mode(
                                                                    AppThemeData
                                                                        .secondary300,
                                                                    BlendMode
                                                                        .srcIn),
                                                              ),
                                                              const SizedBox(
                                                                width: 5,
                                                              ),
                                                              Text(
                                                                "${Constant.getDistance(
                                                                  lat1: vendorModel
                                                                      .latitude
                                                                      .toString(),
                                                                  lng1: vendorModel
                                                                      .longitude
                                                                      .toString(),
                                                                  lat2: Constant
                                                                      .selectedLocation
                                                                      .location!
                                                                      .latitude
                                                                      .toString(),
                                                                  lng2: Constant
                                                                      .selectedLocation
                                                                      .location!
                                                                      .longitude
                                                                      .toString(),
                                                                )} ${Constant.distanceType}",
                                                                style: TextStyle(
                                                                    color: themeChange.getThem()
                                                                        ? AppThemeData
                                                                            .secondary300
                                                                        : AppThemeData
                                                                            .secondary300,
                                                                    fontFamily:
                                                                        AppThemeData
                                                                            .semiBold,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 15,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    vendorModel.title
                                                        .toString(),
                                                    textAlign: TextAlign.start,
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontFamily:
                                                          AppThemeData.semiBold,
                                                      color: themeChange
                                                              .getThem()
                                                          ? AppThemeData.grey50
                                                          : AppThemeData
                                                              .grey900,
                                                    ),
                                                  ),
                                                  Text(
                                                    vendorModel.location
                                                        .toString(),
                                                    textAlign: TextAlign.start,
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontFamily:
                                                          AppThemeData.medium,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: themeChange
                                                              .getThem()
                                                          ? AppThemeData.grey400
                                                          : AppThemeData
                                                              .grey400,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ],
        );
      },
    );
  }
}
