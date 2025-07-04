import 'package:onldocc_admin/utils.dart';

class CareModel {
  final String userId;
  final String name;
  final String age;
  final String gender;
  final String phone;
  final int lastVisit;
  final String? contractCommunityId;
  final bool? careAlarm;
  final bool? agreed;
  final bool partnerContact;
  final int? partnerDates;

  CareModel({
    required this.userId,
    required this.name,
    required this.age,
    required this.gender,
    required this.phone,
    required this.lastVisit,
    this.contractCommunityId,
    this.careAlarm,
    this.agreed,
    required this.partnerContact,
    this.partnerDates,
  });

  CareModel.fromJson(Map<String, dynamic> json)
      : userId = json["users"]?["userId"] ?? "",
        name = json["users"]["name"],
        age = json["users"]["birthYear"] != null &&
                json["users"]["birthDay"] != null
            ? userAgeCalculation(
                json["users"]["birthYear"], json["users"]["birthDay"])
            : "00",
        gender = json["users"]["gender"],
        phone = json["users"]["phone"],
        lastVisit = json["users"]["lastVisit"],
        contractCommunityId = json["users"]["contractCommunityId"],
        careAlarm = json["careAlarm"],
        agreed = json["agreed"],
        partnerContact = false,
        partnerDates = 1;

  CareModel copyWith({
    final bool? partnerContact,
  }) {
    return CareModel(
      userId: userId,
      name: name,
      age: age,
      gender: gender,
      phone: phone,
      lastVisit: lastVisit,
      contractCommunityId: contractCommunityId,
      careAlarm: careAlarm,
      agreed: agreed,
      partnerContact: partnerContact ?? this.partnerContact,
      partnerDates: partnerDates,
    );
  }
}
