import 'package:customer/app/address_screens/address_list_screen.dart';
import 'package:customer/app/dash_board_screens/dash_board_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controllers/location_permission_controller.dart';
import 'package:customer/models/user_model.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/themes/round_button_fill.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/widget/osm_map/map_picker_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:provider/provider.dart';

class LocationPermissionScreen extends StatelessWidget {
  const LocationPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder(
      init: LocationPermissionController(),
      builder: (controller) {
        return Scaffold(
          body: Container(
            height: Responsive.height(100, context),
            width: Responsive.width(100, context),
            decoration: const BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/location_bg.png"), fit: BoxFit.cover)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 35),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Enable Location Services 📍".tr,
                    style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey900, fontSize: 22, fontFamily: AppThemeData.semiBold),
                  ),
                  Text(
                    "To provide the best dining experience, allow Foodie to access your location.".tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey900, fontSize: 16, fontFamily: AppThemeData.bold),
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  RoundedButtonFill(
                    title: "Use Current Location".tr,
                    color: AppThemeData.primary300,
                    textColor: AppThemeData.grey50,
                    onPress: () async {
                      Constant.checkPermission(
                        context: context,
                        onTap: () async {
                          ShowToastDialog.showLoader("Please wait".tr);
                          ShippingAddress addressModel = ShippingAddress();
                          try {
                            await Geolocator.requestPermission();
                            Position newLocalData = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

                            await placemarkFromCoordinates(newLocalData.latitude, newLocalData.longitude).then((valuePlaceMaker) {
                              Placemark placeMark = valuePlaceMaker[0];
                              addressModel.addressAs = "Home";
                              addressModel.location = UserLocation(latitude: newLocalData.latitude, longitude: newLocalData.longitude);
                              String currentLocation =
                                  "${placeMark.name}, ${placeMark.subLocality}, ${placeMark.locality}, ${placeMark.administrativeArea}, ${placeMark.postalCode}, ${placeMark.country}";
                              addressModel.locality = currentLocation;
                            });

                            Constant.selectedLocation = addressModel;
                            ShowToastDialog.closeLoader();

                            Get.offAll(const DashBoardScreen());
                          } catch (e) {
                            await placemarkFromCoordinates(19.228825, 72.854118).then((valuePlaceMaker) {
                              Placemark placeMark = valuePlaceMaker[0];
                              addressModel.addressAs = "Home";
                              addressModel.location = UserLocation(latitude: 19.228825, longitude: 72.854118);
                              String currentLocation =
                                  "${placeMark.name}, ${placeMark.subLocality}, ${placeMark.locality}, ${placeMark.administrativeArea}, ${placeMark.postalCode}, ${placeMark.country}";
                              addressModel.locality = currentLocation;
                            });

                            Constant.selectedLocation = addressModel;
                            ShowToastDialog.closeLoader();

                            Get.offAll(const DashBoardScreen());
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  RoundedButtonFill(
                    title: "Set From Map".tr,
                    color: AppThemeData.primary300,
                    textColor: AppThemeData.grey50,
                    icon: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: SvgPicture.asset(
                        "assets/icons/ic_location_pin.svg",
                        colorFilter: const ColorFilter.mode(AppThemeData.grey50, BlendMode.srcIn),
                      ),
                    ),
                    isRight: false,
                    onPress: () async {
                      Constant.checkPermission(
                        context: context,
                        onTap: () async {
                          ShowToastDialog.showLoader("Please wait".tr);
                          ShippingAddress addressModel = ShippingAddress();
                          try {
                            await Geolocator.requestPermission();
                            await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
                            ShowToastDialog.closeLoader();
                            if (Constant.selectedMapType == 'osm') {
                              final result = await Get.to(() => MapPickerPage());
                              if (result != null) {
                                final firstPlace = result;
                                final lat = firstPlace.coordinates.latitude;
                                final lng = firstPlace.coordinates.longitude;
                                final address = firstPlace.address;

                                addressModel.addressAs = "Home";
                                addressModel.locality = address.toString();
                                addressModel.location = UserLocation(latitude: lat, longitude: lng);
                                Constant.selectedLocation = addressModel;
                                Get.offAll(const DashBoardScreen());
                              }
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlacePicker(
                                    apiKey: Constant.mapAPIKey,
                                    onPlacePicked: (result) {
                                      addressModel.addressAs = "Home";
                                      addressModel.locality = result.formattedAddress!.toString();
                                      addressModel.location = UserLocation(latitude: result.geometry!.location.lat, longitude: result.geometry!.location.lng);
                                      Constant.selectedLocation = addressModel;

                                      Get.offAll(const DashBoardScreen());
                                    },
                                    initialPosition: const LatLng(-33.8567844, 151.213108),
                                    useCurrentLocation: true,
                                    selectInitialPosition: true,
                                    usePinPointingSearch: true,
                                    usePlaceDetailSearch: true,
                                    zoomGesturesEnabled: true,
                                    zoomControlsEnabled: true,
                                    resizeToAvoidBottomInset: false, // only works in page mode, less flickery, remove if wrong offsets
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            await placemarkFromCoordinates(19.228825, 72.854118).then((valuePlaceMaker) {
                              Placemark placeMark = valuePlaceMaker[0];
                              addressModel.addressAs = "Home";
                              addressModel.location = UserLocation(latitude: 19.228825, longitude: 72.854118);
                              String currentLocation =
                                  "${placeMark.name}, ${placeMark.subLocality}, ${placeMark.locality}, ${placeMark.administrativeArea}, ${placeMark.postalCode}, ${placeMark.country}";
                              addressModel.locality = currentLocation;
                            });

                            Constant.selectedLocation = addressModel;
                            ShowToastDialog.closeLoader();

                            Get.offAll(const DashBoardScreen());
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Constant.userModel == null
                      ? const SizedBox()
                      : RoundedButtonFill(
                          title: "Enter Manually location".tr,
                          color: AppThemeData.primary300,
                          textColor: AppThemeData.grey50,
                          isRight: false,
                          onPress: () async {
                            Get.to(const AddressListScreen())!.then(
                              (value) {
                                if (value != null) {
                                  ShippingAddress addressModel = value;
                                  Constant.selectedLocation = addressModel;
                                  Get.offAll(const DashBoardScreen());
                                }
                              },
                            );
                          },
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
