class EventModel {
  final String eventId;
  final String title;
  final String description;
  final String eventImage;
  final bool allUsers;
  final String contractOrgType;
  final String? contractRegionId;
  final String? contractCommunityId;
  final int targetScore;
  final int achieversNumber;
  final String startDate;
  final String endDate;
  final String state;
  final String? orgSubdistrictId;
  final String? orgImage;

  EventModel({
    required this.eventId,
    required this.title,
    required this.description,
    required this.eventImage,
    required this.allUsers,
    required this.contractOrgType,
    this.contractRegionId,
    this.contractCommunityId,
    required this.targetScore,
    required this.achieversNumber,
    required this.startDate,
    required this.endDate,
    required this.state,
    this.orgSubdistrictId,
    this.orgImage,
  });

  EventModel.empty()
      : eventId = "",
        title = "",
        description = "",
        eventImage = "",
        allUsers = true,
        contractOrgType = "region",
        contractRegionId = "",
        contractCommunityId = "",
        targetScore = 0,
        achieversNumber = 0,
        startDate = "",
        endDate = "",
        state = "진행",
        orgSubdistrictId = "",
        orgImage = "";

  Map<String, dynamic> toJson() {
    return {
      "eventId": eventId,
      "title": title,
      "description": description,
      "eventImage": eventImage,
      "allUsers": allUsers,
      "contractOrgType": contractOrgType,
      "contractRegionId": contractRegionId,
      "contractCommunityId": contractCommunityId,
      "targetScore": targetScore,
      "achieversNumber": achieversNumber,
      "startDate": startDate,
      "endDate": endDate,
      "state": state,
    };
  }

  EventModel.fromJson(Map<String, dynamic> json)
      : eventId = json["eventId"],
        title = json["title"],
        description = json["description"],
        eventImage = json["eventImage"],
        allUsers = json["allUsers"],
        contractOrgType = json["contractOrgType"],
        contractRegionId = json["contractRegionId"],
        contractCommunityId = json["contractCommunityId"],
        targetScore = json["targetScore"],
        achieversNumber = json["achieversNumber"],
        startDate = json["startDate"],
        endDate = json["endDate"],
        state = json["state"],
        orgSubdistrictId = json.containsKey("contract_regions")
            ? json["contract_regions"]["subdistrictId"]
            : "",
        orgImage = json.containsKey("contract_regions")
            ? json["contract_regions"]["image"]
            : "";
}
