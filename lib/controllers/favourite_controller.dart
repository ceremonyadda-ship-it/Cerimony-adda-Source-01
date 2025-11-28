import 'package:customer/constant/collection_name.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/models/favourite_item_model.dart';
import 'package:customer/models/favourite_model.dart';
import 'package:customer/models/product_model.dart';
import 'package:customer/models/vendor_model.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:get/get.dart';

class FavouriteController extends GetxController {
  RxBool favouriteRestaurant = true.obs;
  RxList<FavouriteModel> favouriteList = <FavouriteModel>[].obs;
  RxList<VendorModel> favouriteVendorList = <VendorModel>[].obs;

  RxList<FavouriteItemModel> favouriteItemList = <FavouriteItemModel>[].obs;
  RxList<ProductModel> favouriteFoodList = <ProductModel>[].obs;

  RxBool isLoading = true.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getData();
    super.onInit();
  }

  getData() async {
    if (Constant.userModel != null) {
      await FireStoreUtils.getFavouriteRestaurant().then(
        (value) {
          favouriteList.value = value;
        },
      );

      await FireStoreUtils.getFavouriteItem().then(
        (value) {
          favouriteItemList.value = value;
        },
      );

      for (var element in favouriteList) {
        await FireStoreUtils.getVendorById(element.restaurantId.toString()).then(
          (value) async {
            if (value != null) {
              if ((Constant.isSubscriptionModelApplied == true || Constant.adminCommission?.isEnabled == true) && value.subscriptionPlan != null) {
                if (value.subscriptionTotalOrders == "-1") {
                  favouriteVendorList.add(value);
                } else {
                  print("Restaurant :: ${value.title.toString()}");
                  if ((value.subscriptionExpiryDate != null && value.subscriptionExpiryDate!.toDate().isBefore(DateTime.now()) == false) ||
                      value.subscriptionPlan?.expiryDay == '-1') {
                    if (value.subscriptionTotalOrders != '0') {
                      favouriteVendorList.add(value);
                    }
                  }
                }
              } else {
                favouriteVendorList.add(value);
              }
            }
          },
        );
      }

      for (var element in favouriteItemList) {
        await FireStoreUtils.getProductById(element.productId.toString()).then(
          (value) async {
            if (value != null) {
              if (Constant.isSubscriptionModelApplied == true || Constant.adminCommission?.isEnabled == true) {
                await FireStoreUtils.fireStore.collection(CollectionName.vendors).doc(value.vendorID.toString()).get().then((value1) async {
                  if (value1.exists) {
                    VendorModel vendorModel = VendorModel.fromJson(value1.data()!);
                    if (vendorModel.subscriptionPlan != null) {
                      if (vendorModel.subscriptionTotalOrders == "-1") {
                        favouriteFoodList.add(value);
                      } else {
                        if ((vendorModel.subscriptionExpiryDate != null && vendorModel.subscriptionExpiryDate!.toDate().isBefore(DateTime.now()) == false) ||
                            vendorModel.subscriptionPlan?.expiryDay == "-1") {
                          if (vendorModel.subscriptionTotalOrders != '0') {
                            favouriteFoodList.add(value);
                          }
                        }
                      }
                    }
                  }
                });
              } else {
                favouriteFoodList.add(value);
              }

              // favouriteFoodList.add(value);
            }
          },
        );
      }
    }

    isLoading.value = false;
  }
}
