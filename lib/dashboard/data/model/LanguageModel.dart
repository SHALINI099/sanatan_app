// To parse this JSON data, do
//
//     final languageModel = languageModelFromJson(jsonString);

import 'dart:convert';

LanguageModel languageModelFromJson(String str) => LanguageModel.fromJson(json.decode(str));

String languageModelToJson(LanguageModel data) => json.encode(data.toJson());

class LanguageModel {
  bool status;
  List<Datums> data;
  String tagId;
  String msg;

  LanguageModel({
    required this.status,
    required this.data,
    required this.tagId,
    required this.msg,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) => LanguageModel(
    status: json["status"],
    data: List<Datums>.from(json["data"].map((x) => Datums.fromJson(x))),
    tagId: json["tagId"],
    msg: json["msg"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "tagId": tagId,
    "msg": msg,
  };
}

class Datums {
  int id;
  String language;
  String languageCode;
  bool isShow;

  Datums({
    required this.id,
    required this.language,
    required this.languageCode,
    required this.isShow,
  });

  factory Datums.fromJson(Map<String, dynamic> json) => Datums(
    id: json["id"],
    language: json["language"],
    languageCode: json["language_code"],
    isShow: json["is_show"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "language": language,
    "language_code": languageCode,
    "is_show": isShow,
  };
}
