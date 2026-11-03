// To parse this JSON data, do
//
//     final mantraListModel = mantraListModelFromJson(jsonString);

import 'dart:convert';

AlarmListModel alarmListModelFromJson(String str) => AlarmListModel.fromJson(json.decode(str));

String alarmListModelToJson(AlarmListModel data) => json.encode(data.toJson());

class AlarmListModel {
  bool status;
  List<PostDatum> postData;
  String msg;

  AlarmListModel({
    required this.status,
    required this.postData,
    required this.msg,
  });

  factory AlarmListModel.fromJson(Map<String, dynamic> json) => AlarmListModel(
    status: json["status"] ?? false,
    postData: (json["post_data"] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(PostDatum.fromJson)
            .toList() ??
        [],
    msg: json["msg"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "post_data": List<dynamic>.from(postData.map((x) => x.toJson())),
    "msg": msg,
  };
}

class PostDatum {
  int id;
  String title;
  String description;
  String alarmUrl;
  DateTime createdAt;
  String language;
  bool isDeleted;
  String thumbnail;

  PostDatum({
    required this.id,
    required this.title,
    required this.description,
    required this.alarmUrl,
    required this.createdAt,
    required this.language,
    required this.isDeleted,
    required this.thumbnail,
  });

  factory PostDatum.fromJson(Map<String, dynamic> json) => PostDatum(
    id: json["id"] ?? 0,
    title: json["title"] ?? '',
    description: json["description"] ?? '',
    alarmUrl: json["alarm_url"] ?? '',
    createdAt: DateTime.tryParse(json["created_at"] ?? '') ?? DateTime.now(),
    language: json["language"] ?? '',
    isDeleted: json["is_deleted"] ?? false,
    thumbnail: json["thumbnail"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "alarm_url": alarmUrl,
    "created_at": createdAt.toIso8601String(),
    "language": language,
    "is_deleted": isDeleted,
    "thumbnail": thumbnail,
  };
}
