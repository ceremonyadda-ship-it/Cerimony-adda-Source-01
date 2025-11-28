import 'package:cloud_firestore/cloud_firestore.dart';

class InboxModel {
  String? customerId;
  String? customerName;
  String? customerProfileImage;
  String? lastMessage;
  String? orderId;
  String? restaurantId;
  String? restaurantName;
  String? restaurantProfileImage;
  String? lastSenderId;
  String? chatType;
  Timestamp? createdAt;

  InboxModel({
    this.customerId,
    this.customerName,
    this.customerProfileImage,
    this.lastMessage,
    this.orderId,
    this.restaurantId,
    this.restaurantName,
    this.restaurantProfileImage,
    this.lastSenderId,
    this.chatType,
    this.createdAt,
  });

  factory InboxModel.fromJson(Map<String, dynamic> parsedJson) {
    return InboxModel(
      customerId: parsedJson['customerId'] ?? '',
      customerName: parsedJson['customerName'] ?? '',
      customerProfileImage: parsedJson['customerProfileImage'] ?? '',
      lastMessage: parsedJson['lastMessage'],
      orderId: parsedJson['orderId'],
      restaurantId: parsedJson['restaurantId'] ?? '',
      restaurantName: parsedJson['restaurantName'] ?? '',
      lastSenderId: parsedJson['lastSenderId'] ?? '',
      chatType: parsedJson['chatType'] ?? '',
      restaurantProfileImage: parsedJson['restaurantProfileImage'] ?? '',
      createdAt: parsedJson['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'customerProfileImage': customerProfileImage,
      'lastMessage': lastMessage,
      'orderId': orderId,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'restaurantProfileImage': restaurantProfileImage,
      'lastSenderId': lastSenderId,
      'chatType': chatType,
      'createdAt': createdAt,
    };
  }
}
