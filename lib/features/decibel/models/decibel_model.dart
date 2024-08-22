import 'package:onldocc_admin/utils.dart';

class DecibelModel {
  final String decibelId;
  final String userId;
  final String decibel;
  final int createdAt;
  final String name;
  final String age;
  final String gender;
  final String phone;
  final String? contractCommunityId;

  DecibelModel({
    required this.decibelId,
    required this.userId,
    required this.decibel,
    required this.createdAt,
    required this.name,
    required this.age,
    required this.gender,
    required this.phone,
    this.contractCommunityId,
  });

  DecibelModel.fromJson(Map<String, dynamic> json)
      : decibelId = json["decibelId"] ?? "",
        userId = json["userId"] ?? "",
        decibel = json["decibel"] ?? "",
        createdAt = json["createdAt"] ?? 0,
        name = json["users"]["name"] ?? "",
        age = json["users"]["birthYear"] != null &&
                json["users"]["birthDay"] != null
            ? userAgeCalculation(
                json["users"]["birthYear"], json["users"]["birthDay"])
            : "0",
        gender = json["users"]["gender"] ?? "",
        phone = json["users"]["phone"] ?? "",
        contractCommunityId = json["users"]["contractCommunityId"] ?? "";
}
