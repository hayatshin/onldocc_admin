class AdminProfileModel {
  final String userId;
  final String regionImage;
  final bool master;
  final String contractType;
  final String contractName;

  AdminProfileModel({
    required this.userId,
    required this.regionImage,
    required this.master,
    required this.contractType,
    required this.contractName,
  });

  AdminProfileModel.empty()
      : userId = "",
        regionImage = "",
        master = false,
        contractType = "",
        contractName = "";

  AdminProfileModel.fromJson(Map<String, dynamic> json)
      : userId = json["userId"],
        regionImage = json["regionImage"],
        master = json["master"],
        contractType = json["contractType"],
        contractName = json["contractName"];

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "regionImage": regionImage,
      "master": master,
      "contractType": contractType,
      "contractName": contractName,
    };
  }
}
