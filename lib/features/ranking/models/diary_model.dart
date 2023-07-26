import 'package:cloud_firestore/cloud_firestore.dart';

class DiaryModel {
  final String userId;
  final String diaryId;
  final String monthDate;
  final DateTime timestamp;
  final bool secret;
  final List<dynamic> images;
  final TodayMood todayMood;
  final int numLikes;
  final int numComments;
  final String todayDiary;
  final List<dynamic> blockedBy;

  DiaryModel({
    required this.userId,
    required this.diaryId,
    required this.monthDate,
    required this.timestamp,
    required this.secret,
    required this.images,
    required this.todayMood,
    required this.numLikes,
    required this.numComments,
    required this.todayDiary,
    required this.blockedBy,
  });

  DiaryModel.empty()
      : userId = "",
        diaryId = "",
        monthDate = "",
        timestamp = DateTime.now(),
        secret = false,
        images = [],
        todayMood = TodayMood.empty(),
        numLikes = 0,
        numComments = 0,
        todayDiary = "",
        blockedBy = [];

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "diaryId": diaryId,
      "monthDate": monthDate,
      "timestamp": timestamp,
      "secret": secret,
      "images": images,
      "todayMood": todayMood,
      "numLikes": numLikes,
      "numComments": numComments,
      "todayDiary": todayDiary,
      "blockedBy": blockedBy,
    };
  }

  DiaryModel.fromJson(Map<String, dynamic> json)
      : userId = json["userId"] ?? "",
        diaryId = json["diaryId"] ?? "",
        monthDate = json["monthDate"] ?? "",
        timestamp = (json["timestamp"] as Timestamp).toDate(),
        secret = json["secret"] ?? false,
        images = json["images"] ?? [],
        todayMood = TodayMood.fromJson(json["todayMood"]),
        numLikes = json["numLikes"] ?? 0,
        numComments = json["numComments"] ?? 0,
        todayDiary = json["todayDiary"] ?? "",
        blockedBy = json["blockedBy"] ?? [];

  DiaryModel copyWith({
    final String? userId,
    final String? diaryId,
    final String? monthDate,
    final DateTime? timestamp,
    final bool? secret,
    final List<dynamic>? images,
    final TodayMood? todayMood,
    final int? numLikes,
    final int? numComments,
    final String? todayDiary,
    final List<dynamic>? blockedBy,
  }) {
    return DiaryModel(
      userId: userId ?? this.userId,
      diaryId: diaryId ?? this.diaryId,
      monthDate: monthDate ?? this.monthDate,
      timestamp: timestamp ?? this.timestamp,
      secret: secret ?? this.secret,
      images: images ?? this.images,
      todayMood: todayMood ?? this.todayMood,
      numLikes: numLikes ?? this.numLikes,
      numComments: numComments ?? this.numComments,
      todayDiary: todayDiary ?? this.todayDiary,
      blockedBy: blockedBy ?? this.blockedBy,
    );
  }
}

class TodayMood {
  final String? description;
  final int? image;
  final int? position;

  TodayMood({
    required this.description,
    required this.image,
    required this.position,
  });

  TodayMood.empty()
      : description = "",
        image = 0,
        position = 0;

  TodayMood.fromJson(Map<String, dynamic> json)
      : description = json["description"],
        image = json["image"],
        position = json["position"];

  Map<String, dynamic> toJson() {
    return {
      "description": description,
      "image": image,
      "position": position,
    };
  }
}
