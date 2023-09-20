import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onldocc_admin/utils.dart';

class UserModel {
  final int? index;
  final String userId;
  final String name;
  final String age;
  final String fullBirthday;
  final String gender;
  final String phone;
  final String fullRegion;
  final String region;
  final String smallRegion;
  final dynamic community;
  final String registerDate;
  final String? lastVisit;
  final int? totalScore;
  final int? stepScore;
  final int? diaryScore;
  final int? commentScore;

  UserModel({
    required this.index,
    required this.userId,
    required this.name,
    required this.age,
    required this.fullBirthday,
    required this.gender,
    required this.phone,
    required this.fullRegion,
    required this.region,
    required this.smallRegion,
    required this.community,
    required this.registerDate,
    required this.lastVisit,
    required this.totalScore,
    required this.stepScore,
    required this.diaryScore,
    required this.commentScore,
  });

  UserModel.empty()
      : index = 0,
        userId = "",
        name = "",
        age = "",
        fullBirthday = "",
        gender = "",
        phone = "",
        fullRegion = "",
        region = "",
        smallRegion = "",
        community = "",
        registerDate = "",
        lastVisit = "",
        totalScore = 0,
        stepScore = 0,
        diaryScore = 0,
        commentScore = 0;

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "name": name,
      "age": age,
      "fullBirthday": fullBirthday,
      "gender": gender,
      "phone": phone,
      "fullRegion": fullRegion,
      "region": region,
      "smallRegion": smallRegion,
      "community": community,
      "registerDate": registerDate,
      "lastVisit": lastVisit,
      "totalScore": totalScore,
      "stepScore": stepScore,
      "diaryScore": diaryScore,
      "commentScore": commentScore,
    };
  }

  UserModel.fromJson(Map<String, dynamic> json)
      : index = json.containsKey("index") ? json["index"] : 0,
        userId = json.containsKey("userId") ? json["userId"] : "정보 없음",
        name = json.containsKey("name") ? json["name"] : "정보 없음",
        age = json.containsKey("age") ? json["age"] : "정보 없음",
        fullBirthday =
            json.containsKey("fullBirthday") ? json["fullBirthday"] : "정보 없음",
        gender = json.containsKey("gender") ? json["gender"] : "정보 없음",
        phone = json.containsKey("phone") ? json["phone"] : "정보 없음",
        fullRegion =
            json.containsKey("fullRegion") ? json["fullRegion"] : "정보 없음",
        region = json.containsKey("region") ? json["region"] : "",
        smallRegion =
            json.containsKey("smallRegion") ? json["smallRegion"] : "",
        community = json.containsKey("community")
            ? json["commuity"] is String
                ? json["community"]
                : "정보 없음"
            : "정보 없음",
        registerDate =
            json.containsKey("registerDate") ? json["registerDate"] : "정보 없음",
        lastVisit = json.containsKey("lastVisit")
            ? json["lastVisit"] is Timestamp
                ? convertTimettampToString(
                    (json["lastVisit"] as Timestamp).toDate())
                : json["lastVisit"]
            : "",
        totalScore = json.containsKey("totalScore") ? json["totalScore"] : 0,
        stepScore = json.containsKey("stepScore") ? json["stepScore"] : 0,
        diaryScore = json.containsKey("diaryScore") ? json["diaryScore"] : 0,
        commentScore =
            json.containsKey("commentScore") ? json["commentScore"] : 0;

  UserModel copyWith({
    final int? index,
    final String? userId,
    final String? name,
    final String? age,
    final String? fullBirthday,
    final String? gender,
    final String? phone,
    final String? fullRegion,
    final String? region,
    final String? smallRegion,
    final String? community,
    final String? registerDate,
    final String? lastVisit,
    final int? totalScore,
    final int? stepScore,
    final int? diaryScore,
    final int? commentScore,
  }) {
    return UserModel(
      index: index ?? this.index,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      age: age ?? this.age,
      fullBirthday: fullBirthday ?? this.fullBirthday,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      fullRegion: fullRegion ?? this.fullRegion,
      region: region ?? this.region,
      smallRegion: smallRegion ?? this.smallRegion,
      community: community ?? this.community,
      registerDate: registerDate ?? this.registerDate,
      lastVisit: lastVisit ?? this.lastVisit,
      totalScore: totalScore ?? this.totalScore,
      stepScore: stepScore ?? this.stepScore,
      diaryScore: diaryScore ?? this.diaryScore,
      commentScore: commentScore ?? this.commentScore,
    );
  }
}
