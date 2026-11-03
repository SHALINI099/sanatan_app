// To parse this JSON data, do
//
//     final tagModel = tagModelFromJson(jsonString);

import 'dart:convert';

TagModel tagModelFromJson(String str) => TagModel.fromJson(json.decode(str));

String tagModelToJson(TagModel data) => json.encode(data.toJson());

class TagModel {
  bool status;
  List<TagName> tagName;
  String tagId;
  String msg;

  TagModel({
    required this.status,
    required this.tagName,
    required this.tagId,
    required this.msg,
  });

  factory TagModel.fromJson(Map<String, dynamic> json) => TagModel(
    status: json["status"],
    tagName: List<TagName>.from(json["tagName"].map((x) => TagName.fromJson(x))),
    tagId: json["tagId"],
    msg: json["msg"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "tagName": List<dynamic>.from(tagName.map((x) => x.toJson())),
    "tagId": tagId,
    "msg": msg,
  };
}

class TagName {
  int id;
  String tagName;
  String tagImageurl;
  int tagPosition;
  int status;
  DateTime createdAt;
  DateTime updatedAt;
  String language;
  String fieldName;
  String displayTagName;
  bool isPolitical;

  TagName({
    required this.id,
    required this.tagName,
    required this.tagImageurl,
    required this.tagPosition,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.language,
    required this.fieldName,
    required this.displayTagName,
    required this.isPolitical,
  });

  factory TagName.fromJson(Map<String, dynamic> json) => TagName(
    id: json["id"],
    tagName: json["tag_name"],
    tagImageurl: json["tag_imageurl"],
    tagPosition: json["tag_position"],
    status: json["status"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    language: json["language"],
    fieldName: json["field_name"],
    displayTagName: json["display_tag_name"],
    isPolitical: json["is_political"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "tag_name": tagName,
    "tag_imageurl": tagImageurl,
    "tag_position": tagPosition,
    "status": status,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "language": language,
    "field_name": fieldName,
    "display_tag_name": displayTagName,
    "is_political": isPolitical,
  };
}
