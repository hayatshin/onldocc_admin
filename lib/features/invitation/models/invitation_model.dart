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
  final int sendCounts;
  List<String> receiveUsers;

  InvitationModel({
    this.index,
    required this.userId,
    required this.userName,
    required this.userAge,
    required this.userGender,
    required this.userPhone,
    required this.userSubdistrictId,
    this.userContractCommunityId,
    required this.sendCounts,
    required this.receiveUsers,
  });

  InvitationModel.fromJson(Map<String, dynamic> json)
      : index = 0,
        userId = json["userId"],
        userName = json["name"],
        userAge = userAgeCalculation(json["birthYear"], json["birthDay"]),
        userGender = json["gender"],
        userPhone = json["phone"],
        userSubdistrictId = json["subdistrictId"],
        userContractCommunityId = json["contractCommunityId"],
        sendCounts = (json["invitationDate"]).length,
        receiveUsers = removeReceiveNull(json["receiveUsers"]);

  InvitationModel copyWith({
    final int? index,
    final String? userId,
    final String? userName,
    final String? userAge,
    final String? userGender,
    final String? userPhone,
    final String? userSubdistrictId,
    final String? userContractCommunityId,
    final int? sendCounts,
    final List<String>? receiveUsers,
  }) {
    return InvitationModel(
      index: index ?? this.index,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAge: userAge ?? this.userAge,
      userGender: userGender ?? this.userGender,
      userPhone: userPhone ?? this.userPhone,
      userSubdistrictId: userSubdistrictId ?? this.userSubdistrictId,
      sendCounts: sendCounts ?? this.sendCounts,
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

  ReceiveUser.fromJson(Map<String, dynamic> json)
      : index = 0,
        receiveUserId = json["receiveUserId"],
        receiveUserName = json["users"]["name"],
        receiveDate = secondsToYearMonthDayHourMinute(json["createdAt"]);

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

List<String> removeReceiveNull(List<dynamic> receiveUsers) {
  return receiveUsers
      .where((element) => element != null)
      .cast<String>()
      .toList();
}
