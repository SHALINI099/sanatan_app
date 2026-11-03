// To parse this JSON data, do
//
//     final mantraListModel = mantraListModelFromJson(jsonString);

import 'dart:convert';

MantraListModel mantraListModelFromJson(String str) => MantraListModel.fromJson(json.decode(str));

String mantraListModelToJson(MantraListModel data) => json.encode(data.toJson());

class MantraListModel {
  bool status;
  List<PostDatum> postData;
  String msg;

  MantraListModel({
    required this.status,
    required this.postData,
    required this.msg,
  });

  factory MantraListModel.fromJson(Map<String, dynamic> json) => MantraListModel(
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
  String mantraUrl;
  DateTime createdAt;
  String? language;
  bool isDeleted;
  int godId;
  String thumbnail;

  PostDatum({
    required this.id,
    required this.title,
    required this.description,
    required this.mantraUrl,
    required this.createdAt,
    this.language,
    required this.isDeleted,
    required this.godId,
    required this.thumbnail,
  });

  factory PostDatum.fromJson(Map<String, dynamic> json) => PostDatum(
    id: json["id"] ?? 0,
    title: json["title"] ?? '',
    description: json["description"] ?? '',
    mantraUrl: json["mantra_url"] ?? '',
    createdAt: DateTime.tryParse(json["created_at"] ?? '') ?? DateTime.now(),
    language: json["language"] as String?,
    isDeleted: json["is_deleted"] ?? false,
    godId: json["god_id"] ?? 0,
    thumbnail: json["thumbnail"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "mantra_url": mantraUrl,
    "created_at": createdAt.toIso8601String(),
    "language": language,
    "is_deleted": isDeleted,
    "god_id": godId,
    "thumbnail": thumbnail,
  };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
