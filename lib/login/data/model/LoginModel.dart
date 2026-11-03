// To parse this JSON data, do
//
//     final loginModel = loginModelFromJson(jsonString);

import 'dart:convert';

LoginModel loginModelFromJson(String str) =>
    LoginModel.fromJson(json.decode(str));

String loginModelToJson(LoginModel data) => json.encode(data.toJson());

class LoginModel {
  bool status;
  String mobileNumber;
  dynamic otp;
  String identificationToken;
  String msg;

  LoginModel({
    required this.status,
    required this.mobileNumber,
    required this.otp,
    required this.identificationToken,
    required this.msg,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
        status: json["status"],
        mobileNumber: json["mobile_number"],
        otp: json["otp"],
        identificationToken: json["identification_token"],
        msg: json["msg"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "mobile_number": mobileNumber,
        "otp": otp,
        "identification_token": identificationToken,
        "msg": msg,
      };
}
