import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionPlanModel {
  Timestamp? createdAt;
  String? description;
  String? expiryDay;
  Features? features;
  String? id;
  bool? isEnable;
  String? itemLimit;
  String? orderLimit;
  String? name;
  String? price;
  String? place;
  String? image;
  String? type;
  List<String>? planPoints;

  SubscriptionPlanModel({
    this.createdAt,
    this.description,
    this.expiryDay,
    this.features,
    this.id,
    this.isEnable,
    this.itemLimit,
    this.orderLimit,
    this.name,
    this.price,
    this.place,
    this.image,
    this.type,
    this.planPoints,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    // Handle createdAt safely
    Timestamp? safeTimestamp;
    final createdAtValue = json['createdAt'];
    if (createdAtValue is Timestamp) {
      safeTimestamp = createdAtValue;
    } else if (createdAtValue is Map && createdAtValue['_seconds'] != null) {
      safeTimestamp = Timestamp(
        createdAtValue['_seconds'],
        createdAtValue['_nanoseconds'] ?? 0,
      );
    } else {
      safeTimestamp = null;
    }

    return SubscriptionPlanModel(
      createdAt: safeTimestamp,
      description: json['description']?.toString(),
      expiryDay: json['expiryDay']?.toString(),
      features: json['features'] == null
          ? null
          : Features.fromJson(Map<String, dynamic>.from(json['features'])),
      id: json['id']?.toString(),
      isEnable: json['isEnable'] ?? false,
      itemLimit: json['itemLimit']?.toString(),
      orderLimit: json['orderLimit']?.toString(),
      name: json['name']?.toString(),
      price: json['price']?.toString(),
      place: json['place']?.toString(),
      image: json['image']?.toString(),
      type: json['type']?.toString(),
      planPoints: json['plan_points'] == null
          ? []
          : List<String>.from(json['plan_points'].map((e) => e.toString())),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'createdAt': createdAt,
      'description': description,
      'expiryDay': expiryDay,
      'features': features?.toJson(),
      'id': id,
      'isEnable': isEnable,
      'itemLimit': itemLimit,
      'orderLimit': orderLimit,
      'name': name,
      'price': price,
      'place': place,
      'image': image,
      'type': type,
      'plan_points': planPoints ?? [],
    };
  }
}

class Features {
  bool? chat;
  bool? dineIn;
  bool? qrCodeGenerate;
  bool? restaurantMobileApp;

  Features({
    this.chat,
    this.dineIn,
    this.qrCodeGenerate,
    this.restaurantMobileApp,
  });

  factory Features.fromJson(Map<String, dynamic> json) {
    return Features(
      chat: json['chat'] ?? false,
      dineIn: json['dineIn'] ?? false,
      qrCodeGenerate: json['qrCodeGenerate'] ?? false,
      restaurantMobileApp: json['restaurantMobileApp'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chat': chat,
      'dineIn': dineIn,
      'qrCodeGenerate': qrCodeGenerate,
      'restaurantMobileApp': restaurantMobileApp,
    };
  }
}
