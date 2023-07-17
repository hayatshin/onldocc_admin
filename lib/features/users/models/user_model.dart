class UserModel {
  final int? index;
  final String userId;
  final String name;
  final String age;
  final String fullBirthday;
  final String gender;
  final String phone;
  final String fullRegion;
  final String registerDate;
  final String lastVisit;
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
      "registerDate": registerDate,
      "lastVisit": lastVisit,
      "totalScore": totalScore,
      "stepScore": stepScore,
      "diaryScore": diaryScore,
      "commentScore": commentScore,
    };
  }

  UserModel.fromJson(Map<String, dynamic> json)
      : index = json["index"],
        userId = json["userId"],
        name = json["name"],
        age = json["age"] ?? "정보 없음",
        fullBirthday = json["fullBirthday"] ?? "정보 없음",
        gender = json["gender"] ?? "정보 없음",
        phone = json["phone"] ?? "정보 없음",
        fullRegion = json["fullRegion"] ?? "정보 없음",
        registerDate = json["registerDate"] ?? "정보 없음",
        lastVisit = json["lastVisit"] ?? "정보 없음",
        totalScore = json["totalScore"] ?? 0,
        stepScore = json["stepScore"] ?? 0,
        diaryScore = json["diaryScore"] ?? 0,
        commentScore = json["commentScore"] ?? 0;

  UserModel copyWith({
    final int? index,
    final String? userId,
    final String? name,
    final String? age,
    final String? fullBirthday,
    final String? gender,
    final String? phone,
    final String? fullRegion,
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
      registerDate: registerDate ?? this.registerDate,
      lastVisit: lastVisit ?? this.lastVisit,
      totalScore: totalScore ?? this.totalScore,
      stepScore: stepScore ?? this.stepScore,
      diaryScore: diaryScore ?? this.diaryScore,
      commentScore: commentScore ?? this.commentScore,
    );
  }
}
