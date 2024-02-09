class ContractRegionModel {
  final String name;
  final String? contractRegionId;
  final String? contractCommunityId;
  final String subdistrictId;
  final String? image;

  ContractRegionModel({
    required this.name,
    this.contractRegionId,
    this.contractCommunityId,
    required this.subdistrictId,
    this.image,
  });

  ContractRegionModel.empty()
      : name = "전체",
        contractRegionId = "",
        contractCommunityId = "",
        subdistrictId = "",
        image = "";

  ContractRegionModel.total(
      String adminContractRegionId, String adminSubdistrictId)
      : name = "전체",
        contractRegionId = adminContractRegionId,
        contractCommunityId = "",
        subdistrictId = adminSubdistrictId,
        image =
            "https://firebasestorage.googleapis.com/v0/b/chungchunon-android-dd695.appspot.com/o/icons%2Ficon_solid.png?alt=media&token=3e3c0b76-a994-4068-a56b-16077c337080";

  ContractRegionModel.fromJsonRegion(Map<String, dynamic> json)
      : name = json["subdistricts"]["subdistrict"],
        contractRegionId = json["contractRegionId"] ?? "",
        contractCommunityId = json["contractCommunityId"] ?? "",
        subdistrictId = json["subdistrictId"] ?? "",
        image = json["contractRegions"] != null
            ? json["contractRegions"]["image"]
            : "https://firebasestorage.googleapis.com/v0/b/chungchunon-android-dd695.appspot.com/o/icons%2Ficon_solid.png?alt=media&token=3e3c0b76-a994-4068-a56b-16077c337080";

  ContractRegionModel.fromJsonCommunity(Map<String, dynamic> json)
      : name = json["name"],
        contractRegionId = json["contractRegionId"] ?? "",
        contractCommunityId = json["contractCommunityId"] ?? "",
        subdistrictId = json["subdistrictId"] ?? "",
        image = json["image"] ??
            "https://firebasestorage.googleapis.com/v0/b/chungchunon-android-dd695.appspot.com/o/icons%2Ficon_solid.png?alt=media&token=3e3c0b76-a994-4068-a56b-16077c337080";
}
