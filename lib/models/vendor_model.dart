import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/models/admin_commission.dart';
import 'package:customer/models/subscription_plan_model.dart';

class VendorModel {
  String? author;
  bool? dineInActive;
  String? openDineTime;
  List<dynamic>? categoryID;
  String? id;
  String? categoryPhoto;
  List<dynamic>? restaurantMenuPhotos;
  List<WorkingHours>? workingHours;
  String? location;
  String? fcmToken;
  G? g;
  bool? hidephotos;
  bool? reststatus;
  Filters? filters;
  AdminCommission? adminCommission;
  String? photo;
  String? description;
  num? walletAmount;
  String? closeDineTime;
  String? zoneId;
  Timestamp? createdAt;
  double? longitude;
  bool? enabledDiveInFuture;
  String? restaurantCost;
  DeliveryCharge? deliveryCharge;
  String? authorProfilePic;
  String? authorName;
  String? phonenumber;
  List<SpecialDiscount>? specialDiscount;
  bool? specialDiscountEnable;
  GeoPoint? coordinates;
  num? reviewsSum;
  num? reviewsCount;
  List<dynamic>? photos;
  String? title;
  List<dynamic>? categoryTitle;
  double? latitude;
  String? subscriptionPlanId;
  Timestamp? subscriptionExpiryDate;
  SubscriptionPlanModel? subscriptionPlan;
  String? subscriptionTotalOrders;
  bool? isSelfDelivery;

  VendorModel({
    this.author,
    this.dineInActive,
    this.openDineTime,
    this.categoryID,
    this.id,
    this.categoryPhoto,
    this.restaurantMenuPhotos,
    this.workingHours,
    this.location,
    this.fcmToken,
    this.g,
    this.hidephotos,
    this.reststatus,
    this.filters,
    this.reviewsCount,
    this.photo,
    this.description,
    this.walletAmount,
    this.closeDineTime,
    this.zoneId,
    this.createdAt,
    this.longitude,
    this.enabledDiveInFuture,
    this.restaurantCost,
    this.deliveryCharge,
    this.adminCommission,
    this.authorProfilePic,
    this.authorName,
    this.phonenumber,
    this.specialDiscount,
    this.specialDiscountEnable,
    this.coordinates,
    this.reviewsSum,
    this.photos,
    this.title,
    this.categoryTitle,
    this.latitude,
    this.subscriptionPlanId,
    this.subscriptionExpiryDate,
    this.subscriptionPlan,
    this.subscriptionTotalOrders,
    this.isSelfDelivery,
  });

  VendorModel.fromJson(Map<String, dynamic> json) {
    author = json['author'];
    dineInActive = json['dine_in_active'];
    openDineTime = json['openDineTime'];
    categoryID = json['categoryID'] ?? [];
    id = json['id'];
    categoryPhoto = json['categoryPhoto'];
    restaurantMenuPhotos = json['restaurantMenuPhotos'] ?? [];

    if (json['workingHours'] != null) {
      workingHours = <WorkingHours>[];
      json['workingHours'].forEach((v) {
        workingHours!.add(WorkingHours.fromJson(v));
      });
    }

    location = json['location'];
    fcmToken = json['fcmToken'];
    g = json['g'] != null ? G.fromJson(json['g']) : null;

    hidephotos = json['hidephotos'];
    reststatus = json['reststatus'];
    filters = json['filters'] != null ? Filters.fromJson(json['filters']) : null;

    reviewsCount = json['reviewsCount'] ?? 0.0;
    photo = json['photo'];
    description = json['description'];
    walletAmount = json['walletAmount'];
    closeDineTime = json['closeDineTime'];
    zoneId = json['zoneId'];

    createdAt = _parseTimestamp(json['createdAt']);
    longitude = _toDouble(json['longitude']);
    latitude = _toDouble(json['latitude']);
    enabledDiveInFuture = json['enabledDiveInFuture'];
    restaurantCost = json['restaurantCost']?.toString();

    deliveryCharge = json['DeliveryCharge'] != null
        ? DeliveryCharge.fromJson(json['DeliveryCharge'])
        : null;

    adminCommission = json['adminCommission'] != null
        ? AdminCommission.fromJson(json['adminCommission'])
        : null;

    authorProfilePic = json['authorProfilePic'];
    authorName = json['authorName'];
    phonenumber = json['phonenumber'];

    if (json['specialDiscount'] != null) {
      specialDiscount = <SpecialDiscount>[];
      json['specialDiscount'].forEach((v) {
        specialDiscount!.add(SpecialDiscount.fromJson(v));
      });
    }

    specialDiscountEnable = json['specialDiscountEnable'];
    coordinates = _parseGeoPoint(json['coordinates']);
    reviewsSum = json['reviewsSum'] ?? 0.0;
    photos = json['photos'] ?? [];
    title = json['title'];
    categoryTitle = json['categoryTitle'] ?? [];
    subscriptionPlanId = json['subscriptionPlanId'];
    subscriptionExpiryDate = _parseTimestamp(json['subscriptionExpiryDate']);
    subscriptionPlan = json['subscription_plan'] != null
        ? SubscriptionPlanModel.fromJson(json['subscription_plan'])
        : null;
    subscriptionTotalOrders = json['subscriptionTotalOrders'];
    isSelfDelivery = json['isSelfDelivery'] ?? false;
  }

  /// --- Helper Methods ---
  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  Timestamp? _parseTimestamp(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) return value;

    // Firestore emulator / API returns as map {_seconds, _nanoseconds}
    if (value is Map && value['_seconds'] != null) {
      return Timestamp.fromMillisecondsSinceEpoch(value['_seconds'] * 1000);
    }

    // String ISO date (e.g. "2024-01-10T12:00:00Z")
    if (value is String) {
      try {
        return Timestamp.fromDate(DateTime.parse(value));
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  GeoPoint? _parseGeoPoint(dynamic value) {
    if (value == null) return null;

    if (value is GeoPoint) return value;

    if (value is Map &&
        value.containsKey('latitude') &&
        value.containsKey('longitude')) {
      return GeoPoint(
        (value['latitude'] as num).toDouble(),
        (value['longitude'] as num).toDouble(),
      );
    }

    return null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['author'] = author;
    data['dine_in_active'] = dineInActive;
    data['openDineTime'] = openDineTime;
    data['categoryID'] = categoryID;
    data['id'] = id;
    data['categoryPhoto'] = categoryPhoto;
    data['restaurantMenuPhotos'] = restaurantMenuPhotos;
    data['subscriptionPlanId'] = subscriptionPlanId;
    data['subscriptionExpiryDate'] = subscriptionExpiryDate;
    data['subscription_plan'] = subscriptionPlan?.toJson();
    data['subscriptionTotalOrders'] = subscriptionTotalOrders;

    if (workingHours != null) {
      data['workingHours'] = workingHours!.map((v) => v.toJson()).toList();
    }

    data['location'] = location;
    data['fcmToken'] = fcmToken;
    if (g != null) data['g'] = g!.toJson();
    data['hidephotos'] = hidephotos;
    data['reststatus'] = reststatus;
    if (filters != null) data['filters'] = filters!.toJson();

    data['reviewsCount'] = reviewsCount;
    data['photo'] = photo;
    data['description'] = description;
    data['walletAmount'] = walletAmount;
    data['closeDineTime'] = closeDineTime;
    data['zoneId'] = zoneId;
    data['createdAt'] = createdAt;
    data['longitude'] = longitude;
    data['latitude'] = latitude;
    data['enabledDiveInFuture'] = enabledDiveInFuture;
    data['restaurantCost'] = restaurantCost;
    if (deliveryCharge != null) data['DeliveryCharge'] = deliveryCharge!.toJson();
    if (adminCommission != null) data['adminCommission'] = adminCommission!.toJson();

    data['authorProfilePic'] = authorProfilePic;
    data['authorName'] = authorName;
    data['phonenumber'] = phonenumber;
    if (specialDiscount != null) {
      data['specialDiscount'] = specialDiscount!.map((v) => v.toJson()).toList();
    }

    data['specialDiscountEnable'] = specialDiscountEnable;
    data['coordinates'] = coordinates;
    data['reviewsSum'] = reviewsSum;
    data['photos'] = photos;
    data['title'] = title;
    data['categoryTitle'] = categoryTitle;
    data['isSelfDelivery'] = isSelfDelivery ?? false;

    return data;
  }
}

/// --------- Subclasses ----------

class WorkingHours {
  String? day;
  List<Timeslot>? timeslot;

  WorkingHours({this.day, this.timeslot});

  WorkingHours.fromJson(Map<String, dynamic> json) {
    day = json['day'];
    if (json['timeslot'] != null) {
      timeslot = <Timeslot>[];
      json['timeslot'].forEach((v) {
        timeslot!.add(Timeslot.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() => {
    'day': day,
    'timeslot': timeslot?.map((v) => v.toJson()).toList(),
  };
}

class Timeslot {
  String? to;
  String? from;

  Timeslot({this.to, this.from});

  Timeslot.fromJson(Map<String, dynamic> json) {
    to = json['to'];
    from = json['from'];
  }

  Map<String, dynamic> toJson() => {'to': to, 'from': from};
}

class G {
  String? geohash;
  GeoPoint? geopoint;

  G({this.geohash, this.geopoint});

  G.fromJson(Map<String, dynamic> json) {
    geohash = json['geohash'];
    geopoint = json['geopoint'] is GeoPoint
        ? json['geopoint']
        : (json['geopoint'] != null &&
        json['geopoint'] is Map &&
        json['geopoint']['latitude'] != null)
        ? GeoPoint(
      (json['geopoint']['latitude'] as num).toDouble(),
      (json['geopoint']['longitude'] as num).toDouble(),
    )
        : null;
  }

  Map<String, dynamic> toJson() =>
      {'geohash': geohash, 'geopoint': geopoint};
}

class Filters {
  String? goodForLunch;
  String? outdoorSeating;
  String? liveMusic;
  String? vegetarianFriendly;
  String? goodForDinner;
  String? goodForBreakfast;
  String? freeWiFi;
  String? takesReservations;

  Filters.fromJson(Map<String, dynamic> json) {
    goodForLunch = json['Good for Lunch'];
    outdoorSeating = json['Outdoor Seating'];
    liveMusic = json['Live Music'];
    vegetarianFriendly = json['Vegetarian Friendly'];
    goodForDinner = json['Good for Dinner'];
    goodForBreakfast = json['Good for Breakfast'];
    freeWiFi = json['Free Wi-Fi'];
    takesReservations = json['Takes Reservations'];
  }

  Map<String, dynamic> toJson() => {
    'Good for Lunch': goodForLunch,
    'Outdoor Seating': outdoorSeating,
    'Live Music': liveMusic,
    'Vegetarian Friendly': vegetarianFriendly,
    'Good for Dinner': goodForDinner,
    'Good for Breakfast': goodForBreakfast,
    'Free Wi-Fi': freeWiFi,
    'Takes Reservations': takesReservations,
  };
}

class DeliveryCharge {
  num? minimumDeliveryChargesWithinKm;
  num? minimumDeliveryCharges;
  num? deliveryChargesPerKm;
  bool? vendorCanModify;

  // ✅ Add this constructor
  DeliveryCharge({
    this.minimumDeliveryChargesWithinKm,
    this.minimumDeliveryCharges,
    this.deliveryChargesPerKm,
    this.vendorCanModify,
  });

  DeliveryCharge.fromJson(Map<String, dynamic> json) {
    minimumDeliveryChargesWithinKm = json['minimum_delivery_charges_within_km'];
    minimumDeliveryCharges = json['minimum_delivery_charges'];
    deliveryChargesPerKm = json['delivery_charges_per_km'];
    vendorCanModify = json['vendor_can_modify'];
  }

  Map<String, dynamic> toJson() => {
    'minimum_delivery_charges_within_km': minimumDeliveryChargesWithinKm,
    'minimum_delivery_charges': minimumDeliveryCharges,
    'delivery_charges_per_km': deliveryChargesPerKm,
    'vendor_can_modify': vendorCanModify,
  };
}

class SpecialDiscount {
  String? day;
  List<SpecialDiscountTimeslot>? timeslot;

  SpecialDiscount.fromJson(Map<String, dynamic> json) {
    day = json['day'];
    if (json['timeslot'] != null) {
      timeslot = <SpecialDiscountTimeslot>[];
      json['timeslot'].forEach((v) {
        timeslot!.add(SpecialDiscountTimeslot.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() =>
      {'day': day, 'timeslot': timeslot?.map((v) => v.toJson()).toList()};
}

class SpecialDiscountTimeslot {
  String? discount;
  String? discountType;
  String? to;
  String? type;
  String? from;

  SpecialDiscountTimeslot.fromJson(Map<String, dynamic> json) {
    discount = json['discount'];
    discountType = json['discount_type'];
    to = json['to'];
    type = json['type'];
    from = json['from'];
  }

  Map<String, dynamic> toJson() => {
    'discount': discount,
    'discount_type': discountType,
    'to': to,
    'type': type,
    'from': from,
  };
}
