class PopupModel {
  final String? popupId;
  final String? subdistrictId;
  final int noticeFixedAt;
  final String description;
  final int createdAt;
  final String diaryId;
  final bool adminSecret;
  final bool master;

  PopupModel({
    this.popupId,
    required this.subdistrictId,
    required this.noticeFixedAt,
    required this.description,
    required this.createdAt,
    required this.diaryId,
    required this.adminSecret,
    required this.master,
  });

  Map<String, dynamic> toJson() {
    return {
      "subdistrictId": subdistrictId,
      "noticeFixedAt": noticeFixedAt,
      "description": description,
      "createdAt": createdAt,
      "diaryId": diaryId,
      "adminSecret": adminSecret,
      "master": master,
    };
  }

  PopupModel.fromJson(Map<String, dynamic> json)
      : popupId = json["popupId"],
        subdistrictId = json["subdistrictId"],
        noticeFixedAt = json["noticeFixedAt"],
        description = json["description"],
        createdAt = json["createdAt"],
        diaryId = json["diaryId"],
        adminSecret = json["adminSecret"],
        master = json["masters"];
}
