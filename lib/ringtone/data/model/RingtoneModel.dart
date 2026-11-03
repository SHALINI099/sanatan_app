// To parse this JSON data, do
//
//     final ringtoneModel = ringtoneModelFromJson(jsonString);

import 'dart:convert';

RingtoneModel ringtoneModelFromJson(String str) => RingtoneModel.fromJson(json.decode(str));

String ringtoneModelToJson(RingtoneModel data) => json.encode(data.toJson());

class RingtoneModel {
  bool status;
  List<PostDatum> postData;
  String msg;

  RingtoneModel({
    required this.status,
    required this.postData,
    required this.msg,
  });

  factory RingtoneModel.fromJson(Map<String, dynamic> json) => RingtoneModel(
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
  String ringtoneUrl;
  DateTime createdAt;
  String language;
  bool isDeleted;
  int godId;
  String? thumbnail;

  PostDatum({
    required this.id,
    required this.title,
    required this.description,
    required this.ringtoneUrl,
    required this.createdAt,
    required this.language,
    required this.isDeleted,
    required this.godId,
    this.thumbnail,
  });

  factory PostDatum.fromJson(Map<String, dynamic> json) => PostDatum(
    id: json["id"] ?? 0,
    title: json["title"] ?? '',
    description: json["description"] ?? '',
    ringtoneUrl: json["ringtone_url"] ?? '',
    createdAt: DateTime.tryParse(json["created_at"] ?? '') ?? DateTime.now(),
    language: json["language"] ?? '',
    isDeleted: json["is_deleted"] ?? false,
    godId: json["god_id"] ?? 0,
    thumbnail: json["thumbnail"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "ringtone_url": ringtoneUrl,
    "created_at": createdAt.toIso8601String(),
    "language": language,
    "is_deleted": isDeleted,
    "god_id": godId,
    "thumbnail": thumbnail,
  };
}
