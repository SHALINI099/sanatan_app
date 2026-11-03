// To parse this JSON data, do
//
//     final postModel = postModelFromJson(jsonString);

import 'dart:convert';

PostModel postModelFromJson(String str) => PostModel.fromJson(json.decode(str));

String postModelToJson(PostModel data) => json.encode(data.toJson());

class PostModel {
  bool status;
  List<PostDatum> postData;
  String msg;

  PostModel({
    required this.status,
    required this.postData,
    required this.msg,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) => PostModel(
    status: json["status"],
    postData: List<PostDatum>.from(json["post_data"].map((x) => PostDatum.fromJson(x))),
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
  String postType;
  DateTime startDate;
  String startTime;
  DateTime endDate;
  String endTime;
  DateTime createdAt;
  DateTime updatedAt;
  List<int> tagList;
  dynamic nameColorCode;
  dynamic namePlate;
  dynamic partyLogo;
  dynamic partyName;
  int partyId;
  String language;
  int sharedCount;
  int downloadCount;
  String partyColor;
  String appUrl;
  String startdatetime;
  int sangathanId;
  String creator;
  bool isShowCrator;
  Properties properties;
  bool isDynamic;
  int pinnedPosition;
  String pinnedExpireDatetime;

  PostDatum({
    required this.id,
    required this.title,
    required this.sharingContent,
    required this.postUrl,
    required this.avatarPostion,
    required this.avatarShape,
    required this.postType,
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
    required this.createdAt,
    required this.updatedAt,
    required this.tagList,
    required this.nameColorCode,
    required this.namePlate,
    required this.partyLogo,
    required this.partyName,
    required this.partyId,
    required this.language,
    required this.sharedCount,
    required this.downloadCount,
    required this.partyColor,
    required this.appUrl,
    required this.startdatetime,
    required this.sangathanId,
    required this.creator,
    required this.isShowCrator,
    required this.properties,
    required this.isDynamic,
    required this.pinnedPosition,
    required this.pinnedExpireDatetime,
  });

  factory PostDatum.fromJson(Map<String, dynamic> json) => PostDatum(
    id: json["id"],
    title: json["title"],
    sharingContent: json["sharing_content"],
    postUrl: json["post_url"],
    avatarPostion: json["avatar_postion"],
    avatarShape: json["avatar_shape"],
    postType: json["post_type"],
    startDate: DateTime.parse(json["start_date"]),
    startTime: json["start_time"],
    endDate: DateTime.parse(json["end_date"]),
    endTime: json["end_time"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    tagList: List<int>.from(json["tag_list"].map((x) => x)),
    nameColorCode: json["name_color_code"],
    namePlate: json["name_plate"],
    partyLogo: json["party_logo"],
    partyName: json["party_name"],
    partyId: json["party_id"],
    language: json["language"],
    sharedCount: json["shared_count"],
    downloadCount: json["download_count"],
    partyColor: json["party_color"],
    appUrl: json["app_url"],
    startdatetime: json["startdatetime"],
    sangathanId: json["sangathan_id"],
    creator: json["creator"],
    isShowCrator: json["is_show_crator"],
    properties: Properties.fromJson(json["properties"]),
    isDynamic: json["is_dynamic"],
    pinnedPosition: json["pinned_position"],
    pinnedExpireDatetime: json["pinned_expire_datetime"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "sharing_content": sharingContent,
    "post_url": postUrl,
    "avatar_postion": avatarPostion,
    "avatar_shape": avatarShape,
    "post_type": postType,
    "start_date": startDate.toIso8601String(),
    "start_time": startTime,
    "end_date": endDate.toIso8601String(),
    "end_time": endTime,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "tag_list": List<dynamic>.from(tagList.map((x) => x)),
    "name_color_code": nameColorCode,
    "name_plate": namePlate,
    "party_logo": partyLogo,
    "party_name": partyName,
    "party_id": partyId,
    "language": language,
    "shared_count": sharedCount,
    "download_count": downloadCount,
    "party_color": partyColor,
    "app_url": appUrl,
    "startdatetime": startdatetime,
    "sangathan_id": sangathanId,
    "creator": creator,
    "is_show_crator": isShowCrator,
    "properties": properties.toJson(),
    "is_dynamic": isDynamic,
    "pinned_position": pinnedPosition,
    "pinned_expire_datetime": pinnedExpireDatetime,
  };
}

class Properties {
  Properties();

  factory Properties.fromJson(Map<String, dynamic> json) => Properties(
  );

  Map<String, dynamic> toJson() => {
  };
}
