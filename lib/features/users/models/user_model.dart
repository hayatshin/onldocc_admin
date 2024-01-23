class UserModel {
  final int? index;
  final String userId;
  final String name;
  final int userAge;
  final String birthYear;
  final String birthDay;
  final String gender;
  final String phone;
  final String fullRegion;
  final dynamic community;
  final int createdAt;
  final int? lastVisit;
  final int? totalScore;
  final int? stepScore;
  final int? diaryScore;
  final int? commentScore;

  UserModel({
    required this.index,
    required this.userId,
    required this.name,
    required this.userAge,
    required this.birthYear,
    required this.birthDay,
    required this.gender,
    required this.phone,
    required this.fullRegion,
    required this.community,
    required this.createdAt,
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
        userAge = 0,
        birthYear = "",
        birthDay = "",
        gender = "",
        phone = "",
        fullRegion = "",
        community = "",
        createdAt = 0,
        lastVisit = 0,
        totalScore = 0,
        stepScore = 0,
        diaryScore = 0,
        commentScore = 0;

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "name": name,
      "userAge": userAge,
      "birthYear": birthYear,
      "birthDay": birthDay,
      "gender": gender,
      "phone": phone,
      "fullRegion": fullRegion,
      "community": community,
      "createdAt": createdAt,
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
        userAge = json.containsKey("userAge") ? json["userAge"] : 0,
        birthYear = json.containsKey("birthYear") ? json['birthYear'] : "정보 없음",
        birthDay = json.containsKey("birthDay") ? json['birthDay'] : "정보 없음",
        gender = json.containsKey("gender") ? json["gender"] : "정보 없음",
        phone = json.containsKey("phone") ? json["phone"] : "정보 없음",
        fullRegion = json["subdistricts"] != null
            ? json["subdistricts"]["subdistrict"]
            : "정보 없음",
        community = "",
        createdAt = json["createdAt"] ?? 0,
        lastVisit = json["lastVisit"] ?? 0,
        totalScore = json.containsKey("totalScore") ? json["totalScore"] : 0,
        stepScore = json.containsKey("stepScore") ? json["stepScore"] : 0,
        diaryScore = json.containsKey("diaryScore") ? json["diaryScore"] : 0,
        commentScore =
            json.containsKey("commentScore") ? json["commentScore"] : 0;

  UserModel copyWith({
    final int? index,
    final String? userId,
    final String? name,
    final int? userAge,
    final String? birthYear,
    final String? birthDay,
    final String? gender,
    final String? phone,
    final String? fullRegion,
    final String? community,
    final int? createdAt,
    final int? lastVisit,
    final int? totalScore,
    final int? stepScore,
    final int? diaryScore,
    final int? commentScore,
  }) {
    return UserModel(
      index: index ?? this.index,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      userAge: userAge ?? this.userAge,
      birthYear: birthYear ?? this.birthYear,
      birthDay: birthDay ?? this.birthDay,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      fullRegion: fullRegion ?? this.fullRegion,
      community: community ?? this.community,
      createdAt: createdAt ?? this.createdAt,
      lastVisit: lastVisit ?? this.lastVisit,
      totalScore: totalScore ?? this.totalScore,
      stepScore: stepScore ?? this.stepScore,
      diaryScore: diaryScore ?? this.diaryScore,
      commentScore: commentScore ?? this.commentScore,
    );
  }
}
