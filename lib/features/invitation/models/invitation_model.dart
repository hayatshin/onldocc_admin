import 'package:onldocc_admin/utils.dart';

class InvitationModel {
  final int? index;
  final String userName;
  final String userAge;
  final String userGender;
  final String userPhone;
  final String userSubdistrictId;
  final String? userContractCommunityId;
  final int invitationCount;
  final List<dynamic> invitationDates;

  InvitationModel({
    this.index,
    required this.userName,
    required this.userAge,
    required this.userGender,
    required this.userPhone,
    required this.userSubdistrictId,
    this.userContractCommunityId,
    required this.invitationCount,
    required this.invitationDates,
  });

  InvitationModel.fromJson(Map<String, dynamic> json)
      : index = 0,
        userName = json["name"],
        userAge = userAgeCalculation(json["birthYear"], json["birthDay"]),
        userGender = json["gender"],
        userPhone = json["phone"],
        userSubdistrictId = json["subdistrictId"],
        userContractCommunityId = json["contractCommunityId"],
        invitationCount = json["invitationCount"],
        invitationDates = json["invitationDate"]
            .map((dynamic item) => secondsToYearMonthDayHourMinute(item))
            .toList();

  InvitationModel copyWith({
    final int? index,
    final String? userName,
    final String? userAge,
    final String? userGender,
    final String? userPhone,
    final String? userSubdistrictId,
    final String? userContractCommunityId,
    final int? invitationCount,
    final List<dynamic>? invitationDates,
  }) {
    return InvitationModel(
      index: index ?? this.index,
      userName: userName ?? this.userName,
      userAge: userAge ?? this.userAge,
      userGender: userGender ?? this.userGender,
      userPhone: userPhone ?? this.userPhone,
      userSubdistrictId: userSubdistrictId ?? this.userSubdistrictId,
      invitationCount: invitationCount ?? this.invitationCount,
      invitationDates: invitationDates ?? this.invitationDates,
    );
  }
}
