import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/app/dash_board_screens/dash_board_screen.dart';
import 'package:customer/app/location_permission_screen/location_permission_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/models/referral_model.dart';
import 'package:customer/models/user_model.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignupController extends GetxController {
  Rx<TextEditingController> firstNameEditingController = TextEditingController().obs;
  Rx<TextEditingController> lastNameEditingController = TextEditingController().obs;
  Rx<TextEditingController> emailEditingController = TextEditingController().obs;
  Rx<TextEditingController> phoneNUmberEditingController = TextEditingController().obs;
  Rx<TextEditingController> countryCodeEditingController = TextEditingController().obs;
  Rx<TextEditingController> passwordEditingController = TextEditingController().obs;
  Rx<TextEditingController> conformPasswordEditingController = TextEditingController().obs;
  Rx<TextEditingController> referralCodeEditingController = TextEditingController().obs;

  RxBool passwordVisible = true.obs;
  RxBool conformPasswordVisible = true.obs;

  RxString type = "".obs;

  Rx<UserModel> userModel = UserModel().obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getArgument();
    super.onInit();
  }

  getArgument() {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      type.value = argumentData['type'];
      userModel.value = argumentData['userModel'];
      if (type.value == "mobileNumber") {
        phoneNUmberEditingController.value.text = userModel.value.phoneNumber.toString();
        countryCodeEditingController.value.text = userModel.value.countryCode.toString();
      } else if (type.value == "google" || type.value == "apple") {
        emailEditingController.value.text = userModel.value.email ?? "";
        firstNameEditingController.value.text = userModel.value.firstName ?? "";
        lastNameEditingController.value.text = userModel.value.lastName ?? "";
      }
    }
  }

  signUpWithEmailAndPassword() async {
    if (referralCodeEditingController.value.text.toString().isNotEmpty) {
      await FireStoreUtils.checkReferralCodeValidOrNot(referralCodeEditingController.value.text.toString()).then((value) async {
        if (value == true) {
          signUp();
        } else {
          ShowToastDialog.showToast("Referral code is Invalid".tr);
        }
      });
    } else {
      signUp();
    }
  }

  signUp() async {
    ShowToastDialog.showLoader("Please wait".tr);
    if (type.value == "google" || type.value == "apple" || type.value == "mobileNumber") {
      userModel.value.firstName = firstNameEditingController.value.text.toString();
      userModel.value.lastName = lastNameEditingController.value.text.toString();
      userModel.value.email = emailEditingController.value.text.toString().toLowerCase();
      userModel.value.phoneNumber = phoneNUmberEditingController.value.text.toString();
      userModel.value.role = Constant.userRoleCustomer;
      userModel.value.fcmToken = await NotificationService.getToken();
      userModel.value.active = true;
      userModel.value.countryCode = countryCodeEditingController.value.text;
      userModel.value.createdAt = Timestamp.now();
      userModel.value.appIdentifier = Platform.isAndroid ? 'android' : 'ios';

      await FireStoreUtils.getReferralUserByCode(referralCodeEditingController.value.text).then((value) async {
        if (value != null) {
          ReferralModel ownReferralModel = ReferralModel(id: FireStoreUtils.getCurrentUid(), referralBy: value.id, referralCode: Constant.getReferralCode());
          await FireStoreUtils.referralAdd(ownReferralModel);
        } else {
          ReferralModel referralModel = ReferralModel(id: FireStoreUtils.getCurrentUid(), referralBy: "", referralCode: Constant.getReferralCode());
          await FireStoreUtils.referralAdd(referralModel);
        }
      });

      await FireStoreUtils.updateUser(userModel.value).then(
        (value) {
          if (userModel.value.shippingAddress != null && userModel.value.shippingAddress!.isNotEmpty) {
            if (userModel.value.shippingAddress!.where((element) => element.isDefault == true).isNotEmpty) {
              Constant.selectedLocation = userModel.value.shippingAddress!.where((element) => element.isDefault == true).single;
            } else {
              Constant.selectedLocation = userModel.value.shippingAddress!.first;
            }
            Get.offAll(const DashBoardScreen());
          } else {
            Get.offAll(const LocationPermissionScreen());
          }
          ShowToastDialog.showToast("Account create successfully".tr);
        },
      );
    } else {
      try {
        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailEditingController.value.text.trim(),
          password: passwordEditingController.value.text.trim(),
        );
        if (credential.user != null) {
          userModel.value.id = credential.user!.uid;
          userModel.value.firstName = firstNameEditingController.value.text.toString();
          userModel.value.lastName = lastNameEditingController.value.text.toString();
          userModel.value.email = emailEditingController.value.text.toString().toLowerCase();
          userModel.value.phoneNumber = phoneNUmberEditingController.value.text.toString();
          userModel.value.role = Constant.userRoleCustomer;
          userModel.value.fcmToken = await NotificationService.getToken();
          userModel.value.active = true;
          userModel.value.countryCode = countryCodeEditingController.value.text;
          userModel.value.createdAt = Timestamp.now();
          userModel.value.appIdentifier = Platform.isAndroid ? 'android' : 'ios';
          userModel.value.provider = 'email';

          await FireStoreUtils.getReferralUserByCode(referralCodeEditingController.value.text).then((value) async {
            if (value != null) {
              ReferralModel ownReferralModel = ReferralModel(id: FireStoreUtils.getCurrentUid(), referralBy: value.id, referralCode: Constant.getReferralCode());
              await FireStoreUtils.referralAdd(ownReferralModel);
            } else {
              ReferralModel referralModel = ReferralModel(id: FireStoreUtils.getCurrentUid(), referralBy: "", referralCode: Constant.getReferralCode());
              await FireStoreUtils.referralAdd(referralModel);
            }
          });

          await FireStoreUtils.updateUser(userModel.value).then(
            (value) async {
              if (userModel.value.shippingAddress != null && userModel.value.shippingAddress!.isNotEmpty) {
                if (userModel.value.shippingAddress!.where((element) => element.isDefault == true).isNotEmpty) {
                  Constant.selectedLocation = userModel.value.shippingAddress!.where((element) => element.isDefault == true).single;
                } else {
                  Constant.selectedLocation = userModel.value.shippingAddress!.first;
                }
                Get.offAll(const DashBoardScreen());
              } else {
                Get.offAll(const LocationPermissionScreen());
              }
            },
          );
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          ShowToastDialog.showToast("The password provided is too weak.".tr);
        } else if (e.code == 'email-already-in-use') {
          ShowToastDialog.showToast("The account already exists for that email.".tr);
        } else if (e.code == 'invalid-email') {
          ShowToastDialog.showToast("Enter email is Invalid".tr);
        }
      } catch (e) {
        ShowToastDialog.showToast(e.toString());
      }
    }

    ShowToastDialog.closeLoader();
  }
}
