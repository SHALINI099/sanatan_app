
// To parse this JSON data, do
//
//     final fetchPayDetailModel = fetchPayDetailModelFromJson(jsonString);

import 'dart:convert';

FetchPayDetailModel fetchPayDetailModelFromJson(String str) => FetchPayDetailModel.fromJson(json.decode(str));

String fetchPayDetailModelToJson(FetchPayDetailModel data) => json.encode(data.toJson());

class FetchPayDetailModel {
  String status;
  String msg;

  FetchPayDetailModel({
    required this.status,
    required this.msg,
  });

  factory FetchPayDetailModel.fromJson(Map<String, dynamic> json) => FetchPayDetailModel(
    status: json["status"],
    msg: json["msg"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "msg": msg,
  };
}