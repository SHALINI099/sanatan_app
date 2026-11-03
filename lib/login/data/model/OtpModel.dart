// To parse this JSON data, do
//
//     final otpModel = otpModelFromJson(jsonString);

import 'dart:convert';

OtpModel otpModelFromJson(String str) => OtpModel.fromJson(json.decode(str));

String otpModelToJson(OtpModel data) => json.encode(data.toJson());

class OtpModel {
  bool status;
  String authToken;
  bool isOnboarded;
  dynamic isAdmin;
  String msg;
  Data data;

  OtpModel({
    required this.status,
    required this.authToken,
    required this.isOnboarded,
    required this.isAdmin,
    required this.msg,
    required this.data,
  });

  factory OtpModel.fromJson(Map<String, dynamic> json) => OtpModel(
        status: json["status"],
        authToken: json["auth_token"],
        isOnboarded: json["is_onboarded"],
        isAdmin: json["is_admin"],
        msg: json["msg"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "auth_token": authToken,
        "is_onboarded": isOnboarded,
        "is_admin": isAdmin,
        "msg": msg,
        "data": data.toJson(),
      };
}

class Data {
  String mobileNumber;
  String? name;
  dynamic whatsapp;
  String? avatar;
  String? description;
  String? address;
  String? instaId;
  String? fbId;
  String? twiterId;
  String? subscriptionType;
  String? paymentDuedate;

  Data({
    required this.mobileNumber,
    required this.name,
    required this.whatsapp,
    required this.avatar,
    required this.description,
    required this.address,
    required this.instaId,
    required this.fbId,
    required this.twiterId,
    required this.subscriptionType,
    required this.paymentDuedate,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        mobileNumber: json["mobile_number"],
        name: json["name"],
        whatsapp: json["whatsapp"],
        avatar: json["avatar"],
        description: json["description"],
        address: json["address"],
        instaId: json["insta_id"],
        fbId: json["fb_id"],
        twiterId: json["twiter_id"],
        subscriptionType: json["subscription_type"],
        paymentDuedate: json["payment_duedate"],
      );

  Map<String, dynamic> toJson() => {
        "mobile_number": mobileNumber,
        "name": name,
        "whatsapp": whatsapp,
        "avatar": avatar,
        "description": description,
        "address": address,
        "insta_id": instaId,
        "fb_id": fbId,
        "twiter_id": twiterId,
        "subscription_type": subscriptionType,
        "payment_duedate": paymentDuedate,
      };
}
