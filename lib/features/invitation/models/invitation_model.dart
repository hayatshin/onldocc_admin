import 'package:onldocc_admin/utils.dart';

class InvitationModel {
  final int? index;
  final String userId;
  final String userName;
  final String userAge;
  final String userGender;
  final String userPhone;
  final String userSubdistrictId;
  final String? userContractCommunityId;
  List<ReceiveUser> receiveUsers;

  InvitationModel({
    this.index,
    required this.userId,
    required this.userName,
    required this.userAge,
    required this.userGender,
    required this.userPhone,
    required this.userSubdistrictId,
    this.userContractCommunityId,
    required this.receiveUsers,
  });

  InvitationModel.fromJson(Map<String, dynamic> json)
      : index = 0,
        userId = json["sendUserId"],
        userName = json["sendUsers"]["name"],
        userAge = userAgeCalculation(
            json["sendUsers"]["birthYear"], json["sendUsers"]["birthDay"]),
        userGender = json["sendUsers"]["gender"],
        userPhone = json["sendUsers"]["phone"],
        userSubdistrictId = json["sendUsers"]["subdistrictId"],
        userContractCommunityId = json["sendUsers"]["contractCommunityId"],
        receiveUsers = [
          ReceiveUser.fromJson(json["receiveUsers"], json["createdAt"]),
        ];

  InvitationModel copyWith({
    final int? index,
    final String? userId,
    final String? userName,
    final String? userAge,
    final String? userGender,
    final String? userPhone,
    final String? userSubdistrictId,
    final String? userContractCommunityId,
    final List<ReceiveUser>? receiveUsers,
  }) {
    return InvitationModel(
      index: index ?? this.index,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAge: userAge ?? this.userAge,
      userGender: userGender ?? this.userGender,
      userPhone: userPhone ?? this.userPhone,
      userSubdistrictId: userSubdistrictId ?? this.userSubdistrictId,
      receiveUsers: receiveUsers ?? this.receiveUsers,
    );
  }
}

class ReceiveUser {
  final int? index;
  final String receiveUserId;
  final String receiveUserName;
  final String receiveDate;

  ReceiveUser({
    this.index,
    required this.receiveUserId,
    required this.receiveUserName,
    required this.receiveDate,
  });

  ReceiveUser.fromJson(Map<String, dynamic> json, int createdAt)
      : index = 0,
        receiveUserId = json["userId"],
        receiveUserName = json["name"],
        receiveDate = secondsToYearMonthDayHourMinute(createdAt);

  ReceiveUser copyWith({
    final int? index,
  }) {
    return ReceiveUser(
      index: index ?? this.index,
      receiveUserId: receiveUserId,
      receiveUserName: receiveUserName,
      receiveDate: receiveDate,
    );
  }
}
