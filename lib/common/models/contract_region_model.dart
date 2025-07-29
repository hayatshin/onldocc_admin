import 'package:onldocc_admin/constants/const.dart';

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
        contractRegionId = null,
        contractCommunityId = null,
        subdistrictId = "",
        image = null;

  ContractRegionModel.total(
      String adminContractRegionId, String adminSubdistrictId)
      : name = "전체",
        contractRegionId = adminContractRegionId,
        contractCommunityId = null,
        subdistrictId = adminSubdistrictId,
        image = injicareAvatar;

  ContractRegionModel.fromJsonRegion(Map<String, dynamic> json)
      : name = json["subdistricts"]["subdistrict"],
        contractRegionId = json["contractRegionId"],
        contractCommunityId = json["contractCommunityId"],
        subdistrictId = json["subdistrictId"] ?? "",
        image = json["contractRegions"] != null
            ? json["contractRegions"]["image"]
            : injicareAvatar;

  ContractRegionModel.fromJsonCommunity(Map<String, dynamic> json)
      : name = json["name"],
        contractRegionId = json["contractRegionId"],
        contractCommunityId = json["contractCommunityId"],
        subdistrictId = json["subdistrictId"] ?? "",
        image = json["image"] ?? injicareAvatar;
}
