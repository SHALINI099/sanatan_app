// To parse this JSON data, do

import 'dart:convert';

CardModel cardModelFromJson(String str) => CardModel.fromJson(json.decode(str));

String cardModelToJson(CardModel data) => json.encode(data.toJson());

class CardModel {
  bool status;
  List<PostDatum> postData;
  String msg;

  CardModel({
    required this.status,
    required this.postData,
    required this.msg,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) => CardModel(
        status: json["status"],
        postData: List<PostDatum>.from(
            json["post_data"].map((x) => PostDatum.fromJson(x))),
        msg: json["msg"],
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
  String sharingContent;
  String postUrl;
  String avatarPostion;
  String avatarShape;
  DateTime startDate;
  DateTime endDate;
  DateTime createdAt;
  DateTime updatedAt;
  String postType;
  List<int> tagList;
  String nameColorCode;
  String namePlate;
  String partyName;
  String partyLogo;
  int partyId;
  String? language;
  String partyColor;
  String appUrl;

  PostDatum({
    required this.id,
    required this.title,
    required this.sharingContent,
    required this.postUrl,
    required this.avatarPostion,
    required this.avatarShape,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
    required this.postType,
    required this.tagList,
    required this.nameColorCode,
    required this.namePlate,
    required this.partyName,
    required this.partyLogo,
    required this.partyId,
    this.language,
    required this.partyColor,
    required this.appUrl,
  });

  factory PostDatum.fromJson(Map<String, dynamic> json) => PostDatum(
        id: json["id"],
        title: json["title"]!,
        sharingContent: json["sharing_content"],
        postUrl: json["post_url"],
        avatarPostion: json["avatar_postion"]!,
        avatarShape: json["avatar_shape"]!,
        startDate: DateTime.parse(json["start_date"]),
        endDate: DateTime.parse(json["end_date"]),
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        postType: json["post_type"]!,
        tagList: List<int>.from(json["tag_list"].map((x) => x)),
        nameColorCode: json["name_color_code"],
        namePlate: json["name_plate"],
        partyName: json["party_name"],
        partyLogo: json["party_logo"],
        partyId: json["party_id"],
        language: json["language"] as String?,
        partyColor: json["party_color"]!,
        appUrl: json["app_url"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "sharing_content": sharingContent,
        "post_url": postUrl,
        "avatar_postion": avatarPostion,
        "avatar_shape": avatarShape,
        "start_date": startDate.toIso8601String(),
        "end_date": endDate.toIso8601String(),
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "post_type": postType,
        "tag_list": List<dynamic>.from(tagList.map((x) => x)),
        "name_color_code": nameColorCode,
        "name_plate": namePlate,
        "party_name": partyName,
        "party_logo": partyLogo,
        "party_id": partyId,
        "language": language,
        "party_color": partyColor,
        "app_url": appUrl,
      };
}




enum PostType { IMAGE }

final postTypeValues = EnumValues({"image": PostType.IMAGE});

enum Title { D, F, J }

final titleValues = EnumValues({"d": Title.D, "f": Title.F, "j": Title.J});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
