import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/models/cart_product_model.dart';
import 'package:customer/models/tax_model.dart';
import 'package:customer/models/user_model.dart';
import 'package:customer/models/vendor_model.dart';

class OrderModel {
  ShippingAddress? address;
  String? status;
  String? couponId;
  String? vendorID;
  String? driverID;
  num? discount;
  String? authorID;
  String? estimatedTimeToPrepare;
  Timestamp? createdAt;
  Timestamp? triggerDelivery;
  List<TaxModel>? taxSetting;
  String? paymentMethod;
  List<CartProductModel>? products;
  String? adminCommissionType;
  VendorModel? vendor;
  String? id;
  String? adminCommission;
  String? couponCode;
  Map<String, dynamic>? specialDiscount;
  String? deliveryCharge;
  Timestamp? scheduleTime;
  String? tipAmount;
  String? notes;
  UserModel? author;
  UserModel? driver;
  bool? takeAway;
  List<dynamic>? rejectedByDrivers;

  OrderModel(
      {this.address,
      this.status,
      this.couponId,
      this.vendorID,
      this.driverID,
      this.discount,
      this.authorID,
      this.estimatedTimeToPrepare,
      this.createdAt,
      this.triggerDelivery,
      this.taxSetting,
      this.paymentMethod,
      this.products,
      this.adminCommissionType,
      this.vendor,
      this.id,
      this.adminCommission,
      this.couponCode,
      this.specialDiscount,
      this.deliveryCharge,
      this.scheduleTime,
      this.tipAmount,
      this.notes,
      this.author,
      this.driver,
      this.takeAway,
      this.rejectedByDrivers});

  OrderModel.fromJson(Map<String, dynamic> json) {
    address = json['address'] != null ? ShippingAddress.fromJson(json['address']) : null;
    status = json['status'];
    couponId = json['couponId'];
    vendorID = json['vendorID'];
    driverID = json['driverID'];
    discount = json['discount'];
    authorID = json['authorID'];
    estimatedTimeToPrepare = json['estimatedTimeToPrepare'];
    createdAt = json['createdAt'];
    triggerDelivery = json['triggerDelevery'] ?? Timestamp.now();
    if (json['taxSetting'] != null) {
      taxSetting = <TaxModel>[];
      json['taxSetting'].forEach((v) {
        taxSetting!.add(TaxModel.fromJson(v));
      });
    }
    paymentMethod = json['payment_method'];
    if (json['products'] != null) {
      products = <CartProductModel>[];
      json['products'].forEach((v) {
        products!.add(CartProductModel.fromJson(v));
      });
    }
    adminCommissionType = json['adminCommissionType'];
    vendor = json['vendor'] != null ? VendorModel.fromJson(json['vendor']) : null;
    id = json['id'];
    adminCommission = json['adminCommission'];
    couponCode = json['couponCode'];
    specialDiscount = json['specialDiscount'];
    deliveryCharge = json['deliveryCharge'].toString().isEmpty ? "0.0" : json['deliveryCharge'] ?? '0.0';
    scheduleTime = json['scheduleTime'];
    tipAmount = json['tip_amount'].toString().isEmpty ? "0.0" : json['tip_amount'] ?? "0.0";
    notes = json['notes'];
    author = json['author'] != null ? UserModel.fromJson(json['author']) : null;
    driver = json['driver'] != null ? UserModel.fromJson(json['driver']) : null;
    takeAway = json['takeAway'];
    rejectedByDrivers = json['rejectedByDrivers'] ?? [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (address != null) {
      data['address'] = address!.toJson();
    }
    data['status'] = status;
    data['couponId'] = couponId;
    data['vendorID'] = vendorID;
    data['driverID'] = driverID;
    data['discount'] = discount;
    data['authorID'] = authorID;
    data['estimatedTimeToPrepare'] = estimatedTimeToPrepare;
    data['createdAt'] = createdAt;
    data['triggerDelivery'] = triggerDelivery;
    if (taxSetting != null) {
      data['taxSetting'] = taxSetting!.map((v) => v.toJson()).toList();
    }
    data['payment_method'] = paymentMethod;
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    data['adminCommissionType'] = adminCommissionType;
    if (vendor != null) {
      data['vendor'] = vendor!.toJson();
    }
    data['id'] = id;
    data['adminCommission'] = adminCommission;
    data['couponCode'] = couponCode;
    data['specialDiscount'] = specialDiscount;
    data['deliveryCharge'] = deliveryCharge;
    data['scheduleTime'] = scheduleTime;
    data['tip_amount'] = tipAmount;
    data['notes'] = notes;
    if (author != null) {
      data['author'] = author!.toJson();
    }
    if (driver != null) {
      data['driver'] = driver!.toJson();
    }
    data['takeAway'] = takeAway;
    data['rejectedByDrivers'] = rejectedByDrivers;
    return data;
  }
}
