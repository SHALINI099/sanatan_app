// To parse this JSON data, do
//
//     final paymentDetailModel = paymentDetailModelFromJson(jsonString);

import 'dart:convert';

PaymentDetailModel paymentDetailModelFromJson(String str) => PaymentDetailModel.fromJson(json.decode(str));

String paymentDetailModelToJson(PaymentDetailModel data) => json.encode(data.toJson());

class PaymentDetailModel {
  bool status;
  bool hasTrial;
  List<Datum> data;
  String msg;
  String videoUrl;
  bool is_oldgatway;

  PaymentDetailModel({
    required this.status,
    required this.hasTrial,
    required this.data,
    required this.msg,
    required this.videoUrl,
    required this.is_oldgatway,
  });

  factory PaymentDetailModel.fromJson(Map<String, dynamic> json) => PaymentDetailModel(
    status: json["status"],
    hasTrial: json["has_trial"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    msg: json["msg"],
    videoUrl: json["video_url"],
    // Absent key must not fail the whole plans parse; no flag means "new gateway".
    is_oldgatway: json["is_oldgatway"] == true,
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "has_trial": hasTrial,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "msg": msg,
    "video_url": videoUrl,
    "is_oldgatway": is_oldgatway,
  };
}

class Datum {
  String planTitle;
  String planDescription;
  String planId;
  int mainAmount;
  String displayMainAmount;
  String discount;
  int? trialAmount;
  String? trialDisplayAmount;
  int? trialDays;
  int recurringCount;
  String mrp;

  Datum({
    required this.planTitle,
    required this.planDescription,
    required this.planId,
    required this.mainAmount,
    required this.displayMainAmount,
    required this.discount,
    required this.recurringCount,
     this.trialAmount,
     this.trialDisplayAmount,
     this.trialDays,
     required this.mrp,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    planTitle: json["plan_title"],
    planDescription: json["plan_description"],
    planId: json["plan_id"],
    mainAmount: json["main_amount"],
    displayMainAmount: json["display_main_amount"],
    discount: json["discount"],
    trialAmount: json["trial_amount"] as int?,
    trialDisplayAmount: json["trial_display_amount"] as String?,
    trialDays: json["trial_days"] as int?,
    recurringCount: json["recurring_count"],
    mrp: json["mrp"],
  );

  Map<String, dynamic> toJson() => {
    "plan_title": planTitle,
    "plan_description": planDescription,
    "plan_id": planId,
    "main_amount": mainAmount,
    "display_main_amount": displayMainAmount,
    "discount": discount,
    "recurring_count": recurringCount,
    "trial_amount": trialAmount,
    "trial_display_amount": trialDisplayAmount,
    "trial_days": trialDays,
    "mrp": mrp,
  };
}
