import 'package:onldocc_admin/utils.dart';

class UserModel {
  final int? index;
  final String userId;
  final String name;
  final String? userAge;
  final String? userAgeGroup;
  final String birthYear;
  final String birthDay;
  final String gender;
  final String phone;
  final String fullRegion;
  final String contractCommunityId;
  final int createdAt;
  final int? lastVisit;
  final int? partnerDates;
  final int? totalPoint;
  final int? stepPoint;
  final int? diaryPoint;
  final int? commentPoint;
  final int? likePoint;

  // final int? invitationPoint;

  UserModel({
    required this.index,
    required this.userId,
    required this.name,
    this.userAge,
    this.userAgeGroup,
    required this.birthYear,
    required this.birthDay,
    required this.gender,
    required this.phone,
    required this.fullRegion,
    required this.contractCommunityId,
    required this.createdAt,
    required this.lastVisit,
    required this.partnerDates,
    required this.totalPoint,
    required this.stepPoint,
    required this.diaryPoint,
    required this.commentPoint,
    required this.likePoint,
    // required this.invitationPoint,
  });

  UserModel.empty()
      : index = 0,
        userId = "",
        name = "",
        userAge = "",
        userAgeGroup = "",
        birthYear = "",
        birthDay = "",
        gender = "",
        phone = "",
        fullRegion = "",
        contractCommunityId = "",
        createdAt = 0,
        lastVisit = 0,
        partnerDates = 0,
        totalPoint = 0,
        stepPoint = 0,
        diaryPoint = 0,
        commentPoint = 0,
        likePoint = 0;

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "name": name,
      "birthYear": birthYear,
      "birthDay": birthDay,
      "gender": gender,
      "phone": phone,
      "fullRegion": fullRegion,
      "contractCommunityId": contractCommunityId,
      "createdAt": createdAt,
      "lastVisit": lastVisit,
      "partnerDates": partnerDates,
      "totalPoint": totalPoint,
      "stepPoint": stepPoint,
      "diaryPoint": diaryPoint,
      "commentPoint": commentPoint,
      "likePoint": likePoint,
      // "invitationPoint": invitationPoint,
    };
  }

  UserModel.fromJson(Map<String, dynamic> json)
      : index = json.containsKey("index") ? json["index"] : 0,
        userId = json.containsKey("userId") ? json["userId"] : "-",
        name = json.containsKey("name") ? json["name"] : "-",
        userAge = userAgeCalculation(json["birthYear"], json["birthDay"]),
        userAgeGroup =
            userAgeGroupCalculation(json["birthYear"], json["birthDay"]),
        birthYear = json.containsKey("birthYear") ? json['birthYear'] : "-",
        birthDay = json.containsKey("birthDay") ? json['birthDay'] : "-",
        gender = json.containsKey("gender") ? json["gender"] : "-",
        phone = json.containsKey("phone") ? json["phone"] : "-",
        fullRegion =
            json.containsKey("subdistricts") && json["subdistricts"] != null
                ? json["subdistricts"]["subdistrict"]
                : "-",
        contractCommunityId = json["contractCommunityId"] ?? "",
        createdAt = json["createdAt"] ?? 0,
        lastVisit = json.containsKey("lastVisit") && json["lastVisit"] != null
            ? json["lastVisit"]
            : 0,
        partnerDates =
            json.containsKey("partnerDates") && json["partnerDates"] != null
                ? json["partnerDates"]
                : 0,
        totalPoint = json.containsKey("totalPoint") ? json["totalPoint"] : 0,
        stepPoint = json.containsKey("stepPoint") ? json["stepPoint"] : 0,
        diaryPoint = json.containsKey("diaryPoint") ? json["diaryPoint"] : 0,
        commentPoint =
            json.containsKey("commentPoint") ? json["commentPoint"] : 0,
        likePoint = json.containsKey("likePoint") ? json["likePoint"] : 0;

  UserModel copyWith({
    final int? index,
    final String? userId,
    final String? name,
    final String? userAge,
    final String? userAgeGroup,
    final String? birthYear,
    final String? birthDay,
    final String? gender,
    final String? phone,
    final String? fullRegion,
    final String? contractCommunityId,
    final int? createdAt,
    final int? lastVisit,
    final int? partnerDates,
    final int? totalPoint,
    final int? stepPoint,
    final int? diaryPoint,
    final int? commentPoint,
    final int? likePoint,
    // final int? invitationPoint,
  }) {
    return UserModel(
      index: index ?? this.index,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      userAge: userAge ?? this.userAge,
      userAgeGroup: userAgeGroup ?? this.userAgeGroup,
      birthYear: birthYear ?? this.birthYear,
      birthDay: birthDay ?? this.birthDay,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      fullRegion: fullRegion ?? this.fullRegion,
      contractCommunityId: contractCommunityId ?? this.contractCommunityId,
      createdAt: createdAt ?? this.createdAt,
      lastVisit: lastVisit ?? this.lastVisit,
      partnerDates: partnerDates ?? this.partnerDates,
      totalPoint: totalPoint ?? this.totalPoint,
      stepPoint: stepPoint ?? this.stepPoint,
      diaryPoint: diaryPoint ?? this.diaryPoint,
      commentPoint: commentPoint ?? this.commentPoint,
      likePoint: likePoint ?? this.likePoint,
      // invitationPoint: invitationPoint ?? this.invitationPoint,
    );
  }
}
