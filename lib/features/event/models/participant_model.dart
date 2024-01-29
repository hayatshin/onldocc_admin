class ParticipantModel {
  final String userId;
  final String name;
  final int userAge;
  final String gender;
  final String phone;
  final String subdistrictId;
  final String smallRegion;
  final int createdAt;
  final int totalPoint;

  ParticipantModel({
    required this.userId,
    required this.name,
    required this.userAge,
    required this.gender,
    required this.phone,
    required this.subdistrictId,
    required this.smallRegion,
    required this.createdAt,
    required this.totalPoint,
  });

  ParticipantModel.fromJson(Map<String, dynamic> json)
      : userId = json["users"]["userId"],
        name = json["users"]["name"],
        userAge = json["users"]["userAge"],
        gender = json["users"]["gender"],
        phone = json["users"]["phone"],
        subdistrictId = json["users"]["subdistrictId"],
        smallRegion = "",
        createdAt = json["createdAt"] ?? 0,
        totalPoint = 0;

  ParticipantModel copyWith({
    String? smallRegion,
    int? totalPoint,
  }) {
    return ParticipantModel(
      userId: userId,
      name: name,
      userAge: userAge,
      gender: gender,
      phone: phone,
      subdistrictId: subdistrictId,
      smallRegion: smallRegion ?? this.smallRegion,
      createdAt: createdAt,
      totalPoint: totalPoint ?? this.totalPoint,
    );
  }
}
