import 'package:customer/models/vendor_model.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:get/get.dart';

class ScanQrCodeController extends GetxController {
  @override
  void onInit() {
    // TODO: implement onInit
    getData();
    super.onInit();
  }

  RxList<VendorModel> allNearestRestaurant = <VendorModel>[].obs;

  getData() {
    FireStoreUtils.getAllNearestRestaurant().listen((event) async {
      allNearestRestaurant.addAll(event);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
