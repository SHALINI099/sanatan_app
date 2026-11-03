// To parse this JSON data, do
//
//     final onboardingModel = onboardingModelFromJson(jsonString);

import 'dart:convert';

OnboardingModel onboardingModelFromJson(String str) => OnboardingModel.fromJson(json.decode(str));

String onboardingModelToJson(OnboardingModel data) => json.encode(data.toJson());

class OnboardingModel {
  bool status;
  bool onboarding;
  String msg;

  OnboardingModel({
    required this.status,
    required this.onboarding,
    required this.msg,
  });

  factory OnboardingModel.fromJson(Map<String, dynamic> json) => OnboardingModel(
    status: json["status"],
    onboarding: json["onboarding"],
    msg: json["msg"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "onboarding": onboarding,
    "msg": msg,
  };
}
