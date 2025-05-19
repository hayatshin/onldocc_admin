import 'package:onldocc_admin/constants/const.dart';

class AdminProfileModel {
  final String adminId;
  final bool master;
  final String contractType;
  final String contractRegionId;
  final String subdistrictId;
  final String name;
  final String image;
  final String phone;
  final String mail;

  AdminProfileModel({
    required this.adminId,
    required this.master,
    required this.contractType,
    required this.contractRegionId,
    required this.subdistrictId,
    required this.name,
    required this.image,
    required this.phone,
    required this.mail,
  });

  AdminProfileModel.empty()
      : adminId = "",
        master = false,
        contractType = "region",
        contractRegionId = "",
        subdistrictId = "",
        name = "",
        image = "",
        phone = "",
        mail = "";

  AdminProfileModel.fromJson(Map<String, dynamic> json)
      : adminId = json["adminId"],
        master = json["master"],
        contractType = "region",
        contractRegionId = json["contract_regions"] != null
            ? json["contract_regions"]["contractRegionId"]
            : "",
        subdistrictId = json["subdistricts"] != null
            ? json["subdistricts"]["subdistrictId"]
            : "",
        name = json["subdistricts"] != null
            ? json["subdistricts"]["subdistrict"]
            : "마스터",
        image = json["contract_regions"] != null
            ? json["contract_regions"]["image"]
            : injicareAvatar,
        phone = json["contract_regions"] != null
            ? json["contract_regions"]["phone"]
            : "",
        mail = json["contract_regions"] != null
            ? json["contract_regions"]["mail"]
            : "help@hayat.kr";

  Map<String, dynamic> toJson() {
    return {
      "adminId": adminId,
      "master": master,
      "contractType": "region",
      "contractRegionId": contractRegionId,
      "subdistrictId": subdistrictId,
      "name": name,
      "image": image,
      "phone": phone,
      "mail": mail,
    };
  }

  @override
  String toString() {
    return "AdminProfileModel(adminId: $adminId, master: $master, contractType: $contractType, contractRegionId: $contractRegionId, subdistrictId: $subdistrictId, name: $name, image: $image, phone: $phone, mail: $mail)";
  }
}
