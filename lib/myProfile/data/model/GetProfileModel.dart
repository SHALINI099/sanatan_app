// To parse this JSON data, do
//
//     final getProfileModel = getProfileModelFromJson(jsonString);

import 'dart:convert';

GetProfileModel getProfileModelFromJson(String str) =>
    GetProfileModel.fromJson(json.decode(str));

String getProfileModelToJson(GetProfileModel data) =>
    json.encode(data.toJson());

class GetProfileModel {
  bool status;
  String authToken;
  String msg;
  Data data;

  GetProfileModel({
    required this.status,
    required this.authToken,
    required this.msg,
    required this.data,
  });

  factory GetProfileModel.fromJson(Map<String, dynamic> json) =>
      GetProfileModel(
        status: json["status"],
        authToken: json["auth_token"],
        msg: json["msg"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "auth_token": authToken,
        "msg": msg,
        "data": data.toJson(),
      };
}

class Data {
  String mobileNumber;
  String name;
  String? whatsapp;
  String? avatar;
  String? description;
  String? address;
  String? instaId;
  String? fbId;
  String? twiterId;
  String? subscriptionType;
  String? paymentDuedate;
  bool? is_payment_msg_show;
  bool has_trial;
  String? orderId;
  String language;


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
    required this.is_payment_msg_show,
    required this.orderId,
    required this.has_trial,
    required this.language
    ,
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
        is_payment_msg_show: json["is_payment_msg_show"],
        orderId: json["orderId"],
    has_trial: json["has_trial"],
    language: json["language"],
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
        "is_payment_msg_show": is_payment_msg_show,
        "orderId": orderId,
        "has_trial": has_trial,
        "language": language,

      };
}
