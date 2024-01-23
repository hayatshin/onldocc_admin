class ContractRegionModel {
  final String name;
  final String contractRegionId;
  final String subdistrictId;
  final String image;

  ContractRegionModel({
    required this.name,
    required this.contractRegionId,
    required this.subdistrictId,
    required this.image,
  });

  ContractRegionModel.empty()
      : name = "",
        contractRegionId = "",
        subdistrictId = "",
        image = "";

  ContractRegionModel.fromJson(Map<String, dynamic> json)
      : name = json["subdistricts"]["subdistrict"],
        contractRegionId = json["contractRegionId"] ?? "",
        subdistrictId = json["subdistrictId"] ?? "",
        image = json["contractRegions"] != null
            ? json["contractRegions"]["image"]
            : "https://firebasestorage.googleapis.com/v0/b/chungchunon-android-dd695.appspot.com/o/icons%2Ficon_solid.png?alt=media&token=3e3c0b76-a994-4068-a56b-16077c337080";
}
