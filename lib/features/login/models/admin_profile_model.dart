class AdminProfileModel {
  final String userId;
  final String region;
  final String? smallRegion;
  final String regionImage;
  final bool master;
  final String contractType;

  AdminProfileModel({
    required this.userId,
    required this.region,
    required this.smallRegion,
    required this.regionImage,
    required this.master,
    required this.contractType,
  });

  AdminProfileModel.empty()
      : userId = "",
        region = "",
        smallRegion = "",
        regionImage = "",
        master = false,
        contractType = "";

  AdminProfileModel.fromJson(Map<String, dynamic> json)
      : userId = json["userId"],
        region = json["region"],
        smallRegion = json["smallRegion"],
        regionImage = json["regionImage"],
        master = json["master"],
        contractType = json["contractType"];

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "region": region,
      "smallRegion": smallRegion,
      "regionImage": regionImage,
      "master": master,
      "contractType": contractType,
    };
  }
}
