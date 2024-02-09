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
        orgImage = "";

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
    };
  }

  Map<String, dynamic> editToJson() {
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
            : "";
}
