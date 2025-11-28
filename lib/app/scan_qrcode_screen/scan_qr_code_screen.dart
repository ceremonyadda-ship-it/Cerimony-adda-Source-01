import 'package:customer/app/restaurant_details_screen/restaurant_details_screen.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controllers/scan_qr_code_controller.dart';
import 'package:customer/models/vendor_model.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
// import 'package:qr_code_dart_scan/qr_code_dart_scan.dart';

class ScanQrCodeScreen extends StatelessWidget {
  const ScanQrCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder(
      init: ScanQrCodeController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: false,
            titleSpacing: 0,
            backgroundColor: themeChange.getThem()
                ? AppThemeData.surfaceDark
                : AppThemeData.surface,
            title: Text(
              "Scan QRcode".tr,
              style: TextStyle(
                fontSize: 16,
                color: themeChange.getThem()
                    ? AppThemeData.grey50
                    : AppThemeData.grey900,
                fontFamily: AppThemeData.medium,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          body: MobileScanner(
            onDetect: (BarcodeCapture capture) {
              final List<Barcode> barcodes = capture.barcodes;

              // Get the first barcode (QR code)
              if (barcodes.isNotEmpty) {
                final String? code = barcodes.first.rawValue;

                if (code != null && code.isNotEmpty) {
                  Get.back();
                  ShowToastDialog.showLoader("Please wait".tr);

                  if (controller.allNearestRestaurant.isNotEmpty) {
                    bool found = false;
                    for (VendorModel storeModel
                        in controller.allNearestRestaurant) {
                      if (storeModel.id == code) {
                        found = true;
                        Get.back();
                        Get.to(const RestaurantDetailsScreen(),
                            arguments: {"vendorModel": storeModel});
                        break;
                      }
                    }

                    if (!found) {
                      Get.back();
                      ShowToastDialog.showToast("Store is not available".tr);
                    }
                  } else {
                    Get.back();
                    ShowToastDialog.showToast("Store is not available".tr);
                  }
                }
              }
            },
          ),

          // body: MobileScanner(
          //   // fit: BoxFit.contain,
          //   onDetect: (capture) async {
          //     final List<Barcode> barcodes = capture.barcodes;
          //     for (final barcode in barcodes) {
          //       Get.back();
          //       ShowToastDialog.showLoader("Please wait".tr);
          //       if (controller.allNearestRestaurant.isNotEmpty) {
          //         for (VendorModel storeModel in controller.allNearestRestaurant) {
          //           if (storeModel.id == barcode.rawValue) {
          //             Get.back();
          //             Get.to(const RestaurantDetailsScreen(), arguments: {"vendorModel": storeModel});
          //           }
          //         }
          //       } else {
          //         Get.back();
          //         ShowToastDialog.showToast("Store is not available");
          //       }
          //     }
          //   },
          // ),
        );
      },
    );
  }
}
