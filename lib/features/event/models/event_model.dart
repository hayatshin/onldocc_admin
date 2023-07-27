class EventModel {
  final bool? allUser;
  final String? contractType;
  final String? contractName;
  final String? contractLogo;
  final String? description;
  final String? documentId;
  final String? startPeriod;
  final String? endPeriod;
  final int? goalScore;
  final String? missionImage;
  final int? prizeWinners;
  final String? state;
  final String? title;
  final bool? autoProgress;

  EventModel(
    this.allUser,
    this.contractType,
    this.contractName,
    this.contractLogo,
    this.description,
    this.documentId,
    this.startPeriod,
    this.endPeriod,
    this.goalScore,
    this.missionImage,
    this.prizeWinners,
    this.state,
    this.title,
    this.autoProgress,
  );

  EventModel.empty()
      : allUser = false,
        contractType = "",
        contractName = "",
        contractLogo = "",
        description = "",
        documentId = "",
        startPeriod = "",
        endPeriod = "",
        goalScore = 0,
        missionImage = "",
        prizeWinners = 0,
        state = "",
        title = "",
        autoProgress = true;

  Map<String, dynamic> toJson() {
    return {
      "allUser": allUser ?? false,
      "contractType": contractType,
      "contractName": contractName,
      "contractLogo": contractLogo,
      "description": description,
      "documentId": documentId,
      "startPeriod": startPeriod,
      "endPeriod": endPeriod,
      "goalScore": goalScore,
      "missionImage": missionImage,
      "prizeWinners": prizeWinners,
      "state": state ?? "진행",
      "title": title,
      "autoProgress": autoProgress ?? true,
    };
  }

  EventModel.fromJson(Map<String, dynamic> json)
      : allUser = json["allUser"] ?? false,
        contractType = json["contractType"] ?? "",
        contractName = json["contractName"] ?? "",
        contractLogo = json["contractLogo"] ?? "",
        description = json["description"] ?? "",
        documentId = json["documentId"] ?? "",
        startPeriod = json["startPeriod"] ?? "무제한",
        endPeriod = json["endPeriod"] ?? "무제한",
        goalScore = json["goalScore"] ?? 0,
        missionImage = json["missionImage"] ?? "",
        prizeWinners = json["prizeWinners"] ?? 0,
        state = json["state"] ?? "진행",
        title = json["title"] ?? "",
        autoProgress = json["autoProgress"] ?? true;
}
