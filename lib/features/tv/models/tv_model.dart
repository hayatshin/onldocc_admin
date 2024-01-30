class TvModel {
  final String thumbnail;
  final String title;
  final String link;
  final bool allUsers;
  final String videoId;
  final int createdAt;
  final String? contractRegionId;
  final String? contractCommunityId;

  TvModel({
    required this.thumbnail,
    required this.title,
    required this.link,
    required this.allUsers,
    required this.videoId,
    required this.createdAt,
    this.contractRegionId,
    this.contractCommunityId,
  });

  TvModel.empty()
      : thumbnail = "",
        title = "",
        link = "",
        allUsers = false,
        videoId = "",
        createdAt = 0,
        contractRegionId = "",
        contractCommunityId = "";

  Map<String, dynamic> toJson() {
    return {
      "thumbnail": thumbnail,
      "title": title,
      "link": link,
      "allUsers": allUsers,
      "videoId": videoId,
      "createdAt": createdAt,
      "contractRegionId": contractRegionId,
      "contractCommunityId": contractCommunityId,
    };
  }

  Map<String, dynamic> editToJson() {
    return {
      "thumbnail": thumbnail,
      "title": title,
      "link": link,
      "allUsers": allUsers,
      "videoId": videoId,
    };
  }

  TvModel.fromJson(Map<String, dynamic> json)
      : thumbnail = json["thumbnail"],
        title = json["title"],
        link = json["link"],
        allUsers = json["allUsers"],
        videoId = json["videoId"],
        createdAt = json["createdAt"],
        contractRegionId = json["contractRegionId"] ?? "",
        contractCommunityId = json["contract_communityId"] ?? "";

  TvModel copyWith({
    final String? thumbnail,
    final String? title,
    final String? link,
    final bool? allUsers,
    final String? videoId,
    final int? createdAt,
  }) {
    return TvModel(
      thumbnail: thumbnail ?? this.thumbnail,
      title: title ?? this.title,
      link: link ?? this.link,
      allUsers: allUsers ?? this.allUsers,
      videoId: videoId ?? this.videoId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
