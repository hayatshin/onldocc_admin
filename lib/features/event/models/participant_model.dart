import 'package:onldocc_admin/utils.dart';

class ParticipantModel {
  final String userId;
  final String name;
  final String userAge;
  final String gender;
  final String phone;
  final String subdistrictId;
  final String smallRegion;
  final int createdAt;

  final int? stepPoint;
  final int? diaryPoint;
  final int? commentPoint;
  final int? likePoint;
  final int? invitationPoint;

  final int? diaryCount;
  final int? commentCount;
  final int? likeCount;
  final int? invitationCount;

  // user-point-count
  final int? userStepPoint;
  final int? userDiaryPoint;
  final int? userCommentPoint;
  final int? userLikePoint;
  final int? userInvitationPoint;
  final int? userTotalPoint;
  final int? userDiaryCount;
  final int? userCommentCount;
  final int? userLikeCount;
  final int? userInvitationCount;
  final bool? userAchieveOrNot;

  ParticipantModel({
    required this.userId,
    required this.name,
    required this.userAge,
    required this.gender,
    required this.phone,
    required this.subdistrictId,
    required this.smallRegion,
    required this.createdAt,
    this.stepPoint,
    this.diaryPoint,
    this.commentPoint,
    this.likePoint,
    this.invitationPoint,
    this.diaryCount,
    this.commentCount,
    this.likeCount,
    this.invitationCount,
    this.userStepPoint,
    this.userDiaryPoint,
    this.userCommentPoint,
    this.userLikePoint,
    this.userInvitationPoint,
    this.userTotalPoint,
    this.userDiaryCount,
    this.userCommentCount,
    this.userLikeCount,
    this.userInvitationCount,
    this.userAchieveOrNot,
  });

  ParticipantModel.fromJson(Map<String, dynamic> json)
      : userId = json["users"]["userId"],
        name = json["users"]["name"],
        userAge = userAgeCalculation(
            json["users"]["birthYear"], json["users"]["birthDay"]),
        gender = json["users"]["gender"],
        phone = json["users"]["phone"],
        subdistrictId = json["users"]["subdistrictId"],
        smallRegion = "",
        createdAt = json["createdAt"] ?? 0,
        stepPoint = json["stepPoint"] ?? 0,
        diaryPoint = json["diaryPoint"] ?? 0,
        commentPoint = json["commentPoint"] ?? 0,
        likePoint = json["likePoint"] ?? 0,
        invitationPoint = json["invitationPoint"] ?? 0,
        diaryCount = json["diaryCount"] ?? 0,
        commentCount = json["commentCount"] ?? 0,
        likeCount = json["likeCount"] ?? 0,
        invitationCount = json["invitationCount"] ?? 0,
        userStepPoint = 0,
        userDiaryPoint = 0,
        userCommentPoint = 0,
        userLikePoint = 0,
        userInvitationPoint = 0,
        userTotalPoint = 0,
        userDiaryCount = 0,
        userCommentCount = 0,
        userLikeCount = 0,
        userInvitationCount = 0,
        userAchieveOrNot = false;

  ParticipantModel copyWith({
    String? smallRegion,
    int? stepPoint,
    int? diaryPoint,
    int? commentPoint,
    int? likePoint,
    int? invitationPoint,
    int? diaryCount,
    int? commentCount,
    int? likeCount,
    int? invitationCount,
    int? userStepPoint,
    int? userDiaryPoint,
    int? userCommentPoint,
    int? userLikePoint,
    int? userInvitationPoint,
    int? userTotalPoint,
    int? userDiaryCount,
    int? userCommentCount,
    int? userLikeCount,
    int? userInvitationCount,
    bool? userAchieveOrNot,
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
      stepPoint: stepPoint ?? this.stepPoint,
      diaryPoint: diaryPoint ?? this.diaryPoint,
      commentPoint: commentPoint ?? this.commentPoint,
      likePoint: likePoint ?? this.likePoint,
      invitationPoint: invitationPoint ?? this.invitationPoint,
      diaryCount: diaryCount ?? this.diaryCount,
      commentCount: commentCount ?? this.commentCount,
      likeCount: likeCount ?? this.likeCount,
      invitationCount: invitationCount ?? this.invitationCount,
      userStepPoint: userStepPoint ?? this.userStepPoint,
      userDiaryPoint: userDiaryPoint ?? this.userDiaryPoint,
      userCommentPoint: userCommentPoint ?? this.userCommentPoint,
      userLikePoint: userLikePoint ?? this.userLikePoint,
      userInvitationPoint: userInvitationPoint ?? this.userInvitationPoint,
      userTotalPoint: userTotalPoint ?? this.userTotalPoint,
      userDiaryCount: userDiaryCount ?? this.userDiaryCount,
      userCommentCount: userCommentCount ?? this.userCommentCount,
      userLikeCount: userLikeCount ?? this.userLikeCount,
      userInvitationCount: userInvitationCount ?? this.userInvitationCount,
      userAchieveOrNot: userAchieveOrNot ?? this.userAchieveOrNot,
    );
  }
}
