import 'package:onldocc_admin/utils.dart';

enum EventType { targetScore, multipleScores, count, quiz, photo }

EventType stringToEventType(String value) {
  for (EventType type in EventType.values) {
    if (type.toString().split('.').last == value) {
      return type;
    }
  }
  return EventType.targetScore;
}

class EventModel {
  final String eventId;
  final String? contractRegionId;
  final String? contractCommunityId;
  final String title;
  final String description;
  final int? createdAt;
  final String startDate;
  final String endDate;
  final String bannerImage;
  final String eventImage;
  final int achieversNumber;
  final bool allUsers;
  final int? ageLimit;
  final String eventType;
  final bool adminSecret;

  final int? targetScore;
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

  final int? maxStepCount;
  final int? maxCommentCount;
  final int? maxLikeCount;
  final int? maxInvitationCount;

  final String invitationType;

  // quiz-event
  final String? quizEventId;
  final String? quiz;
  final String? firstChoice;
  final String? secondChoice;
  final String? thirdChoice;
  final String? fourthChoice;
  final int? quizAnswer;

  // photo-event
  final String? photo;
  final String? photoTitle;

  final String? state;
  final String? orgSubdistrictId;
  final String? orgName;
  final String? orgImage;

  EventModel({
    required this.eventId,
    required this.title,
    required this.description,
    required this.eventImage,
    required this.allUsers,
    this.contractRegionId,
    this.contractCommunityId,
    this.targetScore,
    required this.achieversNumber,
    required this.startDate,
    required this.endDate,
    this.state,
    this.createdAt,
    this.orgSubdistrictId,
    this.orgName,
    this.orgImage,
    this.stepPoint,
    this.diaryPoint,
    this.commentPoint,
    this.likePoint,
    this.quizPoint,
    required this.adminSecret,
    required this.bannerImage,
    required this.eventType,
    this.ageLimit,
    this.invitationPoint,
    this.invitationCount,
    this.diaryCount,
    this.commentCount,
    this.likeCount,
    this.quizCount,
    this.maxStepCount,
    this.maxCommentCount,
    this.maxLikeCount,
    this.maxInvitationCount,
    required this.invitationType,
    this.quizEventId,
    this.quiz,
    this.firstChoice,
    this.secondChoice,
    this.thirdChoice,
    this.fourthChoice,
    this.quizAnswer,
    this.photo,
    this.photoTitle,
  });

  EventModel.empty()
      : eventId = "",
        title = "",
        description = "",
        eventImage = "",
        allUsers = true,
        contractRegionId = "",
        contractCommunityId = "",
        targetScore = 0,
        achieversNumber = 0,
        startDate = "",
        endDate = "",
        state = "진행",
        createdAt = 0,
        orgSubdistrictId = "",
        orgName = "",
        orgImage = "",
        stepPoint = 0,
        diaryPoint = 0,
        commentPoint = 0,
        likePoint = 0,
        invitationPoint = 0,
        quizPoint = 0,
        adminSecret = true,
        bannerImage = "",
        eventType = "",
        ageLimit = 0,
        invitationCount = 0,
        diaryCount = 0,
        commentCount = 0,
        likeCount = 0,
        quizCount = 0,
        maxStepCount = 0,
        maxCommentCount = 0,
        maxLikeCount = 0,
        maxInvitationCount = 0,
        invitationType = "send",
        quizEventId = "",
        quiz = "",
        firstChoice = "",
        secondChoice = "",
        thirdChoice = "",
        fourthChoice = "",
        quizAnswer = 0,
        photo = "",
        photoTitle = "";

  Map<String, dynamic> toJson() {
    return {
      "eventId": eventId,
      "title": title,
      "description": description,
      "eventImage": eventImage,
      "allUsers": allUsers,
      "contractRegionId": contractRegionId,
      "contractCommunityId": contractCommunityId,
      "targetScore": targetScore,
      "achieversNumber": achieversNumber,
      "startDate": startDate,
      "endDate": endDate,
      "createdAt": createdAt,
      "stepPoint": stepPoint,
      "diaryPoint": diaryPoint,
      "commentPoint": commentPoint,
      "likePoint": likePoint,
      "invitationPoint": invitationPoint,
      "quizPoint": quizPoint,
      "adminSecret": adminSecret,
      "bannerImage": bannerImage,
      "eventType": eventType,
      "ageLimit": ageLimit,
      "invitationCount": invitationCount,
      "diaryCount": diaryCount,
      "commentCount": commentCount,
      "likeCount": likeCount,
      "quizCount": quizCount,
      "maxStepCount": maxStepCount,
      "maxCommentCount": maxCommentCount,
      "maxLikeCount": maxLikeCount,
      "maxInvitationCount": maxInvitationCount,
      "invitationType": invitationType,
    };
  }

  Map<String, dynamic> editToJson() {
    return {
      "eventId": eventId,
      "title": title,
      "description": description,
      "eventImage": eventImage,
      "allUsers": allUsers,
      // "contractRegionId": contractRegionId,
      // "contractCommunityId": contractCommunityId,
      "targetScore": targetScore,
      "achieversNumber": achieversNumber,
      "startDate": startDate,
      "endDate": endDate,
      "stepPoint": stepPoint,
      "diaryPoint": diaryPoint,
      "commentPoint": commentPoint,
      "likePoint": likePoint,
      "invitationPoint": invitationPoint,
      "quizPoint": quizPoint,
      "adminSecret": adminSecret,
      "bannerImage": bannerImage,
      "eventType": eventType,
      "ageLimit": ageLimit,
      "invitationCount": invitationCount,
      "diaryCount": diaryCount,
      "commentCount": commentCount,
      "likeCount": likeCount,
      "quizCount": quizCount,
      "maxStepCount": maxStepCount,
      "maxCommentCount": maxCommentCount,
      "maxLikeCount": maxLikeCount,
      "maxInvitationCount": maxInvitationCount,
      "invitationType": invitationType,
    };
  }

  EventModel.fromJson(Map<String, dynamic> json)
      : eventId = json["eventId"],
        title = json["title"],
        description = json["description"],
        eventImage = json["eventImage"],
        allUsers = json["allUsers"],
        contractRegionId = json["contractRegionId"] ?? "",
        contractCommunityId = json["contractCommunityId"] ?? "",
        targetScore = json["targetScore"],
        achieversNumber = json["achieversNumber"],
        startDate = json["startDate"],
        endDate = json["endDate"],
        state =
            convertEndDateStringToSeconds(json["endDate"]) > getCurrentSeconds()
                ? "진행"
                : "종료",
        createdAt = json["createdAt"],
        orgSubdistrictId = json["contract_regions"] != null
            ? json["contract_regions"]["subdistrictId"]
            : "",
        orgName = json["contract_regions"] != null
            ? json["contract_regions"]["name"]
            : "인지케어",
        orgImage = json["contract_regions"] != null
            ? json["contract_regions"]["image"]
            : "",
        stepPoint = json["stepPoint"] ?? 0,
        diaryPoint = json["diaryPoint"] ?? 0,
        commentPoint = json["commentPoint"] ?? 0,
        likePoint = json["likePoint"] ?? 0,
        invitationPoint = json["invitationPoint"] ?? 0,
        quizPoint = json["quizPoint"] ?? 0,
        adminSecret = json["adminSecret"],
        bannerImage = json["bannerImage"] ?? "",
        eventType = json["eventType"] ?? "",
        ageLimit = json["ageLimit"] ?? 0,
        invitationCount = json["invitationCount"] ?? 0,
        diaryCount = json["diaryCount"] ?? 0,
        likeCount = json["likeCount"] ?? 0,
        commentCount = json["commentCount"] ?? 0,
        quizCount = json["quizCount"] ?? 0,
        maxStepCount = json["maxStepCount"] ?? 10000,
        maxCommentCount = json["maxCommentCount"] ?? 0,
        maxLikeCount = json["maxLikeCount"] ?? 0,
        maxInvitationCount = json["maxInvitationCount"] ?? 0,
        invitationType = json["invitationType"] ?? "send",
        quizEventId = json["quiz_event_db"].isNotEmpty
            ? json["quiz_event_db"][0]["quizEventId"]
            : "",
        quiz = json["quiz_event_db"].isNotEmpty
            ? json["quiz_event_db"][0]["quiz"]
            : "",
        firstChoice = json["quiz_event_db"].isNotEmpty
            ? json["quiz_event_db"][0]["firstChoice"]
            : "",
        secondChoice = json["quiz_event_db"].isNotEmpty
            ? json["quiz_event_db"][0]["secondChoice"]
            : "",
        thirdChoice = json["quiz_event_db"].isNotEmpty
            ? json["quiz_event_db"][0]["thirdChoice"]
            : "",
        fourthChoice = json["quiz_event_db"].isNotEmpty
            ? json["quiz_event_db"][0]["fourthChoice"]
            : "",
        quizAnswer = json["quiz_event_db"].isNotEmpty
            ? json["quiz_event_db"][0]["quizAnswer"]
            : 0,
        photo = json["photo_event_images"].isNotEmpty
            ? json["photo_event_images"][0]["photo"]
            : "",
        photoTitle = json["photo_event_images"].isNotEmpty
            ? json["photo_event_images"][0]["title"]
            : "";

  EventModel copyWith({
    final String? eventId,
    final String? title,
    final String? description,
    final String? eventImage,
    final bool? allUsers,
    final String? contractRegionId,
    final String? contractCommunityId,
    final int? targetScore,
    final int? achieversNumber,
    final String? startDate,
    final String? endDate,
    final String? state,
    final int? createdAt,
    final String? orgSubdistrictId,
    final String? orgName,
    final String? orgImage,
    final int? stepPoint,
    final int? diaryPoint,
    final int? commentPoint,
    final int? likePoint,
    final int? invitationPoint,
    final int? quizPoint,
    final bool? adminSecret,
    final String? bannerImage,
    final String? eventType,
    final int? ageLimit,
    final int? diaryCount,
    final int? commentCount,
    final int? likeCount,
    final int? invitationCount,
    final int? quizCount,
    final int? maxQuizCount,
    final int? maxStepCount,
    final int? maxCommentCount,
    final int? maxLikeCount,
    final int? maxInvitationCount,
    final String? invitationType,
    final String? quizEventId,
    final String? quiz,
    final String? firstChoice,
    final String? secondChoice,
    final String? thirdChoice,
    final String? fourthChoice,
    final int? quizAnswer,
    final String? photo,
    final String? photoTitle,
  }) {
    return EventModel(
      eventId: eventId ?? this.eventId,
      title: title ?? this.title,
      description: description ?? this.description,
      eventImage: eventImage ?? this.eventImage,
      allUsers: allUsers ?? this.allUsers,
      contractRegionId: contractRegionId ?? this.contractRegionId,
      contractCommunityId: contractCommunityId ?? this.contractCommunityId,
      targetScore: targetScore ?? this.targetScore,
      achieversNumber: achieversNumber ?? this.achieversNumber,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      state: state ?? this.state,
      createdAt: createdAt ?? this.createdAt,
      orgSubdistrictId: orgSubdistrictId ?? this.orgSubdistrictId,
      orgName: orgName ?? this.orgName,
      orgImage: orgImage ?? this.orgImage,
      stepPoint: stepPoint ?? this.stepPoint,
      diaryPoint: diaryPoint ?? this.diaryPoint,
      commentPoint: commentPoint ?? this.commentPoint,
      likePoint: likePoint ?? this.likePoint,
      invitationPoint: invitationPoint ?? this.invitationPoint,
      quizPoint: quizPoint ?? this.quizPoint,
      adminSecret: adminSecret ?? this.adminSecret,
      bannerImage: bannerImage ?? this.bannerImage,
      eventType: eventType ?? this.eventType,
      ageLimit: ageLimit ?? this.ageLimit,
      diaryCount: diaryCount ?? this.diaryCount,
      commentCount: commentCount ?? this.commentCount,
      likeCount: likeCount ?? this.likeCount,
      invitationCount: invitationCount ?? this.invitationCount,
      quizCount: quizCount ?? this.quizCount,
      maxStepCount: maxStepCount ?? this.maxStepCount,
      maxCommentCount: maxCommentCount ?? this.maxCommentCount,
      maxLikeCount: maxLikeCount ?? this.maxLikeCount,
      maxInvitationCount: maxInvitationCount ?? this.maxInvitationCount,
      invitationType: invitationType ?? this.invitationType,
      quizEventId: quizEventId ?? this.quizEventId,
      quiz: quiz ?? this.quiz,
      firstChoice: firstChoice ?? this.firstChoice,
      secondChoice: secondChoice ?? this.secondChoice,
      thirdChoice: thirdChoice ?? this.thirdChoice,
      fourthChoice: fourthChoice ?? this.fourthChoice,
      quizAnswer: quizAnswer ?? this.quizAnswer,
      photo: photo ?? this.photo,
      photoTitle: photoTitle ?? this.photoTitle,
    );
  }
}
