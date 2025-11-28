import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/app/chat_screens/ChatVideoContainer.dart';
import 'package:customer/constant/collection_name.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controllers/gift_cards_model.dart';
import 'package:customer/models/AttributesModel.dart';
import 'package:customer/models/BannerModel.dart';
import 'package:customer/models/admin_commission.dart';
import 'package:customer/models/advertisement_model.dart';
import 'package:customer/models/conversation_model.dart';
import 'package:customer/models/coupon_model.dart';
import 'package:customer/models/dine_in_booking_model.dart';
import 'package:customer/models/email_template_model.dart';
import 'package:customer/models/favourite_item_model.dart';
import 'package:customer/models/favourite_model.dart';
import 'package:customer/models/gift_cards_order_model.dart';
import 'package:customer/models/inbox_model.dart';
import 'package:customer/models/mail_setting.dart';
import 'package:customer/models/notification_model.dart';
import 'package:customer/models/on_boarding_model.dart';
import 'package:customer/models/order_model.dart';
import 'package:customer/models/payment_model/cod_setting_model.dart';
import 'package:customer/models/payment_model/flutter_wave_model.dart';
import 'package:customer/models/payment_model/mercado_pago_model.dart';
import 'package:customer/models/payment_model/mid_trans.dart';
import 'package:customer/models/payment_model/orange_money.dart';
import 'package:customer/models/payment_model/pay_fast_model.dart';
import 'package:customer/models/payment_model/pay_stack_model.dart';
import 'package:customer/models/payment_model/paypal_model.dart';
import 'package:customer/models/payment_model/paytm_model.dart';
import 'package:customer/models/payment_model/razorpay_model.dart';
import 'package:customer/models/payment_model/stripe_model.dart';
import 'package:customer/models/payment_model/wallet_setting_model.dart';
import 'package:customer/models/payment_model/xendit.dart';
import 'package:customer/models/product_model.dart';
import 'package:customer/models/rating_model.dart';
import 'package:customer/models/referral_model.dart';
import 'package:customer/models/review_attribute_model.dart';
import 'package:customer/models/story_model.dart';
import 'package:customer/models/tax_model.dart';
import 'package:customer/models/user_model.dart';
import 'package:customer/models/vendor_category_model.dart';
import 'package:customer/models/vendor_model.dart';
import 'package:customer/models/wallet_transaction_model.dart';
import 'package:customer/models/zone_model.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/utils/preferences.dart';
import 'package:customer/widget/geoflutterfire/src/geoflutterfire.dart';
import 'package:customer/widget/geoflutterfire/src/models/point.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
// import 'package:video_compress/video_compress.dart';

class FireStoreUtils {
  static FirebaseFirestore fireStore = FirebaseFirestore.instance;

  static String getCurrentUid() {
    return FirebaseAuth.instance.currentUser!.uid;
  }

  static Future<bool> isLogin() async {
    bool isLogin = false;
    if (FirebaseAuth.instance.currentUser != null) {
      isLogin = await userExistOrNot(FirebaseAuth.instance.currentUser!.uid);
    } else {
      isLogin = false;
    }
    return isLogin;
  }

  static Future<bool> userExistOrNot(String uid) async {
    bool isExist = false;

    await fireStore.collection(CollectionName.users).doc(uid).get().then(
      (value) {
        if (value.exists) {
          isExist = true;
        } else {
          isExist = false;
        }
      },
    ).catchError((error) {
      log("Failed to check user exist: $error");
      isExist = false;
    });
    return isExist;
  }

  static Future<UserModel?> getUserProfile(String uuid) async {
    UserModel? userModel;
    await fireStore
        .collection(CollectionName.users)
        .doc(uuid)
        .get()
        .then((value) {
      if (value.exists) {
        userModel = UserModel.fromJson(value.data()!);
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      userModel = null;
    });
    return userModel;
  }

  static Future<bool?> updateUserWallet(
      {required String amount, required String userId}) async {
    bool isAdded = false;
    await getUserProfile(userId).then((value) async {
      if (value != null) {
        UserModel userModel = value;
        userModel.walletAmount =
            (double.parse(userModel.walletAmount.toString()) +
                double.parse(amount));
        await FireStoreUtils.updateUser(userModel).then((value) {
          isAdded = value;
        });
      }
    });
    return isAdded;
  }

  static Future<bool> updateUser(UserModel userModel) async {
    bool isUpdate = false;
    await fireStore
        .collection(CollectionName.users)
        .doc(userModel.id)
        .set(userModel.toJson())
        .whenComplete(() {
      Constant.userModel = userModel;
      isUpdate = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isUpdate = false;
    });
    return isUpdate;
  }

  static Future<List<OnBoardingModel>> getOnBoardingList() async {
    List<OnBoardingModel> onBoardingModel = [];
    await fireStore
        .collection(CollectionName.onBoarding)
        .where("type", isEqualTo: "customerApp")
        .get()
        .then((value) {
      for (var element in value.docs) {
        OnBoardingModel documentModel =
            OnBoardingModel.fromJson(element.data());
        onBoardingModel.add(documentModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return onBoardingModel;
  }

  static Future<List<VendorModel>> getVendors() async {
    List<VendorModel> giftCardModelList = [];
    QuerySnapshot<Map<String, dynamic>> currencyQuery = await fireStore
        .collection(CollectionName.vendors)
        .where("zoneId", isEqualTo: Constant.selectedZone!.id.toString())
        .get();
    await Future.forEach(currencyQuery.docs,
        (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        log(document.data().toString());
        giftCardModelList.add(VendorModel.fromJson(document.data()));
      } catch (e) {
        debugPrint('FireStoreUtils.get Currency Parse error $e');
      }
    });
    return giftCardModelList;
  }

  static Future<bool?> setWalletTransaction(
      WalletTransactionModel walletTransactionModel) async {
    bool isAdded = false;
    await fireStore
        .collection(CollectionName.wallet)
        .doc(walletTransactionModel.id)
        .set(walletTransactionModel.toJson())
        .then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  getSettings() async {
    try {
      FirebaseFirestore.instance
          .collection(CollectionName.settings)
          .doc('restaurant')
          .get()
          .then((value) {
        Constant.isSubscriptionModelApplied =
            value.data()!['subscription_model'];
      });

      fireStore
          .collection(CollectionName.settings)
          .doc("RestaurantNearBy")
          .snapshots()
          .listen((event) {
        if (event.exists) {
          Constant.radius = event.data()!["radios"];
          Constant.driverRadios = event.data()!["driverRadios"];
          Constant.distanceType = event.data()!["distanceType"];
        }
      });

      await FirebaseFirestore.instance
          .collection(CollectionName.settings)
          .doc("globalSettings")
          .get()
          .then((value) {
        Constant.isEnableAdsFeature =
            value.data()?['isEnableAdsFeature'] ?? false;
        Constant.isSelfDeliveryFeature =
            value.data()!['isSelfDelivery'] ?? false;
        AppThemeData.primary300 = Color(int.parse(
            value.data()!['app_customer_color'].replaceFirst("#", "0xff")));
      });

      fireStore
          .collection(CollectionName.settings)
          .doc("googleMapKey")
          .snapshots()
          .listen((event) {
        if (event.exists) {
          Constant.mapAPIKey = event.data()!["key"];
          Constant.placeHolderImage = event.data()!["placeHolderImage"];
        }
      });

      fireStore
          .collection(CollectionName.settings)
          .doc("home_page_theme")
          .snapshots()
          .listen((event) {
        if (event.exists) {
          Constant.theme = event.data()!["theme"];
        }
      });

      fireStore
          .collection(CollectionName.settings)
          .doc("notification_setting")
          .get()
          .then((event) {
        if (event.exists) {
          Constant.senderId = event.data()?["projectId"];
          Constant.jsonNotificationFileURL = event.data()?["serviceJson"];
        }
      });

      fireStore
          .collection(CollectionName.settings)
          .doc("DriverNearBy")
          .get()
          .then((event) {
        if (event.exists) {
          Constant.selectedMapType = event.data()!["selectedMapType"];
          Constant.mapType = event.data()!["mapType"];
        }
      });

      fireStore
          .collection(CollectionName.settings)
          .doc("privacyPolicy")
          .snapshots()
          .listen((event) {
        if (event.exists) {
          Constant.privacyPolicy = event.data()!["privacy_policy"];
        }
      });

      fireStore
          .collection(CollectionName.settings)
          .doc("termsAndConditions")
          .snapshots()
          .listen((event) {
        if (event.exists) {
          Constant.termsAndConditions = event.data()!["termsAndConditions"];
        }
      });

      fireStore
          .collection(CollectionName.settings)
          .doc("walletSettings")
          .snapshots()
          .listen((event) {
        if (event.exists) {
          Constant.walletSetting = event.data()!["isEnabled"];
        }
      });

      fireStore
          .collection(CollectionName.settings)
          .doc("Version")
          .snapshots()
          .listen((event) {
        if (event.exists) {
          Constant.googlePlayLink = event.data()!["googlePlayLink"] ?? '';
          Constant.appStoreLink = event.data()!["appStoreLink"] ?? '';
          Constant.appVersion = event.data()!["app_version"] ?? '';
          Constant.websiteUrl = event.data()!["websiteUrl"] ?? '';
        }
      });

      fireStore
          .collection(CollectionName.settings)
          .doc('story')
          .get()
          .then((value) {
        Constant.storyEnable = value.data()!['isEnabled'];
      });

      fireStore
          .collection(CollectionName.settings)
          .doc('referral_amount')
          .get()
          .then((value) {
        Constant.referralAmount = value.data()!['referralAmount'];
      });

      fireStore
          .collection(CollectionName.settings)
          .doc('placeHolderImage')
          .get()
          .then((value) {
        Constant.placeholderImage = value.data()!['image'];
      });

      fireStore
          .collection(CollectionName.settings)
          .doc("emailSetting")
          .get()
          .then((value) {
        if (value.exists) {
          Constant.mailSettings = MailSettings.fromJson(value.data()!);
        }
      });

      fireStore
          .collection(CollectionName.settings)
          .doc("specialDiscountOffer")
          .get()
          .then((dineinresult) {
        if (dineinresult.exists) {
          Constant.specialDiscountOffer = dineinresult.data()!["isEnable"];
        }
      });

      await FirebaseFirestore.instance
          .collection(CollectionName.settings)
          .doc("DineinForRestaurant")
          .get()
          .then((value) {
        Constant.isEnabledForCustomer = value['isEnabledForCustomer'] ?? false;
      });

      await fireStore
          .collection(CollectionName.settings)
          .doc("AdminCommission")
          .get()
          .then((value) {
        if (value.data() != null) {
          Constant.adminCommission = AdminCommission.fromJson(value.data()!);
        }
      });
    } catch (e) {
      log(e.toString());
    }
  }

  static Future<bool?> checkReferralCodeValidOrNot(String referralCode) async {
    bool? isExit;
    try {
      await fireStore
          .collection(CollectionName.referral)
          .where("referralCode", isEqualTo: referralCode)
          .get()
          .then((value) {
        if (value.size > 0) {
          isExit = true;
        } else {
          isExit = false;
        }
      });
    } catch (e, s) {
      print('FireStoreUtils.firebaseCreateNewUser $e $s');
      return false;
    }
    return isExit;
  }

  static Future<ReferralModel?> getReferralUserByCode(
      String referralCode) async {
    ReferralModel? referralModel;
    try {
      await fireStore
          .collection(CollectionName.referral)
          .where("referralCode", isEqualTo: referralCode)
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          referralModel = ReferralModel.fromJson(value.docs.first.data());
        }
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return referralModel;
  }

  static Future<String?> referralAdd(ReferralModel ratingModel) async {
    try {
      await fireStore
          .collection(CollectionName.referral)
          .doc(ratingModel.id)
          .set(ratingModel.toJson());
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return null;
  }

  static Future<List<ZoneModel>?> getZone() async {
    List<ZoneModel> airPortList = [];
    await fireStore
        .collection(CollectionName.zone)
        .where('publish', isEqualTo: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        ZoneModel ariPortModel = ZoneModel.fromJson(element.data());
        airPortList.add(ariPortModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return airPortList;
  }

  static Future<List<WalletTransactionModel>?> getWalletTransaction() async {
    List<WalletTransactionModel> walletTransactionList = [];
    log("FireStoreUtils.getCurrentUid() :: ${FireStoreUtils.getCurrentUid()}");
    await fireStore
        .collection(CollectionName.wallet)
        .where('user_id', isEqualTo: FireStoreUtils.getCurrentUid())
        .orderBy('date', descending: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        WalletTransactionModel walletTransactionModel =
            WalletTransactionModel.fromJson(element.data());
        walletTransactionList.add(walletTransactionModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return walletTransactionList;
  }

  static Future getPaymentSettingsData() async {
    await fireStore
        .collection(CollectionName.settings)
        .doc("payFastSettings")
        .get()
        .then((value) async {
      if (value.exists) {
        PayFastModel payFastModel = PayFastModel.fromJson(value.data()!);
        await Preferences.setString(
            Preferences.payFastSettings, jsonEncode(payFastModel.toJson()));
      }
    });
    await fireStore
        .collection(CollectionName.settings)
        .doc("MercadoPago")
        .get()
        .then((value) async {
      if (value.exists) {
        MercadoPagoModel mercadoPagoModel =
            MercadoPagoModel.fromJson(value.data()!);
        await Preferences.setString(
            Preferences.mercadoPago, jsonEncode(mercadoPagoModel.toJson()));
      }
    });
    await fireStore
        .collection(CollectionName.settings)
        .doc("paypalSettings")
        .get()
        .then((value) async {
      if (value.exists) {
        PayPalModel payPalModel = PayPalModel.fromJson(value.data()!);
        await Preferences.setString(
            Preferences.paypalSettings, jsonEncode(payPalModel.toJson()));
      }
    });
    await fireStore
        .collection(CollectionName.settings)
        .doc("stripeSettings")
        .get()
        .then((value) async {
      if (value.exists) {
        StripeModel stripeModel = StripeModel.fromJson(value.data()!);
        await Preferences.setString(
            Preferences.stripeSettings, jsonEncode(stripeModel.toJson()));
      }
    });
    await fireStore
        .collection(CollectionName.settings)
        .doc("flutterWave")
        .get()
        .then((value) async {
      if (value.exists) {
        FlutterWaveModel flutterWaveModel =
            FlutterWaveModel.fromJson(value.data()!);
        await Preferences.setString(
            Preferences.flutterWave, jsonEncode(flutterWaveModel.toJson()));
      }
    });
    await fireStore
        .collection(CollectionName.settings)
        .doc("payStack")
        .get()
        .then((value) async {
      if (value.exists) {
        PayStackModel payStackModel = PayStackModel.fromJson(value.data()!);
        await Preferences.setString(
            Preferences.payStack, jsonEncode(payStackModel.toJson()));
      }
    });
    await fireStore
        .collection(CollectionName.settings)
        .doc("PaytmSettings")
        .get()
        .then((value) async {
      if (value.exists) {
        PaytmModel paytmModel = PaytmModel.fromJson(value.data()!);
        await Preferences.setString(
            Preferences.paytmSettings, jsonEncode(paytmModel.toJson()));
      }
    });
    await fireStore
        .collection(CollectionName.settings)
        .doc("walletSettings")
        .get()
        .then((value) async {
      if (value.exists) {
        WalletSettingModel walletSettingModel =
            WalletSettingModel.fromJson(value.data()!);
        await Preferences.setString(Preferences.walletSettings,
            jsonEncode(walletSettingModel.toJson()));
      }
    });
    await fireStore
        .collection(CollectionName.settings)
        .doc("razorpaySettings")
        .get()
        .then((value) async {
      if (value.exists) {
        RazorPayModel razorPayModel = RazorPayModel.fromJson(value.data()!);
        await Preferences.setString(
            Preferences.razorpaySettings, jsonEncode(razorPayModel.toJson()));
      }
    });
    await fireStore
        .collection(CollectionName.settings)
        .doc("CODSettings")
        .get()
        .then((value) async {
      if (value.exists) {
        CodSettingModel codSettingModel =
            CodSettingModel.fromJson(value.data()!);
        await Preferences.setString(
            Preferences.codSettings, jsonEncode(codSettingModel.toJson()));
      }
    });

    await fireStore
        .collection(CollectionName.settings)
        .doc("midtrans_settings")
        .get()
        .then((value) async {
      if (value.exists) {
        MidTrans midTrans = MidTrans.fromJson(value.data()!);
        await Preferences.setString(
            Preferences.midTransSettings, jsonEncode(midTrans.toJson()));
      }
    });

    await fireStore
        .collection(CollectionName.settings)
        .doc("orange_money_settings")
        .get()
        .then((value) async {
      if (value.exists) {
        OrangeMoney orangeMoney = OrangeMoney.fromJson(value.data()!);
        await Preferences.setString(
            Preferences.orangeMoneySettings, jsonEncode(orangeMoney.toJson()));
      }
    });

    await fireStore
        .collection(CollectionName.settings)
        .doc("xendit_settings")
        .get()
        .then((value) async {
      if (value.exists) {
        Xendit xendit = Xendit.fromJson(value.data()!);
        await Preferences.setString(
            Preferences.xenditSettings, jsonEncode(xendit.toJson()));
      }
    });
  }

  static Future<VendorModel?> getVendorById(String vendorId) async {
    VendorModel? vendorModel;
    try {
      await fireStore
          .collection(CollectionName.vendors)
          .doc(vendorId)
          .get()
          .then((value) {
        if (value.exists) {
          vendorModel = VendorModel.fromJson(value.data()!);
        }
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return vendorModel;
  }

  static StreamController<List<VendorModel>>? getNearestVendorController;

  static Stream<List<VendorModel>> getAllNearestRestaurant(
      {bool? isDining}) async* {
    try {
      getNearestVendorController =
          StreamController<List<VendorModel>>.broadcast();
      List<VendorModel> vendorList = [];
      Query<Map<String, dynamic>> query = isDining == true
          ? fireStore
              .collection(CollectionName.vendors)
              .where('zoneId', isEqualTo: Constant.selectedZone!.id.toString())
              .where("enabledDiveInFuture", isEqualTo: true)
          : fireStore
              .collection(CollectionName.vendors)
              .where('zoneId', isEqualTo: Constant.selectedZone!.id.toString());

      GeoFirePoint center = Geoflutterfire().point(
          latitude: Constant.selectedLocation.location!.latitude ?? 0.0,
          longitude: Constant.selectedLocation.location!.longitude ?? 0.0);
      String field = 'g';

      Stream<List<DocumentSnapshot>> stream = Geoflutterfire()
          .collection(collectionRef: query)
          .within(
              center: center,
              radius: double.parse(Constant.radius),
              field: field,
              strictMode: true);

      stream.listen((List<DocumentSnapshot> documentList) async {
        vendorList.clear();
        for (var document in documentList) {
          final data = document.data() as Map<String, dynamic>;
          VendorModel vendorModel = VendorModel.fromJson(data);
          if ((Constant.isSubscriptionModelApplied == true ||
                  Constant.adminCommission?.isEnabled == true) &&
              vendorModel.subscriptionPlan != null) {
            if (vendorModel.subscriptionTotalOrders == "-1") {
              vendorList.add(vendorModel);
            } else {
              if ((vendorModel.subscriptionExpiryDate != null &&
                      vendorModel.subscriptionExpiryDate!
                              .toDate()
                              .isBefore(DateTime.now()) ==
                          false) ||
                  vendorModel.subscriptionPlan?.expiryDay == "-1") {
                if (vendorModel.subscriptionTotalOrders != '0') {
                  vendorList.add(vendorModel);
                }
              }
            }
          } else {
            vendorList.add(vendorModel);
          }
        }
        getNearestVendorController!.sink.add(vendorList);
      });

      yield* getNearestVendorController!.stream;
    } catch (e) {
      print(e);
    }
  }

  static StreamController<List<VendorModel>>?
      getNearestVendorByCategoryController;

  static Stream<List<VendorModel>> getAllNearestRestaurantByCategoryId(
      {bool? isDining, required String categoryId}) async* {
    try {
      getNearestVendorByCategoryController =
          StreamController<List<VendorModel>>.broadcast();
      List<VendorModel> vendorList = [];
      Query<Map<String, dynamic>> query = isDining == true
          ? fireStore
              .collection(CollectionName.vendors)
              .where('zoneId', isEqualTo: Constant.selectedZone!.id.toString())
              .where('categoryID', arrayContains: categoryId)
              .where("enabledDiveInFuture", isEqualTo: true)
          : fireStore
              .collection(CollectionName.vendors)
              .where('zoneId', isEqualTo: Constant.selectedZone!.id.toString())
              .where('categoryID', arrayContains: categoryId);

      GeoFirePoint center = Geoflutterfire().point(
          latitude: Constant.selectedLocation.location!.latitude ?? 0.0,
          longitude: Constant.selectedLocation.location!.longitude ?? 0.0);
      String field = 'g';

      Stream<List<DocumentSnapshot>> stream = Geoflutterfire()
          .collection(collectionRef: query)
          .within(
              center: center,
              radius: double.parse(Constant.radius),
              field: field,
              strictMode: true);

      stream.listen((List<DocumentSnapshot> documentList) async {
        vendorList.clear();
        for (var document in documentList) {
          final data = document.data() as Map<String, dynamic>;
          VendorModel vendorModel = VendorModel.fromJson(data);
          if ((Constant.isSubscriptionModelApplied == true ||
                  Constant.adminCommission?.isEnabled == true) &&
              vendorModel.subscriptionPlan != null) {
            if (vendorModel.subscriptionTotalOrders == "-1") {
              vendorList.add(vendorModel);
            } else {
              if ((vendorModel.subscriptionExpiryDate != null &&
                      vendorModel.subscriptionExpiryDate!
                              .toDate()
                              .isBefore(DateTime.now()) ==
                          false) ||
                  vendorModel.subscriptionPlan?.expiryDay == '-1') {
                if (vendorModel.subscriptionTotalOrders != '0') {
                  vendorList.add(vendorModel);
                }
              }
            }
          } else {
            vendorList.add(vendorModel);
          }
        }
        getNearestVendorByCategoryController!.sink.add(vendorList);
      });

      yield* getNearestVendorByCategoryController!.stream;
    } catch (e) {
      print(e);
    }
  }

  static Future<List<StoryModel>> getStory() async {
    List<StoryModel> storyList = [];
    await fireStore.collection(CollectionName.story).get().then((value) {
      for (var element in value.docs) {
        StoryModel walletTransactionModel = StoryModel.fromJson(element.data());
        storyList.add(walletTransactionModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return storyList;
  }

  static Future<List<CouponModel>> getHomeCoupon() async {
    List<CouponModel> list = [];
    await fireStore
        .collection(CollectionName.coupons)
        .where('expiresAt', isGreaterThanOrEqualTo: Timestamp.now())
        .where("isEnabled", isEqualTo: true)
        .where("isPublic", isEqualTo: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        CouponModel walletTransactionModel =
            CouponModel.fromJson(element.data());
        list.add(walletTransactionModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return list;
  }

  static Future<List<VendorCategoryModel>> getHomeVendorCategory() async {
    List<VendorCategoryModel> list = [];
    await fireStore
        .collection(CollectionName.vendorCategories)
        .where("show_in_homepage", isEqualTo: true)
        .where('publish', isEqualTo: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        VendorCategoryModel walletTransactionModel =
            VendorCategoryModel.fromJson(element.data());
        list.add(walletTransactionModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return list;
  }

  static Future<List<VendorCategoryModel>> getVendorCategory() async {
    List<VendorCategoryModel> list = [];
    await fireStore
        .collection(CollectionName.vendorCategories)
        .where('publish', isEqualTo: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        VendorCategoryModel walletTransactionModel =
            VendorCategoryModel.fromJson(element.data());
        list.add(walletTransactionModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return list;
  }

  static Future<List<BannerModel>> getHomeTopBanner() async {
    List<BannerModel> bannerList = [];
    await fireStore
        .collection(CollectionName.menuItems)
        .where("is_publish", isEqualTo: true)
        .where("position", isEqualTo: "top")
        .orderBy("set_order", descending: false)
        .get()
        .then(
      (value) {
        for (var element in value.docs) {
          BannerModel bannerHome = BannerModel.fromJson(element.data());
          bannerList.add(bannerHome);
        }
      },
    );
    return bannerList;
  }

  static Future<List<BannerModel>> getHomeBottomBanner() async {
    List<BannerModel> bannerList = [];
    await fireStore
        .collection(CollectionName.menuItems)
        .where("is_publish", isEqualTo: true)
        .where("position", isEqualTo: "middle")
        .orderBy("set_order", descending: false)
        .get()
        .then(
      (value) {
        for (var element in value.docs) {
          BannerModel bannerHome = BannerModel.fromJson(element.data());
          bannerList.add(bannerHome);
        }
      },
    );
    return bannerList;
  }

  static Future<List<FavouriteModel>> getFavouriteRestaurant() async {
    List<FavouriteModel> favouriteList = [];
    await fireStore
        .collection(CollectionName.favoriteRestaurant)
        .where('user_id', isEqualTo: getCurrentUid())
        .get()
        .then(
      (value) {
        for (var element in value.docs) {
          FavouriteModel favouriteModel =
              FavouriteModel.fromJson(element.data());
          favouriteList.add(favouriteModel);
        }
      },
    );
    return favouriteList;
  }

  static Future<List<FavouriteItemModel>> getFavouriteItem() async {
    List<FavouriteItemModel> favouriteList = [];
    await fireStore
        .collection(CollectionName.favoriteItem)
        .where('user_id', isEqualTo: getCurrentUid())
        .get()
        .then(
      (value) {
        for (var element in value.docs) {
          FavouriteItemModel favouriteModel =
              FavouriteItemModel.fromJson(element.data());
          favouriteList.add(favouriteModel);
        }
      },
    );
    return favouriteList;
  }

  static Future removeFavouriteRestaurant(FavouriteModel favouriteModel) async {
    await fireStore
        .collection(CollectionName.favoriteRestaurant)
        .where("restaurant_id", isEqualTo: favouriteModel.restaurantId)
        .get()
        .then((value) {
      value.docs.forEach((element) async {
        await fireStore
            .collection(CollectionName.favoriteRestaurant)
            .doc(element.id)
            .delete();
      });
    });
  }

  static Future<void> setFavouriteRestaurant(
      FavouriteModel favouriteModel) async {
    await fireStore
        .collection(CollectionName.favoriteRestaurant)
        .add(favouriteModel.toJson());
  }

  static Future<void> removeFavouriteItem(
      FavouriteItemModel favouriteModel) async {
    try {
      final favoriteCollection =
          fireStore.collection(CollectionName.favoriteItem);
      final querySnapshot = await favoriteCollection
          .where("product_id", isEqualTo: favouriteModel.productId)
          .get();
      for (final doc in querySnapshot.docs) {
        await favoriteCollection.doc(doc.id).delete();
      }
    } catch (e) {
      print("Error removing favourite item: $e");
    }
  }

  static Future<void> setFavouriteItem(
      FavouriteItemModel favouriteModel) async {
    await fireStore
        .collection(CollectionName.favoriteItem)
        .add(favouriteModel.toJson());
  }

  static Future<List<ProductModel>> getProductByVendorId(
      String vendorId) async {
    String selectedFoodType = Preferences.getString(
        Preferences.foodDeliveryType,
        defaultValue: "Delivery".tr);
    List<ProductModel> list = [];
    if (selectedFoodType == "TakeAway") {
      await fireStore
          .collection(CollectionName.vendorProducts)
          .where("vendorID", isEqualTo: vendorId)
          .where('publish', isEqualTo: true)
          .orderBy("createdAt", descending: false)
          .get()
          .then((value) {
        for (var element in value.docs) {
          ProductModel productModel = ProductModel.fromJson(element.data());
          list.add(productModel);
        }
      }).catchError((error) {
        log(error.toString());
      });
    } else {
      await fireStore
          .collection(CollectionName.vendorProducts)
          .where("vendorID", isEqualTo: vendorId)
          .where("takeawayOption", isEqualTo: false)
          .where('publish', isEqualTo: true)
          .orderBy("createdAt", descending: false)
          .get()
          .then((value) {
        for (var element in value.docs) {
          ProductModel productModel = ProductModel.fromJson(element.data());
          list.add(productModel);
        }
      }).catchError((error) {
        log(error.toString());
      });
    }

    return list;
  }

  static Future<VendorCategoryModel?> getVendorCategoryById(
      String categoryId) async {
    VendorCategoryModel? vendorCategoryModel;
    try {
      await fireStore
          .collection(CollectionName.vendorCategories)
          .doc(categoryId)
          .get()
          .then((value) {
        if (value.exists) {
          vendorCategoryModel = VendorCategoryModel.fromJson(value.data()!);
        }
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return vendorCategoryModel;
  }

  static Future<ProductModel?> getProductById(String productId) async {
    ProductModel? vendorCategoryModel;
    try {
      await fireStore
          .collection(CollectionName.vendorProducts)
          .doc(productId)
          .get()
          .then((value) {
        if (value.exists) {
          vendorCategoryModel = ProductModel.fromJson(value.data()!);
        }
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return vendorCategoryModel;
  }

  static Future<List<CouponModel>> getOfferByVendorId(String vendorId) async {
    List<CouponModel> couponList = [];
    await fireStore
        .collection(CollectionName.coupons)
        .where("resturant_id", isEqualTo: vendorId)
        .where("isEnabled", isEqualTo: true)
        .where("isPublic", isEqualTo: true)
        .where('expiresAt', isGreaterThanOrEqualTo: Timestamp.now())
        .get()
        .then(
      (value) {
        for (var element in value.docs) {
          CouponModel favouriteModel = CouponModel.fromJson(element.data());
          couponList.add(favouriteModel);
        }
      },
    );
    return couponList;
  }

  static Future<List<AttributesModel>?> getAttributes() async {
    List<AttributesModel> attributeList = [];
    await fireStore.collection(CollectionName.vendorAttributes).get().then(
      (value) {
        for (var element in value.docs) {
          AttributesModel favouriteModel =
              AttributesModel.fromJson(element.data());
          attributeList.add(favouriteModel);
        }
      },
    );
    return attributeList;
  }

  static Future<DeliveryCharge?> getDeliveryCharge() async {
    DeliveryCharge? deliveryCharge;
    try {
      await fireStore
          .collection(CollectionName.settings)
          .doc("DeliveryCharge")
          .get()
          .then((value) {
        if (value.exists) {
          deliveryCharge = DeliveryCharge.fromJson(value.data()!);
        }
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return deliveryCharge;
  }

  static Future<List<TaxModel>?> getTaxList() async {
    List<TaxModel> taxList = [];
    List<Placemark> placeMarks = await placemarkFromCoordinates(
        Constant.selectedLocation.location!.latitude!,
        Constant.selectedLocation.location!.longitude!);
    await fireStore
        .collection(CollectionName.tax)
        .where('country', isEqualTo: placeMarks.first.country)
        .where('enable', isEqualTo: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        TaxModel taxModel = TaxModel.fromJson(element.data());
        taxList.add(taxModel);
      }
    }).catchError((error) {
      log(error.toString());
    });

    return taxList;
  }

  static Future<List<CouponModel>> getAllVendorPublicCoupons(
      String vendorId) async {
    List<CouponModel> coupon = [];

    await fireStore
        .collection(CollectionName.coupons)
        .where("resturant_id", isEqualTo: vendorId)
        .where('expiresAt', isGreaterThanOrEqualTo: Timestamp.now())
        .where("isEnabled", isEqualTo: true)
        .where("isPublic", isEqualTo: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        CouponModel taxModel = CouponModel.fromJson(element.data());
        coupon.add(taxModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return coupon;
  }

  static Future<List<CouponModel>> getAllVendorCoupons(String vendorId) async {
    List<CouponModel> coupon = [];

    await fireStore
        .collection(CollectionName.coupons)
        .where("resturant_id", isEqualTo: vendorId)
        .where('expiresAt', isGreaterThanOrEqualTo: Timestamp.now())
        .where("isEnabled", isEqualTo: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        CouponModel taxModel = CouponModel.fromJson(element.data());
        coupon.add(taxModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return coupon;
  }

  static Future<bool?> setOrder(OrderModel orderModel) async {
    bool isAdded = false;
    await fireStore
        .collection(CollectionName.restaurantOrders)
        .doc(orderModel.id)
        .set(orderModel.toJson())
        .then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<bool?> setProduct(ProductModel orderModel) async {
    bool isAdded = false;
    await fireStore
        .collection(CollectionName.vendorProducts)
        .doc(orderModel.id)
        .set(orderModel.toJson())
        .then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<bool?> setBookedOrder(DineInBookingModel orderModel) async {
    bool isAdded = false;
    await fireStore
        .collection(CollectionName.bookedTable)
        .doc(orderModel.id)
        .set(orderModel.toJson())
        .then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<List<OrderModel>> getAllOrder() async {
    List<OrderModel> list = [];

    await fireStore
        .collection(CollectionName.restaurantOrders)
        .where("authorID", isEqualTo: FireStoreUtils.getCurrentUid())
        .orderBy("createdAt", descending: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        OrderModel taxModel = OrderModel.fromJson(element.data());
        list.add(taxModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return list;
  }

  static Future<OrderModel?> getOrderByOrderId(String orderId) async {
    OrderModel? orderModel;
    try {
      await fireStore
          .collection(CollectionName.restaurantOrders)
          .doc(orderId)
          .get()
          .then((value) {
        if (value.data() != null) {
          orderModel = OrderModel.fromJson(value.data()!);
        }
      });
    } catch (e, s) {
      print('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return orderModel;
  }

  static Future<List<DineInBookingModel>> getDineInBooking(
      bool isUpcoming) async {
    List<DineInBookingModel> list = [];

    if (isUpcoming) {
      await fireStore
          .collection(CollectionName.bookedTable)
          .where('author.id', isEqualTo: getCurrentUid())
          .where('date', isGreaterThan: Timestamp.now())
          .orderBy('date', descending: true)
          .orderBy('createdAt', descending: true)
          .get()
          .then((value) {
        for (var element in value.docs) {
          DineInBookingModel taxModel =
              DineInBookingModel.fromJson(element.data());
          list.add(taxModel);
        }
      }).catchError((error) {
        log(error.toString());
      });
    } else {
      await fireStore
          .collection(CollectionName.bookedTable)
          .where('author.id', isEqualTo: getCurrentUid())
          .where('date', isLessThan: Timestamp.now())
          .orderBy('date', descending: true)
          .orderBy('createdAt', descending: true)
          .get()
          .then((value) {
        for (var element in value.docs) {
          DineInBookingModel taxModel =
              DineInBookingModel.fromJson(element.data());
          list.add(taxModel);
        }
      }).catchError((error) {
        log(error.toString());
      });
    }

    return list;
  }

  static Future<ReferralModel?> getReferralUserBy() async {
    ReferralModel? referralModel;
    try {
      await fireStore
          .collection(CollectionName.referral)
          .doc(getCurrentUid())
          .get()
          .then((value) {
        referralModel = ReferralModel.fromJson(value.data()!);
      });
    } catch (e, s) {
      print('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return referralModel;
  }

  static Future<List<GiftCardsModel>> getGiftCard() async {
    List<GiftCardsModel> giftCardModelList = [];
    QuerySnapshot<Map<String, dynamic>> currencyQuery = await fireStore
        .collection(CollectionName.giftCards)
        .where("isEnable", isEqualTo: true)
        .get();
    await Future.forEach(currencyQuery.docs,
        (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        log(document.data().toString());
        giftCardModelList.add(GiftCardsModel.fromJson(document.data()));
      } catch (e) {
        debugPrint('FireStoreUtils.get Currency Parse error $e');
      }
    });
    return giftCardModelList;
  }

  static Future<GiftCardsOrderModel> placeGiftCardOrder(
      GiftCardsOrderModel giftCardsOrderModel) async {
    print("=====>");
    print(giftCardsOrderModel.toJson());
    await fireStore
        .collection(CollectionName.giftPurchases)
        .doc(giftCardsOrderModel.id)
        .set(giftCardsOrderModel.toJson());
    return giftCardsOrderModel;
  }

  static Future<GiftCardsOrderModel?> checkRedeemCode(String giftCode) async {
    GiftCardsOrderModel? giftCardsOrderModel;
    await fireStore
        .collection(CollectionName.giftPurchases)
        .where("giftCode", isEqualTo: giftCode)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        giftCardsOrderModel =
            GiftCardsOrderModel.fromJson(value.docs.first.data());
      }
    });
    return giftCardsOrderModel;
  }

  static Future<EmailTemplateModel?> getEmailTemplates(String type) async {
    EmailTemplateModel? emailTemplateModel;
    await fireStore
        .collection(CollectionName.emailTemplates)
        .where('type', isEqualTo: type)
        .get()
        .then((value) {
      print("------>");
      if (value.docs.isNotEmpty) {
        print(value.docs.first.data());
        emailTemplateModel =
            EmailTemplateModel.fromJson(value.docs.first.data());
      }
    });
    return emailTemplateModel;
  }

  static Future<List<GiftCardsOrderModel>> getGiftHistory() async {
    List<GiftCardsOrderModel> giftCardsOrderList = [];
    await fireStore
        .collection(CollectionName.giftPurchases)
        .where("userid", isEqualTo: FireStoreUtils.getCurrentUid())
        .get()
        .then((value) {
      for (var element in value.docs) {
        GiftCardsOrderModel giftCardsOrderModel =
            GiftCardsOrderModel.fromJson(element.data());
        giftCardsOrderList.add(giftCardsOrderModel);
      }
    });
    return giftCardsOrderList;
  }

  static sendTopUpMail(
      {required String amount,
      required String paymentMethod,
      required String tractionId}) async {
    EmailTemplateModel? emailTemplateModel =
        await FireStoreUtils.getEmailTemplates(Constant.walletTopup);

    String newString = emailTemplateModel!.message.toString();
    newString = newString.replaceAll(
        "{username}",
        Constant.userModel!.firstName.toString() +
            Constant.userModel!.lastName.toString());
    newString = newString.replaceAll(
        "{date}", DateFormat('yyyy-MM-dd').format(Timestamp.now().toDate()));
    newString =
        newString.replaceAll("{amount}", Constant.amountShow(amount: amount));
    newString =
        newString.replaceAll("{paymentmethod}", paymentMethod.toString());
    newString = newString.replaceAll("{transactionid}", tractionId.toString());
    newString = newString.replaceAll(
        "{newwalletbalance}.",
        Constant.amountShow(
            amount: Constant.userModel!.walletAmount.toString()));
    await Constant.sendMail(
        subject: emailTemplateModel.subject,
        isAdmin: emailTemplateModel.isSendToAdmin,
        body: newString,
        recipients: [Constant.userModel!.email]);
  }

  static Future<List> getVendorCuisines(String id) async {
    List tagList = [];
    List prodTagList = [];
    QuerySnapshot<Map<String, dynamic>> productsQuery = await fireStore
        .collection(CollectionName.vendorProducts)
        .where('vendorID', isEqualTo: id)
        .get();
    await Future.forEach(productsQuery.docs,
        (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      if (document.data().containsKey("categoryID") &&
          document.data()['categoryID'].toString().isNotEmpty) {
        prodTagList.add(document.data()['categoryID']);
      }
    });
    QuerySnapshot<Map<String, dynamic>> catQuery = await fireStore
        .collection(CollectionName.vendorCategories)
        .where('publish', isEqualTo: true)
        .get();
    await Future.forEach(catQuery.docs,
        (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      Map<String, dynamic> catDoc = document.data();
      if (catDoc.containsKey("id") &&
          catDoc['id'].toString().isNotEmpty &&
          catDoc.containsKey("title") &&
          catDoc['title'].toString().isNotEmpty &&
          prodTagList.contains(catDoc['id'])) {
        tagList.add(catDoc['title']);
      }
    });
    return tagList;
  }

  static Future<NotificationModel?> getNotificationContent(String type) async {
    NotificationModel? notificationModel;
    await fireStore
        .collection(CollectionName.dynamicNotification)
        .where('type', isEqualTo: type)
        .get()
        .then((value) {
      print("------>");
      if (value.docs.isNotEmpty) {
        print(value.docs.first.data());

        notificationModel = NotificationModel.fromJson(value.docs.first.data());
      } else {
        notificationModel = NotificationModel(
            id: "",
            message: "Notification setup is pending",
            subject: "setup notification",
            type: "");
      }
    });
    return notificationModel;
  }

  static Future<bool?> deleteUser() async {
    bool? isDelete;
    try {
      await fireStore
          .collection(CollectionName.users)
          .doc(FireStoreUtils.getCurrentUid())
          .delete();

      // delete user  from firebase auth
      await FirebaseAuth.instance.currentUser?.delete().then((value) {
        isDelete = true;
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return false;
    }
    return isDelete;
  }

  static Future addDriverInbox(InboxModel inboxModel) async {
    return await fireStore
        .collection("chat_driver")
        .doc(inboxModel.orderId)
        .set(inboxModel.toJson())
        .then((document) {
      return inboxModel;
    });
  }

  static Future addDriverChat(ConversationModel conversationModel) async {
    return await fireStore
        .collection("chat_driver")
        .doc(conversationModel.orderId)
        .collection("thread")
        .doc(conversationModel.id)
        .set(conversationModel.toJson())
        .then((document) {
      return conversationModel;
    });
  }

  static Future addRestaurantInbox(InboxModel inboxModel) async {
    return await fireStore
        .collection("chat_restaurant")
        .doc(inboxModel.orderId)
        .set(inboxModel.toJson())
        .then((document) {
      return inboxModel;
    });
  }

  static Future addRestaurantChat(ConversationModel conversationModel) async {
    return await fireStore
        .collection("chat_restaurant")
        .doc(conversationModel.orderId)
        .collection("thread")
        .doc(conversationModel.id)
        .set(conversationModel.toJson())
        .then((document) {
      return conversationModel;
    });
  }

  static Future<Url> uploadChatImageToFireStorage(
      File image, BuildContext context) async {
    ShowToastDialog.showLoader("Please wait".tr);
    var uniqueID = const Uuid().v4();
    Reference upload =
        FirebaseStorage.instance.ref().child('images/$uniqueID.png');
    UploadTask uploadTask = upload.putFile(image);
    var storageRef = (await uploadTask.whenComplete(() {})).ref;
    var downloadUrl = await storageRef.getDownloadURL();
    var metaData = await storageRef.getMetadata();
    ShowToastDialog.closeLoader();
    return Url(
        mime: metaData.contentType ?? 'image', url: downloadUrl.toString());
  }

  static Future<ChatVideoContainer?> uploadChatVideoToFireStorage(
      BuildContext context, File video) async {
    try {
      ShowToastDialog.showLoader("Uploading video...");
      final String uniqueID = const Uuid().v4();
      final Reference videoRef =
          FirebaseStorage.instance.ref('videos/$uniqueID.mp4');
      final UploadTask uploadTask = videoRef.putFile(
        video,
        SettableMetadata(contentType: 'video/mp4'),
      );
      await uploadTask;
      final String videoUrl = await videoRef.getDownloadURL();
      ShowToastDialog.showLoader("Generating thumbnail...");
      // File thumbnail = await VideoCompress.getFileThumbnail(
      //   video.path,
      //   quality: 75, // 0 - 100
      //   position: -1, // Get the first frame
      // );
      final String thumbnailID = const Uuid().v4();
      final Reference thumbnailRef =
          FirebaseStorage.instance.ref('thumbnails/$thumbnailID.jpg');
      // final UploadTask thumbnailUploadTask = thumbnailRef.putData(
      //   // thumbnail.readAsBytesSync(),
      //   SettableMetadata(contentType: 'image/jpeg'),
      // );
      // await thumbnailUploadTask;
      final String thumbnailUrl = await thumbnailRef.getDownloadURL();
      var metaData = await thumbnailRef.getMetadata();
      ShowToastDialog.closeLoader();

      return ChatVideoContainer(
          videoUrl: Url(
              url: videoUrl.toString(),
              mime: metaData.contentType ?? 'video',
              videoThumbnail: thumbnailUrl),
          thumbnailUrl: thumbnailUrl);
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Error: ${e.toString()}");
      return null;
    }
  }

  static Future<String> uploadVideoThumbnailToFireStorage(File file) async {
    var uniqueID = const Uuid().v4();
    Reference upload =
        FirebaseStorage.instance.ref().child('thumbnails/$uniqueID.png');
    UploadTask uploadTask = upload.putFile(file);
    var downloadUrl =
        await (await uploadTask.whenComplete(() {})).ref.getDownloadURL();
    return downloadUrl.toString();
  }

  static Future<List<RatingModel>> getVendorReviews(String vendorId) async {
    List<RatingModel> ratingList = [];
    await fireStore
        .collection(CollectionName.foodsReview)
        .where('VendorId', isEqualTo: vendorId)
        .get()
        .then((value) {
      for (var element in value.docs) {
        RatingModel giftCardsOrderModel = RatingModel.fromJson(element.data());
        ratingList.add(giftCardsOrderModel);
      }
    });
    return ratingList;
  }

  static Future<RatingModel?> getOrderReviewsByID(
      String orderId, String productID) async {
    RatingModel? ratingModel;

    await fireStore
        .collection(CollectionName.foodsReview)
        .where('orderid', isEqualTo: orderId)
        .where('productId', isEqualTo: productID)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        ratingModel = RatingModel.fromJson(value.docs.first.data());
      }
    }).catchError((error) {
      log(error.toString());
    });
    return ratingModel;
  }

  static Future<VendorCategoryModel?> getVendorCategoryByCategoryId(
      String categoryId) async {
    VendorCategoryModel? vendorCategoryModel;
    try {
      await fireStore
          .collection(CollectionName.vendorCategories)
          .doc(categoryId)
          .get()
          .then((value) {
        if (value.exists) {
          vendorCategoryModel = VendorCategoryModel.fromJson(value.data()!);
        }
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return vendorCategoryModel;
  }

  static Future<ReviewAttributeModel?> getVendorReviewAttribute(
      String attributeId) async {
    ReviewAttributeModel? vendorCategoryModel;
    try {
      await fireStore
          .collection(CollectionName.reviewAttributes)
          .doc(attributeId)
          .get()
          .then((value) {
        if (value.exists) {
          vendorCategoryModel = ReviewAttributeModel.fromJson(value.data()!);
        }
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return vendorCategoryModel;
  }

  static Future<bool?> setRatingModel(RatingModel ratingModel) async {
    bool isAdded = false;
    await fireStore
        .collection(CollectionName.foodsReview)
        .doc(ratingModel.id)
        .set(ratingModel.toJson())
        .then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<VendorModel?> updateVendor(VendorModel vendor) async {
    return await fireStore
        .collection(CollectionName.vendors)
        .doc(vendor.id)
        .set(vendor.toJson())
        .then((document) {
      return vendor;
    });
  }

  static Future<List<AdvertisementModel>> getAllAdvertisement() async {
    List<AdvertisementModel> advertisementList = [];
    await fireStore
        .collection(CollectionName.advertisements)
        .where('status', isEqualTo: 'approved')
        .where('paymentStatus', isEqualTo: true)
        .where('startDate', isLessThanOrEqualTo: DateTime.now())
        .where('endDate', isGreaterThan: DateTime.now())
        .orderBy('priority', descending: false)
        .get()
        .then((value) {
      for (var element in value.docs) {
        AdvertisementModel advertisementModel =
            AdvertisementModel.fromJson(element.data());
        if (advertisementModel.isPaused == null ||
            advertisementModel.isPaused == false) {
          advertisementList.add(advertisementModel);
        }
      }
    }).catchError((error) {
      log(error.toString());
    });
    return advertisementList;
  }

  static Future<AdvertisementModel> getAdvertisementById(String advId) async {
    AdvertisementModel advertisementModel = AdvertisementModel();
    await fireStore
        .collection(CollectionName.advertisements)
        .doc(advId)
        .get()
        .then((value) {
      advertisementModel =
          AdvertisementModel.fromJson(value.data() as Map<String, dynamic>);
    }).catchError((error) {
      log(error.toString());
    });
    return advertisementModel;
  }
}
