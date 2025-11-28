import 'dart:convert';
import 'dart:developer';

import 'package:crypto/crypto.dart';
import 'package:customer/app/auth_screen/signup_screen.dart';
import 'package:customer/app/dash_board_screens/dash_board_screen.dart';
import 'package:customer/app/location_permission_screen/location_permission_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/models/user_model.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginController extends GetxController {
  Rx<TextEditingController> emailEditingController = TextEditingController().obs;
  Rx<TextEditingController> passwordEditingController = TextEditingController().obs;

  RxBool passwordVisible = true.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  loginWithEmailAndPassword() async {
    ShowToastDialog.showLoader("Please wait".tr);
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailEditingController.value.text.trim(),
        password: passwordEditingController.value.text.trim(),
      );
      UserModel? userModel = await FireStoreUtils.getUserProfile(credential.user!.uid);
      log("Login :: ${userModel?.toJson()}");
      if (userModel?.role == Constant.userRoleCustomer) {
        if (userModel?.active == true) {
          userModel?.fcmToken = await NotificationService.getToken();
          await FireStoreUtils.updateUser(userModel!);
          if (userModel.shippingAddress != null && userModel.shippingAddress!.isNotEmpty) {
            if (userModel.shippingAddress!.where((element) => element.isDefault == true).isNotEmpty) {
              Constant.selectedLocation = userModel.shippingAddress!.where((element) => element.isDefault == true).single;
            } else {
              Constant.selectedLocation = userModel.shippingAddress!.first;
            }
            Get.offAll(const DashBoardScreen());
          } else {
            Get.offAll(const LocationPermissionScreen());
          }
        } else {
          await FirebaseAuth.instance.signOut();
          ShowToastDialog.showToast("This user is disable please contact to administrator".tr);
        }
      } else {
        await FirebaseAuth.instance.signOut();
        // ShowToastDialog.showToast("This user is disable please contact to administrator".tr);
      }
    } on FirebaseAuthException catch (e) {
      print(e.code);
      if (e.code == 'user-not-found') {
        ShowToastDialog.showToast("No user found for that email.".tr);
      } else if (e.code == 'wrong-password') {
        ShowToastDialog.showToast("Wrong password provided for that user.".tr);
      } else if (e.code == 'invalid-email') {
        ShowToastDialog.showToast("Invalid Email.");
      } else {
        ShowToastDialog.showToast("${e.message}");
      }
    }
    ShowToastDialog.closeLoader();
  }

  loginWithGoogle() async {
    ShowToastDialog.showLoader("please wait...".tr);
    await signInWithGoogle().then((value) async {
      ShowToastDialog.closeLoader();
      if (value != null) {
        if (value.additionalUserInfo!.isNewUser) {
          UserModel userModel = UserModel();
          userModel.id = value.user!.uid;
          userModel.email = value.user!.email;
          userModel.firstName = value.user!.displayName?.split(' ').first;
          userModel.lastName = value.user!.displayName?.split(' ').last;
          userModel.provider = 'google';

          ShowToastDialog.closeLoader();
          Get.off(const SignupScreen(), arguments: {
            "userModel": userModel,
            "type": "google",
          });
        } else {
          await FireStoreUtils.userExistOrNot(value.user!.uid).then((userExit) async {
            ShowToastDialog.closeLoader();
            if (userExit == true) {
              UserModel? userModel = await FireStoreUtils.getUserProfile(value.user!.uid);
              if (userModel!.role == Constant.userRoleCustomer) {
                if (userModel.active == true) {
                  userModel.fcmToken = await NotificationService.getToken();
                  await FireStoreUtils.updateUser(userModel);
                  if (userModel.shippingAddress != null && userModel.shippingAddress!.isNotEmpty) {
                    if (userModel.shippingAddress!.where((element) => element.isDefault == true).isNotEmpty) {
                      Constant.selectedLocation = userModel.shippingAddress!.where((element) => element.isDefault == true).single;
                    } else {
                      Constant.selectedLocation = userModel.shippingAddress!.first;
                    }
                    Get.offAll(const DashBoardScreen());
                  } else {
                    Get.offAll(const LocationPermissionScreen());
                  }
                } else {
                  await FirebaseAuth.instance.signOut();
                  ShowToastDialog.showToast("This user is disable please contact to administrator".tr);
                }
              } else {
                await FirebaseAuth.instance.signOut();
                // ShowToastDialog.showToast("This user is disable please contact to administrator".tr);
              }
            } else {
              UserModel userModel = UserModel();
              userModel.id = value.user!.uid;
              userModel.email = value.user!.email;
              userModel.firstName = value.user!.displayName?.split(' ').first;
              userModel.lastName = value.user!.displayName?.split(' ').last;
              userModel.provider = 'google';

              Get.off(const SignupScreen(), arguments: {
                "userModel": userModel,
                "type": "google",
              });
            }
          });
        }
      }
    });
  }

  loginWithApple() async {
    ShowToastDialog.showLoader("please wait...".tr);
    await signInWithApple().then((value) async {
      ShowToastDialog.closeLoader();
      if (value != null) {
        Map<String, dynamic> map = value;
        AuthorizationCredentialAppleID appleCredential = map['appleCredential'];
        UserCredential userCredential = map['userCredential'];
        if (userCredential.additionalUserInfo!.isNewUser) {
          UserModel userModel = UserModel();
          userModel.id = userCredential.user!.uid;
          userModel.email = appleCredential.email;
          userModel.firstName = appleCredential.givenName;
          userModel.lastName = appleCredential.familyName;
          userModel.provider = 'apple';

          ShowToastDialog.closeLoader();
          Get.off(const SignupScreen(), arguments: {
            "userModel": userModel,
            "type": "apple",
          });
        } else {
          await FireStoreUtils.userExistOrNot(userCredential.user!.uid).then((userExit) async {
            ShowToastDialog.closeLoader();
            if (userExit == true) {
              UserModel? userModel = await FireStoreUtils.getUserProfile(userCredential.user!.uid);
              if (userModel!.role == Constant.userRoleCustomer) {
                if (userModel.active == true) {
                  userModel.fcmToken = await NotificationService.getToken();
                  await FireStoreUtils.updateUser(userModel);
                  if (userModel.shippingAddress != null && userModel.shippingAddress!.isNotEmpty) {
                    if (userModel.shippingAddress!.where((element) => element.isDefault == true).isNotEmpty) {
                      Constant.selectedLocation = userModel.shippingAddress!.where((element) => element.isDefault == true).single;
                    } else {
                      Constant.selectedLocation = userModel.shippingAddress!.first;
                    }
                    Get.offAll(const DashBoardScreen());
                  } else {
                    Get.offAll(const LocationPermissionScreen());
                  }
                } else {
                  await FirebaseAuth.instance.signOut();
                  ShowToastDialog.showToast("This user is disable please contact to administrator".tr);
                }
              } else {
                await FirebaseAuth.instance.signOut();
                // ShowToastDialog.showToast("This user is disable please contact to administrator".tr);
              }
            } else {
              UserModel userModel = UserModel();
              userModel.id = userCredential.user!.uid;
              userModel.email = appleCredential.email;
              userModel.firstName = appleCredential.givenName;
              userModel.lastName = appleCredential.familyName;
              userModel.provider = 'apple';

              Get.off(const SignupScreen(), arguments: {
                "userModel": userModel,
                "type": "apple",
              });
            }
          });
        }
      }
    });
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn().catchError((error) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("something_went_wrong".tr);
        return null;
      });

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.idToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
    // Trigger the authentication flow
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<Map<String, dynamic>?> signInWithApple() async {
    try {
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      // Request credential for the currently signed in Apple account.
      AuthorizationCredentialAppleID appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
        // webAuthenticationOptions: WebAuthenticationOptions(clientId: clientID, redirectUri: Uri.parse(redirectURL)),
      );

      // Create an `OAuthCredential` from the credential returned by Apple.
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in the user with Firebase. If the nonce we generated earlier does
      // not match the nonce in `appleCredential.identityToken`, sign in will fail.
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      return {"appleCredential": appleCredential, "userCredential": userCredential};
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }
}
