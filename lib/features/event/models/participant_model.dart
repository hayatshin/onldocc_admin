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
  final bool gift;

  final int? stepPoint;
  final int? diaryPoint;
  final int? commentPoint;
  final int? likePoint;
  final int? invitationPoint;
  final int? quizPoint;

  final int? diaryCount;
  final int? commentCount;
  final int? likeCount;
  final int? invitationCount;
  final int? quizCount;

  // user-point-count
  final int? userStepPoint;
  final int? userDiaryPoint;
  final int? userCommentPoint;
  final int? userLikePoint;
  final int? userInvitationPoint;
  final int? userQuizPoint;
  final int? userTotalPoint;
  final int? userDiaryCount;
  final int? userCommentCount;
  final int? userLikeCount;
  final int? userInvitationCount;
  final int? userQuizCount;
  final bool? userAchieveOrNot;

  final int? quizAnswer;
  final String? photo;
  final String? photoTitle;

  ParticipantModel({
    required this.userId,
    required this.name,
    required this.userAge,
    required this.gender,
    required this.phone,
    required this.subdistrictId,
    required this.smallRegion,
    required this.createdAt,
    required this.gift,
    this.stepPoint,
    this.diaryPoint,
    this.commentPoint,
    this.likePoint,
    this.invitationPoint,
    this.quizPoint,
    this.diaryCount,
    this.commentCount,
    this.likeCount,
    this.invitationCount,
    this.quizCount,
    this.userStepPoint,
    this.userDiaryPoint,
    this.userCommentPoint,
    this.userLikePoint,
    this.userInvitationPoint,
    this.userQuizPoint,
    this.userTotalPoint,
    this.userDiaryCount,
    this.userCommentCount,
    this.userLikeCount,
    this.userInvitationCount,
    this.userQuizCount,
    this.userAchieveOrNot,
    this.quizAnswer,
    this.photo,
    this.photoTitle,
  });

  ParticipantModel.empty()
      : userId = "",
        name = "",
        userAge = "",
        gender = "",
        phone = "",
        subdistrictId = "",
        smallRegion = "",
        createdAt = 0,
        gift = false,
        stepPoint = 0,
        diaryPoint = 0,
        commentPoint = 0,
        likePoint = 0,
        invitationPoint = 0,
        quizPoint = 0,
        diaryCount = 0,
        commentCount = 0,
        likeCount = 0,
        invitationCount = 0,
        quizCount = 0,
        userStepPoint = 0,
        userDiaryPoint = 0,
        userCommentPoint = 0,
        userLikePoint = 0,
        userInvitationPoint = 0,
        userQuizPoint = 0,
        userTotalPoint = 0,
        userDiaryCount = 0,
        userCommentCount = 0,
        userLikeCount = 0,
        userInvitationCount = 0,
        userQuizCount = 0,
        userAchieveOrNot = false,
        quizAnswer = 0,
        photo = "",
        photoTitle = "";

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
        gift = json["gift"] ?? false,
        stepPoint = json["stepPoint"] ?? 0,
        diaryPoint = json["diaryPoint"] ?? 0,
        commentPoint = json["commentPoint"] ?? 0,
        likePoint = json["likePoint"] ?? 0,
        invitationPoint = json["invitationPoint"] ?? 0,
        quizPoint = json["quizPoint"] ?? 0,
        diaryCount = json["diaryCount"] ?? 0,
        commentCount = json["commentCount"] ?? 0,
        likeCount = json["likeCount"] ?? 0,
        invitationCount = json["invitationCount"] ?? 0,
        quizCount = json["quizCount"] ?? 0,
        userStepPoint = 0,
        userDiaryPoint = 0,
        userCommentPoint = 0,
        userLikePoint = 0,
        userInvitationPoint = 0,
        userQuizPoint = 0,
        userTotalPoint = 0,
        userDiaryCount = 0,
        userCommentCount = 0,
        userLikeCount = 0,
        userInvitationCount = 0,
        userQuizCount = 0,
        userAchieveOrNot = false,
        quizAnswer = json["answer"] ?? 0,
        photo = json["photo"] ?? "",
        photoTitle = json["title"] ?? "";

  ParticipantModel copyWith({
    String? smallRegion,
    int? stepPoint,
    int? diaryPoint,
    int? commentPoint,
    int? likePoint,
    int? invitationPoint,
    int? quizPoint,
    int? diaryCount,
    int? commentCount,
    int? likeCount,
    int? invitationCount,
    int? quizCount,
    int? userStepPoint,
    int? userDiaryPoint,
    int? userCommentPoint,
    int? userLikePoint,
    int? userInvitationPoint,
    int? userQuizPoint,
    int? userTotalPoint,
    int? userDiaryCount,
    int? userCommentCount,
    int? userLikeCount,
    int? userInvitationCount,
    int? userQuizCount,
    bool? userAchieveOrNot,
    int? quizAnswer,
    String? photo,
    String? photoTitle,
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
      gift: gift,
      stepPoint: stepPoint ?? this.stepPoint,
      diaryPoint: diaryPoint ?? this.diaryPoint,
      commentPoint: commentPoint ?? this.commentPoint,
      likePoint: likePoint ?? this.likePoint,
      invitationPoint: invitationPoint ?? this.invitationPoint,
      quizPoint: quizPoint ?? this.quizPoint,
      diaryCount: diaryCount ?? this.diaryCount,
      commentCount: commentCount ?? this.commentCount,
      likeCount: likeCount ?? this.likeCount,
      invitationCount: invitationCount ?? this.invitationCount,
      quizCount: quizCount ?? this.quizCount,
      userStepPoint: userStepPoint ?? this.userStepPoint,
      userDiaryPoint: userDiaryPoint ?? this.userDiaryPoint,
      userCommentPoint: userCommentPoint ?? this.userCommentPoint,
      userLikePoint: userLikePoint ?? this.userLikePoint,
      userInvitationPoint: userInvitationPoint ?? this.userInvitationPoint,
      userQuizPoint: userQuizPoint ?? this.userQuizPoint,
      userTotalPoint: userTotalPoint ?? this.userTotalPoint,
      userDiaryCount: userDiaryCount ?? this.userDiaryCount,
      userCommentCount: userCommentCount ?? this.userCommentCount,
      userLikeCount: userLikeCount ?? this.userLikeCount,
      userInvitationCount: userInvitationCount ?? this.userInvitationCount,
      userQuizCount: userQuizCount ?? this.userQuizCount,
      userAchieveOrNot: userAchieveOrNot ?? this.userAchieveOrNot,
      quizAnswer: quizAnswer ?? this.quizAnswer,
      photo: photo ?? this.photo,
      photoTitle: photoTitle ?? this.photoTitle,
    );
  }
}
