// To parse this JSON data, do
//
//     final wallpaperModel = wallpaperModelFromJson(jsonString);

import 'dart:convert';

WallpaperModel wallpaperModelFromJson(String str) => WallpaperModel.fromJson(json.decode(str));

String wallpaperModelToJson(WallpaperModel data) => json.encode(data.toJson());

class WallpaperModel {
  bool status;
  List<PostDatum> postData;
  String msg;

  WallpaperModel({
    required this.status,
    required this.postData,
    required this.msg,
  });

  factory WallpaperModel.fromJson(Map<String, dynamic> json) => WallpaperModel(
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
  String wallpaperUrl;
  DateTime createdAt;
  String language;
  bool isDeleted;

  PostDatum({
    required this.id,
    required this.title,
    required this.wallpaperUrl,
    required this.createdAt,
    required this.language,
    required this.isDeleted,
  });

  factory PostDatum.fromJson(Map<String, dynamic> json) => PostDatum(
    id: json["id"] ?? 0,
    title: json["title"] ?? '',
    wallpaperUrl: json["wallpaper_url"] ?? '',
    createdAt: DateTime.tryParse(json["created_at"] ?? '') ?? DateTime.now(),
    language: json["language"] ?? '',
    isDeleted: json["is_deleted"] ?? false,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "wallpaper_url": wallpaperUrl,
    "created_at": createdAt.toIso8601String(),
    "language": language,
    "is_deleted": isDeleted,
  };
}