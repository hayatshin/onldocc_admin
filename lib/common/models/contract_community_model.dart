class ContractCommunityModel {
  final String contractCommunityId;
  final String name;
  final String phone;
  final String image;
  final bool master;
  final String mail;
  final String subdistrictId;
  final bool hasMedicalFeature;
  final bool hasCognitionQuiz;

  ContractCommunityModel({
    required this.contractCommunityId,
    required this.name,
    required this.phone,
    required this.image,
    required this.master,
    required this.mail,
    required this.subdistrictId,
    required this.hasMedicalFeature,
    required this.hasCognitionQuiz,
  });

  ContractCommunityModel.empty()
      : contractCommunityId = "",
        name = "",
        phone = "",
        image = "",
        master = false,
        mail = "",
        subdistrictId = "",
        hasMedicalFeature = true,
        hasCognitionQuiz = true;

  ContractCommunityModel.fromJson(Map<String, dynamic> json)
      : contractCommunityId = json['contractCommunityId'],
        name = json['name'] ?? "",
        phone = json['phone'] ?? "",
        image = json['image'] ?? "",
        master = json['master'] ?? false,
        mail = json['mail'] ?? "",
        subdistrictId = json["subdistrictId"],
        hasMedicalFeature = json["hasMedicalFeature"],
        hasCognitionQuiz = json["hasCognitionQuiz"];
}
