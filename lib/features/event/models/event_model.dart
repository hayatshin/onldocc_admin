import 'package:onldocc_admin/utils.dart';

class EventModel {
  final String eventId;
  final String title;
  final String description;
  final String eventImage;
  final bool allUsers;
  final String? contractRegionId;
  final String? contractCommunityId;
  final int targetScore;
  final int achieversNumber;
  final String startDate;
  final String endDate;
  final String? state;
  final int? createdAt;
  final String? orgSubdistrictId;
  final String? orgImage;
  final int stepPoint;
  final int diaryPoint;
  final int commentPoint;
  final int likePoint;

  EventModel({
    required this.eventId,
    required this.title,
    required this.description,
    required this.eventImage,
    required this.allUsers,
    this.contractRegionId,
    this.contractCommunityId,
    required this.targetScore,
    required this.achieversNumber,
    required this.startDate,
    required this.endDate,
    this.state,
    this.createdAt,
    this.orgSubdistrictId,
    this.orgImage,
    required this.stepPoint,
    required this.diaryPoint,
    required this.commentPoint,
    required this.likePoint,
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
        stepPoint = 10,
        diaryPoint = 100,
        commentPoint = 20,
        likePoint = 0;

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
        stepPoint = json["stepPoint"] ?? 10,
        diaryPoint = json["diaryPoint"] ?? 100,
        commentPoint = json["commentPoint"] ?? 20,
        likePoint = json["likePoint"] ?? 0;

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
    );
  }
}
