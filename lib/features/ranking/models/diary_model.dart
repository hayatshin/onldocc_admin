import 'package:onldocc_admin/utils.dart';

class DiaryModel {
  final String userId;
  final String diaryId;
  final int createdAt;
  final String secretType;
  final int todayMood;
  final int numLikes;
  final int numComments;
  final String todayDiary;
  final List<String>? images;
  final bool? notice;
  final String? userSubdistrictId;
  final String? userContractCommunityId;
  final bool? noticeTopFixed;
  final int? noticeFixedAt;

  DiaryModel({
    required this.userId,
    required this.diaryId,
    required this.createdAt,
    required this.secretType,
    required this.todayMood,
    required this.numLikes,
    required this.numComments,
    required this.todayDiary,
    this.images,
    this.notice,
    this.userSubdistrictId,
    this.userContractCommunityId,
    this.noticeTopFixed,
    this.noticeFixedAt,
  });

  DiaryModel.empty()
      : userId = "",
        diaryId = "",
        createdAt = 0,
        secretType = "전체 공개",
        todayMood = 0,
        numLikes = 0,
        numComments = 0,
        todayDiary = "",
        images = [],
        notice = false,
        userSubdistrictId = "",
        userContractCommunityId = "",
        noticeTopFixed = false,
        noticeFixedAt = 0;

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "diaryId": diaryId,
      "createdAt": createdAt,
      "secretType": secretType,
      "todayMood": todayMood,
      "numLikes": numLikes,
      "numComments": numComments,
      "todayDiary": todayDiary,
      "notice": notice,
      "noticeTopFixed": noticeTopFixed,
      "noticeFixedAt": noticeFixedAt,
    };
  }

  DiaryModel.fromJson(Map<String, dynamic> json)
      : userId = json["userId"],
        diaryId = json["diaryId"],
        createdAt = json["createdAt"],
        secretType = json["secretType"] ?? "전체 공개",
        todayMood = json["todayMood"],
        numLikes = json.containsKey("numLikes") ? json["numLikes"] : 0,
        numComments = json.containsKey("numComments") ? json["numComments"] : 0,
        todayDiary = json.containsKey("todayDiary") ? json["todayDiary"] : "",
        images =
            json.containsKey("images") ? spreadDiaryImages(json["images"]) : [],
        notice = json.containsKey("notice") ? json["notice"] : false,
        userSubdistrictId = json["users"]["subdistrictId"],
        userContractCommunityId = json["users"]["contractCommunityId"],
        noticeTopFixed =
            json.containsKey("noticeTopFixed") ? json["noticeTopFixed"] : false,
        noticeFixedAt =
            json.containsKey("noticeFixedAt") ? json["noticeFixedAt"] : false;

  DiaryModel copyWith({
    final String? userId,
    final String? diaryId,
    final String? monthDate,
    final int? createdAt,
    final String? secretType,
    final dynamic todayMood,
    final int? numLikes,
    final int? numComments,
    final String? todayDiary,
    final List<String>? images,
    final bool? notice,
    final String? userSubdistrictId,
    final String? userContractCommunityId,
    final bool? noticeTopFixed,
    final int? noticeFixedAt,
  }) {
    return DiaryModel(
      userId: userId ?? this.userId,
      diaryId: diaryId ?? this.diaryId,
      createdAt: createdAt ?? this.createdAt,
      secretType: secretType ?? this.secretType,
      todayMood: todayMood ?? this.todayMood,
      numLikes: numLikes ?? this.numLikes,
      numComments: numComments ?? this.numComments,
      todayDiary: todayDiary ?? this.todayDiary,
      images: images ?? this.images,
      notice: notice ?? this.notice,
      userSubdistrictId: userSubdistrictId ?? this.userSubdistrictId,
      userContractCommunityId:
          userContractCommunityId ?? this.userContractCommunityId,
      noticeTopFixed: noticeTopFixed ?? this.noticeTopFixed,
      noticeFixedAt: noticeFixedAt ?? this.noticeFixedAt,
    );
  }
}

// class TodayMood {
//   final String? description;
//   final int? image;
//   final int? position;

//   TodayMood({
//     required this.description,
//     required this.image,
//     required this.position,
//   });

//   TodayMood.empty()
//       : description = "",
//         image = 0,
//         position = 0;

//   TodayMood.fromJson(Map<String, dynamic> json)
//       : description = json["description"],
//         image = json["image"],
//         position = json["position"];

//   Map<String, dynamic> toJson() {
//     return {
//       "description": description,
//       "image": image,
//       "position": position,
//     };
//   }
// }
