class EventModel {
  final bool? allUser;
  final String? community;
  final String? communityLogo;
  final String? description;
  final String? documentId;
  final String? startPeriod;
  final String? endPeriod;
  final int? goalScore;
  final String? missionImage;
  final int? prizeWinners;
  final String? state;
  final String? title;
  final String? fullRegion;
  final String? contractType;
  final bool? autoProgress;

  EventModel(
    this.allUser,
    this.community,
    this.communityLogo,
    this.description,
    this.documentId,
    this.startPeriod,
    this.endPeriod,
    this.goalScore,
    this.missionImage,
    this.prizeWinners,
    this.state,
    this.title,
    this.fullRegion,
    this.contractType,
    this.autoProgress,
  );

  EventModel.empty()
      : allUser = false,
        community = "",
        communityLogo = "",
        description = "",
        documentId = "",
        startPeriod = "",
        endPeriod = "",
        goalScore = 0,
        missionImage = "",
        prizeWinners = 0,
        state = "",
        title = "",
        fullRegion = "",
        contractType = "",
        autoProgress = true;

  Map<String, dynamic> toJson() {
    return {
      "allUser": allUser ?? false,
      "community": community,
      "communityLogo": communityLogo,
      "description": description,
      "documentId": documentId,
      "startPeriod": startPeriod,
      "endPeriod": endPeriod,
      "goalScore": goalScore,
      "missionImage": missionImage,
      "prizeWinners": prizeWinners,
      "state": state ?? "진행",
      "title": title,
      "fullRegion": fullRegion,
      "contractType": contractType,
      "autoProgress": autoProgress ?? true,
    };
  }

  EventModel.fromJson(Map<String, dynamic> json)
      : allUser = json["allUser"] ?? false,
        community = json["community"] ?? "",
        communityLogo = json["communityLogo"] ?? "",
        description = json["description"] ?? "",
        documentId = json["documentId"] ?? "",
        startPeriod = json["startPeriod"] ?? "무제한",
        endPeriod = json["endPeriod"] ?? "무제한",
        goalScore = json["goalScore"] ?? 0,
        missionImage = json["missionImage"] ?? "",
        prizeWinners = json["prizeWinners"] ?? 0,
        state = json["state"] ?? "진행",
        title = json["title"] ?? "",
        fullRegion = json["fullRegion"] ?? "",
        contractType = json["contractType"] ?? "",
        autoProgress = json["autoProgress"] ?? true;
}
