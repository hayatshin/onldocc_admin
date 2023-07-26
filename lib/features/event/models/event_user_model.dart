import 'package:cloud_firestore/cloud_firestore.dart';

class EventUserModel {
  final int? index;
  final String? userId;
  final String? name;
  final String? age;
  final String? gender;
  final String? phone;
  final String? fullRegion;
  final DateTime? participateDate;
  final int? userPoint;
  final bool? goalOrNot;

  EventUserModel(
      {required this.index,
      required this.userId,
      required this.name,
      required this.age,
      required this.gender,
      required this.phone,
      required this.fullRegion,
      required this.participateDate,
      required this.userPoint,
      required this.goalOrNot});

  EventUserModel.empty()
      : index = 0,
        userId = "",
        name = "",
        age = "",
        gender = "",
        phone = "",
        fullRegion = "",
        participateDate = DateTime.now(),
        userPoint = 0,
        goalOrNot = false;

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "name": name,
      "age": age,
      "gender": gender,
      "phone": phone,
      "fullRegion": fullRegion,
      "participateDate": participateDate as Timestamp,
      "userPoint": userPoint,
      "goalOrNot": goalOrNot,
    };
  }

  EventUserModel.fromJson(Map<String, dynamic> json)
      : index = json["index"],
        userId = json["userId"],
        name = json["name"],
        age = json["age"] ?? "정보 없음",
        gender = json["gender"] ?? "정보 없음",
        phone = json["phone"] ?? "정보 없음",
        fullRegion = json["fullRegion"] ?? "정보 없음",
        participateDate = json["participateDate"],
        userPoint = json["userPoint"] ?? 0,
        goalOrNot = json["goalOrNot"] ?? false;

  EventUserModel copyWith({
    final int? index,
    final String? userId,
    final String? name,
    final String? age,
    final String? gender,
    final String? phone,
    final String? fullRegion,
    final DateTime? participateDate,
    final int? userPoint,
    final bool? goalOrNot,
  }) {
    return EventUserModel(
      index: index ?? this.index,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      fullRegion: fullRegion ?? this.fullRegion,
      participateDate: participateDate ?? this.participateDate,
      userPoint: userPoint ?? this.userPoint,
      goalOrNot: goalOrNot ?? this.goalOrNot,
    );
  }
}
