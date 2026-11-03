// To parse this JSON data, do
//
//     final allPostModel = allPostModelFromJson(jsonString);

import 'dart:convert';

AllPostModel allPostModelFromJson(String str) => AllPostModel.fromJson(json.decode(str));

String allPostModelToJson(AllPostModel data) => json.encode(data.toJson());

class AllPostModel {
  bool status;
  List<Datum> data;
  String msg;

  AllPostModel({
    required this.status,
    required this.data,
    required this.msg,
  });

  factory AllPostModel.fromJson(Map<String, dynamic> json) => AllPostModel(
    status: json["status"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    msg: json["msg"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "msg": msg,
  };
}

class Datum {
  int id;
  String type;
  Data data;
  String rn;

  Datum({
    required this.id,
    required this.type,
    required this.data,
    required this.rn,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    type: json["type"],
    data: Data.fromJson(json["data"]),
    rn: json["rn"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
    "data": data.toJson(),
    "rn": rn,
  };
}

class Data {
  int id;
  String title;
  String? sharingContent;
  String? postUrl;
  String? avatarPostion;
  String? avatarShape;
  String? postType;
  DateTime? startDate;
  String? startTime;
  DateTime? endDate;
  String? endTime;
  DateTime createdAt;
  DateTime? updatedAt;
  List<int>? tagList;
  dynamic nameColorCode;
  dynamic namePlate;
  dynamic partyLogo;
  dynamic partyName;
  int? partyId;
  String? language;
  int? sharedCount;
  int? downloadCount;
  String? partyColor;
  String? appUrl;
  String? startdatetime;
  int? sangathanId;
  String? creator;
  bool? isShowCrator;
  Properties? properties;
  bool? isDynamic;
  int? pinnedPosition;
  String? pinnedExpireDatetime;
  String? wallpaperUrl;
  bool? isDeleted;
  int? godId;
  String? description;
  String? alarmUrl;
  String? ringtoneUrl;
  String? mantraUrl;
  String? thumbnail;

  Data({
    required this.id,
    required this.title,
    this.sharingContent,
    this.postUrl,
    this.avatarPostion,
    this.avatarShape,
    this.postType,
    this.startDate,
    this.startTime,
    this.endDate,
    this.endTime,
    required this.createdAt,
    this.updatedAt,
    this.tagList,
    this.nameColorCode,
    this.namePlate,
    this.partyLogo,
    this.partyName,
    this.partyId,
    this.language,
    this.sharedCount,
    this.downloadCount,
    this.partyColor,
    this.appUrl,
    this.startdatetime,
    this.sangathanId,
    this.creator,
    this.isShowCrator,
    this.properties,
    this.isDynamic,
    this.pinnedPosition,
    this.pinnedExpireDatetime,
    this.wallpaperUrl,
    this.isDeleted,
    this.godId,
    this.description,
    this.alarmUrl,
    this.ringtoneUrl,
    this.mantraUrl,
    this.thumbnail,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    title: json["title"],
    sharingContent: json["sharing_content"],
    postUrl: json["post_url"],
    avatarPostion: json["avatar_postion"],
    avatarShape: json["avatar_shape"],
    postType: json["post_type"],
    startDate: json["start_date"] == null ? null : DateTime.parse(json["start_date"]),
    startTime: json["start_time"],
    endDate: json["end_date"] == null ? null : DateTime.parse(json["end_date"]),
    endTime: json["end_time"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    tagList: json["tag_list"] == null ? [] : List<int>.from(json["tag_list"]!.map((x) => x)),
    nameColorCode: json["name_color_code"],
    namePlate: json["name_plate"],
    partyLogo: json["party_logo"],
    partyName: json["party_name"],
    partyId: json["party_id"],
    language: json["language"] as String?,
    sharedCount: json["shared_count"],
    downloadCount: json["download_count"],
    partyColor: json["party_color"],
    appUrl: json["app_url"],
    startdatetime: json["startdatetime"],
    sangathanId: json["sangathan_id"],
    creator: json["creator"],
    isShowCrator: json["is_show_crator"],
    properties: json["properties"] == null ? null : Properties.fromJson(json["properties"]),
    isDynamic: json["is_dynamic"],
    pinnedPosition: json["pinned_position"],
    pinnedExpireDatetime: json["pinned_expire_datetime"],
    wallpaperUrl: json["wallpaper_url"],
    isDeleted: json["is_deleted"],
    godId: json["god_id"],
    description: json["description"],
    alarmUrl: json["alarm_url"],
    ringtoneUrl: json["ringtone_url"],
    mantraUrl: json["mantra_url"],
    thumbnail: json["thumbnail"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "sharing_content": sharingContent,
    "post_url": postUrl,
    "avatar_postion": avatarPostion,
    "avatar_shape": avatarShape,
    "post_type": postType,
    "start_date": startDate?.toIso8601String(),
    "start_time": startTime,
    "end_date": "${endDate!.year.toString().padLeft(4, '0')}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}",
    "end_time": endTime,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "tag_list": tagList == null ? [] : List<dynamic>.from(tagList!.map((x) => x)),
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
    "properties": properties?.toJson(),
    "is_dynamic": isDynamic,
    "pinned_position": pinnedPosition,
    "pinned_expire_datetime": pinnedExpireDatetime,
    "wallpaper_url": wallpaperUrl,
    "is_deleted": isDeleted,
    "god_id": godId,
    "description": description,
    "alarm_url": alarmUrl,
    "ringtone_url": ringtoneUrl,
    "mantra_url": mantraUrl,
    "thumbnail": thumbnail,
  };
}

class Properties {
  Properties();

  factory Properties.fromJson(Map<String, dynamic> json) => Properties(
  );

  Map<String, dynamic> toJson() => {
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
