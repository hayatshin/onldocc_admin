import 'package:onldocc_admin/utils.dart';

class EventModel {
  final String eventId;
  final String title;
  final String description;
  final String eventImage;
  final bool allUsers;
  final String? contractRegionId;
  final String? contractCommunityId;
  final int? targetScore;
  final int achieversNumber;
  final String startDate;
  final String endDate;
  final String? state;
  final int? createdAt;
  final String? orgSubdistrictId;
  final String? orgImage;
  final int? stepPoint;
  final int? diaryPoint;
  final int? commentPoint;
  final int? likePoint;
  final bool adminSecret;

  final String bannerImage;
  final String eventType;
  final int? invitationPoint;
  final int? invitationCount;
  final int? diaryCount;
  final int? commentCount;
  final int? likeCount;

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
    this.orgImage,
    this.stepPoint,
    this.diaryPoint,
    this.commentPoint,
    this.likePoint,
    required this.adminSecret,
    required this.bannerImage,
    required this.eventType,
    this.invitationPoint,
    this.invitationCount,
    this.diaryCount,
    this.commentCount,
    this.likeCount,
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
        orgImage = "",
        stepPoint = 0,
        diaryPoint = 0,
        commentPoint = 0,
        likePoint = 0,
        invitationPoint = 0,
        adminSecret = true,
        bannerImage = "",
        eventType = "",
        invitationCount = 0,
        diaryCount = 0,
        commentCount = 0,
        likeCount = 0;

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
      "adminSecret": adminSecret,
      "bannerImage": bannerImage,
      "eventType": eventType,
      "invitationCount": invitationCount,
      "diaryCount": diaryCount,
      "commentCount": commentCount,
      "likeCount": likeCount,
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
      "adminSecret": adminSecret,
      "bannerImage": bannerImage,
      "eventType": eventType,
      "invitationCount": invitationCount,
      "diaryCount": diaryCount,
      "commentCount": commentCount,
      "likeCount": likeCount,
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
        orgImage = json["contract_regions"] != null
            ? json["contract_regions"]["image"]
            : "",
        stepPoint = json["stepPoint"] ?? 0,
        diaryPoint = json["diaryPoint"] ?? 0,
        commentPoint = json["commentPoint"] ?? 0,
        likePoint = json["likePoint"] ?? 0,
        invitationPoint = json["invitationPoint"] ?? 0,
        adminSecret = json["adminSecret"],
        bannerImage = json["bannerImage"] ?? "",
        eventType = json["eventType"] ?? "",
        invitationCount = json["invitationCount"] ?? 0,
        diaryCount = json["diaryCount"] ?? 0,
        likeCount = json["likeCount"] ?? 0,
        commentCount = json["commentCount"] ?? 0;

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
    final String? orgImage,
    final int? stepPoint,
    final int? diaryPoint,
    final int? commentPoint,
    final int? likePoint,
    final int? invitationPoint,
    final bool? adminSecret,
    final String? bannerImage,
    final String? eventType,
    final int? diaryCount,
    final int? commentCount,
    final int? likeCount,
    final int? invitationCount,
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
      orgImage: orgImage ?? this.orgImage,
      stepPoint: stepPoint ?? this.stepPoint,
      diaryPoint: diaryPoint ?? this.diaryPoint,
      commentPoint: commentPoint ?? this.commentPoint,
      likePoint: likePoint ?? this.likePoint,
      invitationPoint: invitationPoint ?? this.invitationPoint,
      adminSecret: adminSecret ?? this.adminSecret,
      bannerImage: bannerImage ?? this.bannerImage,
      eventType: eventType ?? this.eventType,
      diaryCount: diaryCount ?? this.diaryCount,
      commentCount: commentCount ?? this.commentCount,
      likeCount: likeCount ?? this.likeCount,
      invitationCount: invitationCount ?? this.invitationCount,
    );
  }
}
